import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../../features/auth/data/services/token_storage_service.dart';
import '../error/exceptions.dart';

class ApiClient {
  final Dio _dio;
  final TokenStorageService _tokenStorageService;

  ApiClient(this._dio, this._tokenStorageService) {
    _dio.options.baseUrl = Environment.apiBaseUrl;
    _dio.options.headers = {'Content-Type': 'application/json'};
    
    // Add interceptors for authentication and error handling
    _dio.interceptors.add(AuthInterceptor(_tokenStorageService));
    _dio.interceptors.add(ErrorInterceptor());
    // NOTE: A TokenRefreshInterceptor should be implemented here to handle 401s transparently.
  }

  Dio get dio => _dio;
}

class AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorageService;

  AuthInterceptor(this._tokenStorageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}

// Centralized error handling based on API Contract 1.4
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      // Parse standardized ErrorResponse schema
      final message = data['message'] ?? 'An unknown error occurred';
      final errorCode = data['error_code'] ?? 'UNKNOWN_ERROR';
      
      // Throw structured exception
      throw ServerException(
        message: message,
        statusCode: response.statusCode,
        errorCode: errorCode,
      );
    }
    
    // Handle network errors or other Dio errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      throw ServerException(message: 'Connection timed out', errorCode: 'TIMEOUT');
    }
    
    // Fallback for unhandled errors
    if (err.error is! ServerException) {
        throw ServerException(message: err.message ?? 'Network error', errorCode: 'NETWORK_ERROR');
    }
    
    super.onError(err, handler);
  }
}