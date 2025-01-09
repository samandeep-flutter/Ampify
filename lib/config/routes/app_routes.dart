abstract class AppRoutes {
  static const String auth = 'auth';
  static const String homeView = 'home-view';
  static const String searchView = 'search-view';
  static const String libraryView = 'library-view';
  static const String playlistView = 'playlist-view';
  static const String listnHistory = 'listening-history';
}

abstract class AppRoutePaths {
  static const String auth = '/${AppRoutes.auth}';
  static const String homeView = '/${AppRoutes.homeView}';
  static const String searchView = '/${AppRoutes.searchView}';
  static const String libraryView = '/${AppRoutes.libraryView}';
}
