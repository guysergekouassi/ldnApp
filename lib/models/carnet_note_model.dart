import 'package:cloud_firestore/cloud_firestore.dart';

class CarnetNote {
  final String id;
  final String type; // 'rhema', 'priere', 'meditation'
  final String title;
  final String content;
  final List<String> tags;
  final DateTime date;

  CarnetNote({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.tags,
    required this.date,
  });

  factory CarnetNote.fromFirestore(Map<String, dynamic> data, String id) {
    return CarnetNote(
      id: id,
      type: data['type'] ?? 'rhema',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      date: data['date'] != null 
          ? (data['date'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'content': content,
      'tags': tags,
      'date': FieldValue.serverTimestamp(),
    };
  }
}
