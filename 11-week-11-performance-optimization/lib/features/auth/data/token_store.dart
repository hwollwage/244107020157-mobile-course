import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Returns true when flutter_secure_storage is backed by an OS keychain.
/// On Linux desktop there is no keychain, so we fall back to in-memory storage
/// to allow the app to run (useful for DevTools profiling).
bool get _secureStorageSupported {
  if (defaultTargetPlatform == TargetPlatform.android) return true;
  if (defaultTargetPlatform == TargetPlatform.iOS) return true;
  // macOS has a keychain but requires entitlements; keep in-memory for safety
  // in dev builds.
  return false;
}

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
    : _storage = _secureStorageSupported
          ? (storage ?? const FlutterSecureStorage())
          : null;

  final FlutterSecureStorage? _storage;

  // In-memory fallback used on platforms without a keychain (Linux, etc.)
  final Map<String, String> _memStore = {};

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> save({required String access, required String refresh}) async {
    if (_storage case final s?) {
      await s.write(key: _accessKey, value: access);
      await s.write(key: _refreshKey, value: refresh);
    } else {
      _memStore[_accessKey] = access;
      _memStore[_refreshKey] = refresh;
    }
  }

  Future<String?> readAccess() async {
    if (_storage case final s?) return s.read(key: _accessKey);
    return _memStore[_accessKey];
  }

  Future<String?> readRefresh() async {
    if (_storage case final s?) return s.read(key: _refreshKey);
    return _memStore[_refreshKey];
  }

  Future<void> clear() async {
    if (_storage case final s?) {
      await s.deleteAll();
    } else {
      _memStore.clear();
    }
  }
}
