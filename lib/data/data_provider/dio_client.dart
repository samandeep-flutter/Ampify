import 'dart:async';
import 'dart:io';
import 'package:ampify/data/utils/exports.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../repositories/auth_repo.dart';
import 'api_response.dart';

class DioClient {
  final Dio dio;

  DioClient({required this.dio}) {
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.interceptors
        .addAll([TokenInterceptor(dio), if (kDebugMode) LoggingInterceptor()]);
  }
  @protected
  final box = BoxServices.instance;

  @protected
  Future<Response> _get(String url, {Options? options}) async {
    final response = await dio.get(url, options: options);
    return response;
  }

  @protected
  Future<Response> _post(String url, {data, Options? options}) async {
    final response = await dio.post(url, data: data, options: options);
    return response;
  }

  @protected
  Future<Response> _put(String url, {data, Options? options}) async {
    final response = await dio.put(url, data: data, options: options);
    return response;
  }

  @protected
  Future<Response> _delete(String url, {data, Options? options}) async {
    final response = await dio.delete(url, data: data, options: options);
    return response;
  }

  Future<ApiResponse> get(String url, {Options? options}) async {
    final token = box.read(BoxKeys.token);
    final Map<String, dynamic> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token'
    };
    try {
      final response =
          await _get(url, options: options ?? Options(headers: headers));
      return ApiResponse.withSuccess(response);
    } catch (error) {
      return ApiResponse.withError(error);
    }
  }

  Future<ApiResponse> post(String url,
      {required data, Options? options}) async {
    final token = box.read(BoxKeys.token);
    final Map<String, dynamic> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token'
    };
    try {
      final response = await _post(url,
          data: data, options: options ?? Options(headers: headers));
      return ApiResponse.withSuccess(response);
    } catch (error) {
      return ApiResponse.withError(error);
    }
  }

  Future<ApiResponse> put(String url, {dynamic data, Options? options}) async {
    final token = box.read(BoxKeys.token);
    final Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    try {
      final response = await _put(url,
          data: data, options: options ?? Options(headers: headers));
      return ApiResponse.withSuccess(response);
    } catch (error) {
      return ApiResponse.withError(error);
    }
  }

  Future<ApiResponse> delete(String url,
      {dynamic data, Options? options}) async {
    final token = box.read(BoxKeys.token);
    final Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    try {
      final response = await _delete(url,
          data: data, options: options ?? Options(headers: headers));
      return ApiResponse.withSuccess(response);
    } catch (error) {
      return ApiResponse.withError(error);
    }
  }
}

class TokenInterceptor extends QueuedInterceptorsWrapper {
  final Dio dio;
  TokenInterceptor(this.dio);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    getIt<AuthServices>().setConnection(true);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      final box = BoxServices.instance;
      final completer = Completer<bool>();

      final status = err.response?.data['error']['status'];
      if (status != 401) throw err;

      getIt<AuthRepo>().refreshToken(
        onSuccess: (json) async {
          try {
            dprint('refresh: ${json['access_token']}');
            box.write(BoxKeys.token, json['access_token']);
            err.requestOptions.headers.update(
                'Authorization', (_) => 'Bearer ${json['access_token']}');
            final response = await dio.fetch(err.requestOptions);
            handler.resolve(response);
          } catch (e) {
            logPrint(e, 'token');
          } finally {
            completer.complete(true);
          }
        },
        onError: (e) {
          logPrint(e, 'token');
          completer.completeError(e);
          handler.reject(err);
        },
      );
      await completer.future;
    } on DioException catch (e) {
      if (e.error is SocketException) {
        getIt<AuthServices>().setConnection(false);
      }
      logPrint(e, 'DIO');
      handler.reject(err);
    }
  }
}

class LoggingInterceptor extends InterceptorsWrapper {
  // @override
  // void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
  //   final path = options.uri.path;
  //   dprint('$path\n ${options.data}');
  //   super.onRequest(options, handler);
  // }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final status = response.statusCode;

    final time = DateTime.now().formatTime;
    dprint('$status | ${options.method} [$time] | ${options.path}\n'
        // '${response.data.toString()}\n'
        '<--------------------------END HTTP-------------------------->');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final status = err.response?.statusCode;
    logPrint(
        'ERROR [$status] ${options.method} | ${options.path}'
            '\n${err.response?.data}',
        'DIO');
    super.onError(err, handler);
  }
}
