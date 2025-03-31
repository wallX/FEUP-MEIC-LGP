import 'package:dio/dio.dart';
import 'package:app/services/auth_interceptor.dart';
import 'package:app/services/token_service.dart';

class ApiService {
  late final Dio _dio;
  final TokenService _tokenService;

  ApiService(this._tokenService) {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2', // TODO: Replace with server URL when they provide it to us
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 120),
    ));
    _dio.interceptors.add(AuthInterceptor(_dio, _tokenService));
  }

  Dio get dio => _dio;
}