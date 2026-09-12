import 'package:cloud_firestore/cloud_firestore.dart';

class Regularite {
  final int streak;
  final DateTime? lastActiveDate;
  final Map<String, bool> weekDays;

  Regularite({
    required this.streak,
    this.lastActiveDate,
    required this.weekDays,
  });

  factory Regularite.fromFirestore(Map<String, dynamic> data) {
    return Regularite(
      streak: data['streak'] ?? 0,
      lastActiveDate: data['lastActiveDate'] != null 
          ? (data['lastActiveDate'] as Timestamp).toDate() 
          : null,
      weekDays: Map<String, bool>.from(data['weekDays'] ?? {
        'L': false, 'M1': false, 'M2': false, 'J': false, 'V': false, 'S': false, 'D': false
      }),
    );
  }
}
