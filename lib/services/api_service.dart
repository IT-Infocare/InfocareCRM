import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../utils/logger.dart';

class ApiService {
  late final Dio _dio;
  String? _authToken;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(seconds: AppConfig.apiTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppConfig.apiTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (AppConfig.supabasePublishableKey.isNotEmpty) 'apikey': AppConfig.supabasePublishableKey,
          if (AppConfig.supabasePublishableKey.isNotEmpty) 'Prefer': 'return=representation',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          } else if (AppConfig.supabasePublishableKey.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${AppConfig.supabasePublishableKey}';
          }
          Logger.api(options.method, options.path);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          Logger.api(
            response.requestOptions.method,
            response.requestOptions.path,
            statusCode: response.statusCode,
          );
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          Logger.error(
            'API Error on ${error.requestOptions.method} ${error.requestOptions.path}: ${error.message}',
            error.response?.data,
          );
          return handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  ApiResponse<T> _parseResponse<T>(dynamic rawData, T Function(dynamic json)? fromJson) {
    if (rawData is Map<String, dynamic>) {
      if (rawData.containsKey('success') && rawData.containsKey('data')) {
        return ApiResponse<T>.fromJson(rawData, fromJson);
      }
      return ApiResponse<T>(
        success: true,
        data: fromJson != null ? fromJson(rawData) : rawData as T?,
      );
    }
    if (rawData is List) {
      if (fromJson != null) {
        try {
          final parsed = fromJson(rawData);
          return ApiResponse<T>(success: true, data: parsed);
        } catch (_) {
          if (rawData.isNotEmpty) {
            final parsedSingle = fromJson(rawData.first);
            return ApiResponse<T>(success: true, data: parsedSingle);
          }
        }
      }
    }
    return ApiResponse<T>(
      success: true,
      data: fromJson != null ? fromJson(rawData) : rawData as T?,
    );
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return _parseResponse<T>(response.data, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse<T>(success: false, message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data, queryParameters: queryParameters);
      return _parseResponse<T>(response.data, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse<T>(success: false, message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return _parseResponse<T>(response.data, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse<T>(success: false, message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
      return _parseResponse<T>(response.data, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse<T>(success: false, message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(endpoint);
      return _parseResponse<T>(response.data, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse<T>(success: false, message: 'An unexpected error occurred: $e');
    }
  }

  ApiResponse<T> _handleDioError<T>(DioException e) {
    final statusCode = e.response?.statusCode;
    String message = 'Network communication error';
    List<String>? errors;

    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('message') && data['message'] != null) {
        message = data['message'].toString();
      } else if (data.containsKey('error') && data['error'] != null) {
        message = data['error'].toString();
      } else if (data.containsKey('hint') && data['hint'] != null) {
        message = data['hint'].toString();
      }

      if (data['errors'] is List) {
        errors = (data['errors'] as List).map((e) => e.toString()).toList();
      } else if (data.containsKey('details') && data['details'] != null) {
        errors = [data['details'].toString()];
      }
    } else {
      switch (statusCode) {
        case 400:
          message = 'Bad request';
          break;
        case 401:
          message = 'Unauthorized or session expired';
          break;
        case 403:
          message = 'Permission denied';
          break;
        case 404:
          message = 'Requested resource not found';
          break;
        case 409:
          message = 'Conflict or duplicate entry detected';
          break;
        case 422:
          message = 'Validation errors occurred';
          break;
        case 500:
          message = 'Internal server error';
          break;
      }
    }

    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
    );
  }
}
