import 'pagination_model.dart';

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;
  final PaginationModel? pagination;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'] as T?,
      errors: (json['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      pagination: json['pagination'] != null ? PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'pagination': pagination?.toJson(),
    };
  }
}
