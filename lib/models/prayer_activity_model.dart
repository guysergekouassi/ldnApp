/// Une entrée de la grille « Comment veux-tu rencontrer le Seigneur ? »
/// (écran Prions ensemble), pilotée par la collection `prayer_activities`.
class PrayerActivity {
  final String id;
  final String title;

  /// Durée indicative affichée sur la carte (« 20 min », « 9 jours »…).
  /// Éditable dans Firestore : c'est une estimation éditoriale, pas une mesure.
  final String duration;

  final String imageAsset;
  final String iconName;
  final String colorHex;

  /// Clé de destination, résolue par l'écran (`chapelet`, `office`, `evangile`,
  /// `neuvaines`, `confession`, `intentions`).
  final String action;

  final int order;

  PrayerActivity({
    required this.id,
    required this.title,
    required this.duration,
    required this.imageAsset,
    required this.iconName,
    required this.colorHex,
    required this.action,
    required this.order,
  });

  factory PrayerActivity.fromFirestore(Map<String, dynamic> data, String id) {
    return PrayerActivity(
      id: id,
      title: data['title'] ?? '',
      duration: data['duration'] ?? '',
      imageAsset: data['imageAsset'] ?? 'assets/sunset_bg.jpg',
      iconName: data['iconName'] ?? 'self_improvement',
      colorHex: data['colorHex'] ?? '#FFA500',
      action: data['action'] ?? '',
      order: data['order'] ?? 99,
    );
  }
}
