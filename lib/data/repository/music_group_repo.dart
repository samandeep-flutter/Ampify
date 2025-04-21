import 'package:ampify/services/box_services.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:dio/dio.dart';
import '../data_provider/api_response.dart';
import '../data_provider/dio_client.dart';
import '../utils/app_constants.dart';

class MusicGroupRepo {
  final DioClient dio;
  const MusicGroupRepo({required this.dio});

  Future<bool> isFavPlaylist(String id) async {
    final url = AppConstants.isFollowPlaylist(id);
    final response = await dio.get(url, client: dio);
    final list = List<bool>.from(response.response?.data ?? []);
    return list.first;
  }

  Future<bool> isFavAlbum(String id) async {
    final url = AppConstants.isFollowAlbum(id);
    final response = await dio.get(url, client: dio);
    final list = List<bool>.from(response.response?.data ?? []);
    return list.first;
  }

  Future<bool> saveAlbum(String id) async {
    final url = AppConstants.saveAlbum(id);
    final response = await dio.put(url, client: dio);
    return response.response?.statusCode == 200;
  }

  Future<bool> removeSavedAlbum(String id) async {
    final url = AppConstants.saveAlbum(id);
    final response = await dio.delete(url, client: dio);
    return response.response?.statusCode == 200;
  }

  Future<bool> savePlaylist(String id) async {
    final url = AppConstants.savePlaylist(id);
    final response = await dio.put(url, client: dio);
    return response.response?.statusCode == 200;
  }

  Future<bool> removeSavedPlaylist(String id) async {
    final url = AppConstants.savePlaylist(id);
    final response = await dio.delete(url, client: dio);
    return response.response?.statusCode == 200;
  }

  Future<void> playlistDetails(
    String id, {
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    final url = AppConstants.playlistDetails(id);
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(
      response,
      onSuccess: onSuccess,
      onError: onError ?? (e) => logPrint(e, 'playlist details'),
    );
  }

  Future<void> albumDetails(
    String id, {
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    final url = AppConstants.albumDetails(id);
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(
      response,
      onSuccess: onSuccess,
      onError: onError ?? (e) => logPrint(e, 'album details'),
    );
  }

  Future<void> getUserPlaylists(
    String? id, {
    int? limit,
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    if (id == null) return;
    final url = AppConstants.userPlaylists(id);
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(
      response,
      onSuccess: onSuccess,
      onError: onError ?? (e) => logPrint(e, 'user playlist'),
    );
  }

  Future<void> createPlaylist(
    String title, {
    required String userId,
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    final token = BoxServices.to.read(BoxKeys.token);
    final url = AppConstants.userPlaylists(userId);
    final body = {'name': title, 'public': true};
    final hearders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await dio.post(url,
        options: Options(headers: hearders), data: body, client: dio);
    ApiResponse.verify(
      response,
      onSuccess: onSuccess,
      onError: onError ?? (e) => logPrint(e, 'create playlist'),
    );
  }

  Future<bool> editPlaylist(
      {required String id,
      required String title,
      required String desc,
      required bool public}) async {
    final token = BoxServices.to.read(BoxKeys.token);
    final url = AppConstants.playlistDetails(id);
    final body = {'name': title, 'description': desc, 'public': public};
    final hearders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await dio.put(url,
        options: Options(headers: hearders), data: body, client: dio);
    return response.response?.statusCode == 200;
  }

  Future<bool> changeCoverImage(
      {required String id, required String image}) async {
    final token = BoxServices.to.read(BoxKeys.token);
    final url = AppConstants.changePlaylistCover(id);
    final hearders = {
      'Content-Type': 'image/jpeg',
      'Authorization': 'Bearer $token'
    };
    final response = await dio.put(url,
        options: Options(headers: hearders), data: image, client: dio);
    return response.response?.statusCode == 202;
  }

  Future<void> addTracktoPlaylist(
    String id, {
    required List<String> trackUri,
    Function(Map<String, dynamic> json)? onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    final uris = trackUri.map((e) => e.replaceAll(':', '%3A')).toList();
    final url = AppConstants.addtoPlaylist(id, uris: uris.asString);
    final body = {"uris": trackUri, "position": 0};

    final response = await dio.post(url, data: body, client: dio);
    ApiResponse.verify(
      response,
      onSuccess: onSuccess ?? (json) {},
      onError: onError ?? (e) => logPrint(e, 'addto playlist'),
    );
  }

  Future<void> removeTrackfromPlaylist(
    String id, {
    required List<String> trackId,
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    final url = AppConstants.removeFromPlaylist(id);
    final body = {"uris": trackId /* "snapshot_id": "" */};

    final response = await dio.delete(url, data: body, client: dio);
    ApiResponse.verify(
      response,
      onSuccess: onSuccess,
      onError: onError ?? (e) => logPrint(e, 'addto playlist'),
    );
  }
}
