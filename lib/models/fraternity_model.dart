/// Un groupe local : fratrie de quartier, groupe de prière, équipe de jeunes…
///
/// Le modèle s'appelle encore `Fraternity` parce que la collection Firestore
/// `fraternities` porte ce nom depuis la première version ; il décrit
/// désormais tous les types de groupes proposés dans « Rejoins un groupe ».
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

  /// Clé de [TypeGroupe.libelles]. Vide si le groupe n'est pas classé.
  final String type;

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
    this.type = '',
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
      type: (data['type'] ?? '').toString().trim(),
      // Un groupe sans le champ est considéré ouvert : c'était le
      // comportement avant que le champ n'existe.
      ouvert: data['ouvert'] ?? true,
    );
  }
}

/// Familles de groupes proposées dans l'annuaire.
class TypeGroupe {
  static const Map<String, String> libelles = {
    'fratrie': 'Fratrie de quartier',
    'priere': 'Groupe de prière',
    'jeunes': 'Jeunes & étudiants',
    'couples': 'Couples & familles',
    'service': 'Équipe de service',
    'ligne': 'En ligne',
  };

  static const Map<String, String> icones = {
    'fratrie': 'people_outline',
    'priere': 'volunteer_activism',
    'jeunes': 'school_outlined',
    'couples': 'favorite_border',
    'service': 'handshake_outlined',
    'ligne': 'wifi',
  };

  static String libelle(String cle) => libelles[cle] ?? 'Groupe';

  static String icone(String cle) => icones[cle] ?? 'people_outline';
}
