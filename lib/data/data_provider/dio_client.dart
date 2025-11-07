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
    dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {'Authorization': 'Bearer ${box.token}'},
    );
    dio.interceptors
        .addAll([TokenInterceptor(dio), if (kDebugMode) LoggingInterceptor()]);
  }

  @protected
  final box = BoxServices.instance;

  Future<Response> _get(String url, {Options? options}) {
    return dio.get(url, options: options);
  }

  Future<Response> _post(String url, {data, Options? options}) {
    return dio.post(url, data: data, options: options);
  }

  Future<Response> _put(String url, {data, Options? options}) {
    return dio.put(url, data: data, options: options);
  }

  Future<Response> _delete(String url, {data, Options? options}) {
    return dio.delete(url, data: data, options: options);
  }

  Future<ApiResponse> get(String url, {Options? options}) async {
    final _options = Options(contentType: 'application/x-www-form-urlencoded');
    try {
      final response = await _get(url, options: options ?? _options);
      return ApiResponse.withSuccess(response);
    } catch (error) {
      return ApiResponse.withError(error);
    }
  }

  Future<ApiResponse> post(String url,
      {required data, Options? options}) async {
    final _options = Options(contentType: 'application/x-www-form-urlencoded');
    try {
      final response =
          await _post(url, data: data, options: options ?? _options);
      return ApiResponse.withSuccess(response);
    } catch (error) {
      return ApiResponse.withError(error);
    }
  }

  Future<ApiResponse> put(String url, {dynamic data, Options? options}) async {
    final _options = Options(contentType: 'application/json');
    try {
      final response =
          await _put(url, data: data, options: options ?? _options);
      return ApiResponse.withSuccess(response);
    } catch (error) {
      return ApiResponse.withError(error);
    }
  }

  Future<ApiResponse> delete(String url,
      {dynamic data, Options? options}) async {
    final _options = Options(contentType: 'application/json');
    try {
      final response =
          await _delete(url, data: data, options: options ?? _options);
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
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = BoxServices.instance.token;
    final _options = options..headers['Authorization'] = 'Bearer $token';
    handler.next(_options);
  }

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
            await box.write(BoxKeys.token, json['access_token']);
            err.requestOptions.headers.update(
                'Authorization', (_) => 'Bearer ${json['access_token']}');
            final response = await dio.fetch(err.requestOptions);
            handler.resolve(response);
          } catch (e) {
            logPrint(e, 're-token');
          } finally {
            completer.complete(true);
          }
        },
        onError: (e) {
          logPrint(e, 're-token');
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

  // @override
  // void onResponse(Response response, ResponseInterceptorHandler handler) {
  //   final options = response.requestOptions;
  //   final status = response.statusCode;

  //   final time = DateTime.now().formatLongTime;
  //   dprint('$status | ${options.method} [$time] | ${options.path}\n'
  //       // '${response.data.toString()}\n'
  //       '<--------------------------END HTTP-------------------------->');
  //   super.onResponse(response, handler);
  // }

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
