import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/office_model.dart';
import 'office_detail_screen.dart';

class OfficeDesHeuresScreen extends StatefulWidget {
  const OfficeDesHeuresScreen({Key? key}) : super(key: key);

  @override
  State<OfficeDesHeuresScreen> createState() => _OfficeDesHeuresScreenState();
}

class _OfficeDesHeuresScreenState extends State<OfficeDesHeuresScreen> {
  Map<String, bool> _completedOffices = {};
  int _completedCount = 0;
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<String>>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadCompletedStatus();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCompletedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Pour l'instant, on suppose qu'il y a 4 offices max par jour
    // On va chercher dans les prefs s'ils sont terminés
    int count = 0;
    Map<String, bool> status = {};
    
    // On parcourt toutes les clés pour trouver celles du jour
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('office_completed_') && key.endsWith(today)) {
        if (prefs.getBool(key) == true) {
          final officeId = key.replaceFirst('office_completed_', '').replaceAll('_$today', '');
          status[officeId] = true;
          count++;
        }
      }
    }

    if (mounted) {
      setState(() {
        _completedOffices = status;
        _completedCount = count;
      });
    }

    // Écouter les mises à jour depuis Firestore pour la synchro multi-appareils
    _subscription?.cancel();
    _subscription = _firestoreService.getCompletedOffices(today).listen((completedIds) {
      if (mounted) {
        setState(() {
          final newCompleted = Map<String, bool>.from(_completedOffices);
          int newCount = 0;
          
          for (var id in completedIds) {
            newCompleted[id] = true;
            // Mettons aussi à jour SharedPreferences localement pour les prochaines ouvertures
            prefs.setBool('office_completed_${id}_$today', true);
          }
          
          for (var value in newCompleted.values) {
            if (value == true) newCount++;
          }
          
          _completedOffices = newCompleted;
          _completedCount = newCount;
        });
      }
    });
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
                  _buildStatsRow(),
                  const SizedBox(height: 20),
                  _buildOfficeList(),
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
              image: AssetImage("assets/images/bible.png.jpg"),
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
                Colors.white.withOpacity(0.6),
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
                      "Office des Heures",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                    ),
                    Container(
                      width: 40, // To balance the back button
                    ),
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
                      "Sanctifie ta journée",
                      style: TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    Row(
                      children: [
                        const Text(
                          "avec la ",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFF05B3A), Colors.redAccent],
                          ).createShader(bounds),
                          child: const Text(
                            "Prière",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      "de l'Église",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("“", style: TextStyle(color: Color(0xFFF05B3A), fontSize: 30, fontWeight: FontWeight.bold, height: 1.2)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StreamBuilder<Map<String, String>>(
                                stream: _firestoreService.getCitation('citation_office'),
                                builder: (context, snapshot) {
                                  final citation = snapshot.data;
                                  final content = citation?['content'] ?? '';
                                  final reference = citation?['reference'] ?? '';

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        content,
                                        style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
                                      ),
                                      if (reference.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            reference,
                                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const Text("”", style: TextStyle(color: Color(0xFFF05B3A), fontSize: 20, fontWeight: FontWeight.bold, height: 1)),
                              Container(
                                width: 40,
                                height: 2,
                                color: const Color(0xFFF05B3A),
                                margin: const EdgeInsets.only(top: 5),
                              )
                            ],
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

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(Icons.menu_book, "Offices", "4/Jour", const Color(0xFFF05B3A)),
          _buildDivider(),
          _buildStatItem(Icons.check_circle_outline, "Aujourd'hui", "$_completedCount terminé${_completedCount > 1 ? 's' : ''}", Colors.green),
          _buildDivider(),
          _buildStatItem(Icons.access_time, "Temps prié", "${_completedCount * 15} min", Colors.blue),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 30, color: Colors.grey.shade200);
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ],
        ),
      ],
    );
  }

  Widget _buildOfficeList() {
    return StreamBuilder<List<Office>>(
      stream: _firestoreService.getOffices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFF05B3A)));
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        
        final offices = snapshot.data ?? [];
        
        if (offices.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Aucun office disponible pour le moment.", style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        return Column(
          children: offices.map((office) {
            bool isCompleted = _completedOffices[office.id] ?? false; 
            return _buildOfficeCard(context, office, isCompleted);
          }).toList(),
        );
      },
    );
  }

  Widget _buildOfficeCard(BuildContext context, Office office, bool completed) {
    IconData icon = Icons.menu_book;
    switch (office.iconName) {
      case 'wb_sunny':
        icon = Icons.wb_sunny_outlined;
        break;
      case 'brightness_high':
        icon = Icons.brightness_high;
        break;
      case 'wb_twilight':
        icon = Icons.wb_twilight;
        break;
      case 'nightlight_round':
        icon = Icons.nightlight_round;
        break;
    }
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: completed ? Colors.green.shade50 : const Color(0xFFFFF0ED),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: completed ? Colors.green : const Color(0xFFF05B3A), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(office.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(office.subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(office.timeRange, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 8),
              completed 
                ? const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text("Terminé", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF05B3A),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      minimumSize: const Size(0, 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OfficeDetailScreen(office: office),
                        ),
                      );
                      // Refresh after returning from detail screen
                      _loadCompletedStatus();
                    },
                    child: const Text("Prier", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
