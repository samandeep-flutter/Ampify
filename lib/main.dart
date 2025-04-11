import 'dart:ui';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:ampify/config/firebase_options.dart';
import 'package:ampify/config/routes/app_pages.dart';
import 'package:dart_ytmusic_api/dart_ytmusic_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'buisness_logic/home_bloc/home_bloc.dart';
import 'buisness_logic/library_bloc/library_bloc.dart';
import 'buisness_logic/library_bloc/liked_songs_bloc.dart';
import 'buisness_logic/root_bloc/addto_playlist_bloc.dart';
import 'buisness_logic/root_bloc/edit_playlist_bloc.dart';
import 'buisness_logic/root_bloc/music_group_bloc.dart';
import 'buisness_logic/player_bloc/player_bloc.dart';
import 'buisness_logic/player_bloc/player_slider_bloc.dart';
import 'buisness_logic/root_bloc/root_bloc.dart';
import 'buisness_logic/search_bloc/search_bloc.dart';
import 'services/getit_instance.dart';
import 'config/theme_services.dart';
import 'services/notification_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initServices();
  runApp(const ThemeServices(child: MyApp()));
}

Future<void> _initServices() async {
  dprint('initServices started...');
  try {
    await Firebase.initializeApp(options: DefaultFBOptions.currentPlatform);
    final fbCrash = FirebaseCrashlytics.instance;
    FlutterError.onError = fbCrash.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      fbCrash.recordError(error, stack, fatal: true);
      return true;
    };
    await getInit();
    await dotenv.load();
    await getIt<YTMusic>().initialize();
    await GetStorage.init(BoxKeys.boxName);
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  } catch (e) {
    logPrint(e, 'init');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.scheme;
    return MaterialApp.router(
      routerConfig: AppPage.routes,
      title: StringRes.appName,
      builder: (context, child) => ResponsiveWrapper.builder(
        ClampingScrollWrapper.builder(
            context,
            MultiBlocProvider(providers: [
              BlocProvider(create: (_) => RootBloc()),
              BlocProvider(create: (_) => PlayerBloc()),
              BlocProvider(create: (_) => PlayerSliderBloc()),
              BlocProvider(create: (_) => MusicGroupBloc()),
              BlocProvider(create: (_) => EditPlaylistBloc()),
              BlocProvider(create: (_) => HomeBloc()),
              BlocProvider(create: (_) => SearchBloc()),
              BlocProvider(create: (_) => LikedSongsBloc()),
              BlocProvider(create: (_) => AddtoPlaylistBloc()),
              BlocProvider(create: (_) => LibraryBloc()),
            ], child: child!)),
        breakpoints: [
          const ResponsiveBreakpoint.resize(450, name: MOBILE),
          const ResponsiveBreakpoint.autoScale(600, name: TABLET),
          const ResponsiveBreakpoint.resize(800, name: DESKTOP),
          const ResponsiveBreakpoint.autoScale(1700, name: '4K'),
        ],
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.primary,
          primary: theme.primary,
          onPrimary: theme.onPrimary,
          primaryContainer: theme.primaryContainer,
          onPrimaryContainer: theme.onPrimaryContainer,
        ),
      ),
    );
  }
}
