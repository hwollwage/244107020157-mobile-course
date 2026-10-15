sealed class Failure {
  const Failure(this.message);
  final String message;
}
class NetworkFailure extends Failure { const NetworkFailure(super.message); }
class AuthFailure extends Failure { const AuthFailure(super.message); }
class LocalFailure extends Failure { const LocalFailure(super.message); }