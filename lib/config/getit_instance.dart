import 'package:ampify/data/utils/exports.dart';
import 'package:audio_service/audio_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:app_links/app_links.dart';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> initGetIt() async {
  getIt.registerLazySingleton<AppLinks>(() => AppLinks());
  getIt.registerLazySingleton<YTMusic>(() => YTMusic());
  getIt.registerLazySingleton<InternetConnection>(() => InternetConnection());
  getIt.registerLazySingleton<DioClient>(() => DioClient(dio: Dio()));
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepo(getIt()));
  getIt.registerLazySingleton<HomeRepo>(() => HomeRepo(getIt()));
  getIt.registerLazySingleton<SearchRepo>(() => SearchRepo(getIt()));
  getIt.registerLazySingleton<LibraryRepo>(() => LibraryRepo(getIt()));
  getIt.registerLazySingleton<MusicGroupRepo>(() => MusicGroupRepo(getIt()));
  getIt.registerLazySingleton(
      () => MusicRepo(getIt(), ytMusic: getIt(), ytExplode: YoutubeExplode()));

  // async singletons
  getIt.registerSingletonAsync<AuthServices>(AuthServices.instance.init);
  await getIt.isReady<AuthServices>();
  getIt.registerSingletonAsync<AudioHandler>(audioServicesInit);
  await getIt.isReady<AudioHandler>();
}
