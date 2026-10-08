import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

final fcmTokenProvider = StreamProvider<String>((ref) async* {
  final t = await FirebaseMessaging.instance.getToken();
  if (t != null) yield t;
  yield* FirebaseMessaging.instance.onTokenRefresh;
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(fcmTokenProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Debug', style: TextStyle(fontWeight: FontWeight.bold)),
        token.when(
          data: (t) => Text('FCM token: ${t.substring(0, 12)}...'),
          loading: () => const Text('FCM token: loading...'),
          error: (e, _) => const Text('FCM token: unavailable'),
        ),
      ]),
    );
  }
}