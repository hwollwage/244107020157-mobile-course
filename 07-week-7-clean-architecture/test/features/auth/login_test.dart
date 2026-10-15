import 'package:clean_arch/core/failures.dart';
import 'package:clean_arch/features/auth/domain/entities/user_session.dart';
import 'package:clean_arch/features/auth/domain/repositories/auth_repository.dart';
import 'package:clean_arch/features/auth/domain/usecases/login.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fake repository — tidak butuh Dio, network, atau Firebase ───────────────

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.shouldFail = false});

  final bool shouldFail;

  @override
  Future<({UserSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      return (
        session: null,
        failure: const AuthFailure('Email atau password salah'),
      );
    }
    return (
      session: UserSession(userId: '42', name: 'Hanzel'),
      failure: null,
    );
  }

  @override
  Future<void> logout() async {}
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('Login use case', () {
    test('sukses mengembalikan UserSession', () async {
      final useCase = Login(FakeAuthRepository());
      final result =
          await useCase(email: 'hanzel@campus.id', password: 'secret123');

      expect(result.failure, isNull);
      expect(result.session, isNotNull);
      expect(result.session!.name, 'Hanzel');
      expect(result.session!.userId, '42');
    });

    test('gagal mengembalikan AuthFailure (repo gagal)', () async {
      final useCase = Login(FakeAuthRepository(shouldFail: true));
      final result =
          await useCase(email: 'hanzel@campus.id', password: 'wrong');

      expect(result.session, isNull);
      expect(result.failure, isA<AuthFailure>());
    });

    test('input kosong ditolak sebelum menyentuh repo', () async {
      final useCase = Login(FakeAuthRepository());

      // email kosong
      final r1 = await useCase(email: '', password: 'secret');
      expect(r1.failure, isA<AuthFailure>());
      expect(r1.session, isNull);

      // password kosong
      final r2 =
          await useCase(email: 'hanzel@campus.id', password: '');
      expect(r2.failure, isA<AuthFailure>());

      // keduanya kosong
      final r3 = await useCase(email: '   ', password: '');
      expect(r3.failure, isA<AuthFailure>());
    });

    test('whitespace-only email ditolak', () async {
      final useCase = Login(FakeAuthRepository());
      final result =
          await useCase(email: '   ', password: 'secret123');
      expect(result.failure, isA<AuthFailure>());
    });
  });
}
