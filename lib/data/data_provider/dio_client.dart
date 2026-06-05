import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ampify/data/utils/exports.dart';

class DioClient {
  final Dio dio;
  DioClient({required this.dio}) {
    dio.options = BaseOptions(baseUrl: dotenv.get(EnvKeys.baseURL));
    if (kDebugMode) dio.interceptors.add(LoggingInterceptor());
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

class LoggingInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.uri.path;
    dprint('$path ${options.data != null ? '\n${_data(options.data)}' : ''}',
        name: 'DIO-request', extra: _data(options.data));
    super.onRequest(options, handler);
  }

  String _data(dynamic data) {
    if (data is FormData) {
      final fields = Map.fromEntries(data.fields.map((e) {
        return MapEntry(e.key, e.value.trunacate());
      }));
      final files = Map.fromEntries(
          data.files.map((e) => MapEntry(e.key, e.value.filename)));
      return {...fields, ...files}.toString();
    } else if (data is Map) {
      return data.map((e, v) {
        final value = v.toString().trunacate();
        return MapEntry(e.toString(), value);
      }).toString();
    }
    return data.toString();
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final status = response.statusCode;

    final time = DateTime.now().formatLongTime;
    dprint('$status | ${options.method} [$time] | ${options.path}\n'
        // '${response.data.toString()}\n'
        '<--------------------------END HTTP-------------------------->');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final data = err.response?.data;
    logPrint(
        'ERROR [${err.error.runtimeType}] ${err.type.name} | '
            '${options.method} | ${options.path} ${data != null ? '\n$data' : ''}',
        'DIO-error');
    super.onError(err, handler);
  }
}
