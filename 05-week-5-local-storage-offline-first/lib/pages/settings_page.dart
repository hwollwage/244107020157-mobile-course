import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/prefs.dart';
import '../data/sync.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());

final previousOpenedProvider = Provider<String?>((ref) => null);

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  String _format(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso);
    if (d == null) return 'Pertama kali dibuka';
    return d.toLocal().toString().substring(0, 16);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider).value ?? false;
    final offline = ref.watch(forceOfflineProvider);
    final lastOpened = ref.watch(previousOpenedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('Disimpan di SharedPreferences'),
            value: dark,
            onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          SwitchListTile(
            title: const Text('Force offline (simulasi)'),
            subtitle: const Text('Blokir akses jaringan untuk demo & tes'),
            value: offline,
            onChanged: (v) => ref.read(forceOfflineProvider.notifier).set(v),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Terakhir dibuka'),
            subtitle: Text(_format(lastOpened)),
          ),
        ],
      ),
    );
  }
}