import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/objectif_model.dart';

/// Détail des objectifs spirituels de l'année, avec l'avancement réel de
/// chaque objectif (compteur courant / cible).
class AllObjectifsScreen extends StatelessWidget {
  AllObjectifsScreen({Key? key}) : super(key: key);

  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  IconData _iconFor(String iconName) {
    switch (iconName) {
      case 'pan_tool_outlined':
        return Icons.pan_tool_outlined;
      case 'menu_book':
        return Icons.menu_book;
      case 'menu_book_outlined':
        return Icons.menu_book_outlined;
      default:
        return Icons.track_changes;
    }
  }

  Color _colorFor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        title: const Text(
          "Mes objectifs",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ),
      body: _uid == null
          ? const Center(
              child: Text(
                "Connectez-vous pour suivre vos objectifs.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : StreamBuilder<List<Objectif>>(
              stream: _firestoreService.getUserObjectifs(_uid!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.orange));
                }

                final objectifs = snapshot.data ?? [];
                if (objectifs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        "Aucun objectif défini pour le moment.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: objectifs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final objectif = objectifs[index];
                    final color = _colorFor(objectif.colorHex);
                    final progress = objectif.progress.clamp(0.0, 1.0);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(_iconFor(objectif.icon), color: color, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  objectif.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                ),
                              ),
                              Text(
                                "${(progress * 100).toInt()} %",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          const SizedBox(height: 15),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${objectif.currentCount} sur ${objectif.targetCount}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
