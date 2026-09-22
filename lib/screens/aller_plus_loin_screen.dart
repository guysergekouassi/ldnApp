import 'package:flutter/material.dart';

import '../components/ldn_signature.dart';
import '../models/besoin_aide_model.dart';
import '../services/firestore_service.dart';
import 'bible_plans_screen.dart';
import 'demande_ecoute_screen.dart';
import 'grandir_dans_la_foi_screen.dart';
import 'groupes_screen.dart';
import 'intentions_semaine_screen.dart';
import 'preparation_confession_screen.dart';

/// « Aller plus loin » : orienter selon le besoin du moment.
///
/// Chaque besoin propose d'abord ce que l'application sait faire (une écoute,
/// un groupe, la confession), puis les contacts locaux que l'équipe a saisis.
/// Aucun contact extérieur n'est livré en dur : un numéro erroné affiché à
/// quelqu'un en détresse ferait plus de mal que pas de numéro du tout.
class AllerPlusLoinScreen extends StatefulWidget {
  const AllerPlusLoinScreen({Key? key}) : super(key: key);

  @override
  State<AllerPlusLoinScreen> createState() => _AllerPlusLoinScreenState();
}

class _AllerPlusLoinScreenState extends State<AllerPlusLoinScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _firestoreService.checkAndInitializeBesoinsAide();
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
          "Aller plus loin",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<BesoinAide>>(
        stream: _firestoreService.getBesoinsAide(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          final besoins = snapshot.data ?? <BesoinAide>[];

          return ListView(
            padding: const EdgeInsets.all(15),
            children: [
              _buildIntro(),
              const SizedBox(height: 12),
              _buildUrgence(),
              const SizedBox(height: 16),
              if (besoins.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    "Les ressources arrivent. Reviens dans un instant.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...besoins.map(_buildBesoinCard),
              const SizedBox(height: 10),
              _buildEcouteDirecte(),
              const LdnSignature(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIntro() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        "Il y a des moments où la prière seule ne suffit pas, et où demander de l'aide "
        "est exactement ce qu'il faut faire. Choisis ce qui te ressemble aujourd'hui.",
        style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.6),
      ),
    );
  }

  /// Bandeau d'urgence. Le message vient de `app_content/urgences` quand
  /// l'équipe y a mis des numéros locaux ; sinon une consigne vraie partout.
  Widget _buildUrgence() {
    return StreamBuilder<String>(
      stream: _firestoreService.getConsigneUrgence(),
      builder: (context, snapshot) {
        final message = snapshot.data ?? '';
        if (message.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFB91C1C), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Color(0xFF7F1D1D), fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBesoinCard(BesoinAide besoin) {
    final couleur = _couleur(besoin.couleurHex);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Theme(
        // Le trait de séparation par défaut de l'ExpansionTile coupe la carte
        // en deux quand elle est repliée.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: couleur.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icone(besoin.iconName), color: couleur, size: 18),
          ),
          title: Text(
            besoin.titre,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
          ),
          subtitle: Text(
            besoin.resume,
            style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.3),
          ),
          children: [
            if (besoin.quoiSavoir.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  besoin.quoiSavoir,
                  style: const TextStyle(color: Colors.black87, fontSize: 12, height: 1.6),
                ),
              ),
            if (besoin.premiersPas.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "PREMIERS PAS",
                  style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              ...besoin.premiersPas.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text(
                              "${e.key + 1}",
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.value,
                              style: const TextStyle(color: Colors.black87, fontSize: 12, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
            if (besoin.ressourcesInternes.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...besoin.ressourcesInternes.map((r) => _buildRessourceInterne(r, besoin, couleur)),
            ],
            if (besoin.ressourcesExterieures.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "CONTACTS",
                  style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              ...besoin.ressourcesExterieures.map(_buildRessourceExterieure),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRessourceInterne(RessourceAide ressource, BesoinAide besoin, Color couleur) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _ouvrir(ressource.cible, besoin),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: couleur.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.arrow_circle_right_outlined, color: couleur, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ressource.libelle,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: couleur),
                    ),
                    if (ressource.detail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        ressource.detail,
                        style: const TextStyle(color: Colors.black54, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Contact saisi par l'équipe. Il est affiché tel quel, sans être composé
  /// automatiquement : l'application n'embarque pas `url_launcher`, et un appel
  /// déclenché par erreur depuis cet écran serait malvenu.
  Widget _buildRessourceExterieure(RessourceAide ressource) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconeRessource(ressource.type), color: Colors.grey.shade600, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ressource.libelle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    ressource.cible,
                    style: const TextStyle(color: Color(0xFF5B4FC8), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  if (ressource.detail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      ressource.detail,
                      style: const TextStyle(color: Colors.black54, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcouteDirecte() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B4FC8), Color(0xFF3B2F9E)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.record_voice_over_outlined, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Parler à quelqu'un",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Tu ne sais pas dans quelle case tu entres ? Ce n'est pas grave. "
            "Écris à l'équipe, quelqu'un te répondra.",
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DemandeEcouteScreen()),
              ),
              child: const Text(
                "Demander une écoute",
                style: TextStyle(color: Color(0xFF5B4FC8), fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _ouvrir(String cible, BesoinAide besoin) {
    switch (cible) {
      case 'ecoute':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DemandeEcouteScreen(
              typeInitial: besoin.id == 'doute' ? 'question' : 'ecoute',
              sujetInitial: besoin.titre,
            ),
          ),
        );
        break;
      case 'groupe':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupesScreen()));
        break;
      case 'confession':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PreparationConfessionScreen()),
        );
        break;
      case 'intention':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IntentionsSemaineScreen()),
        );
        break;
      case 'bible':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BiblePlansScreen()));
        break;
      case 'parcours':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GrandirDansLaFoiScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cette ressource n'est pas encore disponible.")),
        );
    }
  }

  Color _couleur(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF5B4FC8);
    }
  }

  IconData _iconeRessource(String type) {
    switch (type) {
      case 'telephone':
        return Icons.phone_outlined;
      case 'lien':
        return Icons.link;
      case 'lieu':
        return Icons.place_outlined;
      default:
        return Icons.info_outline;
    }
  }

  IconData _icone(String nom) {
    switch (nom) {
      case 'favorite_border':
        return Icons.favorite_border;
      case 'person_outline':
        return Icons.person_outline;
      case 'healing':
        return Icons.healing;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'link_off':
        return Icons.link_off;
      case 'shield_outlined':
        return Icons.shield_outlined;
      case 'savings_outlined':
        return Icons.savings_outlined;
      case 'explore_outlined':
        return Icons.explore_outlined;
      case 'handshake_outlined':
        return Icons.handshake_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
