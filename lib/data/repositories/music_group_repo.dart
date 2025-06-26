import 'package:ampify/services/box_services.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:dio/dio.dart';
import '../data_provider/api_response.dart';
import '../data_provider/dio_client.dart';
import '../utils/app_constants.dart';

class MusicGroupRepo {
  final DioClient dio;
  const MusicGroupRepo({required this.dio});

  static final _box = BoxServices.instance;

  Future<bool> isFavPlaylist(String id) async {
    final response = await dio.get(AppConstants.isFollowPlaylist(id));
    final list = List<bool>.from(response.response?.data ?? []);
    return list.first;
  }

  Future<bool> isFavAlbum(String id) async {
    final response = await dio.get(AppConstants.isFollowAlbum(id));
    final list = List<bool>.from(response.response?.data ?? []);
    return list.first;
  }

  Future<bool> saveAlbum(String id) async {
    final response = await dio.put(AppConstants.saveAlbum(id));
    return response.response?.statusCode == 200;
  }

  Future<bool> removeSavedAlbum(String id) async {
    final response = await dio.delete(AppConstants.saveAlbum(id));
    return response.response?.statusCode == 200;
  }

  Future<bool> savePlaylist(String id) async {
    final response = await dio.put(AppConstants.savePlaylist(id));
    return response.response?.statusCode == 200;
  }

  Future<bool> removeSavedPlaylist(String id) async {
    final response = await dio.delete(AppConstants.savePlaylist(id));
    return response.response?.statusCode == 200;
  }

  Future<void> playlistDetails(
    String id, {
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    final response = await dio.get(AppConstants.playlistDetails(id));
    ApiResponse.verify(response,
        onSuccess: onSuccess,
        onError: onError ?? (e) => logPrint(e, 'playlist details'));
  }

  Future<void> albumDetails(
    String id, {
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    final response = await dio.get(AppConstants.albumDetails(id));
    ApiResponse.verify(response,
        onSuccess: onSuccess,
        onError: onError ?? (e) => logPrint(e, 'album details'));
  }

  Future<void> getUserPlaylists(
    String? id, {
    int? limit,
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    if (id == null) return;
    final response = await dio.get(AppConstants.userPlaylists(id));
    ApiResponse.verify(response,
        onSuccess: onSuccess,
        onError: onError ?? (e) => logPrint(e, 'user playlist'));
  }

  Future<void> createPlaylist(
    String title, {
    required String userId,
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    final token = _box.read(BoxKeys.token);
    final body = {'name': title, 'public': true};
    final hearders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await dio.post(AppConstants.userPlaylists(userId),
        options: Options(headers: hearders), data: body);
    ApiResponse.verify(response,
        onSuccess: onSuccess,
        onError: onError ?? (e) => logPrint(e, 'create playlist'));
  }

  Future<bool> editPlaylist(
      {required String id,
      required String title,
      required String desc,
      required bool public}) async {
    final token = _box.read(BoxKeys.token);
    final body = {'name': title, 'description': desc, 'public': public};
    final hearders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await dio.put(AppConstants.playlistDetails(id),
        options: Options(headers: hearders), data: body);
    return response.response?.statusCode == 200;
  }

  Future<bool> changeCoverImage(
      {required String id, required String image}) async {
    final token = _box.read(BoxKeys.token);
    final hearders = {
      'Content-Type': 'image/jpeg',
      'Authorization': 'Bearer $token'
    };
    final response = await dio.put(AppConstants.changePlaylistCover(id),
        options: Options(headers: hearders), data: image);
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

    final response = await dio.post(url, data: body);
    ApiResponse.verify(response,
        onSuccess: onSuccess ?? (_) {},
        onError: onError ?? (e) => logPrint(e, 'addto playlist'));
  }

  Future<void> removeTrackfromPlaylist(
    String id, {
    required List<String> trackId,
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    final url = AppConstants.removeFromPlaylist(id);
    final body = {"uris": trackId /* "snapshot_id": "" */};

    final response = await dio.delete(url, data: body);
    ApiResponse.verify(response,
        onSuccess: onSuccess,
        onError: onError ?? (e) => logPrint(e, 'addto playlist'));
  }
}
