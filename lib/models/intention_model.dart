import 'package:cloud_firestore/cloud_firestore.dart';

class Intention {
  final String id;
  final String title;
  final String description;
  final String colorHex;
  final int count;

  /// Date de dépôt : sert à présenter les intentions de la plus récente à la
  /// plus ancienne. Nulle pour les intentions déposées avant l'ajout du champ.
  final DateTime? createdAt;

  Intention({
    required this.id, 
    required this.title, 
    required this.description,
    required this.colorHex, 
    required this.count,
    this.createdAt,
  });

  factory Intention.fromFirestore(Map<String, dynamic> data, String id) {
    return Intention(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      colorHex: data['colorHex'] ?? '#000000',
      count: data['count'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
