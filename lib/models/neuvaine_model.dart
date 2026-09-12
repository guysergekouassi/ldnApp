class NeuvaineDay {
  final int dayNumber;
  final String title;
  final String prayerText;

  NeuvaineDay({
    required this.dayNumber,
    required this.title,
    required this.prayerText,
  });

  factory NeuvaineDay.fromMap(Map<String, dynamic> data) {
    return NeuvaineDay(
      dayNumber: data['dayNumber'] ?? 1,
      title: (data['title'] ?? '').toString().trim(),
      prayerText: (data['prayerText'] ?? '').toString().trim(),
    );
  }
}

class Neuvaine {
  final String id;
  final String title; // ex: "Neuvaine à Marie"
  final String subtitle; // ex: "qui défait les nœuds"
  final String description;
  final String imageUrl; // ex: "assets/mary_praying.png"
  final List<NeuvaineDay> days;

  Neuvaine({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.days,
  });

  factory Neuvaine.fromFirestore(Map<String, dynamic> data, String id) {
    List<NeuvaineDay> parsedDays = [];
    if (data['days'] != null && data['days'] is List) {
      parsedDays = (data['days'] as List).map((dayData) => NeuvaineDay.fromMap(dayData as Map<String, dynamic>)).toList();
      
      // Ensure they are sorted by day number
      parsedDays.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    }

    return Neuvaine(
      id: id,
      title: (data['title'] ?? '').toString().trim(),
      subtitle: (data['subtitle'] ?? '').toString().trim(),
      description: (data['description'] ?? '').toString().trim(),
      imageUrl: (data['imageUrl'] ?? 'assets/sunset_bg.jpg').toString().trim(),
      days: parsedDays,
    );
  }
}
