abstract class AppRoutes {
  static const String auth = 'auth';
  static const String homeView = 'home-view';
  static const String searchView = 'search-view';
  static const String likedSongs = 'liked-songs';
  static const String libraryView = 'library-view';
  static const String musicGroup = 'music-group-screen';
  static const String listnHistory = 'listening-history';
  static const String createPlaylist = 'create-playlist';
  static const String modifyPlaylist = 'modify-playlist';
}

abstract class AppRoutePaths {
  static const String auth = '/${AppRoutes.auth}';
  static const String musicGroup = '/${AppRoutes.musicGroup}';
  static const String homeView = '/${AppRoutes.homeView}';
  static const String searchView = '/${AppRoutes.searchView}';
  static const String libraryView = '/${AppRoutes.libraryView}';
  static const String createPlaylist = '/${AppRoutes.createPlaylist}/:userId';
  static const String modifyPlaylist = '/${AppRoutes.modifyPlaylist}';
}
