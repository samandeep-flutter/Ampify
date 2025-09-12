import 'dart:async';
import 'dart:io';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/data/utils/exports.dart';
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

  // Future<Uri?> searchSong(String query) async {
  //   try {
  //     final _query = query.split('-').map((e) => e.trim()).toList();
  //     final song = await _search(QuerySong(_query[0], _query[1]));
  //     final manifest = await ytExplode.videos.streams
  //         .getManifest(song!.videoId, ytClients: _ytClients);
  //     return manifest.adaptiveUri;
  //   } catch (e) {
  //     logPrint(e, 'ytExplode');
  //     return null;
  //   }
  // }

  Future<SongYtDetails?> getDetailsFromQuery(String query) async {
    try {
      final _query = query.split('-').map((e) => e.trim()).toList();
      final song = await _search(QuerySong(_query[0], _query[1]));
      final duration = await _getSongDuration(song!.videoId);
      return SongYtDetails(song.videoId, duration: duration!);
    } catch (e) {
      logPrint(e, 'ytMusic');
      return null;
    }
  }

  Future<Uri?> fromVideoId(String? videoId) async {
    try {
      if (videoId == null) return null;
      final manifest = await ytExplode.videos.streams
          .getManifest(videoId, ytClients: _ytClients);
      return manifest.adaptiveUri;
    } catch (e) {
      logPrint(e, 'ytExplode');
      return null;
    }
  }

  Future<SongDetailed?> _search(QuerySong querySong) async {
    try {
      final songs = await ytMusic.searchSongs(querySong.query);
      return songs.firstWhereOrNull((e) {
        final name = e.name.toLowerCase();
        final artist = e.artist.name.toLowerCase();
        return name.contains(querySong.title.toLowerCase()) &&
            artist.contains(querySong.artist.toLowerCase());
      });
    } catch (e) {
      logPrint(e, 'ytMusic');
      return null;
    }
  }

  Future<Duration?> _getSongDuration(String vidId) async {
    try {
      final song = await ytMusic.getSong(vidId);
      return Duration(seconds: song.duration);
    } catch (e) {
      logPrint(e, 'ytMusic');
      return null;
    }
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

class SongYtDetails {
  final String videoId;
  final Duration duration;

  SongYtDetails(this.videoId, {required this.duration});
}

class QuerySong {
  final String title;
  final String artist;

  QuerySong(this.title, this.artist);

  String get query => '$title $artist';
}
