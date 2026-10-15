import 'package:dio/dio.dart';

/// Wrapper tipis di atas Dio.
/// Hanya bertanggung jawab pada konfigurasi HTTP — tidak tahu auth domain.
class ApiClient {
  ApiClient({String baseUrl = 'https://example-campus-api.test'})
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  final Dio dio;
}
