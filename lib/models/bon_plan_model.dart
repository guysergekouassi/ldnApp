import 'package:cloud_firestore/cloud_firestore.dart';

class BonPlan {
  final String id;
  final String title;
  final String description;
  final String actionText;
  final String iconName;

  BonPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.actionText,
    required this.iconName,
  });

  factory BonPlan.fromFirestore(Map<String, dynamic> data, String id) {
    return BonPlan(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      actionText: data['actionText'] ?? 'PROFITER MAINTENANT',
      iconName: data['iconName'] ?? 'local_offer_outlined',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'actionText': actionText,
      'iconName': iconName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
