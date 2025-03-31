import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final FlutterSecureStorage _storage;
  
  TokenService(): _storage = const FlutterSecureStorage();

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<bool> refreshTokens() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      // TODO: Make API call to refresh tokens
      // final response = await dio.post('/refresh', data: {'refresh_token': refreshToken});
      // await saveTokens(
      //   accessToken: response.data['access_token'],
      //   refreshToken: response.data['refresh_token'],
      // );

      return true;
    } catch (e) {
      return false;
    }
  }
}