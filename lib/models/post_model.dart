import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorName;
  final String authorRole;
  final String authorAvatarUrl;
  final String content;
  final String? imageUrl;
  final int likes;
  final DateTime createdAt;

  Post({required this.id, required this.authorName, required this.authorRole, required this.authorAvatarUrl, required this.content, this.imageUrl, required this.likes, required this.createdAt});

  factory Post.fromFirestore(Map<String, dynamic> data, String id) {
    return Post(
      id: id,
      authorName: data['authorName'] ?? '',
      authorRole: data['authorRole'] ?? '',
      authorAvatarUrl: data['authorAvatarUrl'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      likes: data['likes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
