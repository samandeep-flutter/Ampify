abstract class AppRoutes {
  // auth
  static const String auth = 'auth';

  // root
  static const String rootView = 'root-view';
  static const String listnHistory = 'listening-history';
}

abstract class AppRoutePaths {
  static const String auth = '/${AppRoutes.auth}';
  static const String rootView = '/${AppRoutes.rootView}';
}
