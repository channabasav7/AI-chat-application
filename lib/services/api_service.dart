import 'package:dio/dio.dart';
import 'package:ai_chatbot/config/app_config.dart';

/// Handles API calls to external services
class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
  }

  late Dio _dio;

  // ===== OpenAI API Methods =====

  /// Call OpenAI ChatGPT API
  Future<String> callOpenAI(String prompt) async {
    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.openaiApiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        },
      );

      if (response.statusCode == 200) {
        final message = response.data['choices'][0]['message']['content'] as String;
        return message;
      } else {
        throw Exception('Failed to get response from OpenAI');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ===== Google API Methods =====

  /// Call Google API (example: places, translate, etc.)
  Future<dynamic> callGoogleAPI({
    required String endpoint,
    required Map<String, dynamic> params,
  }) async {
    try {
      params['key'] = AppConfig.googleApiKey;

      final response = await _dio.get(
        'https://www.googleapis.com/v1/$endpoint',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get response from Google API');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ===== Generic HTTP Methods =====

  /// Generic GET request
  Future<dynamic> get({
    required String url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        url,
        options: headers != null ? Options(headers: headers) : null,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generic POST request
  Future<dynamic> post({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generic PUT request
  Future<dynamic> put({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: data,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generic DELETE request
  Future<dynamic> delete({
    required String url,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ===== Helper Methods =====

  String _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.badResponse:
        return 'Bad response: ${e.response?.statusCode} - ${e.response?.data}';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.unknown:
        return 'Unknown error: ${e.error}';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  /// Set custom headers for all requests
  void setDefaultHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// Add interceptor for debugging
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Dispose API service
  void dispose() {
    _dio.close();
  }
}
