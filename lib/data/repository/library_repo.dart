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
      onError: onError ?? (e) => logPrint(e, 'profile'),
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
      onError: onError ?? (e) => logPrint(e, 'playlist'),
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
      onError: onError ?? (e) => logPrint(e, 'albums'),
    );
  }

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
      onError: onError ?? (e) => logPrint(e, 'liked songs'),
    );
  }

  Future<bool> addtoLikedSongs(String id) async {
    final url = AppConstants.savetoLiked(id);
    final response = await dio.put(url, client: dio);
    return response.response?.statusCode == 200;
  }

  Future<bool> removefromLikedSongs(String id) async {
    final url = AppConstants.savetoLiked(id);
    final response = await dio.delete(url, client: dio);
    return response.response?.statusCode == 200;
  }
}
