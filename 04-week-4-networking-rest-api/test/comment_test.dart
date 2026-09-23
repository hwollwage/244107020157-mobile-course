import 'package:flutter_test/flutter_test.dart';
import 'package:rest_api/data/models/comment.dart';

void main() {
  test('Comment.fromJson aman kalau ada field yang hilang', () {
    final comment = Comment.fromJson({'id': 5, 'postId': 1});
    expect(comment.id, 5);
    expect(comment.postId, 1);
    expect(comment.name, '');   // default, bukan null/crash
    expect(comment.email, '');
    expect(comment.body, '');
  });
}