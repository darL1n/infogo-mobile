import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Получение access_token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  /// Получение refresh_token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  /// Сохранение обоих токенов
  Future<void> setTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  /// Удаление обоих токенов
  Future<void> deleteTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }
}
