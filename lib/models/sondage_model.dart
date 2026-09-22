import 'package:cloud_firestore/cloud_firestore.dart';

/// Sondage de la semaine, dans la collection `sondages`.
///
/// Les voix sont un simple tableau de compteurs parallèle aux options : le
/// détail de qui a voté quoi reste dans `users/{uid}/votes`, hors de portée
/// des autres membres.
class Sondage {
  final String id;
  final String question;
  final String contexte;
  final List<String> options;
  final List<int> voix;

  /// Semaine de publication, au format `AAAA-Snn`. Le sondage affiché est
  /// celui de la semaine en cours.
  final String semaine;

  final DateTime? createdAt;

  Sondage({
    required this.id,
    required this.question,
    required this.contexte,
    required this.options,
    required this.voix,
    required this.semaine,
    this.createdAt,
  });

  factory Sondage.fromFirestore(Map<String, dynamic> data, String id) {
    final options = (data['options'] as List? ?? const [])
        .map((e) => e.toString())
        .toList();

    // Le tableau des voix est recalé sur celui des options : un sondage dont
    // on aurait ajouté une réponse après coup ne doit pas déborder.
    final brutes = (data['voix'] as List? ?? const [])
        .map((e) => int.tryParse(e.toString()) ?? 0)
        .toList();
    final voix = List<int>.generate(
      options.length,
      (i) => i < brutes.length ? brutes[i] : 0,
    );

    return Sondage(
      id: id,
      question: (data['question'] ?? '').toString().trim(),
      contexte: (data['contexte'] ?? '').toString().trim(),
      options: options,
      voix: voix,
      semaine: (data['semaine'] ?? '').toString().trim(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  int get totalVoix => voix.fold<int>(0, (total, v) => total + v);

  /// Part d'une option, entre 0 et 1. Vaut 0 tant que personne n'a voté.
  double partDe(int index) {
    if (totalVoix == 0 || index < 0 || index >= voix.length) return 0;
    return voix[index] / totalVoix;
  }
}
