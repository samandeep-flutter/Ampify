import 'package:ampify/data/repositories/home_repo.dart';
import 'package:ampify/data/repositories/music_group_repo.dart';
import 'package:ampify/services/audio_services.dart';
import 'package:audio_service/audio_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:ampify/data/repositories/library_repo.dart';
import 'package:ampify/data/repositories/search_repo.dart';
import 'package:ampify/services/auth_services.dart';
import 'package:app_links/app_links.dart';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../data/repositories/auth_repo.dart';
import '../data/data_provider/dio_client.dart';
import '../data/repositories/music_repo.dart';

GetIt getIt = GetIt.instance;

Future<void> getInit() async {
  getIt.registerLazySingleton<AppLinks>(() => AppLinks());
  getIt.registerLazySingleton<YTMusic>(() => YTMusic());
  getIt.registerLazySingleton<YoutubeExplode>(() => YoutubeExplode());
  getIt.registerLazySingletonAsync<AudioHandler>(audioServicesInit);
  getIt.registerSingletonAsync<AuthServices>(AuthServices.to.init);
  getIt.registerLazySingleton<LoggingInterceptor>(() => LoggingInterceptor());
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<DioClient>(
      () => DioClient(dio: getIt(), interceptor: getIt()));
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepo(dio: getIt()));
  getIt.registerLazySingleton<HomeRepo>(() => HomeRepo(dio: getIt()));
  getIt.registerLazySingleton<SearchRepo>(() => SearchRepo(dio: getIt()));
  getIt.registerLazySingleton<LibraryRepo>(() => LibraryRepo(dio: getIt()));
  getIt.registerLazySingleton<MusicGroupRepo>(
      () => MusicGroupRepo(dio: getIt()));
  getIt.registerLazySingleton(
      () => MusicRepo(ytMusic: getIt(), ytExplode: getIt(), dio: getIt()));
}
