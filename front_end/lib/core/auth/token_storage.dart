import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Single source of truth for the access token.
/// Persist on login/register; clear on logout. Used by Dio interceptor.
abstract class TokenStorage {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final FlutterSecureStorage _storage;
  static const _key = 'access_token';

  @override
  Future<String?> getToken() => _storage.read(key: _key);

  @override
  Future<void> saveToken(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
