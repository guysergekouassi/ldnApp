import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/ldn_signature.dart';
import '../models/bible_plan_model.dart';
import '../services/firestore_service.dart';
import 'bible_plan_detail_screen.dart';

/// Catalogue des plans de lecture de la Bible.
class BiblePlansScreen extends StatefulWidget {
  const BiblePlansScreen({Key? key}) : super(key: key);

  @override
  State<BiblePlansScreen> createState() => _BiblePlansScreenState();
}

class _BiblePlansScreenState extends State<BiblePlansScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    // Amorçage à l'ouverture : c'est le seul écran qui a besoin des plans, on
    // évite d'alourdir le démarrage de l'application avec une écriture de plus.
    _firestoreService.checkAndInitializeBiblePlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Lire la Bible",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<BiblePlanProgress>>(
        stream: _uid != null
            ? _firestoreService.getUserBiblePlans(_uid!)
            : Stream.value(<BiblePlanProgress>[]),
        builder: (context, progressSnapshot) {
          final progressions = {
            for (final p in progressSnapshot.data ?? <BiblePlanProgress>[]) p.planId: p,
          };

          return StreamBuilder<List<BiblePlan>>(
            stream: _firestoreService.getBiblePlans(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.orange));
              }

              final plans = snapshot.data ?? <BiblePlan>[];
              if (plans.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      "Les plans de lecture arrivent. Reviens dans un instant.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  _buildIntro(),
                  const SizedBox(height: 15),
                  ...plans.map((plan) => Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _buildPlanCard(plan, progressions[plan.id]),
                      )),
                  const LdnSignature(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Chaque jour, une référence à ouvrir dans ta Bible et un point d'attention. "
              "Tu avances à ton rythme : rien ne se perd si tu sautes un jour.",
              style: TextStyle(color: Colors.black87, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BiblePlan plan, BiblePlanProgress? progression) {
    final couleur = _couleur(plan.colorHex);
    final commence = progression != null;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BiblePlanDetailScreen(planId: plan.id)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  Image.asset(
                    plan.imageAsset,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 110,
                      color: couleur.withOpacity(0.15),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, couleur.withOpacity(0.75)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Text(
                          "${plan.subtitle} · ${plan.durationLabel}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
                  ),
                  if (commence) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              value: progression.progression,
                              backgroundColor: const Color(0xFFE5E7EB),
                              valueColor: AlwaysStoppedAnimation<Color>(couleur),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${progression.joursLus}/${progression.durationDays}",
                          style: TextStyle(color: couleur, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(
                        commence
                            ? (progression.isCompleted ? Icons.verified : Icons.play_circle_outline)
                            : Icons.arrow_circle_right_outlined,
                        size: 16,
                        color: couleur,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        commence
                            ? (progression.isCompleted ? "Plan terminé" : "Reprendre")
                            : "Commencer ce plan",
                        style: TextStyle(color: couleur, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _couleur(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.orange;
    }
  }
}
