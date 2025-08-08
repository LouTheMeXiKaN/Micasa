import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';

// Handles secure storage of tokens using native encrypted storage (iOS Keychain / Android Keystore)
class TokenStorageService {
  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  TokenStorageService(this._secureStorage);

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<User?> getUser() async {
    final userJson = await _secureStorage.read(key: _userKey);
    if (userJson != null) {
      try {
        return User.fromJson(jsonDecode(userJson));
      } catch (e) {
        // Handle potential parsing errors if JSON is corrupted
        await clearAuthData(); // Clear corrupted data
        return null;
      }
    }
    return null;
  }

  Future<void> saveAuthData(AuthResponse authResponse) async {
    await _secureStorage.write(key: _tokenKey, value: authResponse.token);
    await _secureStorage.write(
      key: _userKey,
      value: jsonEncode(authResponse.user.toJson()),
    );
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
  }
}