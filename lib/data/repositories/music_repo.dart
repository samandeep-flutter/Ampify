import 'dart:async';
import 'dart:io';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:dart_ytmusic_api/dart_ytmusic_api.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../data_provider/dio_client.dart';

class MusicRepo {
  final DioClient dio;
  final YTMusic ytMusic;
  final YoutubeExplode ytExplode;

  MusicRepo(
      {required this.ytMusic, required this.ytExplode, required this.dio});

  @protected
  final _ytClients = [YoutubeApiClient.androidVr];

  Future<Uri?> searchSong(String query) async {
    try {
      final songs = await ytMusic.searchSongs(query);
      final manifest = await ytExplode.videos.streams
          .getManifest(songs.first.videoId, ytClients: _ytClients);
      return manifest.adaptiveUri;
    } catch (e) {
      logPrint(e, 'ytExplode');
      return null;
    }
  }

  Future<SongYtDetails?> getDetailsFromQuery(String query) async {
    try {
      final songs = await ytMusic.searchSongs(query);
      final duration = await _getSongDuration(songs.first.videoId);
      return SongYtDetails(songs.first.videoId, duration: duration!);
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
