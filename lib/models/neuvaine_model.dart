class NeuvaineDay {
  final int dayNumber;
  final String title;
  final String prayerText;

  NeuvaineDay({
    required this.dayNumber,
    required this.title,
    required this.prayerText,
  });

  factory NeuvaineDay.fromMap(Map<String, dynamic> data) {
    return NeuvaineDay(
      dayNumber: data['dayNumber'] ?? 1,
      title: (data['title'] ?? '').toString().trim(),
      prayerText: (data['prayerText'] ?? '').toString().trim(),
    );
  }
}

/// Classification des neuvaines, sur deux axes de nature différente.
///
/// Le destinataire est unique (on s'adresse à une seule personne), l'intention
/// est multiple (une même neuvaine répond souvent à plusieurs besoins). C'est
/// l'intention que l'on cherche en pratique — « une neuvaine pour la guérison »
/// — le destinataire sert surtout à parcourir le catalogue.
class NeuvaineTaxonomie {
  /// À qui la neuvaine s'adresse. Une seule valeur par neuvaine.
  static const Map<String, String> destinataires = {
    'marie': 'Vierge Marie',
    'jesus': 'Jésus',
    'esprit': 'Esprit Saint',
    'saints': 'Saints & Anges',
  };

  /// Pourquoi on la prie. Plusieurs valeurs possibles par neuvaine.
  static const Map<String, String> intentions = {
    'guerison': 'Guérison',
    'protection': 'Protection',
    'situations_bloquees': 'Situations bloquées',
    'causes_desesperees': 'Causes désespérées',
    'discernement': 'Discernement',
    'conversion': 'Conversion',
    'confiance': 'Confiance & abandon',
    'miracles': 'Miracles & objets perdus',
  };

  static String libelleDestinataire(String cle) => destinataires[cle] ?? 'Autre';
  static String libelleIntention(String cle) => intentions[cle] ?? cle;
}

class Neuvaine {
  final String id;
  final String title; // ex: "Neuvaine à Marie"
  final String subtitle; // ex: "qui défait les nœuds"
  final String description;
  final String imageUrl; // ex: "assets/mary_praying.png"
  final List<NeuvaineDay> days;

  /// Clé de [NeuvaineTaxonomie.destinataires]. Vide si la neuvaine n'a pas
  /// encore été classée.
  final String recipient;

  /// Clés de [NeuvaineTaxonomie.intentions]. Liste vide si non classée.
  final List<String> intentions;

  Neuvaine({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.days,
    this.recipient = '',
    this.intentions = const [],
  });

  factory Neuvaine.fromFirestore(Map<String, dynamic> data, String id) {
    List<NeuvaineDay> parsedDays = [];
    if (data['days'] != null && data['days'] is List) {
      parsedDays = (data['days'] as List).map((dayData) => NeuvaineDay.fromMap(dayData as Map<String, dynamic>)).toList();
      
      // Ensure they are sorted by day number
      parsedDays.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    }

    return Neuvaine(
      id: id,
      title: (data['title'] ?? '').toString().trim(),
      subtitle: (data['subtitle'] ?? '').toString().trim(),
      description: (data['description'] ?? '').toString().trim(),
      imageUrl: (data['imageUrl'] ?? 'assets/sunset_bg.jpg').toString().trim(),
      days: parsedDays,
      // Valeurs de repli : les documents déjà en base sans classification
      // doivent continuer à s'afficher, pas disparaître des listes.
      recipient: (data['recipient'] ?? '').toString().trim(),
      intentions: data['intentions'] is List
          ? List<String>.from((data['intentions'] as List).map((e) => e.toString().trim()))
          : const [],
    );
  }
}
