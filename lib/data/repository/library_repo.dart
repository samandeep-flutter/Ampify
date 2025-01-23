import 'package:ampify/data/utils/app_constants.dart';
import '../data_provider/api_response.dart';
import '../data_provider/dio_client.dart';

class LibraryRepo {
  final DioClient dio;
  const LibraryRepo({required this.dio});

  Future<void> getProfile({
    required Function(Map<String, dynamic> map) onSuccess,
    Function(Map<String, dynamic> errorMap)? onError,
  }) async {
    final response = await dio.get(AppConstants.profile, client: dio);
    ApiResponse.verify(
      response,
      onSuccess: onSuccess,
      onError: onError ?? (json) => logPrint('profile: $json'),
    );
  }

  /// limit default to 10.
  Future<void> getMyPlaylists({
    int? offset,
    required Function(Map<String, dynamic> map) onSuccess,
    Function(Map<String, dynamic> errorMap)? onError,
  }) async {
    final url = '${AppConstants.myPlaylists}?offset=${offset ?? 0}&limit=10';
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(
      response,
      onSuccess: onSuccess,
      onError: onError ?? (json) => logPrint('playlist: $json'),
    );
  }

  /// limit default to 10.
  Future<void> getMyAlbums({
    int? offset,
    required Function(Map<String, dynamic> map) onSuccess,
    Function(Map<String, dynamic> errorMap)? onError,
  }) async {
    final url = '${AppConstants.myAlbums}?offset=${offset ?? 0}&limit=10';
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(
      response,
      onSuccess: onSuccess,
      onError: onError ?? (json) => logPrint('albums: $json'),
    );
  }

  // Future<void> getUserPlaylists(
  //   String? id, {
  //   int? limit,
  //   required Function(Map<String, dynamic> map) onSuccess,
  //   Function(Map<String, dynamic> errorMap)? onError,
  // }) async {
  //   if (id == null) return;
  //   final url = AppConstants.userPlaylists(id);
  //   final response = await dio.get(url, client: dio);
  //   ApiResponse.verify(
  //     response,
  //     onSuccess: onSuccess,
  //     onError: onError ?? (json) => logPrint('user playlist: $json'),
  //   );
  // }

  /// Get current user's liked songs
  ///
  /// limit default to 20.
  Future<void> getLikedSongs({
    int? limit,
    int? offset,
    required Function(Map<String, dynamic> map) onSuccess,
    Function(Map<String, dynamic> errorMap)? onError,
  }) async {
    final url = '${AppConstants.likedSongs(offset ?? 0)}&limit=${limit ?? 20}';
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(
      response,
      onSuccess: onSuccess,
      onError: onError ?? (json) => logPrint('liked songs: $json'),
    );
  }

  Future<void> playlistDetails(
    String id, {
    required Function(Map<String, dynamic> map) onSuccess,
    Function(Map<String, dynamic> errorMap)? onError,
  }) async {
    final url = AppConstants.playlistDetails(id);
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(
      response,
      onSuccess: onSuccess,
      onError: onError ?? (json) => logPrint('playlist details: $json'),
    );
  }

  Future<void> albumDetails(
    String id, {
    required Function(Map<String, dynamic> map) onSuccess,
    Function(Map<String, dynamic> errorMap)? onError,
  }) async {
    final url = AppConstants.albumDetails(id);
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(
      response,
      onSuccess: onSuccess,
      onError: onError ?? (json) => logPrint('album details: $json'),
    );
  }
}
