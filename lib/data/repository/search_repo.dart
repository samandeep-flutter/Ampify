import 'package:ampify/data/utils/app_constants.dart';
import '../data_provider/api_response.dart';
import '../data_provider/dio_client.dart';

class SearchRepo {
  final DioClient dio;
  const SearchRepo({required this.dio});

  Future<void> searchSongs(
    String query, {
    int? limit,
    required Function(Map<String, dynamic> map) onSuccess,
    Function(Map<String, dynamic> errorMap)? onError,
  }) async {
    if (query.isEmpty) return;
    final url = '${AppConstants.search}?q=$query'
        '&type=album%2Cplaylist%2Ctrack%2Cartist&limit=${limit ?? 5}';
    final response = await dio.get(url, client: dio);
    ApiResponse.verify(
      response,
      onSuccess: onSuccess,
      onError: onError ?? (json) => logPrint('search: $json'),
    );
  }
}
