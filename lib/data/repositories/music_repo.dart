import 'dart:async';
import 'dart:io';
import 'package:ampify/data/utils/exports.dart';
import 'package:dart_ytmusic_api/dart_ytmusic_api.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MusicRepo {
  @protected
  final DioClient dio;
  @protected
  final YTMusic ytMusic;
  @protected
  final YoutubeExplode ytExplode;

  MusicRepo(
      {required this.ytMusic, required this.ytExplode, required this.dio});

  final _ytClients = [YoutubeApiClient.androidVr];
  Future<SongYtDetails?> getDetailsFromQuery(Track track) async {
    try {
      final artist =
          track.artists?.map((e) => e.name?.toLowerCase() ?? '') ?? [];
      final song = await _search(QuerySong(track.name!, artist));
      final duration = await _getSongDuration(song!.videoId);
      return SongYtDetails(song.videoId, duration: duration!);
    } catch (e) {
      logPrint(e, 'yt-query');
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

  Future<SongDetailed?> _search(QuerySong query) async {
    final songs = await ytMusic.searchSongs(query.text);
    try {
      return songs.firstWhere((e) {
        final _name = e.name.toLowerCase();
        final _artist = e.artist.name.toLowerCase();
        final isSame = _artist.contains(_name);
        return (_name.contains(query.title.toLowerCase())) &&
            (query.artists.any((f) => _artist.contains(f)) || isSame);
      }, orElse: () => throw FormatException());
    } on FormatException {
      return songs.firstElement;
    } catch (e) {
      logPrint(e, 'yt-search');
      return null;
    }
  }

  Future<Duration?> _getSongDuration(String vidId) async {
    try {
      final song = await ytMusic.getSong(vidId);
      return Duration(seconds: song.duration);
    } catch (e) {
      logPrint(e, 'yt-duration');
      return null;
    }
  }

  Future<List<UpNextsDetails>?> getRecomendations(Track track) async {
    try {
      if (track.ytDetails != null) throw FormatException();
      final artist =
          track.artists?.map((e) => e.name?.toLowerCase() ?? '') ?? [];
      final song = await _search(QuerySong(track.name!, artist));
      return await ytMusic.getUpNexts(song!.videoId);
    } on FormatException {
      return await ytMusic.getUpNexts(track.ytDetails!.videoId);
    } catch (e) {
      logPrint(e, 'yt-recomendations');
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

  factory SongYtDetails.fromJson(Map<String, dynamic> json) {
    return SongYtDetails(json['videoId'],
        duration: Duration(seconds: json['duration'] ?? 0));
  }

  Map<String, dynamic> toJson() =>
      {'videoId': videoId, 'duration': duration.inSeconds};
}

class QuerySong {
  final String title;
  final Iterable<String> artists;

  QuerySong(this.title, this.artists);

  String get text => '$title ${artists.first}';
}
