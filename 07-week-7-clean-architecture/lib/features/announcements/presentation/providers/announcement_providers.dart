import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';

// ─── Repository provider ─────────────────────────────────────────────────────

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(api: ref.watch(apiClientProvider));
});

// ─── Data providers ───────────────────────────────────────────────────────────

/// Semua pengumuman — dipakai HomePage.
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final result = await ref.watch(announcementRepositoryProvider).fetchAll();
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.items;
});

/// Satu pengumuman berdasarkan id — dipakai AnnouncementPage.
final announcementDetailProvider =
    FutureProvider.family<Announcement, String>((ref, id) async {
  final result =
      await ref.watch(announcementRepositoryProvider).fetchById(id);
  if (result.failure != null) throw Exception(result.failure!.message);
  if (result.item == null) throw Exception('Pengumuman tidak ditemukan');
  return result.item!;
});
