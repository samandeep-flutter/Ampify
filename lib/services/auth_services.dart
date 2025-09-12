import 'dart:async';
import 'dart:io';
import 'package:ampify/data/data_models/profile_model.dart';
import 'package:ampify/data/repositories/auth_repo.dart';
import 'package:ampify/data/repositories/library_repo.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:app_links/app_links.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';

class AuthServices {
  AuthServices._init();
  static AuthServices? _to;
  static AuthServices get to => _to ??= AuthServices._init();

  final navigator = GlobalKey<NavigatorState>();
  BuildContext? get context => navigator.currentContext;

  final _connectionStream = StreamController<bool>();
  Stream<bool> get connectionStream => _connectionStream.stream;
  bool _isConnected = true;

  final AppLinks _appLinks = getIt();
  final _box = BoxServices.instance;

  AudioSession? session;
  ProfileModel? profile;

  Future<AuthServices> init() async {
    _appLinks.uriLinkStream.listen(_dynamicLinks);
    try {
      session = await AudioSession.instance;
      _connectionStream.add(true);
    } catch (e) {
      logPrint(e, 'auth init');
    }
    return this;
  }

  void _dynamicLinks(Uri uri) {
    logPrint(uri, 'app_links');
    switch (uri.authority) {
      case 'spotify-login':
        if (Platform.isIOS) return;
        final AuthRepo authRepo = getIt();
        final code = uri.queryParameters['code'];
        authRepo.getToken(code!);
        break;
    }
  }

  String get initialRoute {
    try {
      _box.read(BoxKeys.token) as String;
      return AppRoutes.homeView;
    } catch (_) {
      return AppRoutes.auth;
    }
  }

  Future<void> setConnection(bool result) async {
    if (result == _isConnected) return;
    _connectionStream.add(result);
    _isConnected = result;
  }

  Future<void> getProfile() async {
    final LibraryRepo _libRepo = getIt();
    await _libRepo.getProfile(onSuccess: (json) {
      profile = ProfileModel.fromJson(json);
    });
  }

  Future<void> logout() async {
    await _box.remove(BoxKeys.token);
    await _box.remove(BoxKeys.uid);
    await _box.remove(BoxKeys.refreshToken);
    context?.goNamed(AppRoutes.auth);
  }

  void dispose() {
    _connectionStream.close();
  }
}
