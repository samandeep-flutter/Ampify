sealed class StringRes {
  static const String appName = 'Ampify';

  static const String auth = 'Authenticate';
  static const String submit = 'Submit';
  static const String success = 'Success';
  static const String home = 'Home';
  static const String search = 'Search';
  static const String library = 'Library';
  static const String playlist = 'Playlist';
  static const String album = 'Album';
  static const String profile = 'Profile';
  static const String logout = 'Logout';
  static const String cancel = 'Cancel';
  static const String close = 'Close';
  static const String share = 'Share';
  static const String create = 'Create';
  static const String gallery = 'via Gallery';
  static const String camera = 'via Camera';
  static const String settings = 'Settings';
  static const String likedSongs = 'Liked Songs';
  static const String refresh = 'Refresh';
  static const String queue = 'Queue';
  static const String goBack = 'go back';
  static const String sortOrder = 'Sort Order';
  static const String sortBy = 'Sort by';
  static const String createPlaylist = 'Create Playlist';
  static const String pubPlaylist = 'Public Playlist';
  static const String priPlaylist = 'Private Playlist';
  static const String nowPublic = 'Playlist is now Public';
  static const String nowPrivate = 'Playlist is now Private';
  static const String nowPlaying = 'Now Playing';
  static const String nextQueue = 'Next in Queue';
  static const String clearQueue = 'Clear Queue';
  static const String queueTitle = 'Playing from play queue';
  static const String myLibrary = 'My Library';
  static const String editCover = 'Edit Cover';
  static const String addTracks = 'Add Tracks to Playlist';
  static const String editDetails = 'Edit Details';
  static const String noImage = 'No Image Selected';
  static const String uploading = 'Uploading...';
  static const String somethingWrong = 'Something went wrong';
  static const String listenHistory = 'Listening History';
  static const String queueAdded = 'Added to you queue';
  static const String detailsUpdated = 'Playlist details updated';
  static const String playlistName = 'Give your playlist a name';
  static const String noQueue = 'Play a track in order to add to queue';
  static const String noResults = 'No results found, '
      'try using different keyword.';

  static const String addtoLiked = 'Add to Liked Songs';
  static const String removeLiked = 'Remove from Liked Songs';
  static const String addtoPlaylist = 'Add to Playlist';
  static const String gotoAlbum = 'Go to Album';
  static const String addtoQueue = 'Add to Queue';

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
  static const String noPlaylists = 'No playlists available. '
      'Create a playlist to get started!';
  static const String emptyPlaylists = 'Your playlist is empty, \nstart '
      'adding some tracks to set the vibe!';
  static const String playlistDesc = 'Add a short description to'
      ' personalize your playlist.';
}
