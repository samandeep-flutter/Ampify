import 'dart:ui';
import 'package:ampify/data/utils/exports.dart';
import 'package:ampify/config/firebase_options.dart';
import 'package:dart_ytmusic_api/dart_ytmusic_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  await _initServices();
  runApp(const ThemeServices(child: MyApp()));
}

Future<void> _initServices() async {
  dprint('initServices started...');
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
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
    LifecycleHandler.instance.init();
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    final _box = BoxServices.instance;
    if (_box.read(BoxKeys.token) == null) return;
    await getIt<AuthServices>().getProfile();
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
      debugShowCheckedModeBanner: false,
      scrollBehavior: CupertinoScrollBehavior(),
      builder: (context, child) {
        ResponsiveFont.init(context);
        return ResponsiveWrapper.builder(
          MultiBlocProvider(providers: [
            BlocProvider(create: (_) => RootBloc()),
            BlocProvider(create: (_) => PlayerBloc()),
            BlocProvider(create: (_) => PlayerSliderBloc()),
            BlocProvider(create: (_) => HomeBloc()),
            BlocProvider(create: (_) => SearchBloc()),
            BlocProvider(create: (_) => LibraryBloc()),
            BlocProvider(create: (_) => LikedSongsBloc()),
          ], child: child ?? const SizedBox.shrink()),
          breakpoints: [
            const ResponsiveBreakpoint.resize(450, name: MOBILE),
            const ResponsiveBreakpoint.autoScale(600, name: TABLET),
            const ResponsiveBreakpoint.resize(800, name: DESKTOP),
            const ResponsiveBreakpoint.autoScale(1700, name: '4K'),
          ],
        );
        // return ResponsiveBreakpoints.builder(
        //   breakpoints: [
        //     const Breakpoint(start: 0, end: 450, name: MOBILE),
        //     const Breakpoint(start: 451, end: 800, name: TABLET),
        //     const Breakpoint(start: 801, end: 1920, name: DESKTOP),
        //     const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        //   ],
        //   child: MultiBlocProvider(
        //     providers: [
        //       // init bloc here
        //     ],
        //     child: MaxWidthBox(
        //       maxWidth: 1200,
        //       backgroundColor: theme.disabled,
        //       child: Builder(builder: (context) {
        //         return ResponsiveScaledBox(
        //           width: ResponsiveValue<double?>(context, conditionalValues: [
        //             Condition.equals(name: MOBILE, value: 450),
        //             Condition.between(start: 800, end: 1100, value: 800),
        //             Condition.between(start: 1000, end: 1200, value: 1000),
        //           ]).value,
        //           child: ClampingScrollWrapper.builder(
        //               context, child ?? const SizedBox.shrink()),
        //         );
        //       }),
        //     ),
        //   ),
        // );
      },
      themeMode: theme.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.primary,
          primary: theme.primary,
          onPrimary: theme.onPrimary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: theme.background,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.primary,
          primary: theme.primary,
          onPrimary: theme.onPrimary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: theme.background,
        useMaterial3: true,
      ),
    );
  }
}

class LifecycleHandler extends WidgetsBindingObserver {
  LifecycleHandler._init();
  static LifecycleHandler? _instance;
  static LifecycleHandler get instance =>
      _instance ??= LifecycleHandler._init();

  final AuthServices auth = getIt();

  void init() => WidgetsBinding.instance.addObserver(this);
  void dispose() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) auth.checkConnectivity();
    super.didChangeAppLifecycleState(state);
  }
}
