import 'package:cloud_firestore/cloud_firestore.dart';

/// Avis déposé à la fin d'un parcours, dans `parcours_avis`.
///
/// L'identifiant du document est `<parcoursId>__<uid>` : un membre n'a qu'un
/// avis par parcours, et on peut le relire sans requête.
class AvisParcours {
  final String id;
  final String parcoursId;
  final String authorUid;
  final String authorName;

  /// Note de 1 à 5.
  final int note;

  /// Clé de [PointsFortsParcours.libelles] : ce qui a le plus aidé.
  final String pointFort;

  final String commentaire;
  final bool recommande;
  final DateTime? createdAt;

  AvisParcours({
    required this.id,
    required this.parcoursId,
    required this.authorUid,
    required this.authorName,
    required this.note,
    required this.pointFort,
    required this.commentaire,
    required this.recommande,
    this.createdAt,
  });

  static String documentId(String parcoursId, String uid) => '${parcoursId}__$uid';

  factory AvisParcours.fromFirestore(Map<String, dynamic> data, String id) {
    return AvisParcours(
      id: id,
      parcoursId: (data['parcoursId'] ?? '').toString().trim(),
      authorUid: (data['authorUid'] ?? '').toString().trim(),
      authorName: (data['authorName'] ?? 'Un membre').toString().trim(),
      note: (data['note'] as num?)?.toInt().clamp(1, 5) ?? 3,
      pointFort: (data['pointFort'] ?? '').toString().trim(),
      commentaire: (data['commentaire'] ?? '').toString().trim(),
      recommande: data['recommande'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Ce qui a le plus aidé pendant le parcours.
class PointsFortsParcours {
  static const Map<String, String> libelles = {
    'contenu': "La qualité du contenu",
    'rythme': "Le rythme, un jour à la fois",
    'concret': "Les applications concrètes",
    'priere': "Les temps de prière proposés",
    'regularite': "Le fait d'être tenu à la régularité",
  };

  static String libelle(String cle) => libelles[cle] ?? "Autre";
}

/// Synthèse des avis d'un parcours, calculée côté client : le nombre d'avis
/// reste modeste, et cela évite d'entretenir un agrégat qui pourrait diverger.
class ResumeAvis {
  final int nombre;
  final double moyenne;
  final int recommandations;

  const ResumeAvis({
    required this.nombre,
    required this.moyenne,
    required this.recommandations,
  });

  static const ResumeAvis vide = ResumeAvis(nombre: 0, moyenne: 0, recommandations: 0);

  factory ResumeAvis.depuis(List<AvisParcours> avis) {
    if (avis.isEmpty) return vide;
    final total = avis.fold<int>(0, (somme, a) => somme + a.note);
    return ResumeAvis(
      nombre: avis.length,
      moyenne: total / avis.length,
      recommandations: avis.where((a) => a.recommande).length,
    );
  }

  /// Part de membres qui recommandent, entre 0 et 1.
  double get tauxRecommandation => nombre == 0 ? 0 : recommandations / nombre;
}
