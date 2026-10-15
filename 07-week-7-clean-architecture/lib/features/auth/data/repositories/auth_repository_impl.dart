import 'package:dio/dio.dart';
import '../../../../core/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/token_store.dart';

/// Implementasi AuthRepository.
/// Tanggung jawab: memanggil API dan memetakan respons ke domain.
/// Semua Dio dan secure-storage terkurung di sini — domain tidak tahu keduanya.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required ApiClient api, required TokenStore tokens})
      : _api = api,
        _tokens = tokens;

  final ApiClient _api;
  final TokenStore _tokens;

  @override
  Future<({UserSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = res.data as Map<String, dynamic>;
      await _tokens.save(
        access: data['access_token'] as String? ?? data['token'] as String,
        refresh: data['refresh_token'] as String? ?? '',
      );
      return (
        session: UserSession(
          userId: '${data['id']}',
          name: data['name'] as String? ?? '',
        ),
        failure: null,
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      return (
        session: null,
        failure: code == 401
            ? const AuthFailure('Email atau password salah')
            : NetworkFailure('Gagal terhubung: ${e.message}'),
      );
    } catch (e) {
      return (
        session: null,
        failure: NetworkFailure('Error tidak terduga: $e'),
      );
    }
  }

  @override
  Future<void> logout() => _tokens.clear();

  /// Digunakan oleh AuthStateNotifier untuk cek sesi saat app dibuka.
  Future<bool> hasSession() => _tokens.hasToken();
}
