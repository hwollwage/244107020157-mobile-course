import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../routes.dart';
import '../../../../announcements/presentation/providers/announcement_providers.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

/// Halaman utama — hanya tahu provider domain, tidak ada Dio/JSON.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: state.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat: $e'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(announcementsProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (announcements) => announcements.isEmpty
            ? const Center(child: Text('Belum ada pengumuman.'))
            : ListView.separated(
                itemCount: announcements.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final a = announcements[i];
                  return ListTile(
                    title: Text(a.title),
                    subtitle: Text(
                      _formatDate(a.createdAt),
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => ctx.push(AppRoutes.announcement(a.id)),
                  );
                },
              ),
      ),
    );
  }

  /// Helper format tanggal — boleh ada di presentation, bukan di entity.
  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}
