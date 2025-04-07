import 'package:dio/dio.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class TokenService {
  final FlutterSecureStorage _storage;
  final ApiService _apiService = ApiService(TokenService());
  
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
      final token = await getAccessToken();
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiService.dio.post('/api/auth/refresh',
        options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Refresh-Token':refreshToken
              },
          )
      );
      await saveTokens(
        accessToken: response.data['token'],
        refreshToken: response.data['refresh'],
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}