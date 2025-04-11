import 'package:dio/dio.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

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
      Dio retryDio = Dio(
        BaseOptions(
          baseUrl: "http://10.0.2.2",
        ),
      );

      final token = await getAccessToken();
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await retryDio.post('/api/auth/refresh',
        options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Refresh-Token':refreshToken
              },
          )
      );

      if (response.statusCode == 200){
        await saveTokens(
          accessToken: response.data['token'],
          refreshToken: response.data['refresh'],
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> refreshTokensHttpClient() async {
    try {
      var httpClient = http.Client();

      Uri uri = Uri.parse("http://10.0.2.2/api/auth/refresh");

      final token = await getAccessToken();
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await httpClient.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${token}',
          'Refresh-Token': refreshToken,
        }
      );

      if (response.statusCode == 200){

        final stringData = response.body;
        final Map<String, dynamic> jsonData = jsonDecode(stringData);
        
        await saveTokens(
          accessToken: jsonData['token'],
          refreshToken: jsonData['refresh'], 
        );
      }
      return true;
    } catch(e){
      return false;
    }
  }
}