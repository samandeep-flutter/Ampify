import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

typedef SuccessCallback = FutureOr<void> Function(Map<String, dynamic> json);
typedef ErrorCallback = void Function(Map<String, dynamic> error);

class ApiResponse {
  final Response? response;
  final dynamic error;

  ApiResponse.withError(this.error) : response = null;
  ApiResponse.withSuccess(this.response) : error = null;

  static Future<void> verify(
    ApiResponse apiResponse, {
    required SuccessCallback onSuccess,
    required ErrorCallback onError,
  }) async {
    final response = apiResponse.response;
    if (response != null) {
      final json = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          await onSuccess(json);
        } catch (error) {
          if (error is Map<String, dynamic>) {
            onError(error);
          } else {
            onError({'error': error.toString()});
          }
        }
        return;
      }
    }
    try {
      final error = jsonDecode(apiResponse.error);
      onError(error);
    } catch (_) {
      final err = apiResponse.error as DioException;
      final res = err.response;
      try {
        onError(res?.data);
      } catch (_) {
        onError({'${res?.statusCode}': res?.data});
      }
    }
  }
}
