import 'package:cloud_firestore/cloud_firestore.dart';

/// Rythme attendu d'un engagement de la règle de vie.
enum FrequenceEngagement { quotidien, hebdomadaire, mensuel }

extension FrequenceEngagementLibelle on FrequenceEngagement {
  String get libelle {
    switch (this) {
      case FrequenceEngagement.quotidien:
        return "Chaque jour";
      case FrequenceEngagement.hebdomadaire:
        return "Chaque semaine";
      case FrequenceEngagement.mensuel:
        return "Chaque mois";
    }
  }

  /// Nombre d'occurrences attendues sur une fenêtre de [jours] jours.
  /// Sert à calculer un taux de fidélité comparable d'un engagement à l'autre.
  int occurrencesAttenduesSur(int jours) {
    switch (this) {
      case FrequenceEngagement.quotidien:
        return jours;
      case FrequenceEngagement.hebdomadaire:
        return (jours / 7).ceil();
      case FrequenceEngagement.mensuel:
        return (jours / 30).ceil();
    }
  }
}

/// Un engagement proposé dans la règle de vie. Le catalogue est figé dans le
/// code : ce sont des pratiques stables, pas du contenu éditorial à saisir.
class EngagementSpirituel {
  final String id;
  final String titre;
  final String description;
  final String iconName;
  final FrequenceEngagement frequence;

  const EngagementSpirituel({
    required this.id,
    required this.titre,
    required this.description,
    required this.iconName,
    required this.frequence,
  });
}

/// Règle de vie choisie par le membre, dans `users/{uid}/stats/discipline`.
///
/// Un document unique plutôt qu'une sous-collection : la liste est courte, et
/// un seul flux suffit à alimenter toute la vue Membre.
class DisciplineMembre {
  final List<String> engagementIds;
  final DateTime? misAJourLe;

  const DisciplineMembre({required this.engagementIds, this.misAJourLe});

  factory DisciplineMembre.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const DisciplineMembre(engagementIds: []);
    return DisciplineMembre(
      engagementIds: (data['engagements'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      misAJourLe: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  bool contient(String id) => engagementIds.contains(id);

  bool get estDefinie => engagementIds.isNotEmpty;
}

/// Ce qui a été tenu un jour donné, dans
/// `users/{uid}/discipline_progress/{AAAA-MM-JJ}`.
class JourneeDiscipline {
  final String jour;
  final List<String> engagementsTenus;

  const JourneeDiscipline({required this.jour, required this.engagementsTenus});

  factory JourneeDiscipline.fromFirestore(Map<String, dynamic>? data, String id) {
    return JourneeDiscipline(
      jour: id,
      engagementsTenus: (data?['engagements'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

/// Palier de membre, déduit des données et non stocké : il ne peut donc jamais
/// contredire ce que le membre vit réellement dans l'application.
enum StatutMembre { invite, membre, engage, pilier }

extension StatutMembreLibelle on StatutMembre {
  String get libelle {
    switch (this) {
      case StatutMembre.invite:
        return "Invité";
      case StatutMembre.membre:
        return "Membre";
      case StatutMembre.engage:
        return "Membre engagé";
      case StatutMembre.pilier:
        return "Pilier de la communauté";
    }
  }

  String get description {
    switch (this) {
      case StatutMembre.invite:
        return "Tu découvres l'application. Crée ton compte pour garder ta progression.";
      case StatutMembre.membre:
        return "Choisis ta règle de vie pour devenir membre engagé.";
      case StatutMembre.engage:
        return "Tu tiens une règle de vie. Continue, jour après jour.";
      case StatutMembre.pilier:
        return "Trente jours de fidélité consécutifs. Ta persévérance porte la communauté.";
    }
  }

  String get couleurHex {
    switch (this) {
      case StatutMembre.invite:
        return "#94A3B8";
      case StatutMembre.membre:
        return "#16A34A";
      case StatutMembre.engage:
        return "#5B4FC8";
      case StatutMembre.pilier:
        return "#D4A017";
    }
  }

  /// Palier atteint, à partir de faits vérifiables : un compte, une règle de
  /// vie d'au moins trois engagements, puis un mois de régularité.
  static StatutMembre calculer({
    required bool estInvite,
    required int nombreEngagements,
    required int streak,
  }) {
    if (estInvite) return StatutMembre.invite;
    if (nombreEngagements < 3) return StatutMembre.membre;
    if (streak >= 30) return StatutMembre.pilier;
    return StatutMembre.engage;
  }
}
