import '../../../../core/failures.dart';
import '../../domain/repositories/notification_repository.dart';

/// No-op implementation used on platforms where Firebase is not available
/// (Linux, Windows desktop). All operations return safe defaults so the app
/// can be run and profiled without a Firebase project.
class StubNotificationRepository implements NotificationRepository {
  const StubNotificationRepository();

  @override
  Future<({String? token, Failure? failure})> currentToken() async =>
      (token: 'stub-token-linux', failure: null);

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Future<({bool subscribed, Failure? failure})> isSubscribed() async =>
      (subscribed: false, failure: null);

  @override
  Future<Failure?> setSubscribed(bool value) async => null;
}
