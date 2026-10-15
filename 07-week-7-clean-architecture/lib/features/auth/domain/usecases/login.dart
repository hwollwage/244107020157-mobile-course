import '../../../../core/failures.dart';
import '../entities/user_session.dart';
import '../repositories/auth_repository.dart';

class Login {
  const Login(this._repository);
  final AuthRepository _repository;

  Future<({UserSession? session, Failure? failure})> call({
    required String email,
    required String password,
  }) {
    if (email.trim().isEmpty || password.isEmpty) {
      return Future.value((
        session: null,
        failure: const AuthFailure('Email dan password wajib diisi'),
      ));
    }
    return _repository.login(email: email.trim(), password: password);
  }
}