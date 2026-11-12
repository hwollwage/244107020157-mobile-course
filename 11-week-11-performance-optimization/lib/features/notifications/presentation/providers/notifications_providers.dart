import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/stub_notification_repository.dart';
import '../../domain/repositories/notification_repository.dart';

bool get _firebaseSupported =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => _firebaseSupported
      ? NotificationRepositoryImpl()
      : const StubNotificationRepository(),
);
