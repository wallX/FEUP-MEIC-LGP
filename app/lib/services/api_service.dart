import 'package:dio/dio.dart';
import 'package:app/services/auth_interceptor.dart';
import 'package:app/services/token_service.dart';
import 'package:app/data/app_constants.dart';

class ApiService {
  late final Dio _dio;
  final TokenService _tokenService;

  ApiService(this._tokenService) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 120),
    ));
    _dio.interceptors.add(AuthInterceptor(_dio, _tokenService));
  }

  Dio get dio => _dio;
}