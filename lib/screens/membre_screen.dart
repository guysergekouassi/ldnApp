import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/ldn_signature.dart';
import '../components/user_avatar.dart';
import '../models/discipline_model.dart';
import '../models/regularite_model.dart';
import '../services/discipline_catalogue.dart';
import '../services/firestore_service.dart';
import 'groupes_screen.dart';

/// Vue Membre : la carte de membre et la règle de vie.
///
/// Le statut n'est pas stocké mais déduit de faits vérifiables (compte créé,
/// nombre d'engagements, régularité) : il ne peut donc jamais contredire ce que
/// le membre vit réellement dans l'application.
class MembreScreen extends StatefulWidget {
  const MembreScreen({Key? key}) : super(key: key);

  @override
  State<MembreScreen> createState() => _MembreScreenState();
}

class _MembreScreenState extends State<MembreScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? _user = FirebaseAuth.instance.currentUser;

  String get _today => FirestoreService.dayKey(DateTime.now());

  bool get _estInvite => _user?.isAnonymous ?? true;

  @override
  Widget build(BuildContext context) {
    final uid = _user?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Espace Membre",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: uid == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  "Connecte-toi pour accéder à ton espace membre.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          : StreamBuilder<DisciplineMembre>(
              stream: _firestoreService.getDiscipline(uid),
              builder: (context, disciplineSnapshot) {
                final discipline =
                    disciplineSnapshot.data ?? const DisciplineMembre(engagementIds: []);

                return StreamBuilder<Regularite>(
                  stream: _firestoreService.getRegularite(uid),
                  builder: (context, regulariteSnapshot) {
                    final streak = regulariteSnapshot.data?.streak ?? 0;

                    return ListView(
                      padding: const EdgeInsets.all(15),
                      children: [
                        _buildCarteMembre(discipline, streak),
                        const SizedBox(height: 15),
                        _buildRegleDeVie(uid, discipline),
                        const SizedBox(height: 15),
                        _buildAccesGroupe(uid),
                        const LdnSignature(),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Carte de membre
  // ---------------------------------------------------------------------------

  Widget _buildCarteMembre(DisciplineMembre discipline, int streak) {
    final statut = StatutMembreLibelle.calculer(
      estInvite: _estInvite,
      nombreEngagements: discipline.engagementIds.length,
      streak: streak,
    );
    final couleur = _couleur(statut.couleurHex);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [couleur, Color.lerp(couleur, Colors.black, 0.3) ?? couleur],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CurrentUserAvatar(radius: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nomAffiche(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statut.libelle,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            statut.description,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildStat("$streak", streak > 1 ? "jours d'affilée" : "jour d'affilée"),
              const SizedBox(width: 12),
              _buildStat(
                "${discipline.engagementIds.length}",
                discipline.engagementIds.length > 1 ? "engagements" : "engagement",
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _nomAffiche() {
    if (_estInvite) return "Invité";
    final nom = _user?.displayName;
    if (nom != null && nom.trim().isNotEmpty) return nom;
    return "Membre";
  }

  Widget _buildStat(String valeur, String libelle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              valeur,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              libelle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Règle de vie
  // ---------------------------------------------------------------------------

  Widget _buildRegleDeVie(String uid, DisciplineMembre discipline) {
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Ma discipline spirituelle",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                ),
              ),
              if (discipline.estDefinie)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => _modifierRegleDeVie(uid, discipline),
                  child: const Text(
                    "Modifier",
                    style: TextStyle(color: Color(0xFF5B4FC8), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Ce que tu t'engages à tenir, et ce que tu tiens vraiment.",
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 16),
          if (!discipline.estDefinie)
            _buildInvitationRegleDeVie(uid, discipline)
          else
            _buildListeEngagements(uid, discipline),
        ],
      ),
    );
  }

  Widget _buildInvitationRegleDeVie(String uid, DisciplineMembre discipline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F0FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "Une règle de vie, c'est trois ou quatre engagements simples que tu tiens "
            "vraiment — pas dix que tu abandonnes en deux semaines.",
            style: TextStyle(color: Colors.black87, fontSize: 12, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4FC8),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => _modifierRegleDeVie(uid, discipline),
            icon: const Icon(Icons.rule, color: Colors.white, size: 18),
            label: const Text(
              "Choisir ma règle de vie",
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListeEngagements(String uid, DisciplineMembre discipline) {
    return StreamBuilder<List<String>>(
      stream: _firestoreService.getDisciplineDuJour(uid, _today),
      builder: (context, jourSnapshot) {
        final tenusAujourdHui = jourSnapshot.data ?? <String>[];

        return StreamBuilder<Map<String, int>>(
          stream: _firestoreService.getFideliteDiscipline(uid),
          builder: (context, fideliteSnapshot) {
            final fidelite = fideliteSnapshot.data ?? <String, int>{};

            return Column(
              children: discipline.engagementIds.map((id) {
                final engagement = engagementParId(id);
                // Un engagement retiré du catalogue depuis est ignoré plutôt
                // qu'affiché sous forme d'identifiant brut.
                if (engagement == null) return const SizedBox.shrink();

                return _buildEngagement(
                  uid,
                  engagement,
                  tenusAujourdHui.contains(id),
                  fidelite[id] ?? 0,
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildEngagement(
    String uid,
    EngagementSpirituel engagement,
    bool tenuAujourdHui,
    int joursTenus,
  ) {
    final attendu = engagement.frequence.occurrencesAttenduesSur(30);
    final taux = attendu == 0 ? 0.0 : (joursTenus / attendu).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _firestoreService.toggleEngagementDuJour(
              uid,
              _today,
              engagement.id,
              !tenuAujourdHui,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tenuAujourdHui ? const Color(0xFF16A34A) : Colors.transparent,
                border: Border.all(
                  color: tenuAujourdHui ? const Color(0xFF16A34A) : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: tenuAujourdHui
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_icone(engagement.iconName), size: 15, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        engagement.titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Text(
                      "${(taux * 100).round()} %",
                      style: TextStyle(
                        color: _couleurTaux(taux),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: taux,
                    backgroundColor: const Color(0xFFEEEEEE),
                    valueColor: AlwaysStoppedAnimation<Color>(_couleurTaux(taux)),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${engagement.frequence.libelle} · $joursTenus fois sur les 30 derniers jours",
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Vert au-delà des deux tiers, orange au-dessus d'un tiers, rouge en
  /// dessous : un repère franc, sans nuances illisibles sur une barre de 4 px.
  Color _couleurTaux(double taux) {
    if (taux >= 0.66) return const Color(0xFF16A34A);
    if (taux >= 0.33) return const Color(0xFFE99D1A);
    return const Color(0xFFC72127);
  }

  Future<void> _modifierRegleDeVie(String uid, DisciplineMembre discipline) async {
    final choix = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChoixEngagements(selectionInitiale: discipline.engagementIds),
    );

    if (choix == null) return;
    await _firestoreService.enregistrerDiscipline(uid, choix);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          choix.isEmpty
              ? "Règle de vie effacée."
              : "Règle de vie enregistrée : ${choix.length} engagements.",
        ),
        backgroundColor: choix.isEmpty ? Colors.grey : Colors.green,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Groupe local
  // ---------------------------------------------------------------------------

  Widget _buildAccesGroupe(String uid) {
    return StreamBuilder<String?>(
      stream: _firestoreService.getMonGroupeId(uid),
      builder: (context, snapshot) {
        final aUnGroupe = snapshot.data != null;

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GroupesScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F0FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.groups_outlined, color: Color(0xFF5B4FC8), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aUnGroupe ? "Mon groupe" : "Rejoins un groupe",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        aUnGroupe
                            ? "Voir les rencontres et changer de groupe."
                            : "On ne tient pas seul : trouve une communauté près de chez toi.",
                        style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _couleur(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF5B4FC8);
    }
  }

  IconData _icone(String nom) {
    switch (nom) {
      case 'wb_sunny_outlined':
        return Icons.wb_sunny_outlined;
      case 'menu_book':
        return Icons.menu_book;
      case 'circle_outlined':
        return Icons.circle_outlined;
      case 'nightlight_round':
        return Icons.nightlight_round;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'church_outlined':
        return Icons.church_outlined;
      case 'no_food_outlined':
        return Icons.no_food_outlined;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'favorite_border':
        return Icons.favorite_border;
      default:
        return Icons.check_circle_outline;
    }
  }
}

/// Feuille de sélection des engagements de la règle de vie.
class _ChoixEngagements extends StatefulWidget {
  final List<String> selectionInitiale;

  const _ChoixEngagements({Key? key, required this.selectionInitiale}) : super(key: key);

  @override
  State<_ChoixEngagements> createState() => _ChoixEngagementsState();
}

class _ChoixEngagementsState extends State<_ChoixEngagements> {
  late final Set<String> _selection = {...widget.selectionInitiale};

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Ma règle de vie",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Choisis-en trois ou quatre. Tu pourras toujours en ajouter plus tard.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: catalogueEngagements.map(_buildLigne).toList(),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4FC8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.pop(context, _selection.toList()),
                    child: Text(
                      _selection.isEmpty
                          ? "Ne rien choisir pour l'instant"
                          : "Enregistrer (${_selection.length})",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLigne(EngagementSpirituel engagement) {
    final choisi = _selection.contains(engagement.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() {
          if (choisi) {
            _selection.remove(engagement.id);
          } else {
            _selection.add(engagement.id);
          }
        }),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: choisi ? const Color(0xFFF3F0FF) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: choisi ? const Color(0xFF5B4FC8) : const Color(0xFFE5E7EB),
              width: choisi ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                choisi ? Icons.check_circle : Icons.circle_outlined,
                color: choisi ? const Color(0xFF5B4FC8) : Colors.grey.shade400,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            engagement.titre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Text(
                          engagement.frequence.libelle,
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      engagement.description,
                      style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
