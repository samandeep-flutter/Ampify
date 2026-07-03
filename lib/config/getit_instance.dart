import 'package:ampify/data/utils/exports.dart';
import 'package:audio_service/audio_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> initGetIt() async {
  getIt.registerLazySingleton<YTMusic>(() => YTMusic());
  getIt.registerLazySingleton<LibraryRepo>(() => LibraryRepo());
  getIt.registerLazySingleton<MusicGroupRepo>(() => MusicGroupRepo(getIt()));
  getIt.registerLazySingleton(
      () => MusicRepo(getIt(), ytExplode: YoutubeExplode()));

  // async singletons
  getIt.registerSingletonAsync<AuthServices>(AuthServices.instance.init);
  await getIt.isReady<AuthServices>();
  getIt.registerSingletonAsync<AudioHandler>(audioServicesInit);
  await getIt.isReady<AudioHandler>();
}
