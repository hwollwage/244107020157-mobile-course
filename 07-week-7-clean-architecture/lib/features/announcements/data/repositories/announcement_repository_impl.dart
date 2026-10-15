import 'package:dio/dio.dart';
import '../../../../core/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

/// Implementasi AnnouncementRepository.
/// Dio terkurung di sini — domain tidak tahu Dio ada.
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<({List<Announcement> items, Failure? failure})> fetchAll() async {
    try {
      final res = await _api.dio.get('/announcements');
      final list = (res.data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(AnnouncementModel.fromJson)
          .map((m) => m.toEntity())
          .toList();
      return (items: list, failure: null);
    } on DioException catch (e) {
      return (
        items: const [],
        failure: NetworkFailure('Gagal memuat pengumuman: ${e.message}'),
      );
    } catch (e) {
      return (
        items: const [],
        failure: NetworkFailure('Error tidak terduga: $e'),
      );
    }
  }

  @override
  Future<({Announcement? item, Failure? failure})> fetchById(String id) async {
    try {
      final res = await _api.dio.get('/announcements/$id');
      final item = AnnouncementModel.fromJson(
          res.data as Map<String, dynamic>).toEntity();
      return (item: item, failure: null);
    } on DioException catch (e) {
      return (
        item: null,
        failure: NetworkFailure('Gagal memuat detail: ${e.message}'),
      );
    }
  }
}
