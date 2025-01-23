import 'package:ampify/services/box_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../services/getit_instance.dart';
import '../repository/auth_repo.dart';
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
  Future<Response> _get(String url, {Options? options}) async {
    final response = await dio.get(url, options: options);
    return response;
  }

  Future<Response> _post(String url, {data, Options? options}) async {
    final response = await dio.post(url, data: data, options: options);
    return response;
  }

  Future<ApiResponse> get(String url,
      {Options? options, required DioClient client}) async {
    final token = BoxServices.to.read(BoxKeys.token);
    final Map<String, dynamic> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token'
    };
    try {
      Response response =
          await client._get(url, options: options ?? Options(headers: headers));
      return ApiResponse.withSuccess(response);
    } catch (_) {
      await getIt<AuthRepo>().refreshToken();
      String token = BoxServices.to.read(BoxKeys.token);
      headers.update('Authorization', (_) => 'Bearer $token');
      try {
        Response response = await client._get(url,
            options: options ?? Options(headers: headers));
        return ApiResponse.withSuccess(response);
      } catch (e) {
        return ApiResponse.withError(e);
      }
    }
  }

  Future<ApiResponse> post(String url,
      {required data, Options? options, required DioClient client}) async {
    final token = BoxServices.to.read(BoxKeys.token);
    final Map<String, dynamic> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token'
    };

    try {
      Response response = await client._post(url,
          data: data, options: options ?? Options(headers: headers));
      return ApiResponse.withSuccess(response);
    } catch (_) {
      await getIt<AuthRepo>().refreshToken();
      String token = BoxServices.to.read(BoxKeys.token);
      headers.update('Authorization', (_) => 'Bearer $token');
      try {
        Response response = await client._post(url,
            data: data, options: options ?? Options(headers: headers));
        return ApiResponse.withSuccess(response);
      } catch (e) {
        return ApiResponse.withError(e);
      }
    }
  }
}

class LoggingInterceptor extends InterceptorsWrapper {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    dprint('${response.statusCode} | ${options.method} | ${options.path}\n'
        // '${response.data.toString()}\n'
        '<--------------------------END HTTP-------------------------->');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logPrint('ERROR [${err.response?.statusCode}] ${err.requestOptions.path}');
    super.onError(err, handler);
  }
}
