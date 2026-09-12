class Office {
  final String id;
  final String title;
  final String subtitle;
  final String timeRange;
  final String iconName;
  final int order;
  final String hymn;
  final String psalms;
  final String lecture;
  final String prayer;
  final String antiphon;
  final String colorHex;

  Office({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeRange,
    required this.iconName,
    required this.order,
    required this.hymn,
    required this.psalms,
    required this.lecture,
    required this.prayer,
    required this.antiphon,
    required this.colorHex,
  });

  factory Office.fromFirestore(Map<String, dynamic> data, String id) {
    // Nettoyer les clés pour éviter les bugs si un espace a été tapé par erreur dans Firebase
    final cleanData = <String, dynamic>{};
    data.forEach((key, value) {
      cleanData[key.trim()] = value;
    });

    return Office(
      id: id,
      title: cleanData['title']?.toString().trim() ?? '',
      subtitle: cleanData['subtitle']?.toString().trim() ?? '',
      timeRange: cleanData['timeRange']?.toString().trim() ?? '',
      iconName: cleanData['icon']?.toString().trim() ?? 'brightness_high',
      order: int.tryParse(cleanData['order'].toString()) ?? 0,
      hymn: cleanData['hymn']?.toString() ?? '',
      psalms: cleanData['psalms']?.toString() ?? '',
      lecture: cleanData['lecture']?.toString() ?? '',
      prayer: cleanData['prayer']?.toString() ?? '',
      antiphon: cleanData['antiphon']?.toString() ?? '',
      colorHex: cleanData['colorHex']?.toString().trim() ?? '#F05B3A',
    );
  }
}
