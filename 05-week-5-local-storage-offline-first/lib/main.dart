import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/prefs.dart';
import 'pages/settings_page.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = PrefsRepository();
  final previous = await prefs.getLastOpened();
  await prefs.markOpenedNow();

  runApp(ProviderScope(
    overrides: [previousOpenedProvider.overrideWithValue(previous)],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider).value ?? false;
    return MaterialApp.router(
      title: 'Week 5 - Offline Notes',
      routerConfig: appRouter,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
    );
  }
}