import 'dart:ui';
import 'package:ampify/data/utils/exports.dart';
import 'package:ampify/config/firebase_options.dart';
import 'package:dart_ytmusic_api/dart_ytmusic_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'buisness_logic/home_bloc/home_bloc.dart';
import 'buisness_logic/library_bloc/library_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'buisness_logic/library_bloc/liked_songs_bloc.dart';
import 'buisness_logic/player_bloc/player_bloc.dart';
import 'buisness_logic/player_bloc/player_slider_bloc.dart';
import 'buisness_logic/root_bloc/root_bloc.dart';
import 'buisness_logic/search_bloc/search_bloc.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
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
    await initGetIt();
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
    final _box = BoxServices.instance;
    if (_box.read(BoxKeys.token) == null) return;
    await getIt<AuthServices>().getProfile();
  } catch (e) {
    logPrint(e, 'init');
  } finally {
    FlutterNativeSplash.remove();
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
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        ResponsiveFont.init(context);
        return ResponsiveBreakpoints.builder(
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => RootBloc()),
              BlocProvider(create: (_) => PlayerBloc()),
              BlocProvider(create: (_) => PlayerSliderBloc()),
              BlocProvider(create: (_) => HomeBloc()),
              BlocProvider(create: (_) => SearchBloc()),
              BlocProvider(create: (_) => LibraryBloc()),
              BlocProvider(create: (_) => LikedSongsBloc()),
            ],
            child: MaxWidthBox(
              maxWidth: 1200,
              backgroundColor: theme.disabled,
              child: Builder(builder: (context) {
                return ResponsiveScaledBox(
                  width: ResponsiveValue<double?>(context, conditionalValues: [
                    Condition.equals(name: MOBILE, value: 450),
                    Condition.between(start: 800, end: 1100, value: 800),
                    Condition.between(start: 1000, end: 1200, value: 1000),
                  ]).value,
                  child: ClampingScrollWrapper.builder(
                      context, child ?? const SizedBox.shrink()),
                );
              }),
            ),
          ),
        );
      },
      themeMode: theme.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.primary,
          primary: theme.primary,
          onPrimary: theme.onPrimary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.primary,
          primary: theme.primary,
          onPrimary: theme.onPrimary,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
    );
  }
}
