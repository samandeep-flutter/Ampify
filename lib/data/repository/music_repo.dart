import 'package:dart_ytmusic_api/dart_ytmusic_api.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../data_provider/dio_client.dart';

class MusicRepo {
  final DioClient dio;
  final YTMusic ytMusic;
  final YoutubeExplode ytExplode;

  MusicRepo(
      {required this.ytMusic, required this.ytExplode, required this.dio});

  Future<Uri> searchSongs(String query) async {
    List<SongDetailed> songs = await ytMusic.searchSongs(query);
    final id = songs.first.videoId;
    final manifest = await ytExplode.videos.streamsClient.getManifest(id);
    final stream = manifest.audioOnly.withHighestBitrate();
    return stream.url;
  }
}
