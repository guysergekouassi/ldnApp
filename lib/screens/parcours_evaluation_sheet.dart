import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/carnet_note_model.dart';
import '../models/parcours_avis_model.dart';
import '../services/firestore_service.dart';

/// Les cinq degrés d'appropriation proposés à la fin d'une étape.
///
/// La question n'est pas « as-tu compris ? » mais « où en es-tu ? » : un
/// parcours spirituel ne se vérifie pas par un QCM, et une échelle honnête
/// donne au membre un repère qu'un score ne donnerait pas.
const List<String> _degresAppropriation = [
  "Je découvre, c'est nouveau pour moi",
  "Je comprends, mais ça reste théorique",
  "Ça me rejoint, j'ai de quoi méditer",
  "Je commence à le mettre en pratique",
  "C'est devenu concret dans ma vie",
];

/// Évaluation de fin d'étape. Renvoie true si le membre a enregistré.
Future<bool?> showEvaluationEtape(
  BuildContext context, {
  required String parcoursId,
  required String parcoursTitle,
  required String lessonTitle,
  required int jour,
  required Color couleur,
}) {
  if (FirebaseAuth.instance.currentUser == null) return Future.value(null);

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // Le membre doit pouvoir passer : une évaluation obligatoire ferait
    // abandonner le parcours plus vite qu'elle n'apporterait de données.
    isDismissible: true,
    builder: (_) => _EvaluationEtape(
      parcoursId: parcoursId,
      parcoursTitle: parcoursTitle,
      lessonTitle: lessonTitle,
      jour: jour,
      couleur: couleur,
    ),
  );
}

/// Avis de fin de parcours. Renvoie true si l'avis a été déposé.
Future<bool?> showAvisParcours(
  BuildContext context, {
  required String parcoursId,
  required String parcoursTitle,
  required Color couleur,
  AvisParcours? avisExistant,
}) {
  if (FirebaseAuth.instance.currentUser == null) return Future.value(null);

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AvisParcoursForm(
      parcoursId: parcoursId,
      parcoursTitle: parcoursTitle,
      couleur: couleur,
      avisExistant: avisExistant,
    ),
  );
}

Widget _poignee() {
  return Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

BoxDecoration _feuille() => const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    );

class _EvaluationEtape extends StatefulWidget {
  final String parcoursId;
  final String parcoursTitle;
  final String lessonTitle;
  final int jour;
  final Color couleur;

  const _EvaluationEtape({
    Key? key,
    required this.parcoursId,
    required this.parcoursTitle,
    required this.lessonTitle,
    required this.jour,
    required this.couleur,
  }) : super(key: key);

  @override
  State<_EvaluationEtape> createState() => _EvaluationEtapeState();
}

class _EvaluationEtapeState extends State<_EvaluationEtape> {
  final _retenuController = TextEditingController();

  int? _niveau;
  bool _versLeCarnet = true;
  bool _enregistrement = false;

  @override
  void dispose() {
    _retenuController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _niveau == null) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _enregistrement = true);

    final retenu = _retenuController.text.trim();
    final service = FirestoreService();

    try {
      await service.enregistrerEvaluationEtape(
        uid,
        widget.parcoursId,
        widget.jour,
        niveau: _niveau!,
        retenu: retenu,
      );

      // Ce que le membre retient a plus de valeur dans son carnet que perdu au
      // fond d'un document de progression.
      if (_versLeCarnet && retenu.isNotEmpty) {
        await service.addCarnetNote(
          uid,
          CarnetNote(
            id: '',
            type: 'meditation',
            title: "${widget.parcoursTitle} — jour ${widget.jour}",
            content: retenu,
            tags: const ['parcours'],
            date: DateTime.now(),
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      messenger.showSnackBar(
        const SnackBar(content: Text("C'est noté. À demain 🙏"), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _enregistrement = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Enregistrement impossible. Vérifie ta connexion."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: _feuille(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _poignee(),
              const SizedBox(height: 18),
              Text(
                "Jour ${widget.jour} validé",
                style: TextStyle(color: widget.couleur, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              const Text(
                "Où en es-tu avec ce que tu viens de lire ?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0F172A), height: 1.3),
              ),
              const SizedBox(height: 4),
              const Text(
                "Il n'y a pas de bonne réponse. C'est un repère pour toi.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ...List.generate(_degresAppropriation.length, (i) => _buildDegre(i + 1)),
              const SizedBox(height: 14),
              TextField(
                controller: _retenuController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: "Une chose que je retiens (facultatif)",
                  hintText: "Une phrase, un mot, une résolution…",
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  counterText: "",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.couleur),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => setState(() => _versLeCarnet = !_versLeCarnet),
                child: Row(
                  children: [
                    Icon(
                      _versLeCarnet ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 20,
                      color: _versLeCarnet ? widget.couleur : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Garder cette note dans mon carnet spirituel",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.couleur,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: (_niveau == null || _enregistrement) ? null : _enregistrer,
                  child: _enregistrement
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          "Enregistrer",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                child: const Text("Passer", style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDegre(int niveau) {
    final choisi = _niveau == niveau;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _niveau = niveau),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: choisi ? widget.couleur.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: choisi ? widget.couleur : const Color(0xFFE5E7EB),
              width: choisi ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: choisi ? widget.couleur : Colors.transparent,
                  border: Border.all(color: choisi ? widget.couleur : Colors.grey.shade300, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$niveau",
                  style: TextStyle(
                    color: choisi ? Colors.white : Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _degresAppropriation[niveau - 1],
                  style: TextStyle(
                    fontSize: 12.5,
                    color: const Color(0xFF0F172A),
                    fontWeight: choisi ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvisParcoursForm extends StatefulWidget {
  final String parcoursId;
  final String parcoursTitle;
  final Color couleur;
  final AvisParcours? avisExistant;

  const _AvisParcoursForm({
    Key? key,
    required this.parcoursId,
    required this.parcoursTitle,
    required this.couleur,
    this.avisExistant,
  }) : super(key: key);

  @override
  State<_AvisParcoursForm> createState() => _AvisParcoursFormState();
}

class _AvisParcoursFormState extends State<_AvisParcoursForm> {
  late final _commentaireController =
      TextEditingController(text: widget.avisExistant?.commentaire ?? '');

  late int _note = widget.avisExistant?.note ?? 0;
  late String _pointFort = widget.avisExistant?.pointFort ?? '';
  late bool _recommande = widget.avisExistant?.recommande ?? true;
  bool _enregistrement = false;

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _note == 0) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _enregistrement = true);

    try {
      await FirestoreService().enregistrerAvisParcours(
        uid,
        widget.parcoursId,
        note: _note,
        pointFort: _pointFort,
        commentaire: _commentaireController.text,
        recommande: _recommande,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Merci ! Ton avis aidera les prochains 🙏"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _enregistrement = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Envoi impossible. Vérifie ta connexion."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: _feuille(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _poignee(),
              const SizedBox(height: 18),
              Text(
                widget.avisExistant == null ? "PARCOURS TERMINÉ" : "MODIFIER MON AVIS",
                style: TextStyle(color: widget.couleur, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              Text(
                widget.parcoursTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0F172A), height: 1.3),
              ),
              const SizedBox(height: 4),
              const Text(
                "Ton retour sert à deux choses : améliorer le parcours, et aider ceux qui hésitent à le commencer.",
                style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 18),
              const Text(
                "Ta note",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                  (i) => IconButton(
                    padding: const EdgeInsets.only(right: 4),
                    constraints: const BoxConstraints(),
                    splashRadius: 22,
                    icon: Icon(
                      i < _note ? Icons.star : Icons.star_border,
                      color: i < _note ? const Color(0xFFD4A017) : Colors.grey.shade400,
                      size: 34,
                    ),
                    onPressed: () => setState(() => _note = i + 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Qu'est-ce qui t'a le plus aidé ?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PointsFortsParcours.libelles.entries
                    .map((e) => _buildPuce(e.key, e.value))
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentaireController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                maxLength: 800,
                decoration: InputDecoration(
                  labelText: "Ton commentaire (facultatif)",
                  hintText: "Ce qui t'a marqué, ce qui manquait…",
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  counterText: "",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.couleur),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => setState(() => _recommande = !_recommande),
                child: Row(
                  children: [
                    Icon(
                      _recommande ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 20,
                      color: _recommande ? widget.couleur : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Je recommande ce parcours à d'autres",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.couleur,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: (_note == 0 || _enregistrement) ? null : _enregistrer,
                  child: _enregistrement
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _note == 0 ? "Choisis une note" : "Envoyer mon avis",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                child: const Text("Plus tard", style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPuce(String cle, String libelle) {
    final choisi = _pointFort == cle;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _pointFort = choisi ? '' : cle),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: choisi ? widget.couleur : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: choisi ? widget.couleur : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          libelle,
          style: TextStyle(
            color: choisi ? Colors.white : Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
