import 'package:cloud_firestore/cloud_firestore.dart';

class Objectif {
  final String id;
  final String title;
  final String icon;
  final String colorHex;
  final int currentCount;
  final int targetCount;
  final DateTime? lastCompletedDate;

  Objectif({
    required this.id,
    required this.title,
    required this.icon,
    required this.colorHex,
    required this.currentCount,
    required this.targetCount,
    this.lastCompletedDate,
  });

  factory Objectif.fromFirestore(Map<String, dynamic> data, String id) {
    return Objectif(
      id: id,
      title: data['title'] ?? '',
      icon: data['icon'] ?? 'track_changes',
      colorHex: data['colorHex'] ?? '#000000',
      currentCount: data['currentCount'] ?? 0,
      targetCount: data['targetCount'] ?? 100,
      lastCompletedDate: data['lastCompletedDate'] != null 
          ? (data['lastCompletedDate'] as Timestamp).toDate() 
          : null,
    );
  }

  double get progress => targetCount > 0 ? currentCount / targetCount : 0.0;
}
