class AppResource {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String actionText;
  final String? price;

  AppResource({required this.id, required this.title, required this.description, this.imageUrl, required this.actionText, this.price});

  factory AppResource.fromFirestore(Map<String, dynamic> data, String id) {
    return AppResource(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      actionText: data['actionText'] ?? 'Découvrir',
      price: data['price'],
    );
  }
}
