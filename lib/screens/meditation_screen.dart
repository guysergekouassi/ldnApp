import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/carnet_note_model.dart';
import '../models/evangile_model.dart';
import '../services/aelf_api_service.dart';
import '../services/firestore_service.dart';

/// Un temps de la lectio divina.
class _TempsMeditation {
  final String titre;
  final String latin;
  final String guidance;
  final String question;
  final String exemple;
  final IconData icone;

  const _TempsMeditation({
    required this.titre,
    required this.latin,
    required this.guidance,
    required this.question,
    required this.exemple,
    required this.icone,
  });
}

/// Méditation du jour, conduite sur l'Évangile du jour selon la lectio divina.
///
/// L'écran ne propose pas un texte générique : il charge l'Évangile réel du
/// jour depuis l'AELF, l'affiche au premier temps, et les quatre temps portent
/// dessus. Sans ce texte, la méditation n'aurait pas d'objet — l'écran refuse
/// donc de démarrer plutôt que de guider dans le vide.
///
/// Les réponses rejoignent le carnet spirituel, comme l'examen du soir.
class MeditationScreen extends StatefulWidget {
  const MeditationScreen({Key? key}) : super(key: key);

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  static const List<_TempsMeditation> _temps = [
    _TempsMeditation(
      titre: "Lire",
      latin: "Lectio",
      guidance:
          "Lis le passage lentement, deux fois. Ne cherche pas encore à comprendre : laisse les mots passer.",
      question: "Quel mot, quelle phrase te retient ?",
      exemple: "Recopie-la simplement, sans l'expliquer…",
      icone: Icons.menu_book_outlined,
    ),
    _TempsMeditation(
      titre: "Méditer",
      latin: "Meditatio",
      guidance:
          "Reprends ce mot et laisse-le descendre. Pourquoi celui-là, aujourd'hui, dans ta vie à toi ?",
      question: "Qu'est-ce que ce passage te dit aujourd'hui ?",
      exemple: "Une résonance avec ta semaine, une question qu'il ouvre…",
      icone: Icons.self_improvement_outlined,
    ),
    _TempsMeditation(
      titre: "Prier",
      latin: "Oratio",
      guidance:
          "Ce n'est plus toi qui lis le texte, c'est toi qui réponds. Parle simplement, comme à un ami.",
      question: "Que veux-tu dire à Dieu à partir de là ?",
      exemple: "Une demande, un merci, un cri…",
      icone: Icons.favorite_border,
    ),
    _TempsMeditation(
      titre: "Contempler",
      latin: "Contemplatio",
      guidance:
          "Reste un instant sans rien dire. Il n'y a plus rien à produire : tu te tiens là, c'est tout.",
      question: "Que gardes-tu de ce temps ?",
      exemple: "Une paix, une résolution, une question qui reste…",
      icone: Icons.wb_sunny_outlined,
    ),
  ];

  final AelfApiService _apiService = AelfApiService();
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  final PageController _pageController = PageController();
  late final List<TextEditingController> _reponses =
      List.generate(_temps.length, (_) => TextEditingController());

  late Future<MesseLecture?> _evangile;
  int _tempsCourant = 0;
  bool _enregistrement = false;

  @override
  void initState() {
    super.initState();
    _evangile = _chargerEvangile();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _reponses) {
      c.dispose();
    }
    super.dispose();
  }

  /// Extrait l'Évangile des lectures du jour. Renvoie null si l'AELF est
  /// injoignable ou si la messe du jour n'en comporte pas.
  Future<MesseLecture?> _chargerEvangile() async {
    final lectures = await _apiService.getMesseDuJour();
    if (lectures.isEmpty) return null;
    try {
      return lectures.firstWhere((l) => l.type == 'evangile');
    } catch (_) {
      return null;
    }
  }

  /// N'avance que d'un temps : le dernier est confié à `_terminer`, qui a
  /// besoin de l'Évangile et n'est atteignable que depuis la navigation.
  void _suivant() {
    if (_tempsCourant >= _temps.length - 1) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _precedent() {
    if (_tempsCourant == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _composerNote() {
    final buffer = StringBuffer();
    for (int i = 0; i < _temps.length; i++) {
      final reponse = _reponses[i].text.trim();
      if (reponse.isEmpty) continue;
      if (buffer.isNotEmpty) buffer.write('\n\n');
      buffer.write('${_temps[i].titre}\n$reponse');
    }
    return buffer.toString();
  }

  Future<void> _terminer(MesseLecture? evangile) async {
    final contenu = _composerNote();

    if (contenu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Réponds à au moins un temps pour enregistrer ta méditation."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final uid = _uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connecte-toi pour enregistrer ta méditation dans le carnet."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _enregistrement = true);

    // La référence rejoint le contenu : des mois plus tard, la note doit dire
    // sur quel passage elle a été écrite.
    final reference = evangile?.reference ?? '';
    final corps = reference.isEmpty ? contenu : "Évangile : $reference\n\n$contenu";

    try {
      await _firestoreService.addCarnetNote(
        uid,
        CarnetNote(
          id: '',
          type: 'meditation',
          title: "Méditation — ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
          content: corps,
          tags: const ['meditation', 'evangile'],
          date: DateTime.now(),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Méditation enregistrée dans ton carnet. 📖"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Enregistrement de la méditation impossible : $e");
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
      body: FutureBuilder<MesseLecture?>(
        future: _evangile,
        builder: (context, snapshot) {
          final chargement = snapshot.connectionState == ConnectionState.waiting;
          final evangile = snapshot.data;

          return Column(
            children: [
              _buildHeader(evangile),
              if (chargement)
                const Expanded(
                  child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                )
              else if (evangile == null)
                Expanded(child: _buildIndisponible())
              else ...[
                _buildProgression(),
                const SizedBox(height: 15),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _tempsCourant = i),
                    itemCount: _temps.length,
                    itemBuilder: (context, i) => _buildTemps(_temps[i], i, evangile),
                  ),
                ),
                _buildNavigation(evangile),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(MesseLecture? evangile) {
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 190),
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/sunset_bg.jpg"),
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
                      "Méditation",
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
                      "Laisse-toi habiter par",
                      style: TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFE99D1A), Colors.orangeAccent],
                          ).createShader(bounds),
                          child: const Text(
                            "l'Évangile",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Text(
                          " du jour",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    if (evangile != null && evangile.reference.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        evangile.reference,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

  /// Sans Évangile, la méditation n'a pas d'objet : on le dit franchement
  /// plutôt que d'ouvrir des champs de saisie sur rien.
  Widget _buildIndisponible() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              "Évangile du jour indisponible",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "La méditation se fonde sur l'Évangile du jour, que nous n'arrivons pas à charger. Vérifie ta connexion, puis réessaie.",
              style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => setState(() => _evangile = _chargerEvangile()),
              child: const Text(
                "Réessayer",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgression() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(_temps.length, (i) {
                final atteint = i <= _tempsCourant;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == _temps.length - 1 ? 0 : 5),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 5,
                      decoration: BoxDecoration(
                        color: atteint ? Colors.orange : Colors.grey.shade300,
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
            "${_tempsCourant + 1}/${_temps.length}",
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

  Widget _buildTemps(_TempsMeditation temps, int index, MesseLecture evangile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          // Le texte de l'Évangile n'est déplié qu'au premier temps : c'est là
          // qu'on lit. Ensuite il reste consultable, replié, pour ne pas
          // repousser la question hors de l'écran.
          _buildTexteEvangile(evangile, ouvertParDefaut: index == 0),
          const SizedBox(height: 15),
          Container(
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
                      child: Icon(temps.icone, color: Colors.orange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            temps.titre,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            temps.latin,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  temps.guidance,
                  style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.6),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 20),
                Text(
                  temps.question,
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
                  minLines: 3,
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, height: 1.5),
                  cursorColor: Colors.orange,
                  decoration: InputDecoration(
                    hintText: temps.exemple,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTexteEvangile(MesseLecture evangile, {required bool ouvertParDefaut}) {
    return Container(
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
      child: Theme(
        // Sans cela, l'ExpansionTile garde les séparateurs gris par défaut,
        // qui jurent avec les cartes du reste de l'application.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: ouvertParDefaut,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_stories_outlined, color: Colors.orange, size: 20),
          ),
          title: Text(
            evangile.title.isNotEmpty ? evangile.title : "Évangile du jour",
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: evangile.reference.isEmpty
              ? null
              : Text(
                  evangile.reference,
                  style: const TextStyle(color: Colors.orange, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          children: [
            Text(
              evangile.text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation(MesseLecture evangile) {
    final dernier = _tempsCourant == _temps.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(color: Color(0xFFF8F9FA)),
      child: Row(
        children: [
          if (_tempsCourant > 0)
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
            onPressed: _enregistrement ? null : (dernier ? () => _terminer(evangile) : _suivant),
            child: _enregistrement
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    dernier ? "Terminer" : "Continuer",
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
