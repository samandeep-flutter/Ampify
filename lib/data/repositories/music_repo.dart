import 'dart:async';
import 'package:ampify/data/utils/exports.dart' hide SearchResult;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Playlist;

class YtMusicRepo {
  final YTMusic ytMusic;
  final YoutubeExplode ytExplode;
  YtMusicRepo(this.ytMusic, {required this.ytExplode});

  Future<List<MyHomeSection>> homeSection() async {
    try {
      final _list = await ytMusic.getHomeSections();
      return _list.map((e) => MyHomeSection.fromYT(e)).toList();
    } catch (e) {
      logPrint(e, 'yt-home');
      return [];
    }
  }

  Future<List<LibraryModel>> search(String query) async {
    try {
      final list = await ytMusic.search(query.trim().toLowerCase());
      return List<LibraryModel>.from(list.map((e) => LibraryModel.fromYT(e)));
    } catch (e) {
      logPrint(e, 'yt-search');
      return [];
    }
  }

  Future<Playlist> playlistDetails(String id) async {
    final playlist = await ytMusic.getPlaylist(id);
    return Playlist.fromYT(playlist);
  }

  Future<Album> albumDetails(String id) async {
    final album = await ytMusic.getAlbum(id);
    return Album.fromYtFull(album);
  }

  Future<List<Track>> playlistTracks(String id) async {
    try {
      final list = await ytMusic.getPlaylistVideos(id);
      return List<Track>.from(list.map((e) => Track.fromVid(e)));
    } catch (e) {
      logPrint(e, 'playlist-tracks');
      return [];
    }
  }

  Future<Uri?> fromVideoId(String? videoId) async {
    try {
      if (videoId == null) return null;
      final manifest = await ytExplode.videos.streams
          .getManifest(videoId, ytClients: [YoutubeApiClient.androidVr]);
      return manifest.adaptiveUri;
    } catch (e) {
      logPrint(e, 'ytExplode');
      return null;
    }
  }

  Future<Duration?> getSongDuration(Track item) async {
    try {
      if (item.duration != null) return item.duration;
      final song = await ytMusic.getSong(item.videoId);
      return Duration(seconds: song.duration);
    } catch (e) {
      logPrint(e, 'yt-duration');
      return null;
    }
  }

  Future<List<Track>> getUpNexts(String videoId) async {
    try {
      final list = await ytMusic.getUpNexts(videoId);
      return list.map((e) => Track.fromUpNext(e)).toList();
    } catch (e) {
      logPrint(e, 'up-next');
      return [];
    }
  }
}

extension MyStream on StreamManifest {
  Uri get adaptiveUri {
    if (Platform.isIOS) return muxed.first.url;
    return audioOnly.first.url;
  }
}
