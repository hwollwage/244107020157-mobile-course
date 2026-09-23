import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart'; // sumber dioProvider yang benar
import 'repositories/comment_repository.dart';
import 'models/comment.dart';

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

// FutureProvider.family: gak butuh class Notifier terpisah,
// tapi tetap otomatis kasih AsyncValue (loading/error/data) ke UI.
// param int = postId, jadi tiap postId beda dapat cache sendiri-sendiri.
final commentListProvider = FutureProvider.family<List<Comment>, int>(
  (ref, postId) async {
    final repo = ref.watch(commentRepositoryProvider);
    return repo.fetchComments(postId);
  },
);

// Sama polanya kayak friendlyErrorMessage di modul,
// tinggal dipindah ke lib/data/network_errors.dart biar dipakai bareng (task refactor #2)
String friendlyCommentError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout. Cek internet lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak bisa terhubung ke server. Cek koneksi internet kamu.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return 'Komentar tidak ditemukan (404).';
        if (code == 401 || code == 403) return 'Akses ditolak ($code).';
        return 'Masalah server ($code). Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
    }
  }
  return 'Terjadi kesalahan tak terduga: $error';
}