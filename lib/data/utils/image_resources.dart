sealed class ImageRes {
  static String get thumbnail => _toImages('thumbnail.png');
  static String get userThumbnail => _toImages('user-thumbnail.png');

  static String get google => _toIcons('google.png');
  static String get history => _toIcons('history.png');
  static String get search => _toIcons('search.png');
  static String get shuffle => _toIcons('shuffle.png');
  static String get musicAlt => _toIcons('music-alt.png');
  static String get music => _toIcons('music.png');
  static String get sort => _toIcons('sort.png');

  static String get musicWave => _toIcons('music-wave.gif');
  static String get musicWavePaused => _toIcons('music-wave-paused.png');

  static String _toIcons(String icon) => 'assets/icons/$icon';
  static String _toImages(String icon) => 'assets/images/$icon';
}
