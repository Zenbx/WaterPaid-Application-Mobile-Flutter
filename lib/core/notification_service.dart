import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (status.isPermanentlyDenied) {
        // Handle permanently denied
      }
    } else if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'water_paid_alerts',
      'WaterPaid Alerts',
      channelDescription:
          'Notifications for water leaks, credit status, and service updates.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Specialized alerts
  Future<void> alertCreditExhausted() async {
    await showNotification(
      id: 1,
      title: 'Crédit Épuisé',
      body:
          'Attention, votre crédit d\'eau est épuisé. Veuillez recharger pour éviter une coupure.',
    );
  }

  Future<void> alertLeakDetected() async {
    await showNotification(
      id: 2,
      title: 'Alerte Fuite d\'eau',
      body:
          'Une consommation anormale a été détectée sur votre compteur. Risque de fuite !',
    );
  }

  Future<void> alertLowPressure() async {
    await showNotification(
      id: 3,
      title: 'Débit Faible',
      body: 'Un débit d\'eau anormalement faible a été détecté.',
    );
  }

  Future<void> alertWaterCutoff() async {
    await showNotification(
      id: 4,
      title: 'Coupure d\'eau',
      body:
          'Une coupure d\'eau générale ou programmée est en cours dans votre zone.',
    );
  }
}
