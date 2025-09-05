import 'package:ampify/data/utils/app_constants.dart';
import '../data_provider/api_response.dart';
import '../data_provider/dio_client.dart';

class SearchRepo {
  final DioClient dio;
  const SearchRepo({required this.dio});

  Future<void> search(
    String query, {
    int? limit,
    required Function(Map<String, dynamic> json) onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    if (query.isEmpty) return;
    // add ',artist' to get artists in search.
    final url = '${AppConstants.search}?q=$query&type=album,playlist,track';
    final response = await dio.get('$url&limit=${limit ?? 6}');
    ApiResponse.verify(response,
        onSuccess: onSuccess, onError: onError ?? (e) => logPrint(e, 'search'));
  }
}
