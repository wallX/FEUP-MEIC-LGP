import 'package:dio/dio.dart';
import 'token_service.dart';


/// AuthInterceptor is a Dio interceptor that handles token refresh logic. <br>
/// * It intercepts requests and responses to manage authentication tokens. <br>
/// * If a request fails with a 401 status code, it attempts to refresh the token and retry the request. <br>
/// * It also adds the access token to the request headers if available. <br>
/// * This is useful for managing authentication in just one place using Dio for HTTP requests. <br>
/// * Otherwise we would have to add the token to every request manually and handle the 401 errors in every request. <br>
class AuthInterceptor extends Interceptor {
  final TokenService _tokenService;
  final Dio _dio;
  bool _isRefreshing = false;

  AuthInterceptor(this._dio, this._tokenService);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final success = await _tokenService.refreshTokens();
        if (success) { // Retry the original request with new token
          
          final token = await _tokenService.getAccessToken();

          final headers = Map<String, dynamic>.from(err.requestOptions.headers);
          headers['Authorization'] = 'Bearer $token';

          final opts = Options(
            method: err.requestOptions.method,
            headers: headers,
            followRedirects: err.requestOptions.followRedirects,
            validateStatus: err.requestOptions.validateStatus,
            receiveTimeout: err.requestOptions.receiveTimeout,
            sendTimeout: err.requestOptions.sendTimeout,
            contentType: err.requestOptions.contentType,
            responseType: err.requestOptions.responseType,
          );

          final response = await _dio.request(
            err.requestOptions.path,
            options: opts,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );
          handler.resolve(response);
          return;
        }
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }

  /// Adds the access (JWT) token to the request headers if available.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}