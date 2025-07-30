import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:ampify/data/utils/exports.dart';
import '../data_provider/api_response.dart';
import '../data_provider/dio_client.dart';

class AuthRepo {
  final DioClient dio;
  const AuthRepo({required this.dio});

  @protected
  static final _box = BoxServices.instance;

  @protected
  final _scopes =
      'playlist-read-private playlist-read-collaborative playlist-modify-private playlist-modify-public user-read-recently-played user-read-private user-library-modify user-library-read user-top-read ugc-image-upload';

  Future<String?> auth() async {
    try {
      final data = {
        'response_type': 'code',
        'client_id': dotenv.get(EnvKeys.id),
        'redirect_uri': dotenv.get(EnvKeys.redirect),
        'scope': _scopes,
      };
      final response = await FlutterWebAuth2.authenticate(
        url: Uri.https('accounts.spotify.com', '/authorize', data).toString(),
        callbackUrlScheme: dotenv.get(EnvKeys.redirect).split(':').first,
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
      'redirect_uri': dotenv.get(EnvKeys.redirect),
    };
    final cred = '${dotenv.get(EnvKeys.id)}:${dotenv.get(EnvKeys.secret)}';
    final header = {
      'Authorization': 'Basic ${base64Encode(utf8.encode(cred))}',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    final response = await dio.post(AppConstants.token,
        options: Options(headers: header), data: data);
    ApiResponse.verify(response,
        onSuccess: (json) {
          dprint('token: ${json['access_token']}');
          _box.write(BoxKeys.refreshToken, json['refresh_token']);
          _box.write(BoxKeys.token, json['access_token']);
        },
        onError: (e) => logPrint(e, 'token'));
  }

  Future<void> refreshToken({
    required Function(Map<String, dynamic> json) onSuccess,
    required Function(Map<String, dynamic> error) onError,
  }) async {
    final data = {
      'grant_type': 'refresh_token',
      'refresh_token': _box.read(BoxKeys.refreshToken),
    };
    final cred = '${dotenv.get(EnvKeys.id)}:${dotenv.get(EnvKeys.secret)}';
    final header = {
      'Authorization': 'Basic ${base64Encode(utf8.encode(cred))}',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    final response = await dio.post(AppConstants.token,
        data: data, options: Options(headers: header));
    ApiResponse.verify(response, onSuccess: onSuccess, onError: onError);
  }
}
