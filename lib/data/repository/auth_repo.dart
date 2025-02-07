import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import '../../services/box_services.dart';
import '../data_provider/api_response.dart';
import '../data_provider/dio_client.dart';
import '../utils/app_constants.dart';

class AuthRepo {
  final DioClient dio;
  const AuthRepo({required this.dio});

  static final _box = BoxServices.to;

  Future<String?> auth() async {
    const scopes =
        'playlist-read-private playlist-read-collaborative playlist-modify-private playlist-modify-public user-read-recently-played user-read-private user-library-modify user-library-read user-top-read';
    try {
      final data = {
        'response_type': 'code',
        'client_id': dotenv.get('CLIENT_ID'),
        'redirect_uri': dotenv.get('REDIRECT'),
        'scope': scopes,
      };
      final url = Uri.https('accounts.spotify.com', '/authorize', data);
      final response = await FlutterWebAuth.authenticate(
        url: url.toString(),
        callbackUrlScheme: dotenv.get('REDIRECT').split(':').first,
      );
      return Uri.parse(response).queryParameters['code'];
    } catch (e) {
      logPrint(e, 'auth');
      return null;
    }
  }

  Future<void> getToken(String code) async {
    final data = {
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': dotenv.get('REDIRECT'),
    };
    final cred = '${dotenv.get('CLIENT_ID')}:${dotenv.get('CLIENT_SECRET')}';
    final header = {
      'Authorization': 'Basic ${base64Encode(utf8.encode(cred))}',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    final response = await dio.post(AppConstants.token,
        options: Options(headers: header), data: data, client: dio);
    ApiResponse.verify(response,
        onSuccess: (json) {
          dprint('token: ${json['access_token']}');
          _box.write(BoxKeys.refreshToken, json['refresh_token']);
          _box.write(BoxKeys.token, json['access_token']);
        },
        onError: (e) => logPrint(e, 'token'));
  }

  Future<void> refreshToken() async {
    final data = {
      'grant_type': 'refresh_token',
      'refresh_token': _box.read(BoxKeys.refreshToken),
    };
    final cred = '${dotenv.get('CLIENT_ID')}:${dotenv.get('CLIENT_SECRET')}';
    final header = {
      'Authorization': 'Basic ${base64Encode(utf8.encode(cred))}',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    final response = await dio.post(AppConstants.token,
        data: data, client: dio, options: Options(headers: header));
    ApiResponse.verify(response, onSuccess: (json) {
      dprint('refresh: ${json['access_token']}');
      _box.write(BoxKeys.token, json['access_token']);
    }, onError: (e) {
      logPrint(e, 'token');
    });
  }
}
