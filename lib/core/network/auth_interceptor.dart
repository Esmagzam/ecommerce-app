import 'dart:io';

import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService secureStorageService;
  final void Function()? onUnauthorized;

  AuthInterceptor({required this.secureStorageService, this.onUnauthorized});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept'] = 'application/json';

    final token = await secureStorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await secureStorageService.deleteToken();
      onUnauthorized?.call();
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: const UnauthorizedException(),
        ),
      );
    }

    if (err.response?.statusCode == 422) {
      final data = err.response?.data;
      String message = 'Баталгаажуулалтын алдаа гарлаа.';
      Map<String, List<String>> fieldErrors = {};

      if (data is Map<String, dynamic>) {
        if (data['message'] != null) {
          message = data['message'].toString();
        }
        if (data['errors'] is Map) {
          final rawErrors = data['errors'] as Map;
          rawErrors.forEach((key, value) {
            if (value is List) {
              fieldErrors[key.toString()] = value
                  .map((e) => e.toString())
                  .toList();
            } else if (value is String) {
              fieldErrors[key.toString()] = [value];
            }
          });
        }
      }

      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: ServerException(
            message: message,
            statusCode: 422,
            fieldErrors: fieldErrors,
          ),
        ),
      );
    }

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.error is SocketException) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: const NetworkException(),
        ),
      );
    }

    if (err.response != null) {
      final data = err.response?.data;
      String message =
          'Сервертэй холбогдоход алдаа гарлаа (${err.response?.statusCode}).';
      if (data is Map<String, dynamic> && data['message'] != null) {
        message = data['message'].toString();
      }
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: ServerException(
            message: message,
            statusCode: err.response?.statusCode,
          ),
        ),
      );
    }

    return handler.next(err);
  }
}
