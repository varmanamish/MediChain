// lib/services/api_service.dart
import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class ApiService {
  late Dio _dio;
  final SecureStorage _secureStorage = SecureStorage();

  static const String baseUrl =
      'http://10.0.2.2:8081'; // Change to your backend URL
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(milliseconds: connectTimeout),
        receiveTimeout: Duration(milliseconds: receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests
          final token = await _secureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('🚀 [API] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ [API] ${response.statusCode} ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          print(
            '❌ [API] ${error.response?.statusCode} ${error.requestOptions.uri}',
          );

          // Handle token expiration
          if (error.response?.statusCode == 401) {
            final newToken = await _refreshTokenAndRetry(error.requestOptions);
            if (newToken != null) {
              return handler.resolve(await _retryRequest(error.requestOptions));
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _refreshTokenAndRetry(RequestOptions options) async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return null;

      final response = await _dio.post(
        '/api/token/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];
        await _secureStorage.writeToken(newAccessToken);
        return newAccessToken;
      }
    } catch (e) {
      print('Token refresh failed: $e');
      await _secureStorage.clearAll();
    }
    return null;
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions options) async {
    final token = await _secureStorage.getToken();
    options.headers['Authorization'] = 'Bearer $token';

    return _dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(method: options.method, headers: options.headers),
    );
  }

  // Generic HTTP methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, dynamic data) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, dynamic data) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String path, dynamic data) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // File upload
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });

      return await _dio.post(
        path,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Download file
  Future<Response> downloadFile(String path, String savePath) async {
    try {
      return await _dio.download(path, savePath);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception(
        'Connection timeout. Please check your internet connection.',
      );
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception(
        'No internet connection. Please check your network settings.',
      );
    } else if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final message =
          e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.response?.data?['detail'] ??
          'Server error occurred';

      switch (statusCode) {
        case 400:
          return Exception('Bad request: $message');
        case 401:
          return Exception('Unauthorized: Please login again');
        case 403:
          return Exception('Access denied: $message');
        case 404:
          return Exception('Resource not found: $message');
        case 422:
          return Exception('Validation error: $message');
        case 500:
          return Exception('Server error: Please try again later');
        case 502:
          return Exception('Bad gateway: Server is temporarily unavailable');
        case 503:
          return Exception('Service unavailable: Server is under maintenance');
        default:
          return Exception('HTTP error $statusCode: $message');
      }
    } else {
      return Exception('Network error: ${e.message}');
    }
  }

  // Cancel token for canceling requests
  CancelToken createCancelToken() {
    return CancelToken();
  }

  // Update base URL (useful for switching environments)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }
}
