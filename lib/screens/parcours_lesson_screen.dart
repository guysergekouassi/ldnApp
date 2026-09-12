import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class ParcoursLessonScreen extends StatefulWidget {
  final String parcoursId;
  final String parcoursTitle;
  final String lessonTitle;
  final int dayNumber;
  final int totalDays;
  final int currentCompletedDays;
  final String content;
  final Color primaryColor;

  const ParcoursLessonScreen({
    Key? key,
    required this.parcoursId,
    required this.parcoursTitle,
    required this.lessonTitle,
    required this.dayNumber,
    required this.totalDays,
    required this.currentCompletedDays,
    required this.content,
    this.primaryColor = Colors.orange,
  }) : super(key: key);

  @override
  State<ParcoursLessonScreen> createState() => _ParcoursLessonScreenState();
}

class _ParcoursLessonScreenState extends State<ParcoursLessonScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  bool _isSaving = false;

  bool get isAlreadyCompleted => widget.dayNumber <= widget.currentCompletedDays;

  Future<void> _completeLesson() async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vous devez être connecté.")));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      int newCompletedDays = widget.currentCompletedDays;
      if (widget.dayNumber > widget.currentCompletedDays) {
        newCompletedDays = widget.dayNumber;
        await _firestoreService.updateParcoursProgress(_uid!, widget.parcoursId, newCompletedDays);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Leçon validée !")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFF8F9FA),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    "assets/sunset_bg.jpg",
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                          const Color(0xFFF8F9FA),
                        ],
                        stops: const [0.4, 0.8, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Jour ${widget.dayNumber}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.lessonTitle,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.content,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333),
                        height: 1.8,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAlreadyCompleted ? Colors.green.shade50 : widget.primaryColor,
                          foregroundColor: isAlreadyCompleted ? Colors.green : Colors.white,
                          elevation: isAlreadyCompleted ? 0 : 5,
                          shadowColor: widget.primaryColor.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: isAlreadyCompleted ? BorderSide(color: Colors.green.shade200) : BorderSide.none,
                          ),
                        ),
                        onPressed: isAlreadyCompleted || _isSaving ? null : _completeLesson,
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(isAlreadyCompleted ? Icons.check_circle : Icons.emoji_events_outlined),
                                  const SizedBox(width: 10),
                                  Text(
                                    isAlreadyCompleted ? "Jour validé" : "Terminer ce jour",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }
}
