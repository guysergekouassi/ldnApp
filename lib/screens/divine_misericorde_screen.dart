import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/ldn_signature.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/share_service.dart';
import '../services/temps_liturgique.dart';
import 'neuvaines_screen.dart';

/// Portail de la Divine Miséricorde : le chapelet, l'Heure de la Miséricorde
/// (15 h) et la neuvaine confiée à sainte Faustine.
class DivineMisericordeScreen extends StatefulWidget {
  const DivineMisericordeScreen({Key? key}) : super(key: key);

  @override
  State<DivineMisericordeScreen> createState() => _DivineMisericordeScreenState();
}

class _DivineMisericordeScreenState extends State<DivineMisericordeScreen> {
  /// Clé du rappel de 15 h. Le choix est propre à l'appareil, comme les autres
  /// réglages de notification : il n'a pas à voyager d'un téléphone à l'autre.
  static const String _clePreferenceRappel = 'rappelHeureMisericorde';

  static const Color _violet = Color(0xFF5B4FC8);

  final FirestoreService _firestoreService = FirestoreService();

  bool _rappelActif = false;
  bool _reglageCharge = false;

  @override
  void initState() {
    super.initState();
    _chargerReglage();
  }

  Future<void> _chargerReglage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _rappelActif = prefs.getBool(_clePreferenceRappel) ?? false;
      _reglageCharge = true;
    });
  }

  Future<void> _basculerRappel(bool actif) async {
    // On demande l'autorisation avant d'enregistrer : sans elle, le réglage
    // afficherait « activé » sans qu'aucune notification n'arrive jamais.
    if (actif) {
      final autorise = await NotificationService().requestPermissions();
      if (!autorise) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Autorise les notifications pour recevoir ce rappel."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    await NotificationService().syncHeureDeLaMisericorde(actif);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clePreferenceRappel, actif);

    if (!mounted) return;
    setState(() => _rappelActif = actif);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(actif
            ? "Rappel activé : chaque jour à 15 h."
            : "Rappel de 15 h désactivé."),
        backgroundColor: actif ? Colors.green : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildFeteCard(),
                  const SizedBox(height: 15),
                  _buildChapeletCard(),
                  const SizedBox(height: 15),
                  _buildHeureCard(),
                  const SizedBox(height: 15),
                  _buildNeuvaineCard(),
                  const SizedBox(height: 10),
                  const LdnSignature(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_violet, Color(0xFF3B2F9E)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                IconButton(
                  tooltip: "Partager",
                  icon: const Icon(Icons.ios_share, color: Colors.white, size: 20),
                  onPressed: () => ShareService.shareVerse(
                    reference: "Petit Journal de sainte Faustine",
                    text: "Jésus, j'ai confiance en Toi.",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              "Divine Miséricorde",
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "« Jésus, j'ai confiance en Toi. »",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "La dévotion transmise par sainte Faustine Kowalska.",
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Compte à rebours vers la fête, fixée au 2ᵉ dimanche de Pâques.
  Widget _buildFeteCard() {
    final aujourdHui = CalendrierLiturgique.jourSeul(DateTime.now());
    var fete = CalendrierLiturgique.divineMisericorde(aujourdHui.year);
    if (fete.isBefore(aujourdHui)) {
      fete = CalendrierLiturgique.divineMisericorde(aujourdHui.year + 1);
    }
    final jours = fete.difference(aujourdHui).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.event, color: _violet, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Fête de la Divine Miséricorde",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 3),
                Text(
                  jours == 0
                      ? "C'est aujourd'hui : le 2ᵉ dimanche de Pâques."
                      : "Dans $jours jour${jours > 1 ? 's' : ''} — le ${_formatDate(fete)}.",
                  style: const TextStyle(color: Colors.black54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";

  Widget _buildChapeletCard() {
    return _buildCarte(
      icone: Icons.brightness_high,
      titre: "Chapelet de la Divine Miséricorde",
      sousTitre: "Environ 12 minutes · guidé pas à pas",
      description:
          "Se prie sur un chapelet ordinaire : « Père Éternel… » sur les gros grains, "
          "« Par sa douloureuse Passion… » sur les dix petits.",
      libelleBouton: "Prier le chapelet",
      onTap: () async {
        final enregistre = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const ChapeletMisericordeScreen()),
        );
        if (enregistre == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Chapelet achevé. Que sa miséricorde te garde 🙏"),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  Widget _buildHeureCard() {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.schedule, color: _violet, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "L'Heure de la Miséricorde",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                ),
              ),
              if (_reglageCharge)
                Switch(
                  value: _rappelActif,
                  activeColor: _violet,
                  onChanged: _basculerRappel,
                )
              else
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _violet),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "À 15 h, l'heure de la mort du Christ, arrête-toi un instant : un signe de croix, "
            "une pensée pour le monde, et « Jésus, j'ai confiance en Toi ».",
            style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
          ),
          if (_rappelActif) ...[
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.notifications_active_outlined, color: Colors.green, size: 14),
                SizedBox(width: 6),
                Text(
                  "Rappel quotidien programmé à 15 h",
                  style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNeuvaineCard() {
    return _buildCarte(
      icone: Icons.local_fire_department_outlined,
      titre: "Neuvaine à la Divine Miséricorde",
      sousTitre: "9 jours · les intentions confiées à sainte Faustine",
      description:
          "Chaque jour, une catégorie d'âmes est présentée au Père : les pécheurs, les prêtres, "
          "ceux qui ne croient pas encore, les âmes du purgatoire…",
      libelleBouton: "Ouvrir la neuvaine",
      onTap: _ouvrirNeuvaine,
    );
  }

  /// Ouvre la neuvaine correspondante dans le catalogue.
  ///
  /// Elle est retrouvée par son titre : son identifiant Firestore est généré à
  /// l'insertion et diffère donc d'une installation à l'autre.
  Future<void> _ouvrirNeuvaine() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final neuvaines = await _firestoreService.getNeuvaines().first;
      final trouvees = neuvaines.where(
        (n) => n.title.toLowerCase().contains('miséricorde'),
      );

      if (trouvees.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text("La neuvaine n'est pas encore disponible. Réessaie après un redémarrage."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      navigator.push(
        MaterialPageRoute(builder: (_) => NeuvainesScreen(neuvaine: trouvees.first)),
      );
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Chargement impossible. Vérifie ta connexion."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCarte({
    required IconData icone,
    required String titre,
    required String sousTitre,
    required String description,
    required String libelleBouton,
    required VoidCallback onTap,
  }) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: _violet, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(sousTitre, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _violet,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onTap,
              child: Text(
                libelleBouton,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Une étape du chapelet : un texte, répété autant de fois que le grain le
/// demande (dix pour les petits grains d'une dizaine, trois pour le Trisagion).
class _EtapeChapelet {
  final String titre;
  final String texte;
  final int repetitions;

  const _EtapeChapelet(this.titre, this.texte, {this.repetitions = 1});
}

/// Chapelet de la Divine Miséricorde, guidé grain par grain.
///
/// Sa structure n'est pas celle du Rosaire : pas de mystères à méditer, mais
/// deux invocations reprises sur cinq dizaines. Il a donc son propre écran
/// plutôt qu'un type de mystère ajouté au chapelet marial.
class ChapeletMisericordeScreen extends StatefulWidget {
  const ChapeletMisericordeScreen({Key? key}) : super(key: key);

  @override
  State<ChapeletMisericordeScreen> createState() => _ChapeletMisericordeScreenState();
}

class _ChapeletMisericordeScreenState extends State<ChapeletMisericordeScreen> {
  static const Color _violet = Color(0xFF5B4FC8);

  late final List<_EtapeChapelet> _etapes = _construireEtapes();

  int _index = 0;

  /// Rang de la répétition en cours dans l'étape, à partir de 1.
  int _repetition = 1;

  bool _enregistrement = false;

  static const String _perePeternel =
      "Père Éternel, je t'offre le Corps et le Sang, l'Âme et la Divinité de ton Fils bien-aimé, "
      "Notre Seigneur Jésus-Christ, en réparation pour nos péchés et ceux du monde entier.";

  static const String _douloureusePassion =
      "Par sa douloureuse Passion, sois miséricordieux pour nous et pour le monde entier.";

  List<_EtapeChapelet> _construireEtapes() {
    return [
      const _EtapeChapelet(
        "Signe de croix",
        "Au nom du Père, et du Fils, et du Saint-Esprit. Amen.",
      ),
      const _EtapeChapelet(
        "Notre Père",
        "Notre Père, qui es aux cieux, que ton nom soit sanctifié, que ton règne vienne, "
        "que ta volonté soit faite sur la terre comme au ciel. Donne-nous aujourd'hui notre pain de ce jour. "
        "Pardonne-nous nos offenses, comme nous pardonnons aussi à ceux qui nous ont offensés. "
        "Et ne nous laisse pas entrer en tentation, mais délivre-nous du Mal. Amen.",
      ),
      const _EtapeChapelet(
        "Je vous salue Marie",
        "Je vous salue Marie, pleine de grâce, le Seigneur est avec vous. "
        "Vous êtes bénie entre toutes les femmes et Jésus, le fruit de vos entrailles, est béni. "
        "Sainte Marie, Mère de Dieu, priez pour nous pauvres pécheurs, maintenant et à l'heure de notre mort. Amen.",
      ),
      const _EtapeChapelet(
        "Je crois en Dieu",
        "Je crois en Dieu, le Père tout-puissant, créateur du ciel et de la terre ; "
        "et en Jésus-Christ, son Fils unique, notre Seigneur, qui a été conçu du Saint-Esprit, "
        "est né de la Vierge Marie, a souffert sous Ponce Pilate, a été crucifié, est mort et a été enseveli, "
        "est descendu aux enfers, le troisième jour est ressuscité des morts, est monté aux cieux, "
        "est assis à la droite de Dieu le Père tout-puissant, d'où il viendra juger les vivants et les morts. "
        "Je crois en l'Esprit Saint, à la sainte Église catholique, à la communion des saints, "
        "à la rémission des péchés, à la résurrection de la chair, à la vie éternelle. Amen.",
      ),
      // Cinq dizaines : un gros grain, puis dix petits.
      for (var dizaine = 1; dizaine <= 5; dizaine++) ...[
        _EtapeChapelet("$dizaineᵉ dizaine · gros grain", _perePeternel),
        _EtapeChapelet("$dizaineᵉ dizaine · petits grains", _douloureusePassion, repetitions: 10),
      ],
      const _EtapeChapelet(
        "Pour conclure",
        "Dieu Saint, Dieu Fort, Dieu Éternel, prends pitié de nous et du monde entier.",
        repetitions: 3,
      ),
      const _EtapeChapelet(
        "Prière finale",
        "Ô Sang et Eau qui avez jailli du Cœur de Jésus comme source de miséricorde pour nous, "
        "j'ai confiance en toi.",
        repetitions: 3,
      ),
    ];
  }

  /// Nombre total de grains, pour la barre de progression.
  int get _totalGrains =>
      _etapes.fold<int>(0, (total, etape) => total + etape.repetitions);

  int get _grainsFaits {
    var total = 0;
    for (var i = 0; i < _index; i++) {
      total += _etapes[i].repetitions;
    }
    return total + _repetition - 1;
  }

  bool get _estDerniereEtape => _index == _etapes.length - 1;

  void _suivant() {
    final etape = _etapes[_index];

    if (_repetition < etape.repetitions) {
      setState(() => _repetition++);
      return;
    }

    if (_estDerniereEtape) {
      _terminer();
      return;
    }

    setState(() {
      _index++;
      _repetition = 1;
    });
  }

  void _precedent() {
    if (_repetition > 1) {
      setState(() => _repetition--);
      return;
    }
    if (_index == 0) return;

    setState(() {
      _index--;
      // On revient sur la dernière répétition de l'étape précédente, pas sur
      // son début : sinon reculer d'un grain en referait dix.
      _repetition = _etapes[_index].repetitions;
    });
  }

  Future<void> _terminer() async {
    setState(() => _enregistrement = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await FirestoreService().validerJourDePriere(uid);
      } catch (e) {
        // La prière a bien eu lieu : un échec d'enregistrement ne doit pas
        // bloquer la sortie de l'écran.
        debugPrint("Enregistrement du jour de prière impossible : $e");
      }
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final etape = _etapes[_index];
    final progression = _totalGrains == 0 ? 0.0 : _grainsFaits / _totalGrains;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: _violet,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Chapelet de la Miséricorde",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: "Quitter le chapelet",
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progression,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(_violet),
              minHeight: 5,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      etape.titre.toUpperCase(),
                      style: const TextStyle(
                        color: _violet,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      etape.repetitions > 1
                          ? "Grain $_repetition sur ${etape.repetitions}"
                          : "Grain ${_grainsFaits + 1} sur $_totalGrains",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        etape.texte,
                        style: const TextStyle(fontSize: 16, height: 1.7, color: Color(0xFF0F172A)),
                      ),
                    ),
                    if (etape.repetitions > 1) ...[
                      const SizedBox(height: 20),
                      _buildGrains(etape.repetitions),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: (_index == 0 && _repetition == 1) ? null : _precedent,
                      child: const Icon(Icons.arrow_back, size: 20, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _violet,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _enregistrement ? null : _suivant,
                        child: _enregistrement
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _estDerniereEtape && _repetition == etape.repetitions
                                    ? "Terminer"
                                    : "Grain suivant",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chapelet des dix petits grains, pour situer le grain en cours d'un
  /// coup d'œil sans compter les répétitions.
  Widget _buildGrains(int total) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(total, (i) {
        final fait = i < _repetition;
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fait ? _violet : Colors.transparent,
            border: Border.all(color: fait ? _violet : Colors.grey.shade400, width: 1.5),
          ),
        );
      }),
    );
  }
}
