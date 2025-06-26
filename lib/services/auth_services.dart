import 'dart:io';
import 'package:ampify/data/repositories/auth_repo.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/config/routes/app_routes.dart';
import 'package:ampify/services/box_services.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthServices {
  AuthServices._init();
  static AuthServices? _to;
  static AuthServices get to => _to ??= AuthServices._init();

  final navigator = GlobalKey<NavigatorState>();
  BuildContext? get context => navigator.currentContext;

  final AppLinks _appLinks = getIt();
  final box = BoxServices.instance;

  Future<AuthServices> init() async {
    _appLinks.uriLinkStream.listen(_dynamicLinks);
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
      box.read(BoxKeys.token) as String;
      return AppRoutes.homeView;
    } catch (_) {
      return AppRoutes.auth;
    }
  }

  Future<void> logout() async {
    await box.remove(BoxKeys.token);
    await box.remove(BoxKeys.profile);
    await box.remove(BoxKeys.refreshToken);
    context?.goNamed(AppRoutes.auth);
  }
}
