import 'package:ampify/data/utils/app_constants.dart';
import '../data_provider/api_response.dart';
import '../data_provider/dio_client.dart';

class LibraryRepo {
  final DioClient dio;
  const LibraryRepo({required this.dio});

  Future<void> getProfile({
    required Function(Map<String, dynamic> map) onSuccess,
    required Function(Map<String, dynamic> errorMap) onError,
  }) async {
    final response = await dio.get(AppConstants.profile, client: dio);
    ApiResponse.verify(response, onSuccess: onSuccess, onError: onError);
  }

  Future<void> getMyPlaylists({
    int? limit,
    required Function(Map<String, dynamic> map) onSuccess,
    required Function(Map<String, dynamic> errorMap) onError,
  }) async {
    final url = '${AppConstants.myPlaylists}?limit=${limit ?? '20'}';
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(response, onSuccess: onSuccess, onError: onError);
  }

  Future<void> getUserPlaylists(
    String? id, {
    int? limit,
    required Function(Map<String, dynamic> map) onSuccess,
    required Function(Map<String, dynamic> errorMap) onError,
  }) async {
    if (id == null) return;
    final url = AppConstants.userPlaylists(id);
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(response, onSuccess: onSuccess, onError: onError);
  }

  Future<void> playlistDetails(
    String id, {
    required Function(Map<String, dynamic> map) onSuccess,
    required Function(Map<String, dynamic> errorMap) onError,
  }) async {
    final url = AppConstants.playlistDetails(id);
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(response, onSuccess: onSuccess, onError: onError);
  }
}
