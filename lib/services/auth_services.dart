import 'dart:async';
import 'dart:io';
import 'package:ampify/data/utils/exports.dart';
import 'package:ampify/services/device_info.dart';
import 'package:app_links/app_links.dart';
import 'package:audio_session/audio_session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

class AuthServices {
  AuthServices._init();
  static AuthServices? _instance;
  static AuthServices get instance => _instance ??= AuthServices._init();

  final _appLinks = AppLinks();
  final _box = BoxServices.instance;
  final _auth = FirebaseAuth.instance;

  final navigator = GlobalKey<NavigatorState>();
  final shellNavigator = GlobalKey<NavigatorState>();

  // BuildContext? get context => navigator.currentContext;
  // BuildContext? get shellContext => shellNavigator.currentContext;

  final connectivity = ValueNotifier<bool>(true);
  bool get isOffline => !connectivity.value;
  final _connectivity = InternetConnection();
  StreamSubscription? _connectivitySub;

  AudioSession? session;
  DeviceInfoModel? deviceInfo;
  Directory? internalDir;

  final _buffer = Duration(seconds: 1);

  Future<AuthServices> init() async {
    try {
      _appLinks.uriLinkStream.listen(_dynamicLinks);
      session = await AudioSession.instance;
      session!.configure(const AudioSessionConfiguration.music());
      internalDir = await getApplicationDocumentsDirectory();
      await getDeviceInfo();
      _verifyConectivity();
      _initStreams();
    } catch (e) {
      logPrint(e, 'auth-init');
    }
    return this;
  }

  void _dynamicLinks(Uri uri) {
    debugLog(uri, 'app-links');
    switch (uri.authority) {
      // case 'spotify-login':
      //   if (Platform.isIOS) return;
      // final AuthRepo authRepo = getIt();
      // final code = uri.queryParameters['code'];
      // authRepo.getToken(code!);
      // break;
    }
  }

  String get initialRoute {
    try {
      _auth.currentUser as User;
      return AppRoutes.homeView;
    } catch (_) {
      return AppRoutes.auth;
    }
  }

  Future<void> _initStreams() async {
    _connectivitySub = _connectivity.onStatusChange.listen((status) {
      _verifyConectivity(status.isConnected);
    });
  }

  Future<void> onStateChanged(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) _verifyConectivity();
  }

  Future<void> _verifyConectivity([bool? value]) async {
    try {
      if (value != null) {
        if (value == connectivity.value) return;
        connectivity.value = value;
        if (!value) Future.delayed(_buffer, _verifyConectivity);
      } else {
        final result = await _connectivity.hasInternetAccess;
        connectivity.value = result;
      }
    } catch (e) {
      logPrint(e, 'connectivity');
    }
  }

  Future<void> getDeviceInfo() async {
    try {
      final json = _box.read(BoxKeys.deviceInfo);
      deviceInfo = DeviceInfoModel.fromJson(json);
    } catch (_) {
      deviceInfo = await Future.microtask(DeviceInfoService.getInfo);
      _box.write(BoxKeys.deviceInfo, deviceInfo?.toJson());
    }
  }

  Future<void> logout() async {
    try {
      List<String> list = [];
      for (var key in _box.keys) {
        if (BoxKeys.isGlobal(key)) continue;
        list.add(key);
      }
      await _auth.signOut();
      await _box.removeAll(list);
    } catch (e) {
      logPrint(e, 'logout');
    } finally {
      navigator.currentContext?.goNamed(AppRoutes.auth);
    }
  }

  void dispose() {
    connectivity.dispose();
    _connectivitySub?.cancel();
  }
}
