import 'package:ampify/data/utils/exports.dart';
import '../data_provider/api_response.dart';
import '../data_provider/dio_client.dart';

class LibraryRepo {
  final DioClient dio;
  const LibraryRepo({required this.dio});

  Future<void> getProfile(
      {required SuccessCallback onSuccess, ErrorCallback? onError}) async {
    final response = await dio.get(AppConstants.profile);
    ApiResponse.verify(
      response,
      onSuccess: onSuccess,
      onError: onError ?? (e) => logPrint(e, 'profile'),
    );
  }

  /// limit default to 10.
  Future<void> getMyPlaylists({
    int? offset,
    required SuccessCallback onSuccess,
    ErrorCallback? onError,
  }) async {
    const url = AppConstants.myPlaylists;
    // add '&limit=10' to limit to 10
    final response = await dio.get('$url?offset=${offset ?? 0}');
    ApiResponse.verify(response,
        onSuccess: onSuccess,
        onError: onError ?? (e) => logPrint(e, 'playlist'));
  }

  /// limit default to 10.
  Future<void> getMyAlbums({
    int? offset,
    required SuccessCallback onSuccess,
    ErrorCallback? onError,
  }) async {
    const url = AppConstants.myAlbums;
    // add '&limit=10' to limit to 10
    final response = await dio.get('$url?offset=${offset ?? 0}');
    ApiResponse.verify(response,
        onSuccess: onSuccess, onError: onError ?? (e) => logPrint(e, 'albums'));
  }

  /// Get current user's liked songs
  ///
  /// limit default to 20.
  Future<void> getLikedSongs({
    int? limit,
    int? offset,
    required SuccessCallback onSuccess,
    ErrorCallback? onError,
  }) async {
    final url = AppConstants.likedSongs(offset ?? 0);
    final response = await dio.get('$url&limit=${limit ?? 20}');
    ApiResponse.verify(response,
        onSuccess: onSuccess,
        onError: onError ?? (e) => logPrint(e, 'liked songs'));
  }

  Future<bool> addtoLikedSongs(String id) async {
    final response = await dio.put(AppConstants.savetoLiked(id));
    return response.response?.statusCode == 200;
  }

  Future<bool> removefromLikedSongs(String id) async {
    final response = await dio.delete(AppConstants.savetoLiked(id));
    return response.response?.statusCode == 200;
  }

  Future<List<bool>> isLiked(List<String> ids) async {
    final response = await dio.get(AppConstants.checkSaved(ids.asString));
    return List<bool>.from(response.response?.data ?? []);
  }
}
