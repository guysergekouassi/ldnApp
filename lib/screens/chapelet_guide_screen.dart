import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/firestore_service.dart';
import '../models/chapelet_mystery_model.dart';
import '../models/favori_model.dart';
import '../services/share_service.dart';
import 'create_intention_screen.dart';

class ChapeletGuideScreen extends StatefulWidget {
  final String mysteryType;
  const ChapeletGuideScreen({Key? key, this.mysteryType = "Joyeux"}) : super(key: key);

  @override
  State<ChapeletGuideScreen> createState() => _ChapeletGuideScreenState();
}

/// Une étape lue à voix haute pendant la dizaine : l'annonce du mystère, sa
/// méditation, puis les prières qui la composent.
class _SegmentPriere {
  final String titre;
  final String texte;

  const _SegmentPriere(this.titre, this.texte);
}

class _ChapeletGuideScreenState extends State<ChapeletGuideScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  /// Lecture d'un enregistrement, quand le mystère porte un `audioUrl`.
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Lecture guidée par synthèse vocale, utilisée par défaut : elle rend la
  /// dizaine écoutable sans qu'aucun enregistrement n'ait été produit.
  final FlutterTts _tts = FlutterTts();

  int _currentStep = 1;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late String _currentMysteryType;

  /// Étapes de la dizaine en cours et position dans celle-ci.
  List<_SegmentPriere> _segments = const [];
  String? _mystereLu;
  int _segmentIndex = 0;

  /// Vrai pendant une lecture vocale : le lecteur de fichiers ne doit alors pas
  /// piloter l'état du bouton.
  bool _ttsActif = false;

  /// Incrémenté à chaque arrêt : une boucle de lecture d'une génération
  /// périmée se termine d'elle-même au lieu d'enchaîner sur la prière suivante.
  int _generationLecture = 0;

  bool _voixFrancaiseDisponible = true;

  @override
  void initState() {
    super.initState();
    _currentMysteryType = widget.mysteryType;
    _initialiserVoix();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted && !_ttsActif) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
  }

  @override
  void dispose() {
    _generationLecture++;
    _tts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initialiserVoix() async {
    try {
      if (Platform.isIOS) {
        // Sans cela, la voix reste muette quand le téléphone est en silencieux.
        await _tts.setSharedInstance(true);
      }
      // `speak` ne rend la main qu'à la fin de la phrase : c'est ce qui permet
      // d'enchaîner les prières dans l'ordre.
      await _tts.awaitSpeakCompletion(true);
      await _tts.setLanguage("fr-FR");
      await _tts.setSpeechRate(Platform.isIOS ? 0.45 : 0.42);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);

      final disponible = await _tts.isLanguageAvailable("fr-FR");
      if (mounted) setState(() => _voixFrancaiseDisponible = disponible == true);
    } catch (e) {
      debugPrint("Synthèse vocale indisponible : $e");
      if (mounted) setState(() => _voixFrancaiseDisponible = false);
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static const List<String> _rangs = ["Premier", "Deuxième", "Troisième", "Quatrième", "Cinquième"];

  /// La dizaine complète : annonce, méditation du mystère, Notre Père,
  /// dix Je vous salue Marie, Gloire au Père et prière de Fatima.
  List<_SegmentPriere> _construireSegments(ChapeletMystery mystere) {
    final rang = (mystere.step >= 1 && mystere.step <= _rangs.length) ? _rangs[mystere.step - 1] : "";
    final annonce = rang.isEmpty
        ? mystere.name
        : "$rang mystère ${mystere.type.toLowerCase()} : ${mystere.name}";

    return [
      _SegmentPriere("Annonce du mystère", "$annonce. ${mystere.reference}"),
      if (mystere.description.trim().isNotEmpty) _SegmentPriere("Méditation", mystere.description),
      _SegmentPriere("Notre Père", _textesPrieres["Notre Père"]!),
      for (int i = 1; i <= 10; i++)
        _SegmentPriere("Je vous salue Marie ($i/10)", _textesPrieres["Je vous salue Marie"]!),
      _SegmentPriere("Gloire au Père", _textesPrieres["Gloire au Père"]!),
      _SegmentPriere("Prière de Fatima", _textesPrieres["Prière de Fatima"]!),
    ];
  }

  Future<void> _togglePlayPause(ChapeletMystery mystere) async {
    // Un enregistrement déposé sur le mystère a la priorité sur la voix de
    // synthèse : c'est le chemin qui servira le jour où des voix seront
    // enregistrées, sans rien changer à l'écran.
    if (mystere.audioUrl.isNotEmpty) {
      await _lireFichier(mystere.audioUrl);
      return;
    }

    if (_isPlaying) {
      await _arreterLecture(garderPosition: true);
      return;
    }

    if (!_voixFrancaiseDisponible) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Voix française indisponible sur cet appareil. Installe-la dans Réglages > Synthèse vocale."),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    if (_mystereLu != mystere.id || _segments.isEmpty) {
      _segments = _construireSegments(mystere);
      _mystereLu = mystere.id;
      _segmentIndex = 0;
    }

    setState(() {
      _ttsActif = true;
      _isPlaying = true;
    });

    await _lireDepuis(_segmentIndex);
  }

  Future<void> _lireDepuis(int debut) async {
    _generationLecture++;
    final generation = _generationLecture;

    try {
      for (int i = debut; i < _segments.length; i++) {
        if (generation != _generationLecture || !mounted) return;
        setState(() => _segmentIndex = i);
        await _tts.speak(_segments[i].texte);
      }
    } catch (e) {
      debugPrint("Lecture vocale interrompue : $e");
    }

    if (generation != _generationLecture || !mounted) return;

    // Dizaine terminée : on revient au début pour la suivante.
    setState(() {
      _isPlaying = false;
      _ttsActif = false;
      _segmentIndex = 0;
    });
  }

  /// Arrête la lecture en cours. [garderPosition] distingue la pause, qui
  /// reprendra à la prière en cours, du changement de mystère, qui repart de
  /// l'annonce.
  Future<void> _arreterLecture({bool garderPosition = false}) async {
    _generationLecture++;
    _ttsActif = false;

    // Remise à zéro immédiate : l'affichage ne doit pas attendre que le moteur
    // vocal ait rendu la main, sinon la jauge garde la prière précédente le
    // temps de l'arrêt — et la garderait indéfiniment si stop() échouait.
    if (mounted) {
      setState(() {
        _isPlaying = false;
        if (!garderPosition) {
          _segmentIndex = 0;
          _segments = const [];
          _mystereLu = null;
        }
      });
    }

    try {
      await _tts.stop();
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint("Arrêt de la lecture impossible : $e");
    }
  }

  Future<void> _lireFichier(String url) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else if (_audioPlayer.state == PlayerState.paused) {
        // Reprendre là où on s'est arrêté, au lieu de tout reprendre au début.
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.play(UrlSource(url));
      }
    } catch (e) {
      debugPrint("Lecture de l'enregistrement impossible : $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enregistrement illisible pour ce mystère."), backgroundColor: Colors.red),
      );
    }
  }

  void _showMysteriesSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Choisir les mystères", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 5),
              const Text("Sélectionne les mystères à méditer.", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 15),
              _mysteryOption(ctx, "Joyeux", "Lundi et Samedi", Colors.orange),
              _mysteryOption(ctx, "Douloureux", "Mardi et Vendredi", Colors.redAccent),
              _mysteryOption(ctx, "Glorieux", "Mercredi et Dimanche", Colors.amber),
              _mysteryOption(ctx, "Lumineux", "Jeudi", Colors.yellow.shade700),
            ],
          ),
        );
      },
    );
  }

  Widget _mysteryOption(BuildContext ctx, String type, String days, Color color) {
    final isSelected = _currentMysteryType == type;
    return ListTile(
      leading: Icon(Icons.brightness_high, color: color),
      title: Text("Mystères $type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? color : const Color(0xFF0F172A))),
      subtitle: Text(days, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      trailing: isSelected ? Icon(Icons.check_circle, color: color) : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.pop(ctx);
        _arreterLecture();
        setState(() {
          _currentMysteryType = type;
          _currentStep = 1;
        });
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: StreamBuilder<List<ChapeletMystery>>(
        key: ValueKey(_currentMysteryType),
        stream: _firestoreService.getChapeletMysteries(_currentMysteryType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          if (snapshot.hasError) {
             print("Firestore Error: ${snapshot.error}");
             return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 50, color: Colors.red),
                    const SizedBox(height: 10),
                    Text("Erreur Firebase: ${snapshot.error}", style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Retour", style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text("La collection 'rosary_mysteries' est vide ou introuvable.", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Retour", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          final mysteries = snapshot.data!;
          final currentMystery = mysteries.firstWhere((m) => m.step == _currentStep, orElse: () => mysteries.first);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, currentMystery),
                const SizedBox(height: 20),
                _buildStats(),
                const SizedBox(height: 20),
                _buildCurrentMystery(currentMystery),
                const SizedBox(height: 20),
                _buildTimeline(mysteries),
                const SizedBox(height: 20),
                _buildAudioPlayer(currentMystery),
                const SizedBox(height: 15),
                _buildActionButtons(currentMystery),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChapeletMystery mystery) {
    return Stack(
      children: [
        Container(
          height: 350,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/sunset_bg.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.4),
                const Color(0xFFF8F9FA),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                        icon: const Icon(Icons.chevron_left, color: Color(0xFF0F172A)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      "Chapelet guidé",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                            ],
                          ),
                          child: _buildBookmarkButton(mystery),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.more_horiz, color: Color(0xFF0F172A)),
                            onPressed: () => _showMoreMenu(mystery),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  "Aujourd'hui,",
                  style: TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
                ),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.2),
                    children: [
                      TextSpan(text: "prie le "),
                      TextSpan(text: "Chapelet\n", style: TextStyle(color: Colors.orange)),
                      TextSpan(text: "avec confiance"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("“", style: TextStyle(color: Colors.orange, fontSize: 30, fontWeight: FontWeight.bold, height: 0.8)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Avec Marie, nous contemplons\nles mystères de la vie du Christ.",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.4),
                          ),
                          const SizedBox(height: 5),
                          const Text("”", style: TextStyle(color: Colors.orange, fontSize: 30, fontWeight: FontWeight.bold, height: 0.8)),
                          const SizedBox(height: 5),
                          Container(width: 30, height: 2, color: Colors.orange),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(Icons.access_time, "Durée estimée", "20 min", Colors.orange),
            _buildDivider(),
            _buildStatItem(Icons.brightness_high, "Mystères", widget.mysteryType, Colors.orange),
            _buildDivider(),
            _buildStatItem(Icons.bar_chart, "Progression", "${(_currentStep / 5 * 100).toInt()} %", Colors.orange),
            _buildDivider(),
            _buildStatItem(Icons.calendar_today, "Dernière prière", "Hier", Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildCurrentMystery(ChapeletMystery mystery) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: Image.asset(
                  mystery.imageUrl.isNotEmpty ? mystery.imageUrl : "assets/mary_praying.png",
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(height: 200, color: Colors.grey[300]);
                  },
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "MYSTÈRE ACTUEL",
                      style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16),
                        children: [
                          TextSpan(text: "${mystery.step}", style: const TextStyle(color: Colors.orange)),
                          const TextSpan(text: "er", style: TextStyle(color: Colors.orange, fontSize: 10)),
                          TextSpan(text: " Mystère ${mystery.type}"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      mystery.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.star, color: Colors.orange, size: 10),
                        ),
                        Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mystery.description,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mystery.reference,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(List<ChapeletMystery> mysteries) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(5, (index) {
            final stepNum = index + 1;
            final isActive = _currentStep == stepNum;
            // Get name if it exists, otherwise "À venir"
            String label = "À venir";
            if (mysteries.any((m) => m.step == stepNum)) {
              label = mysteries.firstWhere((m) => m.step == stepNum).name;
            }

            final isLast = stepNum == 5;

            return Expanded(
              flex: isLast ? 2 : 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        if (mysteries.any((m) => m.step == stepNum)) {
                          // Changer de dizaine interrompt la lecture en cours :
                          // sans cela la voix poursuivrait la dizaine précédente
                          // et la jauge resterait sur sa prière.
                          _arreterLecture();
                          setState(() {
                            _currentStep = stepNum;
                          });
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.orange : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: isActive ? Colors.orange : Colors.grey.shade300, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "$stepNum",
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              color: isActive ? const Color(0xFF0F172A) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.only(top: 15),
                        height: 2,
                        color: Colors.grey.shade200,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(ChapeletMystery mystery) {
    final bool modeFichier = mystery.audioUrl.isNotEmpty;

    // Segments affichés : ceux de la lecture en cours, sinon ceux que le
    // mystère produirait — le compteur est ainsi juste avant même d'appuyer.
    final segments = (_mystereLu == mystery.id && _segments.isNotEmpty)
        ? _segments
        : _construireSegments(mystery);
    final int index = _segmentIndex.clamp(0, segments.length - 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_currentStep > 1) {
                      _arreterLecture();
                      setState(() => _currentStep--);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                    ),
                    child: const Icon(Icons.skip_previous, color: Colors.grey, size: 24),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => _togglePlayPause(mystery),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFFF5252).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 35),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    if (_currentStep < 5) {
                      _arreterLecture();
                      setState(() => _currentStep++);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                    ),
                    child: const Icon(Icons.skip_next, color: Colors.grey, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              mystery.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 15),
            if (modeFichier)
              _buildBarreEnregistrement()
            else
              _buildBarreLectureGuidee(segments, index),
          ],
        ),
      ),
    );
  }

  /// Progression d'un enregistrement : position et durée réelles.
  Widget _buildBarreEnregistrement() {
    final totalSeconds = _duration.inSeconds;
    final sliderValue = (totalSeconds > 0) ? (_position.inSeconds / totalSeconds).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        Text(_formatDuration(_position), style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: Colors.orange,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: sliderValue,
              onChanged: totalSeconds == 0
                  ? null
                  : (value) async {
                      await _audioPlayer.seek(Duration(seconds: (value * totalSeconds).toInt()));
                    },
            ),
          ),
        ),
        Text(_formatDuration(_duration), style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  /// Progression de la lecture guidée : la prière en cours et son rang dans la
  /// dizaine, la seule mesure qui ait un sens pour une voix de synthèse.
  Widget _buildBarreLectureGuidee(List<_SegmentPriere> segments, int index) {
    final bool commencee = _isPlaying || _segmentIndex > 0;
    final double progression = segments.isEmpty ? 0 : (index + (commencee ? 1 : 0)) / segments.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progression,
            minHeight: 4,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                commencee ? segments[index].titre : "Dizaine guidée à voix haute",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: commencee ? FontWeight.bold : FontWeight.normal,
                  color: commencee ? Colors.orange : Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              commencee ? "${index + 1}/${segments.length}" : "${segments.length} étapes",
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(ChapeletMystery mystery) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionItem(Icons.brightness_high, "Changer\nde mystères", Colors.orange, onTap: _showMysteriesSelection),
                _buildDivider(),
                _buildActionItem(Icons.menu_book, "Voir le texte\ndes prières", Colors.grey.shade700, onTap: () => _showPrieresTexte(mystery)),
                _buildDivider(),
                _buildActionItem(
                  Icons.favorite_border,
                  "Déposer une\nintention",
                  const Color(0xFFFF5252),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateIntentionScreen()),
                  ),
                ),
              ],
            ),
            if (_currentStep == 5) ...[
              const SizedBox(height: 15),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid != null) {
                        bool success = await _firestoreService.validerJourDePriere(uid);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? "Félicitations ! Votre journée de prière est validée ! 🎉" : "Vous avez déjà validé votre journée de prière aujourd'hui."),
                              backgroundColor: success ? Colors.green : Colors.orange,
                            ),
                          );
                          Navigator.pop(context); // Retour à l'écran précédent
                        }
                      }
                    },
                    child: const Text("Terminer mon chapelet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  /// Signet du mystère en cours, adossé aux favoris de l'utilisateur.
  Widget _buildBookmarkButton(ChapeletMystery mystery) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const IconButton(
        icon: Icon(Icons.bookmark_border, color: Colors.grey),
        onPressed: null,
      );
    }

    return StreamBuilder<List<Favori>>(
      stream: _firestoreService.getUserFavoris(uid),
      builder: (context, snapshot) {
        final favoris = snapshot.data ?? [];
        final isFavori = favoris.any((f) => f.type == 'priere' && f.title == mystery.name);

        return IconButton(
          icon: Icon(
            isFavori ? Icons.bookmark : Icons.bookmark_border,
            color: isFavori ? Colors.orange : const Color(0xFF0F172A),
          ),
          tooltip: isFavori ? "Retirer des favoris" : "Ajouter aux favoris",
          onPressed: () async {
            final ajoute = await _firestoreService.toggleFavori(
              uid,
              Favori(
                id: '',
                title: mystery.name,
                imageUrl: mystery.imageUrl.isNotEmpty ? mystery.imageUrl : 'assets/images/chapelet.png.jpg',
                type: 'priere',
                reference: mystery.reference,
              ),
            );
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ajoute ? "Ajouté à tes favoris ⭐" : "Retiré de tes favoris"),
                backgroundColor: ajoute ? Colors.orange : Colors.grey,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  void _showMoreMenu(ChapeletMystery mystery) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined, color: Color(0xFF0F172A)),
              title: const Text("Partager ce mystère"),
              onTap: () {
                Navigator.pop(sheetContext);
                ShareService.shareVerse(
                  reference: "${mystery.name} — ${mystery.reference}",
                  text: mystery.description,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_high, color: Colors.orange),
              title: const Text("Changer de mystères"),
              onTap: () {
                Navigator.pop(sheetContext);
                _showMysteriesSelection();
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book, color: Color(0xFF0F172A)),
              title: const Text("Voir le texte des prières"),
              onTap: () {
                Navigator.pop(sheetContext);
                _showPrieresTexte(mystery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Texte des prières du chapelet. Le mystère médité vient de Firestore ; les
  /// prières qui l'encadrent sont les formules fixes du Rosaire.
  static const Map<String, String> _textesPrieres = {
    "Notre Père":
        "Notre Père, qui es aux cieux, que ton nom soit sanctifié, que ton règne vienne, "
        "que ta volonté soit faite sur la terre comme au ciel. Donne-nous aujourd'hui notre pain de ce jour. "
        "Pardonne-nous nos offenses, comme nous pardonnons aussi à ceux qui nous ont offensés. "
        "Et ne nous laisse pas entrer en tentation, mais délivre-nous du Mal. Amen.",
    "Je vous salue Marie":
        "Je vous salue Marie, pleine de grâce, le Seigneur est avec vous. "
        "Vous êtes bénie entre toutes les femmes et Jésus, le fruit de vos entrailles, est béni. "
        "Sainte Marie, Mère de Dieu, priez pour nous pauvres pécheurs, maintenant et à l'heure de notre mort. Amen.",
    "Gloire au Père":
        "Gloire au Père, et au Fils, et au Saint-Esprit, comme il était au commencement, "
        "maintenant et toujours, pour les siècles des siècles. Amen.",
    "Prière de Fatima":
        "Ô mon Jésus, pardonnez-nous nos péchés, préservez-nous du feu de l'enfer, "
        "et conduisez au ciel toutes les âmes, spécialement celles qui ont le plus besoin de votre miséricorde. Amen.",
  };

  void _showPrieresTexte(ChapeletMystery mystery) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Texte des prières",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mystère médité — ${mystery.name}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                  ),
                  if (mystery.reference.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(mystery.reference, style: const TextStyle(fontSize: 12, color: Colors.orange)),
                  ],
                  const SizedBox(height: 10),
                  Text(mystery.description, style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ..._textesPrieres.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 6),
                    Text(entry.value, style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.black87)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color iconColor, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF0F172A), height: 1.2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
