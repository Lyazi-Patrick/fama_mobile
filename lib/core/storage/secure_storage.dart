import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around secure storage, just for the auth token.
/// Kept separate so swapping storage strategy later only touches this file.
class SecureStorage {
  static const _tokenKey = 'fama_auth_token';
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
