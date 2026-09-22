import 'package:cloud_firestore/cloud_firestore.dart';

/// Nature de la demande adressée à l'équipe d'accompagnement.
class TypeDemandeEcoute {
  static const Map<String, String> libelles = {
    'ecoute': "Être écouté",
    'accompagnement': "Un accompagnement spirituel",
    'priere': "Être porté dans la prière",
    'question': "Poser une question sur la foi",
  };

  static const Map<String, String> descriptions = {
    'ecoute': "Parler à quelqu'un, une fois, sans engagement.",
    'accompagnement': "Être suivi dans la durée par un accompagnateur.",
    'priere': "Confier une intention, sans forcément en parler.",
    'question': "Une question de foi, de doctrine ou de morale.",
  };

  static String libelle(String cle) => libelles[cle] ?? "Demande";
}

/// Comment le membre souhaite être recontacté.
class MoyenDeContact {
  static const Map<String, String> libelles = {
    'app': "Dans l'application",
    'telephone': "Par téléphone",
    'whatsapp': "Par WhatsApp",
    'email': "Par email",
    'personne': "En personne, lors d'une rencontre",
  };

  static String libelle(String cle) => libelles[cle] ?? "Au choix";

  /// Vrai quand le moyen réclame une coordonnée saisie par le membre.
  static bool demandeUneCoordonnee(String cle) =>
      cle == 'telephone' || cle == 'whatsapp' || cle == 'email';
}

/// Avancement d'une demande, tel que l'équipe le met à jour.
class StatutDemande {
  static const String envoyee = 'envoyee';
  static const String priseEnCharge = 'prise_en_charge';
  static const String terminee = 'terminee';

  static String libelle(String cle) {
    switch (cle) {
      case priseEnCharge:
        return "Prise en charge";
      case terminee:
        return "Terminée";
      default:
        return "Envoyée";
    }
  }

  static String message(String cle) {
    switch (cle) {
      case priseEnCharge:
        return "Quelqu'un de l'équipe a pris ta demande. Tu seras recontacté.";
      case terminee:
        return "Cette demande est clôturée. Tu peux en déposer une nouvelle.";
      default:
        return "Ta demande est bien arrivée. L'équipe la lit sous quelques jours.";
    }
  }
}

/// Une demande d'écoute ou d'accompagnement, dans `demandes_ecoute`.
///
/// Ce sont des données sensibles : les règles Firestore n'en autorisent la
/// lecture qu'à leur auteur.
class DemandeEcoute {
  final String id;
  final String uid;
  final String type;
  final String sujet;
  final String message;
  final String moyenContact;
  final String coordonnee;
  final String statut;
  final DateTime? createdAt;

  /// Responsable qui a pris la demande en charge. Vide tant que personne ne
  /// s'en est saisi.
  final String traitePar;

  DemandeEcoute({
    required this.id,
    required this.uid,
    required this.type,
    required this.sujet,
    required this.message,
    required this.moyenContact,
    required this.coordonnee,
    required this.statut,
    this.createdAt,
    this.traitePar = '',
  });

  factory DemandeEcoute.fromFirestore(Map<String, dynamic> data, String id) {
    return DemandeEcoute(
      id: id,
      uid: (data['uid'] ?? '').toString().trim(),
      type: (data['type'] ?? 'ecoute').toString().trim(),
      sujet: (data['sujet'] ?? '').toString().trim(),
      message: (data['message'] ?? '').toString().trim(),
      moyenContact: (data['moyenContact'] ?? 'app').toString().trim(),
      coordonnee: (data['coordonnee'] ?? '').toString().trim(),
      statut: (data['statut'] ?? StatutDemande.envoyee).toString().trim(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      traitePar: (data['traitePar'] ?? '').toString().trim(),
    );
  }

  bool get estOuverte => statut != StatutDemande.terminee;
}
