import 'dart:io';
import 'dart:ui';
import 'package:ampify/data/utils/exports.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'buisness_logic/home_bloc/home_bloc.dart';
import 'buisness_logic/library_bloc/library_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'buisness_logic/library_bloc/liked_songs_bloc.dart';
import 'buisness_logic/player_bloc/player_bloc.dart';
import 'buisness_logic/player_bloc/player_slider_bloc.dart';
import 'buisness_logic/root_bloc/root_bloc.dart';
import 'buisness_logic/search_bloc/search_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'package:oktoast/oktoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initServices();
  runApp(const LifecycleHandler(child: MyApp()));
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
    await BoxServices.initialize();
    await getIt<YTMusic>().initialize();
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    if (Platform.isIOS || Platform.isAndroid) {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
    if (Platform.isWindows || Platform.isMacOS) {
      await windowManager.ensureInitialized();
      await windowManager.waitUntilReadyToShow(
          WindowOptions(
            skipTaskbar: false,
            size: Utils.defSize,
            minimumSize: Utils.defSize,
            title: StringRes.appName,
            backgroundColor: Colors.transparent,
            titleBarStyle: TitleBarStyle.normal,
          ), () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
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
      builder: _builder,
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

  Widget _builder(BuildContext context, Widget? child) {
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
  }
}

class LifecycleHandler extends StatefulWidget {
  final Widget child;
  const LifecycleHandler({super.key, required this.child});

  @override
  State<LifecycleHandler> createState() => _LifecycleHandlerState();
}

class _LifecycleHandlerState extends State<LifecycleHandler>
    with WidgetsBindingObserver, WindowListener {
  final AuthServices _auth = getIt();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    _auth.dispose();
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _auth.onStateChanged(state);
  }

  @override
  void onWindowFocus() {
    setState(() {});
    // do something
  }

  @override
  Widget build(BuildContext context) {
    return ThemeServices(child: OKToast(child: widget.child));
  }
}
