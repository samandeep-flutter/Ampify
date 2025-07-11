import 'dart:async';
import 'dart:io';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:dart_ytmusic_api/dart_ytmusic_api.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../data_provider/dio_client.dart';

class MusicRepo {
  final DioClient dio;
  final YTMusic ytMusic;
  final YoutubeExplode ytExplode;

  MusicRepo(
      {required this.ytMusic, required this.ytExplode, required this.dio});

  final _ytClients = [YoutubeApiClient.androidVr];

  Future<SongDetails?> searchSong(String query) async {
    try {
      final _uri = Completer<Uri>();
      final _duration = Completer<Duration>();
      List<SongDetailed> songs = await ytMusic.searchSongs(query);

      fromVideoId(songs.first.videoId).then((uri) {
        _uri.complete(uri);
      });
      _getSongDuration(songs.first.videoId).then((duration) {
        _duration.complete(duration);
      });
      final uri = await _uri.future;
      final duration = await _duration.future;
      return SongDetails(uri, duration: duration);
    } catch (e) {
      logPrint(e, 'ytExplode');
      return null;
    }
  }

  Future<Uri> fromVideoId(String videoId) async {
    final manifest = await ytExplode.videos.streams
        .getManifest(videoId, ytClients: _ytClients);
    return manifest.adaptiveUri;
  }

  Future<Duration> _getSongDuration(String vidId) async {
    final song = await ytMusic.getSong(vidId);
    return Duration(seconds: song.duration);
  }
}

extension MyStream on StreamManifest {
  Uri get adaptiveUri {
    if (Platform.isIOS) return muxed.first.url;
    return audioOnly.first.url;
  }
}

class SongDetails {
  final Uri uri;
  final Duration duration;

  SongDetails(this.uri, {required this.duration});
}
