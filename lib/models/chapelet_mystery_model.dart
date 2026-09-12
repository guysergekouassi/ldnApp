class ChapeletMystery {
  final String id;
  final String type;
  final int step;
  final String name;
  final String description;
  final String reference;
  final String imageUrl;
  final String audioUrl;

  ChapeletMystery({required this.id, required this.type, required this.step, required this.name, required this.description, required this.reference, required this.imageUrl, required this.audioUrl});

  factory ChapeletMystery.fromFirestore(Map<String, dynamic> data, String id) {
    return ChapeletMystery(
      id: id,
      type: (data['type'] ?? '').toString().trim(),
      step: int.tryParse(data['step'].toString()) ?? 1,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      reference: data['reference'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
    );
  }
}

