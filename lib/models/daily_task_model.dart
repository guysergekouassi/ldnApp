class DailyTask {
  final String id;
  final String title;
  final String iconName;
  final String action; // 'evangile', 'chapelet' ou '' (simple case à cocher)
  final int order;

  /// Vrai pour les étapes ajoutées par l'utilisateur lui-même (intentions
  /// personnelles), stockées sous `users/{uid}/custom_daily_tasks`. Seules
  /// celles-ci peuvent être modifiées ou supprimées depuis la carte.
  final bool isCustom;

  DailyTask({
    required this.id,
    required this.title,
    required this.iconName,
    required this.action,
    required this.order,
    this.isCustom = false,
  });

  factory DailyTask.fromFirestore(Map<String, dynamic> data, String id, {bool isCustom = false}) {
    return DailyTask(
      id: id,
      title: data['title']?.toString().trim() ?? '',
      iconName: data['icon']?.toString().trim() ?? 'check_circle_outline',
      action: data['action']?.toString().trim() ?? '',
      order: int.tryParse(data['order'].toString()) ?? 0,
      isCustom: isCustom,
    );
  }
}
