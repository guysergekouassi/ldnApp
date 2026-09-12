import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/neuvaine_model.dart';
import '../services/firestore_service.dart';
class NeuvainesScreen extends StatefulWidget {
  final Neuvaine neuvaine;

  const NeuvainesScreen({Key? key, required this.neuvaine}) : super(key: key);

  @override
  State<NeuvainesScreen> createState() => _NeuvainesScreenState();
}

class _NeuvainesScreenState extends State<NeuvainesScreen> {
  int _selectedDay = 1;
  Set<int> _completedDays = {};
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (mounted) {
      final completedList = prefs.getStringList('neuvaine_${widget.neuvaine.id}_completed_days') ?? [];
      setState(() {
        _completedDays = completedList.map((e) => int.parse(e)).toSet();
        _updateSelectedDay();
      });
    }

    _subscription?.cancel();
    _subscription = _firestoreService.getNeuvaineProgress(widget.neuvaine.id).listen((progress) {
      if (mounted) {
        final List<int> firestoreCompleted = List<int>.from(progress['completedDays'] ?? []);
        setState(() {
          _completedDays.addAll(firestoreCompleted);
          _updateSelectedDay();
          
          prefs.setStringList(
            'neuvaine_${widget.neuvaine.id}_completed_days',
            _completedDays.map((e) => e.toString()).toList(),
          );
        });
      }
    });
  }

  void _updateSelectedDay() {
    for (int i = 1; i <= 9; i++) {
      if (!_completedDays.contains(i)) {
        _selectedDay = i;
        break;
      }
      if (i == 9) _selectedDay = 9;
    }
  }

  Future<void> _markDayCompleted() async {
    setState(() {
      _completedDays.add(_selectedDay);
      if (_selectedDay < 9) {
        _selectedDay++;
      }
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'neuvaine_${widget.neuvaine.id}_completed_days',
      _completedDays.map((e) => e.toString()).toList(),
    );

    final isCompleted = _completedDays.length == 9;
    if (isCompleted) {
      await prefs.setBool('neuvaine_${widget.neuvaine.id}_is_completed', true);
    }
    
    // Firestore update
    await _firestoreService.updateNeuvaineProgress(
      widget.neuvaine.id, 
      _completedDays.toList(), 
      isCompleted
    );

    if (isCompleted) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Icon(Icons.emoji_events, color: Colors.orange, size: 50),
              SizedBox(height: 10),
              Text("Félicitations !", textAlign: TextAlign.center),
            ],
          ),
          content: const Text(
            "Vous avez terminé avec succès les 9 jours de cette neuvaine. Que vos prières soient exaucées.",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text("Amen", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la popup
                Navigator.of(context).pop(); // Retourne à la liste
              },
            ),
          ],
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
                  _buildNineDaysTracker(),
                  const SizedBox(height: 20),
                  _buildDayContent(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/mary_praying.png"),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.4),
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
                      "Neuvaines",
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
                    Text(
                      widget.neuvaine.title,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.orange, Colors.redAccent],
                            ).createShader(bounds),
                            child: Text(
                              widget.neuvaine.subtitle,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
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

  Widget _buildNineDaysTracker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
          const Padding(
            padding: EdgeInsets.only(left: 10.0, bottom: 15),
            child: Text("MON PARCOURS - 9 JOURS", style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 10),
                ...List.generate(9, (index) {
                  final day = index + 1;
                  final isCompleted = _completedDays.contains(day);
                  final isCurrent = day == _selectedDay;
                  
                  return Row(
                    children: [
                      _buildDayCircle(day, isCompleted, isCurrent),
                      if (day < 9) _buildLine(isCompleted || isCurrent),
                    ],
                  );
                }),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(bool active) {
    return Container(
      width: 20,
      height: 2,
      color: active ? Colors.orange : Colors.grey.shade300,
    );
  }

  Widget _buildDayCircle(int day, bool completed, bool isCurrent) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = day;
        });
      },
      child: Column(
        children: [
          Container(
            width: isCurrent ? 36 : 30,
            height: isCurrent ? 36 : 30,
            decoration: BoxDecoration(
              color: isCurrent ? Colors.orange : (completed ? Colors.orange.shade100 : Colors.white),
              shape: BoxShape.circle,
              border: Border.all(color: completed || isCurrent ? Colors.orange : Colors.grey.shade300, width: isCurrent ? 3 : 1),
              boxShadow: isCurrent ? [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 8)] : null,
            ),
            child: Center(
              child: completed && !isCurrent
                  ? const Icon(Icons.check, size: 16, color: Colors.orange)
                  : Text(
                      "J$day",
                      style: TextStyle(
                        color: isCurrent ? Colors.white : (completed ? Colors.orange : Colors.grey),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayContent() {
    // Find content for selected day
    NeuvaineDay? currentDayContent;
    for (var day in widget.neuvaine.days) {
      if (day.dayNumber == _selectedDay) {
        currentDayContent = day;
        break;
      }
    }

    // Fallback if not found
    final title = currentDayContent?.title ?? "Prière du Jour $_selectedDay";
    final text = currentDayContent?.prayerText ?? "Texte de la prière non disponible pour ce jour.";
    final isCompleted = _completedDays.contains(_selectedDay);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.local_fire_department_outlined, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Jour $_selectedDay", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            text.replaceAll(r'\n', '\n'),
            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6, letterSpacing: 0.2),
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? Colors.green : Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              onPressed: () {
                if (!isCompleted) {
                  _markDayCompleted();
                }
              },
              icon: Icon(isCompleted ? Icons.check_circle : Icons.check, color: Colors.white, size: 20),
              label: Text(
                isCompleted ? "Prière terminée" : "J'ai terminé ma prière", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
