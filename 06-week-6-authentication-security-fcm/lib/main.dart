import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'messaging/push_service.dart';
import 'providers/auth_provider.dart';
import 'router.dart';

final container = ProviderContainer();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  registerBackgroundHandler();
  await container.read(authStateProvider.future);
  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = buildRouter(container);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPush());
  }

  Future<void> _initPush() async {
    await requestNotificationPermission();
    await initLocalNotifications(go: _router.go);
    await initFcmToken(onToken: (token) async {
      try {
        await container
            .read(dioProvider)
            .post('/devices', data: {'fcm_token': token, 'platform': 'android'});
      } catch (e) {
        debugPrint('POST /devices failed (mock backend): $e');
      }
    });
    listenForeground(_router.go);
    await handleTerminated(_router.go);
  }

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(title: 'Campus Notify', routerConfig: _router);
}