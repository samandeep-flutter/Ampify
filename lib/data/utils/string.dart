sealed class StringRes {
  static const String appName = 'Ampify';

  static const String auth = 'Authenticate';
  static const String submit = 'Submit';
  static const String success = 'Success';
  static const String home = 'Home';
  static const String profile = 'Profile';
  static const String logout = 'Logout';
  static const String cancel = 'Cancel';
  static const String settings = 'Settings';
  static const String refresh = 'Refresh';
  static const String goBack = 'go back';
  static const String somethingWrong = 'Something went wrong';
  static const String listenHistory = 'Listening History';
  static const String noResults = 'No results found, '
      'try using different keyword.';

  // errors
  static const String errorEmail = 'Invalid Email';
  static const String errorPhone = 'Invalid Phone Number';
  static const String errorWeakPass = 'The password provided is too weak';
  static const String errorCriteria = 'Password criteria dosen\'t match';
  static String errorEmpty(String title) => '$title is required';
  static const String errorUnknown = 'Something went wrong, try again';
  static const String errorLoad = 'Failed to load data, refresh to load again';
  static const String errorCredentials = 'Something went wrong,'
      ' please login again';

  // long texts
  static const String authDesc = 'Log in with Spotify to connect and amplify'
      ' your music journey. You\'ll be redirected to a browser for authentication';
  static const String logoutDesc = 'Are you sure you want to log out? You’ll'
      ' need to reconnect to Spotify to use Ampify again.';
  static const String homeSubtitle = 'Turn Up the Volume on Your Music'
      ' Journey!';
  static const String listnHisSubtitle = 'Rediscover your vibe with a curated '
      'view of your listening history.';
  static const String emptyListnHistory = 'No tunes here yet, start  listening'
      ' and your history will appear!';
  static const String searchBarSubtitle = 'Find your favorite tracks, artists,'
      ' or playlists—start typing to explore!';
  static const String emptySearchResults = 'No matches found—try refining '
      'your search or explore something new!';
}
