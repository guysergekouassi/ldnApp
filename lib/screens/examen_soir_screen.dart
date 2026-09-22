import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/carnet_note_model.dart';
import '../services/firestore_service.dart';

/// Une étape de l'examen du soir.
class _EtapeExamen {
  final String titre;
  final String guidance;
  final String question;
  final String exemple;
  final IconData icone;

  const _EtapeExamen({
    required this.titre,
    required this.guidance,
    required this.question,
    required this.exemple,
    required this.icone,
  });
}

/// Examen du soir, dans sa forme ignatienne en cinq temps.
///
/// Ce n'est pas la préparation à la confession (qui vit dans
/// `PreparationConfessionScreen` et cherche les péchés à confesser) : c'est une
/// relecture quotidienne de la journée, qui se termine sur une résolution.
///
/// Les réponses sont enregistrées comme une note du carnet spirituel, de type
/// `meditation` et taguée `examen` — le carnet ne filtre que sur trois types,
/// une note `examen` y serait invisible.
class ExamenSoirScreen extends StatefulWidget {
  const ExamenSoirScreen({Key? key}) : super(key: key);

  @override
  State<ExamenSoirScreen> createState() => _ExamenSoirScreenState();
}

class _ExamenSoirScreenState extends State<ExamenSoirScreen> {
  static const List<_EtapeExamen> _etapes = [
    _EtapeExamen(
      titre: "Action de grâce",
      guidance: "Avant de regarder ce qui a manqué, regarde ce qui a été donné.",
      question: "De quoi rends-tu grâce aujourd'hui ?",
      exemple: "Un visage, une nouvelle, un moment de paix…",
      icone: Icons.volunteer_activism_outlined,
    ),
    _EtapeExamen(
      titre: "Demande de lumière",
      guidance:
          "Tu ne relis pas ta journée seul. Demande à l'Esprit de te montrer ce que tu ne vois pas de toi-même.",
      question: "Qu'est-ce que tu demandes de voir clairement ce soir ?",
      exemple: "Une attitude qui revient, une peur, un angle mort…",
      icone: Icons.light_mode_outlined,
    ),
    _EtapeExamen(
      titre: "Relecture de la journée",
      guidance:
          "Reprends ta journée heure par heure, sans te juger. Où étais-tu vivant ? Où t'es-tu éteint ?",
      question: "Qu'est-ce qui a marqué ta journée ?",
      exemple: "Le moment le plus lumineux, le plus lourd…",
      icone: Icons.history_outlined,
    ),
    _EtapeExamen(
      titre: "Demande de pardon",
      guidance:
          "Nomme simplement, sans t'accabler. La miséricorde arrive toujours avant le remords.",
      question: "Où as-tu manqué d'amour aujourd'hui ?",
      exemple: "Envers Dieu, envers un proche, envers toi-même…",
      icone: Icons.favorite_border,
    ),
    _EtapeExamen(
      titre: "Résolution pour demain",
      guidance: "Une seule chose, concrète et petite. Pas un programme.",
      question: "Quel pas veux-tu poser demain ?",
      exemple: "Un appel, un pardon demandé, dix minutes de silence…",
      icone: Icons.wb_twilight,
    ),
  ];

  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  final PageController _pageController = PageController();
  late final List<TextEditingController> _reponses =
      List.generate(_etapes.length, (_) => TextEditingController());

  int _etapeCourante = 0;
  bool _enregistrement = false;

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _reponses) {
      c.dispose();
    }
    super.dispose();
  }

  void _suivant() {
    if (_etapeCourante < _etapes.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _terminer();
    }
  }

  void _precedent() {
    if (_etapeCourante == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Met en forme les cinq réponses en une note lisible des mois plus tard.
  /// Les étapes laissées vides sont omises plutôt que rendues sous un titre nu.
  String _composerNote() {
    final buffer = StringBuffer();
    for (int i = 0; i < _etapes.length; i++) {
      final reponse = _reponses[i].text.trim();
      if (reponse.isEmpty) continue;
      if (buffer.isNotEmpty) buffer.write('\n\n');
      buffer.write('${_etapes[i].titre}\n$reponse');
    }
    return buffer.toString();
  }

  Future<void> _terminer() async {
    final contenu = _composerNote();

    if (contenu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Réponds à au moins une étape pour enregistrer ton examen."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final uid = _uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connecte-toi pour enregistrer ton examen dans le carnet."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _enregistrement = true);

    try {
      await _firestoreService.addCarnetNote(
        uid,
        CarnetNote(
          id: '',
          type: 'meditation',
          title: "Examen du soir — ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
          content: contenu,
          tags: const ['examen'],
          date: DateTime.now(),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Examen enregistré dans ton carnet. 🌙"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Enregistrement de l'examen impossible : $e");
      if (!mounted) return;
      setState(() => _enregistrement = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enregistrement impossible. Réessaie."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(),
          _buildProgression(),
          const SizedBox(height: 15),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _etapeCourante = i),
              itemCount: _etapes.length,
              itemBuilder: (context, i) => _buildEtape(_etapes[i], i),
            ),
          ),
          _buildNavigation(),
        ],
      ),
    );
  }

  /// Même en-tête que les autres écrans : photo de fond, dégradé vers le fond
  /// de page, bouton retour en pastille blanche et titre en dégradé orange.
  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 190),
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/mountain_bg.png"),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 190),
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
                      "Examen du soir",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Container(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Prends le temps de",
                      style: TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFE99D1A), Colors.orangeAccent],
                          ).createShader(bounds),
                          child: const Text(
                            "relire",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Text(
                          " ta journée",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgression() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(_etapes.length, (i) {
                final atteinte = i <= _etapeCourante;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == _etapes.length - 1 ? 0 : 5),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 5,
                      decoration: BoxDecoration(
                        color: atteinte ? Colors.orange : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "${_etapeCourante + 1}/${_etapes.length}",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtape(_EtapeExamen etape, int index) {
    // Défilement : au clavier ouvert sur un petit écran, le contenu doit
    // pouvoir remonter au lieu de déborder.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(etape.icone, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    etape.titre,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              etape.guidance,
              style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 20),
            Text(
              etape.question,
              style: const TextStyle(
                color: Color(0xFFE99D1A),
                fontSize: 15,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reponses[index],
              maxLines: 6,
              minLines: 4,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, height: 1.5),
              cursorColor: Colors.orange,
              decoration: InputDecoration(
                hintText: etape.exemple,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Tu peux laisser une étape vide : seules les réponses écrites seront gardées.",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation() {
    final derniere = _etapeCourante == _etapes.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(color: Color(0xFFF8F9FA)),
      child: Row(
        children: [
          if (_etapeCourante > 0)
            TextButton.icon(
              onPressed: _enregistrement ? null : _precedent,
              icon: const Icon(Icons.arrow_back_ios_new, size: 12, color: Colors.grey),
              label: const Text("Retour", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _enregistrement ? null : _suivant,
            child: _enregistrement
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    derniere ? "Terminer" : "Continuer",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
