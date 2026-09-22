/// Une journée d'un plan de lecture : la référence à lire et le point
/// d'attention proposé.
///
/// Le texte biblique lui-même n'est pas embarqué : le plan renvoie à la Bible
/// du lecteur (papier ou application), et l'app suit la progression.
class BibleReading {
  final int dayNumber;
  final String reference;
  final String focus;

  BibleReading({
    required this.dayNumber,
    required this.reference,
    required this.focus,
  });

  factory BibleReading.fromMap(Map<String, dynamic> data) {
    return BibleReading(
      dayNumber: data['dayNumber'] ?? 1,
      reference: (data['reference'] ?? '').toString().trim(),
      focus: (data['focus'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toMap() => {
        'dayNumber': dayNumber,
        'reference': reference,
        'focus': focus,
      };
}

class BiblePlan {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageAsset;
  final String colorHex;
  final int order;
  final List<BibleReading> readings;

  BiblePlan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageAsset,
    required this.colorHex,
    required this.order,
    required this.readings,
  });

  factory BiblePlan.fromFirestore(Map<String, dynamic> data, String id) {
    final list = data['readings'] as List? ?? const [];
    final readings = list
        .map((e) => BibleReading.fromMap(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

    return BiblePlan(
      id: id,
      title: (data['title'] ?? '').toString().trim(),
      subtitle: (data['subtitle'] ?? '').toString().trim(),
      description: (data['description'] ?? '').toString().trim(),
      imageAsset: (data['imageAsset'] ?? 'assets/images/bible.png.jpg').toString().trim(),
      colorHex: (data['colorHex'] ?? '#C72127').toString().trim(),
      order: data['order'] ?? 99,
      readings: readings,
    );
  }

  /// Durée dérivée du nombre réel de lectures, jamais d'un champ saisi à part
  /// qui pourrait diverger du contenu.
  int get durationDays => readings.length;

  String get durationLabel => "$durationDays jour${durationDays > 1 ? 's' : ''}";
}

/// Avancée d'un membre dans un plan, sous `users/{uid}/biblePlans/{planId}`.
class BiblePlanProgress {
  final String planId;
  final String title;
  final int durationDays;

  /// Numéros de jours déjà lus. Le plan se suit à son rythme : rien n'oblige
  /// à lire un jour par jour de calendrier.
  final List<int> completedDays;

  final bool isCompleted;
  final DateTime? startedAt;

  BiblePlanProgress({
    required this.planId,
    required this.title,
    required this.durationDays,
    required this.completedDays,
    required this.isCompleted,
    this.startedAt,
  });

  factory BiblePlanProgress.fromFirestore(Map<String, dynamic> data, String id) {
    return BiblePlanProgress(
      planId: id,
      title: (data['title'] ?? '').toString().trim(),
      durationDays: data['durationDays'] ?? 0,
      completedDays: (data['completedDays'] as List? ?? const [])
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((e) => e > 0)
          .toList(),
      isCompleted: data['isCompleted'] ?? false,
      startedAt: data['startedAt']?.toDate(),
    );
  }

  int get joursLus => completedDays.length;

  double get progression =>
      durationDays <= 0 ? 0.0 : (joursLus / durationDays).clamp(0.0, 1.0);

  bool estLu(int dayNumber) => completedDays.contains(dayNumber);

  /// Premier jour non lu : celui que l'écran propose de reprendre.
  int get prochainJour {
    for (var jour = 1; jour <= durationDays; jour++) {
      if (!completedDays.contains(jour)) return jour;
    }
    return durationDays;
  }
}
