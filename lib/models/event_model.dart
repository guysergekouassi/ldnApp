class AppEvent {
  final String id;
  final String title;
  final String day;
  final String month;
  final String time;
  final String location;
  final String badge;
  final String imageUrl;

  AppEvent({required this.id, required this.title, required this.day, required this.month, required this.time, required this.location, required this.badge, required this.imageUrl});

  factory AppEvent.fromFirestore(Map<String, dynamic> data, String id) {
    return AppEvent(
      id: id,
      title: data['title'] ?? '',
      day: data['day'] ?? '',
      month: data['month'] ?? '',
      time: data['time'] ?? '',
      location: data['location'] ?? '',
      badge: data['badge'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
