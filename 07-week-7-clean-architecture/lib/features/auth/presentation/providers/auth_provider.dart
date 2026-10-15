import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/token_store.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';

// ─── Infrastructure providers ───────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final tokenStoreProvider = Provider<TokenStore>((ref) => const TokenStore());

// ─── Repository & use-case providers ────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    api: ref.watch(apiClientProvider),
    tokens: ref.watch(tokenStoreProvider),
  );
});

/// Use case: hanya Login yang punya aturan bisnis (validasi input + simpan token).
/// Logout hanya satu baris → repo langsung sudah cukup.
final loginProvider = Provider<Login>((ref) {
  return Login(ref.watch(authRepositoryProvider));
});

// ─── Auth state ──────────────────────────────────────────────────────────────

/// true  → sudah login (ada token tersimpan)
/// false → belum login
class AuthStateNotifier extends AutoDisposeAsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final repo = ref.watch(authRepositoryProvider) as AuthRepositoryImpl;
    return repo.hasSession();
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(loginProvider)(
      email: email,
      password: password,
    );
    if (result.failure != null) {
      state = const AsyncData(false);
      return result.failure!.message;
    }
    state = const AsyncData(true);
    return null; // null = sukses
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(false);
  }
}

final authStateProvider =
    AsyncNotifierProvider.autoDispose<AuthStateNotifier, bool>(
  AuthStateNotifier.new,
);

/// Provider Dio untuk dipakai main.dart (push token registration).
final dioProvider = Provider((ref) => ref.watch(apiClientProvider).dio);
