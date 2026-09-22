import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/bible_plan_model.dart';
import '../services/firestore_service.dart';
import '../services/share_service.dart';

/// Détail d'un plan de lecture : les jours, leur référence, et le suivi.
class BiblePlanDetailScreen extends StatefulWidget {
  final String planId;

  const BiblePlanDetailScreen({Key? key, required this.planId}) : super(key: key);

  @override
  State<BiblePlanDetailScreen> createState() => _BiblePlanDetailScreenState();
}

class _BiblePlanDetailScreenState extends State<BiblePlanDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: StreamBuilder<BiblePlan?>(
        stream: _firestoreService.getBiblePlan(widget.planId),
        builder: (context, planSnapshot) {
          if (planSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          final plan = planSnapshot.data;
          if (plan == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text("Ce plan de lecture n'existe plus.", style: TextStyle(color: Colors.grey)),
              ),
            );
          }

          return StreamBuilder<BiblePlanProgress?>(
            stream: _uid != null
                ? _firestoreService.getBiblePlanProgress(_uid!, plan.id)
                : Stream.value(null),
            builder: (context, progressSnapshot) {
              return _buildContenu(plan, progressSnapshot.data);
            },
          );
        },
      ),
    );
  }

  Widget _buildContenu(BiblePlan plan, BiblePlanProgress? progression) {
    final couleur = _couleur(plan.colorHex);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: couleur,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            if (progression != null)
              PopupMenuButton<String>(
                tooltip: "Options du plan",
                icon: const Icon(Icons.more_vert, color: Colors.white),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (_) => _abandonner(plan),
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'quitter',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 10),
                        Text("Abandonner ce plan", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(52, 0, 52, 14),
            title: Text(
              plan.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  plan.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: couleur),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, couleur.withOpacity(0.9)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(15),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildEnTete(plan, progression, couleur),
              const SizedBox(height: 20),
              const Text(
                "Le parcours jour par jour",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              ...plan.readings.map(
                (lecture) => _buildJour(plan, lecture, progression, couleur),
              ),
              const SizedBox(height: 30),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildEnTete(BiblePlan plan, BiblePlanProgress? progression, Color couleur) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Text(
            "${plan.subtitle} · ${plan.durationLabel}",
            style: TextStyle(color: couleur, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            plan.description,
            style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 18),
          if (progression == null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: couleur,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _demarrer(plan),
                icon: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                label: const Text(
                  "Commencer ce plan",
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else ...[
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
            const SizedBox(height: 10),
            Text(
              progression.isCompleted
                  ? "Plan terminé. Tu as traversé le livre en entier 🎉"
                  : "Prochaine étape : jour ${progression.prochainJour}.",
              style: TextStyle(
                color: progression.isCompleted ? Colors.green : Colors.black54,
                fontSize: 12,
                fontWeight: progression.isCompleted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJour(
    BiblePlan plan,
    BibleReading lecture,
    BiblePlanProgress? progression,
    Color couleur,
  ) {
    final lu = progression?.estLu(lecture.dayNumber) ?? false;
    final estProchain = progression != null &&
        !progression.isCompleted &&
        progression.prochainJour == lecture.dayNumber;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: estProchain ? Border.all(color: couleur, width: 1.5) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _basculerJour(plan, lecture.dayNumber, progression),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lu ? couleur : Colors.transparent,
                border: Border.all(color: lu ? couleur : Colors.grey.shade300, width: 1.5),
              ),
              alignment: Alignment.center,
              child: lu
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      "${lecture.dayNumber}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lecture.reference,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: lu ? Colors.grey : const Color(0xFF0F172A),
                    decoration: lu ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  lecture.focus,
                  style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              splashRadius: 18,
              tooltip: "Partager cette lecture",
              icon: Icon(Icons.ios_share, size: 16, color: Colors.grey.shade500),
              onPressed: () => ShareService.shareVerse(
                reference: "${lecture.reference} — ${plan.title}",
                text: lecture.focus,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _demarrer(BiblePlan plan) async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connecte-toi pour suivre ta lecture."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _firestoreService.demarrerBiblePlan(_uid!, plan);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Plan commencé : ${plan.durationLabel} avec la Parole 📖"),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Coche ou décoche une journée. Si le plan n'a pas encore été commencé, on
  /// le démarre au passage : cocher un jour est une manière naturelle de s'y
  /// mettre, et exiger un appui préalable sur « Commencer » serait un détour.
  Future<void> _basculerJour(
    BiblePlan plan,
    int jour,
    BiblePlanProgress? progression,
  ) async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connecte-toi pour suivre ta lecture."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (progression == null) {
      await _firestoreService.demarrerBiblePlan(_uid!, plan);
    }

    final lu = await _firestoreService.toggleJourLecture(_uid!, plan.id, jour);
    if (!mounted || !lu) return;

    final joursLus = (progression?.joursLus ?? 0) + 1;
    if (joursLus >= plan.durationDays) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Plan « ${plan.title} » terminé. Bravo ! 🎉"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _abandonner(BiblePlan plan) async {
    if (_uid == null) return;

    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Abandonner ce plan ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Ta progression dans "${plan.title}" sera effacée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Continuer le plan", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Abandonner", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirme != true) return;
    await _firestoreService.quitterBiblePlan(_uid!, plan.id);
  }

  Color _couleur(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.orange;
    }
  }
}
