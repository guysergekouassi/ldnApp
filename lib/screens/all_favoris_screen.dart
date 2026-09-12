import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../services/share_service.dart';
import '../models/favori_model.dart';

/// Liste complète des favoris de l'utilisateur (versets, prières, parcours…).
class AllFavorisScreen extends StatelessWidget {
  AllFavorisScreen({Key? key}) : super(key: key);

  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  IconData _iconForType(String type) {
    switch (type) {
      case 'verset':
        return Icons.menu_book;
      case 'priere':
        return Icons.pan_tool_outlined;
      case 'neuvaine':
        return Icons.local_fire_department_outlined;
      case 'parcours':
        return Icons.school_outlined;
      default:
        return Icons.bookmark;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'verset':
        return 'Verset';
      case 'priere':
        return 'Prière';
      case 'neuvaine':
        return 'Neuvaine';
      case 'parcours':
        return 'Parcours';
      default:
        return 'Favori';
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
          "Mes favoris",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ),
      body: _uid == null
          ? const Center(
              child: Text(
                "Connectez-vous pour retrouver vos favoris.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : StreamBuilder<List<Favori>>(
              stream: _firestoreService.getUserFavoris(_uid!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.orange));
                }

                final favoris = snapshot.data ?? [];
                if (favoris.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        "Aucun favori pour le moment.\nTouche l'icône 🔖 sur un verset pour l'ajouter.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: favoris.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final favori = favoris[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(_iconForType(favori.type), color: Colors.orange, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _labelForType(favori.type),
                                  style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  favori.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                ),
                                if (favori.reference.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    favori.reference,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                                  ),
                                ],
                                if (favori.createdAt != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    "Ajouté le ${DateFormat('dd/MM/yyyy').format(favori.createdAt!)}",
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share_outlined, size: 18, color: Colors.grey),
                                tooltip: "Partager",
                                onPressed: () => ShareService.shareVerse(
                                  reference: favori.title,
                                  text: favori.reference,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                tooltip: "Retirer",
                                onPressed: () => _firestoreService.removeFavori(_uid!, favori.id),
                              ),
                            ],
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
