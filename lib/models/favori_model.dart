import 'package:cloud_firestore/cloud_firestore.dart';

class Favori {
  final String id;
  final String title;
  final String imageUrl;
  final String type; // 'verset', 'priere', 'neuvaine', 'parcours'...
  final String reference;
  final DateTime? createdAt;

  Favori({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.type,
    required this.reference,
    this.createdAt,
  });

  factory Favori.fromFirestore(Map<String, dynamic> data, String id) {
    return Favori(
      id: id,
      title: data['title']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? 'assets/sunset_bg.jpg',
      type: data['type']?.toString() ?? 'autre',
      reference: data['reference']?.toString() ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'type': type,
      'reference': reference,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
