import 'package:ampify/data/data_provider/api_response.dart';
import 'package:ampify/data/data_provider/dio_client.dart';
import 'package:ampify/data/utils/exports.dart';

class HomeRepo {
  final DioClient dio;
  const HomeRepo({required this.dio});

  Future<void> getNewReleases({
    int? limit,
    int? offset,
    required SuccessCallback onSuccess,
    ErrorCallback? onError,
  }) async {
    final url = AppConstants.newReleases(offset ?? 0);
    final response = await dio.get('$url&limit=${limit ?? 10}');
    ApiResponse.verify(response,
        onSuccess: onSuccess,
        onError: onError ?? (e) => logPrint(e, 'releases'));
  }

  Future<void> getSeveralTracks({
    required List<String> ids,
    required SuccessCallback onSuccess,
    ErrorCallback? onError,
  }) async {
    final _ids = ids.asString.noSpace;
    final response = await dio.get(AppConstants.severalTracks(_ids));
    ApiResponse.verify(response,
        onSuccess: onSuccess,
        onError: onError ?? (e) => logPrint(e, 'many-tracks'));
  }

  Future<void> getSeveralAlbums({
    required List<String> ids,
    required SuccessCallback onSuccess,
    ErrorCallback? onError,
  }) async {
    final _ids = ids.asString.noSpace;
    final response = await dio.get(AppConstants.severalTracks(_ids));
    ApiResponse.verify(response,
        onSuccess: onSuccess,
        onError: onError ?? (e) => logPrint(e, 'many-albums'));
  }

  Future<void> browseCategory({
    int? limit,
    required SuccessCallback onSuccess,
    ErrorCallback? onError,
  }) async {
    final url = AppConstants.browse('en_IN');
    final response = await dio.get('$url&limit=${limit ?? 10}');
    ApiResponse.verify(response,
        onSuccess: onSuccess, onError: onError ?? (e) => logPrint(e, 'browse'));
  }

  Future<void> recentlyPlayed(
      {required SuccessCallback onSuccess, ErrorCallback? onError}) async {
    final response = await dio.get(AppConstants.recentlyPlayed);
    ApiResponse.verify(response,
        onSuccess: onSuccess,
        onError: onError ?? (e) => logPrint(e, 'recently'));
  }
}
