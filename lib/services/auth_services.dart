import 'dart:io';

import 'package:ampify/data/repository/auth_repo.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/config/routes/app_routes.dart';
import 'package:ampify/services/box_services.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:app_links/app_links.dart';

class AuthServices {
  AuthServices._init();
  static AuthServices? _to;
  static AuthServices get to => _to ??= AuthServices._init();

  final box = BoxServices.to;
  final AuthRepo auth = getIt();

  late String minVersion;

  Future<AuthServices> init() async {
    // _getFirebaseToken();
    final AppLinks appLinks = getIt();
    appLinks.uriLinkStream.listen((uri) {
      logPrint('app_links: ${uri.toString()}');
      switch (uri.authority) {
        case 'spotify-login':
          if (Platform.isIOS) return;
          final AuthRepo authRepo = getIt();
          final code = uri.queryParameters['code'];
          authRepo.getToken(code!);

          break;
        default:
          break;
      }
    });
    return this;
  }

  String navigate() {
    try {
      box.read(BoxKeys.token) as String;
      dprint('refreshing token...');
      auth.refreshToken();
      return AppRoutes.rootView;
    } catch (_) {
      return AppRoutes.auth;
    }
  }
}
