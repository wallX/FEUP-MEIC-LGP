import 'package:app/data/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class TokenService {
  String? accessToken;
  String? refreshToken;
  final storage = const FlutterSecureStorage();
  
  TokenService({this.accessToken, this.refreshToken});

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refresh_token');
  }

  Future<void> saveTokens() async {
    if (accessToken != null) {
      await storage.write(key: 'access_token', value: accessToken);
    }
    if (refreshToken != null) {
      await storage.write(key: 'refresh_token', value: refreshToken);
    }
  }

  void setTokens({String? accessToken, String? refreshToken}) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    saveTokens();
  }

  Future<void> loadTokens() async {
    accessToken = await storage.read(key: 'access_token');
    refreshToken = await storage.read(key: 'refresh_token');
  }

  Future<void> clearTokens() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }

  Future<bool> refreshTokens() async {
    try {
      Dio retryDio = Dio(
        BaseOptions(
          baseUrl: AppConstants.apiBaseUrl,
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
        setTokens(
          accessToken: response.data['token'],
          refreshToken: response.data['refresh'],
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Function to refresh tokens when using HttpClient instead of Dio
  /// Simply saves the new tokens and returns True if successful
  Future<bool> refreshTokensHttpClient() async {
    try {
      var httpClient = http.Client();

      Uri uri = Uri.parse("${AppConstants.apiBaseUrl}/api/auth/refresh");

      final token = await getAccessToken();
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await httpClient.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Refresh-Token': refreshToken,
        }
      );

      if (response.statusCode == 200){

        final stringData = response.body;
        final Map<String, dynamic> jsonData = jsonDecode(stringData);
        
        setTokens(
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