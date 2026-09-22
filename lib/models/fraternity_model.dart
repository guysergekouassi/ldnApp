/// Une fratie de la communauté : Saint Michel, Divin Amour, Saint François,
/// Sacré-Cœur, Sainte Faustine.
///
/// « Fratie » est le mot de la communauté : c'est celui qui s'affiche, et non
/// « fraternité » ni « fratrie ».
///
/// Le modèle s'appelle encore `Fraternity` parce que la collection Firestore
/// `fraternities` porte ce nom depuis la première version.
///
/// Il n'y a plus de catégories de groupes : la communauté a cinq fraties
/// nommées, que l'on rejoint par leur nom. Classer cinq entrées par type
/// n'aidait personne et laissait croire à un annuaire qui s'étoffe.
class Fraternity {
  final String id;
  final String name;
  final String location;
  final int memberCount;
  final String nextMeetingDate;
  final String nextMeetingLocation;

  /// Champs ajoutés pour l'annuaire des groupes. Ils ont des valeurs de repli :
  /// le document semé par les premières versions ne les porte pas.
  final String description;

  /// Dates des prochaines rencontres, saisies à la main dans Firestore : la
  /// communauté se retrouve deux fois par mois, à des dates qui changent.
  ///
  /// Vide tant que personne ne les a renseignées. L'app le dit alors
  /// franchement plutôt que d'afficher une date inventée ou périmée.
  final List<String> rencontres;

  /// Faux quand le groupe est complet ou ne prend plus d'inscriptions.
  final bool ouvert;

  Fraternity({
    required this.id,
    required this.name,
    required this.location,
    required this.memberCount,
    required this.nextMeetingDate,
    required this.nextMeetingLocation,
    this.description = '',
    this.rencontres = const [],
    this.ouvert = true,
  });

  factory Fraternity.fromFirestore(Map<String, dynamic> data, String id) {
    return Fraternity(
      id: id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      memberCount: data['memberCount'] ?? 0,
      nextMeetingDate: data['nextMeetingDate'] ?? '',
      nextMeetingLocation: data['nextMeetingLocation'] ?? '',
      description: (data['description'] ?? '').toString().trim(),
      rencontres: (data['rencontres'] as List?)
              ?.map((d) => d.toString().trim())
              .where((d) => d.isNotEmpty)
              .toList() ??
          const [],
      // Un groupe sans le champ est considéré ouvert : c'était le
      // comportement avant que le champ n'existe.
      ouvert: data['ouvert'] ?? true,
    );
  }
}
