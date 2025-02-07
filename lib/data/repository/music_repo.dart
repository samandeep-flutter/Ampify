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

  final _ytClients = [
    if (Platform.isAndroid) YoutubeApiClient.androidVr,
    if (Platform.isIOS) YoutubeApiClient.ios,
  ];

  Future<Uri?> searchSong(String query) async {
    String? id;
    try {
      List<SongDetailed> songs = await ytMusic.searchSongs(query);
      id = songs.first.videoId;
    } catch (e) {
      logPrint(e, 'YT');
    }
    try {
      final manifest = await ytExplode.videos.streams
          .getManifest(id!, ytClients: _ytClients);
      final stream = manifest.audioOnly.withHighestBitrate();
      return stream.url;
    } catch (e) {
      logPrint(e, 'ytExplode');
      return null;
    }
  }
}
