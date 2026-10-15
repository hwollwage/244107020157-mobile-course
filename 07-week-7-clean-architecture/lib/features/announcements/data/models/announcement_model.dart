import '../../domain/entities/announcement.dart';

/// Model hanya ada di data layer.
/// Tanggung jawab tunggal: mapping JSON ↔ entity.
/// UI dan domain tidak pernah melihat kelas ini.
class AnnouncementModel {
  AnnouncementModel._({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> j) {
    return AnnouncementModel._(
      id: '${j['id']}',
      title: j['title'] as String? ?? '',
      body: j['body'] as String? ?? '',
      createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;

  /// Konversi ke entity domain — batas data → domain.
  Announcement toEntity() => Announcement(
        id: id,
        title: title,
        body: body,
        createdAt: createdAt,
      );
}
