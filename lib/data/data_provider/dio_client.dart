import 'package:ampify/services/box_services.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../services/getit_instance.dart';
import '../repositories/auth_repo.dart';
import '../utils/app_constants.dart';
import 'api_response.dart';

class DioClient {
  late Dio dio;
  final LoggingInterceptor interceptor;

  DioClient({Dio? dio, required this.interceptor}) {
    this.dio = dio ?? Dio();
    this.dio.options.baseUrl = AppConstants.baseUrl;
    if (kDebugMode) this.dio.interceptors.add(interceptor);
  }
  final _box = BoxServices.instance;

  Future<Response> _get(String url, {Options? options}) async {
    final response = await dio.get(url, options: options);
    return response;
  }

  Future<Response> _post(String url, {data, Options? options}) async {
    final response = await dio.post(url, data: data, options: options);
    return response;
  }

  Future<Response> _put(String url, {data, Options? options}) async {
    final response = await dio.put(url, data: data, options: options);
    return response;
  }

  Future<Response> _delete(String url, {data, Options? options}) async {
    final response = await dio.delete(url, data: data, options: options);
    return response;
  }

  Future<ApiResponse> get(String url, {Options? options}) async {
    final token = _box.read(BoxKeys.token);
    final Map<String, dynamic> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token'
    };
    try {
      final response =
          await _get(url, options: options ?? Options(headers: headers));
      return ApiResponse.withSuccess(response);
    } catch (error) {
      try {
        error as DioException;
        final status = error.response?.data['error']['status'];
        if (status != 401) {
          return ApiResponse.withError(error);
        }
      } catch (_) {}
      await getIt<AuthRepo>().refreshToken();
      String token = _box.read(BoxKeys.token);
      headers.update('Authorization', (_) => 'Bearer $token');
      try {
        final response =
            await _get(url, options: options ?? Options(headers: headers));
        return ApiResponse.withSuccess(response);
      } catch (e) {
        return ApiResponse.withError(e);
      }
    }
  }

  Future<ApiResponse> post(String url,
      {required data, Options? options}) async {
    final token = _box.read(BoxKeys.token);
    final Map<String, dynamic> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token'
    };

    try {
      final response = await _post(url,
          data: data, options: options ?? Options(headers: headers));
      return ApiResponse.withSuccess(response);
    } catch (error) {
      try {
        error as DioException;
        final status = error.response?.data['error']['status'];
        if (status != 401) {
          return ApiResponse.withError(error);
        }
      } catch (_) {}
      await getIt<AuthRepo>().refreshToken();
      String token = _box.read(BoxKeys.token);
      headers.update('Authorization', (_) => 'Bearer $token');
      try {
        final response = await _post(url,
            data: data, options: options ?? Options(headers: headers));
        return ApiResponse.withSuccess(response);
      } catch (e) {
        return ApiResponse.withError(e);
      }
    }
  }

  Future<ApiResponse> put(String url, {dynamic data, Options? options}) async {
    final token = _box.read(BoxKeys.token);
    final Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    try {
      final response = await _put(url,
          data: data, options: options ?? Options(headers: headers));
      return ApiResponse.withSuccess(response);
    } catch (error) {
      try {
        error as DioException;
        final status = error.response?.data['error']['status'];
        if (status != 401) {
          return ApiResponse.withError(error);
        }
      } catch (_) {}
      await getIt<AuthRepo>().refreshToken();
      String token = _box.read(BoxKeys.token);
      headers.update('Authorization', (_) => 'Bearer $token');
      try {
        Response response = await _put(url,
            data: data, options: options ?? Options(headers: headers));
        return ApiResponse.withSuccess(response);
      } catch (e) {
        return ApiResponse.withError(e);
      }
    }
  }

  Future<ApiResponse> delete(String url,
      {dynamic data, Options? options}) async {
    final token = _box.read(BoxKeys.token);
    final Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    try {
      final response = await _delete(url,
          data: data, options: options ?? Options(headers: headers));
      return ApiResponse.withSuccess(response);
    } catch (error) {
      try {
        error as DioException;
        final status = error.response?.data['error']['status'];
        if (status != 401) {
          return ApiResponse.withError(error);
        }
      } catch (_) {}
      await getIt<AuthRepo>().refreshToken();
      String token = _box.read(BoxKeys.token);
      headers.update('Authorization', (_) => 'Bearer $token');
      try {
        final response = await _delete(url,
            data: data, options: options ?? Options(headers: headers));
        return ApiResponse.withSuccess(response);
      } catch (e) {
        return ApiResponse.withError(e);
      }
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
