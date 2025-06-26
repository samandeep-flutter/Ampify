sealed class ImageRes {
  static final String spotify = _toIcons('spotify.png');
  static final String thumbnail = _toImages('thumbnail.png');
  static final String userThumbnail = _toImages('user-thumbnail.png');
  static final String history = _toIcons('history.png');
  static final String search = _toIcons('search.png');
  static final String shuffle = _toIcons('shuffle.png');
  static final String musicAlt = _toIcons('music-alt.png');
  static final String music = _toIcons('music.png');
  static final String editMusic = _toIcons('edit_music.png');
  static final String sort = _toIcons('sort.png');
  static final String copyrightC = _toIcons('copyright.png');
  static final String copyrightP = _toIcons('copyright_p.png');
  static final String musicWave = _toIcons('music-wave.gif');
  static final String musicWavePaused = _toIcons('music-wave-paused.png');

  static String _toIcons(String icon) => 'assets/icons/$icon';
  static String _toImages(String icon) => 'assets/images/$icon';
}
