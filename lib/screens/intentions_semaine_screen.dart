import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/intention_model.dart';
import '../services/firestore_service.dart';

class IntentionsSemaineScreen extends StatefulWidget {
  const IntentionsSemaineScreen({Key? key}) : super(key: key);

  @override
  State<IntentionsSemaineScreen> createState() => _IntentionsSemaineScreenState();
}

class _IntentionsSemaineScreenState extends State<IntentionsSemaineScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Set<String> _prayedIntentions = {};
  StreamSubscription<List<String>>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadPrayedIntentions();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayedIntentions() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Fallback local initial
    if (mounted) {
      setState(() {
        _prayedIntentions = (prefs.getStringList('prayedIntentions') ?? []).toSet();
      });
    }

    // Synchro avec Firebase
    _subscription?.cancel();
    _subscription = _firestoreService.getPrayedIntentions().listen((intentionsList) {
      if (mounted) {
        setState(() {
          final newIntentions = _prayedIntentions.union(intentionsList.toSet());
          _prayedIntentions = newIntentions;
          prefs.setStringList('prayedIntentions', newIntentions.toList());
        });
      }
    });
  }

  Future<void> _prayForIntention(String intentionId) async {
    if (_prayedIntentions.contains(intentionId)) return;
    
    // Firestore updates
    await _firestoreService.incrementIntentionCount(intentionId);
    await _firestoreService.addPrayedIntention(intentionId);
    
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prayedIntentions.add(intentionId);
    });
    await prefs.setStringList('prayedIntentions', _prayedIntentions.toList());
  }

  void _showAddIntentionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text("Déposer une intention", style: TextStyle(color: Color(0xFFC72127))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Titre de l'intention",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC72127)),
                  onPressed: isLoading ? () {} : () async {
                    if (titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir tous les champs.")));
                      return;
                    }
                    setDialogState(() => isLoading = true);
                    await _firestoreService.addIntention(
                      titleController.text.trim(),
                      descriptionController.text.trim(),
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Intention déposée avec succès.")));
                    }
                  },
                  child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Publier", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildIntentionsList(),
                  const SizedBox(height: 80), // extra space for FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddIntentionDialog(context),
        backgroundColor: const Color(0xFFC72127),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Déposer une intention", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 280,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/hands_heart.png"),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.5),
                const Color(0xFFF8F9FA),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      "Intentions",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                    ),
                    Container(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Portons ensemble les",
                      style: TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    Row(
                      children: [
                        const Text(
                          "prières de la ",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFC72127), Colors.orangeAccent],
                          ).createShader(bounds),
                          child: const Text(
                            "Communauté",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntentionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("CETTE SEMAINE", style: TextStyle(fontSize: 10, color: Color(0xFFC72127), fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        StreamBuilder<List<Intention>>(
          stream: _firestoreService.getIntentions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFC72127)));
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Une erreur est survenue.", style: TextStyle(color: Colors.red)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Aucune intention pour le moment.", style: TextStyle(color: Colors.grey)));
            }
            
            final intentions = snapshot.data!;
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: intentions.length,
              itemBuilder: (context, index) {
                final intention = intentions[index];
                final isPraying = _prayedIntentions.contains(intention.id);
                return _buildIntentionCard(intention, isPraying);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildIntentionCard(Intention intention, bool isPraying) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFC72127).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, color: Color(0xFFC72127), size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(intention.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    Text(intention.description, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_outline, color: Colors.grey, size: 14),
                  const SizedBox(width: 4),
                  Text("${intention.count} prient déjà", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPraying ? Colors.green : const Color(0xFFC72127),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  minimumSize: const Size(0, 30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: isPraying ? () {} : () => _prayForIntention(intention.id),
                child: Text(
                  isPraying ? "Je prie" : "M'unir", 
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
