import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Plages d'identifiants réservées, pour pouvoir annuler un type de rappel
  /// sans toucher aux autres.
  static const int _prayerIdBase = 0; // 0, 1, 2 : Matin / Midi / Soir
  static const int _misericordeId = 50;
  static const int _intentionIdBase = 100;

  /// Ordre d'affichage des rappels de prière, qui fixe aussi leur identifiant.
  static const List<String> prayerPeriods = ['Matin', 'Midi', 'Soir'];

  /// Vrai uniquement sur les plateformes où les notifications locales
  /// existent. Le web n'est pas supporté par flutter_local_notifications :
  /// chaque appel y lèverait une MissingPluginException.
  bool get isSupported => !kIsWeb;

  Future<void> init() async {
    if (_isInitialized || !isSupported) return;

    tz.initializeTimeZones();
    await _configurerFuseauHoraire();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );
    _isInitialized = true;
  }

  /// Cale `tz.local` sur le fuseau réel de l'appareil.
  ///
  /// Sans cela `tz.local` vaut UTC : un rappel réglé sur 06:30 était programmé
  /// à 06:30 UTC, donc sonnait à 07:30 ou 08:30 en France. Toutes les heures
  /// du programme de prière étaient décalées de l'écart au méridien.
  Future<void> _configurerFuseauHoraire() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
      return;
    } catch (e) {
      debugPrint("Fuseau horaire de l'appareil illisible : $e");
    }

    // Repli : on retient un fuseau dont le décalage actuel correspond à celui
    // de l'appareil. Moins fiable qu'un identifiant IANA sur les changements
    // d'heure, mais toujours préférable à UTC.
    try {
      final decalage = DateTime.now().timeZoneOffset;
      final maintenant = DateTime.now().toUtc();
      for (final lieu in tz.timeZoneDatabase.locations.values) {
        if (tz.TZDateTime.from(maintenant, lieu).timeZoneOffset == decalage) {
          tz.setLocalLocation(lieu);
          return;
        }
      }
    } catch (e) {
      debugPrint('Repli sur le décalage horaire impossible : $e');
    }
  }

  /// Demande les autorisations nécessaires. Sur Android 13+, sans
  /// POST_NOTIFICATIONS accordée à l'exécution, aucune notification n'est
  /// affichée même si la permission est déclarée au manifeste.
  Future<bool> requestPermissions() async {
    if (!isSupported) return false;

    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission() ?? false;
      // Nécessaire pour que les rappels tombent à l'heure exacte (Android 12+).
      await android.requestExactAlarmsPermission();
      return granted;
    }

    final ios = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }

    return true;
  }

  /// (Re)programme les trois rappels quotidiens à partir des horaires choisis.
  ///
  /// N'annule que les identifiants réservés aux rappels de prière : les
  /// notifications d'intentions ne sont pas affectées.
  Future<void> syncPrayerReminders(Map<String, String> times) async {
    if (!isSupported) return;
    // Les horaires peuvent être lus avant que `main` n'ait fini d'initialiser
    // le service ; sans cela la programmation échouerait silencieusement.
    await init();

    for (int i = 0; i < prayerPeriods.length; i++) {
      await _notificationsPlugin.cancel(_prayerIdBase + i);
    }

    for (int i = 0; i < prayerPeriods.length; i++) {
      final period = prayerPeriods[i];
      final parsed = _parseTime(times[period]);
      if (parsed == null) continue;

      await _schedulePrayerTime(
        _prayerIdBase + i,
        "Temps de prière",
        "C'est l'heure de ta prière du ${period.toLowerCase()}. 🙏",
        parsed,
      );
    }
  }

  /// Active ou coupe le rappel de l'Heure de la Miséricorde, à 15 h.
  ///
  /// Il porte son propre identifiant : l'activer ou le couper ne touche pas
  /// aux trois rappels de prière quotidiens.
  Future<void> syncHeureDeLaMisericorde(bool actif) async {
    if (!isSupported) return;
    await init();

    await _notificationsPlugin.cancel(_misericordeId);
    if (!actif) return;

    await _schedulePrayerTime(
      _misericordeId,
      "Heure de la Miséricorde",
      "Il est 15 h, l'heure où le Christ a donné sa vie. Une minute pour lui. 🙏",
      const TimeOfDay(hour: 15, minute: 0),
    );
  }

  /// Convertit « 06:30 » en [TimeOfDay]. Renvoie null si la valeur est absente
  /// ou mal formée, pour ne pas faire échouer toute la programmation.
  TimeOfDay? _parseTime(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _schedulePrayerTime(int id, String title, String body, TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Si l'heure est déjà passée aujourd'hui, on programme pour demain.
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel_id',
          'Rappels de Prière',
          channelDescription: 'Notifications pour vos heures de prière',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Répète chaque jour
    );
  }

  /// Notifie l'arrivée d'une nouvelle intention communautaire.
  Future<void> showNewIntentionNotification({
    required String intentionId,
    required String title,
  }) async {
    if (!isSupported) return;

    await _notificationsPlugin.show(
      _intentionIdBase + (intentionId.hashCode.abs() % 500),
      "Nouvelle intention de prière",
      title,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'intentions_channel_id',
          'Intentions communautaires',
          channelDescription: "Alerte lorsqu'une intention est déposée par la communauté",
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'intention:$intentionId',
    );
  }

  /// Rappels de prière effectivement armés dans le système.
  ///
  /// Sert à vérifier qu'une notification est bien programmée pour chaque heure
  /// définie, ce qu'aucun retour d'écran ne montre autrement.
  Future<List<PendingNotificationRequest>> pendingPrayerReminders() async {
    if (!isSupported) return const [];

    final pending = await _notificationsPlugin.pendingNotificationRequests();
    return pending
        .where((n) =>
            n.id >= _prayerIdBase && n.id < _prayerIdBase + prayerPeriods.length)
        .toList();
  }

  Future<void> cancelAll() async {
    if (!isSupported) return;
    await _notificationsPlugin.cancelAll();
  }
}
