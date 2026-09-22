import 'package:cloud_firestore/cloud_firestore.dart';

/// Témoignage partagé par un membre : « ce que Dieu a fait dans ma vie ».
///
/// Les témoignages sont publics dès leur dépôt ([isApproved] à vrai) ; le
/// champ existe pour permettre une modération ultérieure sans migration.
class Temoignage {
  final String id;
  final String authorUid;
  final String authorName;
  final String authorAvatarUrl;
  final String title;
  final String content;
  final int likes;
  final bool isApproved;

  /// Nul tant que le serveur n'a pas horodaté le document (écriture optimiste).
  final DateTime? createdAt;

  Temoignage({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.title,
    required this.content,
    required this.likes,
    required this.isApproved,
    this.createdAt,
  });

  factory Temoignage.fromFirestore(Map<String, dynamic> data, String id) {
    return Temoignage(
      id: id,
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? 'Un membre',
      authorAvatarUrl: data['authorAvatarUrl'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      likes: data['likes'] ?? 0,
      isApproved: data['isApproved'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Initiales affichées quand le membre n'a pas de photo de profil.
  String get initiales {
    final mots = authorName.trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty);
    if (mots.isEmpty) return '?';
    if (mots.length == 1) return mots.first.substring(0, 1).toUpperCase();
    return (mots.first.substring(0, 1) + mots.last.substring(0, 1)).toUpperCase();
  }
}
