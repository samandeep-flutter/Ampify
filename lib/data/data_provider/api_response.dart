import 'dart:convert';
import 'package:dio/dio.dart';

class ApiResponse {
  final Response? response;
  final dynamic error;

  ApiResponse.withError(this.error) : response = null;
  ApiResponse.withSuccess(this.response) : error = null;

  static Future<void> verify(
    ApiResponse apiResponse, {
    required Function(Map<String, dynamic> map) onSuccess,
    required Function(Map<String, dynamic> errorMap) onError,
  }) async {
    final response = apiResponse.response;
    if (response != null) {
      Map<String, dynamic> json = response.data;
      if (response.statusCode == 200) {
        onSuccess(json);
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
