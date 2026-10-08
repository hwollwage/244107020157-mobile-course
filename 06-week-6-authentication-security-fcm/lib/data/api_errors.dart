import 'package:dio/dio.dart';

String friendlyError(Object e) {
  if (e is DioException) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        break;
    }
    final code = e.response?.statusCode;
    if (code == 401) return 'Your session has expired. Please log in again.';
    if (code != null && code >= 500) return 'Server error. Please try later.';
  }
  return 'Something went wrong. Please try again.';
}