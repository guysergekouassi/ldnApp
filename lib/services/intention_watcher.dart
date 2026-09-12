import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

/// Surveille la collection `intentions` et notifie l'utilisateur dès qu'une
/// intention est déposée par un autre membre.
///
/// Portée : cette surveillance fonctionne tant que l'application tourne
/// (premier plan ou récemment mise en arrière-plan). Pour recevoir l'alerte
/// application fermée, il faut Firebase Cloud Messaging piloté par une Cloud
/// Function déclenchée à l'écriture — voir le README des notifications.
class IntentionWatcher {
  static final IntentionWatcher _instance = IntentionWatcher._internal();
  factory IntentionWatcher() => _instance;
  IntentionWatcher._internal();

  static const String _lastSeenKey = 'last_seen_intention_at';

  StreamSubscription<QuerySnapshot>? _subscription;

  /// Horodatage de la dernière intention déjà signalée : évite de re-notifier
  /// l'historique au démarrage, et évite les doublons entre deux sessions.
  DateTime? _lastSeen;

  Future<void> start() async {
    if (_subscription != null) return;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_lastSeenKey);
    _lastSeen = stored != null ? DateTime.fromMillisecondsSinceEpoch(stored) : DateTime.now();

    _subscription = FirebaseFirestore.instance
        .collection('intentions')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .listen(_onSnapshot, onError: (_) {});
  }

  Future<void> _onSnapshot(QuerySnapshot snapshot) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    // On ne traite que les ajouts, pas les modifications de compteur « je prie ».
    for (final change in snapshot.docChanges) {
      if (change.type != DocumentChangeType.added) continue;

      final data = change.doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      // Pas d'alerte pour sa propre intention.
      if (currentUid != null && data['authorId'] == currentUid) continue;

      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      if (createdAt == null) continue;
      if (_lastSeen != null && !createdAt.isAfter(_lastSeen!)) continue;

      final title = (data['title'] ?? '').toString();
      if (title.isEmpty) continue;

      await NotificationService().showNewIntentionNotification(
        intentionId: change.doc.id,
        title: title,
      );

      _lastSeen = createdAt;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSeenKey, createdAt.millisecondsSinceEpoch);
    }
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
