import '../../../../core/failures.dart';
import '../entities/announcement.dart';

/// Kontrak berada di domain — data hanya mengimplementasikan.
/// Dependency Inversion terpenuhi: domain tidak tahu Dio/SQLite.
abstract class AnnouncementRepository {
  Future<({List<Announcement> items, Failure? failure})> fetchAll();
  Future<({Announcement? item, Failure? failure})> fetchById(String id);
}
