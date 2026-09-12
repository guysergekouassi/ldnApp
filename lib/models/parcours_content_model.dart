class ParcoursContent {
  final String id;
  final String title;

  /// Métadonnées d'affichage du parcours dans « Grandir dans la foi ».
  final String subtitle;
  final String kicker;
  final String category;
  final String iconName;
  final String colorHex;
  final String imageAsset;
  final bool isNew;
  final int order;

  final List<ParcoursLessonContent> lessons;

  ParcoursContent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kicker,
    required this.category,
    required this.iconName,
    required this.colorHex,
    required this.imageAsset,
    required this.isNew,
    required this.order,
    required this.lessons,
  });

  factory ParcoursContent.fromFirestore(Map<String, dynamic> data, String id) {
    var lessonsList = data['lessons'] as List? ?? [];
    return ParcoursContent(
      id: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      kicker: data['kicker'] ?? 'Parcours',
      category: data['category'] ?? 'Fondamentaux',
      iconName: data['iconName'] ?? 'track_changes',
      colorHex: data['colorHex'] ?? '#FFA500',
      imageAsset: data['imageAsset'] ?? 'assets/sunset_bg.jpg',
      isNew: data['isNew'] ?? false,
      order: data['order'] ?? 99,
      lessons: lessonsList.map((e) => ParcoursLessonContent.fromMap(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Durée du parcours, dérivée du nombre réel de leçons.
  String get durationLabel => "${lessons.length} jour${lessons.length > 1 ? 's' : ''}";
}

class ParcoursLessonContent {
  final int dayNumber;
  final String title;
  final String desc;
  final String content;

  ParcoursLessonContent({
    required this.dayNumber,
    required this.title,
    required this.desc,
    required this.content,
  });

  factory ParcoursLessonContent.fromMap(Map<String, dynamic> data) {
    return ParcoursLessonContent(
      dayNumber: data['dayNumber'] ?? 1,
      title: data['title'] ?? '',
      desc: data['desc'] ?? '',
      content: data['content'] ?? '',
    );
  }
}
