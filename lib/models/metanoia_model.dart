import 'package:cloud_firestore/cloud_firestore.dart';

class Metanoia {
  final String id;
  final String title;
  final String subtitle;
  final String duration;
  final String iconCode;
  final String colorHex;
  final String imageAsset;
  final bool isNew;
  final String description;

  Metanoia({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.iconCode,
    required this.colorHex,
    required this.imageAsset,
    required this.isNew,
    required this.description,
  });

  factory Metanoia.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Metanoia(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      duration: data['duration'] ?? '',
      iconCode: data['iconCode'] ?? 'Icons.book',
      colorHex: data['colorHex'] ?? '0xFF5B4FC8',
      imageAsset: data['imageAsset'] ?? 'assets/sunset_bg.jpg',
      isNew: data['isNew'] ?? false,
      description: data['description'] ?? '',
    );
  }
}

class MetanoiaLevel {
  final String id;
  final String MetanoiaId;
  final String title;
  final String subtitle;
  final String imageAsset;
  final int order;
  final int totalLessons;

  MetanoiaLevel({
    required this.id,
    required this.MetanoiaId,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.order,
    required this.totalLessons,
  });

  factory MetanoiaLevel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MetanoiaLevel(
      id: doc.id,
      MetanoiaId: data['MetanoiaId'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      imageAsset: data['imageAsset'] ?? 'assets/mountain_bg.png',
      order: data['order'] ?? 0,
      totalLessons: data['totalLessons'] ?? 0,
    );
  }
}

class MetanoiaLesson {
  final String id;
  final String levelId;
  final String title;
  final String content;
  final int order;

  MetanoiaLesson({
    required this.id,
    required this.levelId,
    required this.title,
    required this.content,
    required this.order,
  });

  factory MetanoiaLesson.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MetanoiaLesson(
      id: doc.id,
      levelId: data['levelId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      order: data['order'] ?? 0,
    );
  }
}
