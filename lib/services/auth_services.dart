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
  // final navigator = GlobalKey<NavigatorState>();
  late String minVersion;

  Future<AuthServices> init() async {
    getIt<AppLinks>().uriLinkStream.listen(_dynamicLinks);
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

  String navigate() {
    try {
      box.read(BoxKeys.token) as String;
      return AppRoutes.homeView;
    } catch (_) {
      return AppRoutes.auth;
    }
  }
}
