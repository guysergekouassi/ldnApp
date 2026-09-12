class Annonce {
  final String id;
  final String title;
  final String subtitle;
  final String colorHex;

  Annonce({required this.id, required this.title, required this.subtitle, required this.colorHex});

  factory Annonce.fromFirestore(Map<String, dynamic> data, String id) {
    return Annonce(
      id: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      colorHex: data['colorHex'] ?? '#000000',
    );
  }
}
