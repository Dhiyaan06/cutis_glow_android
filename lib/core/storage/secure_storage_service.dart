import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Menyimpan token Sanctum secara aman (Keychain di iOS, Keystore di Android).
class SecureStorageService {
  static const _tokenKey = 'sanctum_token';

  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}