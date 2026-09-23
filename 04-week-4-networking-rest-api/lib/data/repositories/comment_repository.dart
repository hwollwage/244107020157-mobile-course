import 'package:dio/dio.dart';
import '../models/comment.dart';

class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  Future<List<Comment>> fetchComments(int postId) async {
    // Timeout 10 detik khusus request ini (selain timeout global di Dio client)
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
      options: Options(sendTimeout: const Duration(seconds: 10)),
    );
    final data = response.data ?? [];
    // whereType filter elemen yang bukan Map (jaga-jaga API ngirim data aneh)
    return data.whereType<Map<String, dynamic>>().map(Comment.fromJson).toList();
  }
}