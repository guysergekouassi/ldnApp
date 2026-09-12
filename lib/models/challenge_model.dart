class Challenge {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final int participants;
  final int durationDays;

  Challenge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.participants,
    required this.durationDays,
  });

  factory Challenge.fromFirestore(Map<String, dynamic> data, String id) {
    return Challenge(
      id: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      participants: data['participants'] ?? 0,
      durationDays: data['durationDays'] ?? 0,
    );
  }
}
