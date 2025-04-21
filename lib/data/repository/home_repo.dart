import 'package:ampify/data/data_provider/api_response.dart';
import 'package:ampify/data/data_provider/dio_client.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/services/extension_services.dart';

class HomeRepo {
  final DioClient dio;
  const HomeRepo({required this.dio});

  Future<void> getNewReleases({
    int? limit,
    int? offset,
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    final url = '${AppConstants.newReleases(offset ?? 0)}&limit=${limit ?? 10}';
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(response,
        onSuccess: onSuccess,
        onError: onError ?? (e) => logPrint(e, 'new Release'));
  }

  Future<void> getSeveralTracks({
    required List<String> ids,
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    final url = AppConstants.severalTracks(ids.asString.noSpace);
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(response,
        onSuccess: onSuccess, onError: onError ?? (e) => logPrint(e, 'tracks'));
  }

  Future<void> getSeveralAlbums({
    required List<String> ids,
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    final url = AppConstants.severalTracks(ids.asString.noSpace);
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(response,
        onSuccess: onSuccess, onError: onError ?? (e) => logPrint(e, 'tracks'));
  }

  Future<void> browseCategory({
    int? limit,
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    final url = '${AppConstants.browse('en_IN')}&limit=${limit ?? 10}';
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(response,
        onSuccess: onSuccess, onError: onError ?? (e) => logPrint(e, 'browse'));
  }

  Future<void> recentlyPlayed({
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    const url = AppConstants.recentlyPlayed;
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(response,
        onSuccess: onSuccess, onError: onError ?? (e) => logPrint(e, 'recent'));
  }
}
