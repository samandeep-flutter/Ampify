import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ampify/data/utils/exports.dart';

class DioClient {
  final Dio dio;
  DioClient({required this.dio}) {
    dio.options = BaseOptions(
      baseUrl: dotenv.get(EnvKeys.baseURL),
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
    try {
      final key = options.headers['Authorization'] as String?;
      if (!(key?.startsWith('Bearer') ?? false)) throw Exception();
      final token = BoxServices.instance.token;
      final _options = options..headers['Authorization'] = 'Bearer $token';
      handler.next(_options);
    } catch (_) {
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      final box = BoxServices.instance;
      final completer = Completer<bool>();
      if (err.response?.statusCode != 401) throw err;

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
    } catch (e) {
      logPrint(e, 'DIO');
      handler.reject(err);
    }
  }
}

class LoggingInterceptor extends InterceptorsWrapper {
  // @override
  // void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
  //   final path = options.uri.path;
  //   dprint('$path ${options.data != null ? '\n${_data(options.data)}' : ''}',
  //       name: 'DIO-request', extra: _data(options.data));
  //   super.onRequest(options, handler);
  // }

  // String _data(dynamic data) {
  // if (data is FormData) {
  //   final fields = Map.fromEntries(data.fields.map((e) {
  //     return MapEntry(e.key, e.value.trunacate());
  //   }));
  //   final files = Map.fromEntries(
  //       data.files.map((e) => MapEntry(e.key, e.value.filename)));
  //   return {...fields, ...files}.toString();
  // } else if (data is Map) {
  //   return data.map((e, v) {
  //     final value = v.toString().trunacate();
  //     return MapEntry(e.toString(), value);
  //   }).toString();
  // }
  // return data.toString();
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
