class ExamenItem {
  final String id;
  final String category; // 'dieu', 'prochain', 'soi'
  final String text;
  final int order;

  ExamenItem({
    required this.id,
    required this.category,
    required this.text,
    required this.order,
  });

  factory ExamenItem.fromFirestore(Map<String, dynamic> data, String id) {
    return ExamenItem(
      id: id,
      category: data['category']?.toString().trim() ?? 'dieu',
      text: data['text']?.toString() ?? '',
      order: int.tryParse(data['order'].toString()) ?? 0,
    );
  }
}
