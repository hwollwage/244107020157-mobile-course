import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// MUST be top-level + @pragma: it runs in a separate isolate when the app is
/// in background/terminated. NEVER touch BuildContext, Riverpod or go_router here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('BG message: ${message.messageId}');
}

class PushService {
  PushService({required this.sendTokenToBackend, required this.navigate});

  /// POST /devices {fcm_token, platform}
  final Future<void> Function(String token) sendTokenToBackend;

  /// Receives a route like /announcement/3. No BuildContext inside the service.
  final void Function(String route) navigate;

  static const topic = 'campus-announcement';
  final _local = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _requestPermission();
    await _initLocal();
    await _initToken();
    _listen();
    await _handleInitialMessage();
  }

  Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
    debugPrint('Permission: ${settings.authorizationStatus}');

    // DIFFERS - Android 13+: runtime POST_NOTIFICATIONS permission
    // (plus the manifest entry). iOS: system dialog + APNs key in Firebase.
    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    // DIFFERS - iOS only: show the system banner while in foreground.
    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
              alert: true, badge: true, sound: true);
    }
  }

  Future<void> _initLocal() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (r) {
        final route = r.payload;
        if (route != null && route.isNotEmpty) navigate(route);
      },
    );
  }

  Future<void> _initToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM token: $token');
    if (token != null) await sendTokenToBackend(token);

    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      debugPrint('Token refreshed: $t');
      sendTokenToBackend(t);
    });

    await subscribe();
  }

  void _listen() {
    // Foreground: FCM shows nothing on Android, so show a local notification.
    FirebaseMessaging.onMessage.listen((m) async {
      final route = (m.data['route'] as String?) ?? '/';
      await _local.show(
        id: m.hashCode,
        title: m.notification?.title ?? 'Announcement',
        body: m.notification?.body ?? '',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'campus_announcements',
            'Campus Announcements',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: route,
      );
    });

    // Background -> tapped
    FirebaseMessaging.onMessageOpenedApp
        .listen((m) => navigate((m.data['route'] as String?) ?? '/'));
  }

  // Terminated -> opened from a notification
  Future<void> _handleInitialMessage() async {
    final m = await FirebaseMessaging.instance.getInitialMessage();
    if (m != null) navigate((m.data['route'] as String?) ?? '/');
  }

  Future<void> subscribe() =>
      FirebaseMessaging.instance.subscribeToTopic(topic);
  Future<void> unsubscribe() =>
      FirebaseMessaging.instance.unsubscribeFromTopic(topic);
}