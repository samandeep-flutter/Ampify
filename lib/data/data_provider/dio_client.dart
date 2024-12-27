import 'package:ampify/services/box_services.dart';
import 'package:dio/dio.dart';
import '../../services/getit_instance.dart';
import '../repository/auth_repo.dart';
import '../utils/app_constants.dart';
import '../utils/string.dart';
import 'api_response.dart';

class DioClient {
  late Dio dio;
  final LoggingInterceptor interceptor;

  DioClient({Dio? dio, required this.interceptor}) {
    this.dio = dio ?? Dio();
    this.dio.interceptors.add(interceptor);
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
    try {
      final token = BoxServices.to.read(BoxKeys.token);
      final Map<String, dynamic> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token'
      };
      Response response =
          await client._get(url, options: options ?? Options(headers: headers));
      return ApiResponse.withSuccess(response);
    } catch (error) {
      return ApiResponse.withError(error);
    }
  }

  Future<ApiResponse> post(String url,
      {required data, Options? options, required DioClient client}) async {
    try {
      final token = BoxServices.to.read(BoxKeys.token);
      final Map<String, dynamic> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token'
      };
      Response response = await client._post(url,
          data: data, options: options ?? Options(headers: headers));
      return ApiResponse.withSuccess(response);
    } catch (error) {
      return ApiResponse.withError(error);
    }
  }
}

class LoggingInterceptor extends InterceptorsWrapper {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    logPrint('${response.statusCode} | ${options.method} | ${options.path}');
    logPrint('<--------------------------END HTTP-------------------------->');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logPrint('ERROR [${err.response?.statusCode}] ${err.requestOptions.path}');
    if (err.response?.statusCode == 401) getIt<AuthRepo>().refreshToken();
    showToast(StringRes.errorUnknown);
    super.onError(err, handler);
  }
}
