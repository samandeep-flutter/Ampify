import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ampify/data/data_models/profile_model.dart';
import 'package:ampify/data/repositories/auth_repo.dart';
import 'package:ampify/data/repositories/library_repo.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:app_links/app_links.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';

class AuthServices {
  AuthServices._init();
  static AuthServices? _instance;
  static AuthServices get instance => _instance ??= AuthServices._init();

  final AppLinks _appLinks = getIt();
  final Connectivity _connectivity = getIt();
  final AuthRepo _authRepo = getIt();
  final _box = BoxServices.instance;

  final navigator = GlobalKey<NavigatorState>();
  final shellNavigator = GlobalKey<NavigatorState>();
  // BuildContext? get context => navigator.currentContext;
  // BuildContext? get shellContext => shellNavigator.currentContext;

  final _connectionStream = StreamController<bool>();
  Stream<bool> get connectionStream => _connectionStream.stream;
  bool _isConnected = true;

  AudioSession? session;
  ProfileModel? profile;

  Future<AuthServices> init() async {
    _appLinks.uriLinkStream.listen(_dynamicLinks);
    _connectivity.onConnectivityChanged.listen(checkConnectivity);
    try {
      session = await AudioSession.instance;
      session!.configure(const AudioSessionConfiguration.music());
      _connectionStream.add(true);
    } catch (e) {
      logPrint(e, 'auth init');
    }
    return this;
  }

  void _dynamicLinks(Uri uri) {
    debugLog(uri, 'app_links');
    switch (uri.authority) {
      case 'spotify-login':
        if (Platform.isIOS) return;
        final AuthRepo authRepo = getIt();
        final code = uri.queryParameters['code'];
        authRepo.getToken(code!);
        break;
    }
  }

  void checkConnectivity([List<ConnectivityResult>? _]) async {
    final _result = await _authRepo.checkConnection();
    setConnection(_result);
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
    navigator.currentContext?.goNamed(AppRoutes.auth);
  }

  void dispose() {
    _connectionStream.close();
  }
}
