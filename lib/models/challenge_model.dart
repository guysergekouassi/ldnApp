import 'package:cloud_firestore/cloud_firestore.dart';

class Challenge {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final int participants;
  final int durationDays;

  Challenge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.participants,
    required this.durationDays,
  });

  factory Challenge.fromFirestore(Map<String, dynamic> data, String id) {
    return Challenge(
      id: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      participants: data['participants'] ?? 0,
      durationDays: data['durationDays'] ?? 0,
    );
  }
}

/// Participation d'un membre à un défi, stockée sous
/// `users/{uid}/challenges/{challengeId}`.
///
/// Le titre et la durée sont recopiés depuis le défi : la carte d'accueil peut
/// ainsi s'afficher sans attendre le chargement de la collection `challenges`.
class ChallengeProgress {
  final String challengeId;
  final String title;
  final String subtitle;
  final int durationDays;

  /// Jours validés, au format `AAAA-MM-JJ` (voir `FirestoreService.dayKey`).
  final List<String> completedDays;

  final bool isCompleted;
  final DateTime? joinedAt;

  ChallengeProgress({
    required this.challengeId,
    required this.title,
    required this.subtitle,
    required this.durationDays,
    required this.completedDays,
    required this.isCompleted,
    this.joinedAt,
  });

  factory ChallengeProgress.fromFirestore(Map<String, dynamic> data, String id) {
    return ChallengeProgress(
      challengeId: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      durationDays: data['durationDays'] ?? 0,
      completedDays: List<String>.from(data['completedDays'] ?? const <String>[]),
      isCompleted: data['isCompleted'] ?? false,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate(),
    );
  }

  int get joursValides => completedDays.length;

  double get progression =>
      durationDays <= 0 ? 0.0 : (joursValides / durationDays).clamp(0.0, 1.0);

  bool estValideLe(String dayKey) => completedDays.contains(dayKey);
}
