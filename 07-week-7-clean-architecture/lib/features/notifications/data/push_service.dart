import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../routes.dart';

// ─── Background handler (top-level, wajib) ───────────────────────────────────

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

// ─── Local notifications ──────────────────────────────────────────────────────

final _localNotifs = FlutterLocalNotificationsPlugin();

const _androidChannel = AndroidNotificationChannel(
  'campus_notify_high',
  'Campus Notify',
  description: 'Pengumuman kampus',
  importance: Importance.high,
);

Future<void> initLocalNotifications({
  required void Function(String location) go,
}) async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);

  await _localNotifs.initialize(
    settings,
    onDidReceiveNotificationResponse: (details) {
      if (details.payload != null) {
        final data = jsonDecode(details.payload!) as Map<String, dynamic>;
        go(routeFromMessage(data));
      }
    },
  );

  await _localNotifs
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_androidChannel);
}

// ─── Permission ───────────────────────────────────────────────────────────────

Future<void> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  debugPrint('Notification permission: ${settings.authorizationStatus}');
}

// ─── FCM token ────────────────────────────────────────────────────────────────

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await onToken(token);
  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);
}

// ─── Foreground listener ──────────────────────────────────────────────────────

void listenForeground(void Function(String location) go) {
  FirebaseMessaging.onMessage.listen((message) {
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification != null && android != null) {
      _localNotifs.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: android.smallIcon,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    go(routeFromMessage(message.data));
  });
}

// ─── Terminated state ─────────────────────────────────────────────────────────

Future<void> handleTerminated(void Function(String location) go) async {
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) go(routeFromMessage(initial.data));
}
