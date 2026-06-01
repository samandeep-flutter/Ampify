import 'package:ampify/data/utils/exports.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotiServices {
  static NotiServices? _instance;
  static NotiServices get instance => _instance ??= NotiServices._init();
  NotiServices._init();

  static final _messaging = FirebaseMessaging.instance;
  // final _plugin = FlutterLocalNotificationsPlugin();
  // final _box = BoxServices.instance;

  Future<void> initialize() async {
    try {
      // if (Platform.isWindows) return _init();
      await _messaging.requestPermission();
      await _messaging.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugLog('init ${initialMessage.notification!.body}', 'notification');
      }
    } catch (e) {
      logPrint(e, 'fb-init');
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugLog('dataMap ${message.toMap()}', 'notification');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugLog('onAppOpen ${message.toMap()}', 'notification');
    });
  }

  // Future<void> _init() async {
  //   try {
  //     final _device = _box.read(BoxKeys.deviceInfo);
  //     final initDarwin = DarwinInitializationSettings();
  //     final initWin = WindowsInitializationSettings(
  //       appName: StringRes.appName,
  //       appUserModelId: dotenv.get(EnvKeys.bundleID),
  //       guid: _device?['deviceId'] ?? '',
  //     );
  //     await _plugin.initialize(
  //         settings: InitializationSettings(macOS: initDarwin, windows: initWin),
  //         onDidReceiveNotificationResponse: _onDidReceiveResponse);
  //   } catch (e) {
  //     logPrint(e, 'noti-init');
  //   }
  // }

  // void _onDidReceiveResponse(NotificationResponse response) async {
  //   if (response.payload != null) dprint(response.payload, name: 'noti');
  // }

  // Future<void> showNotification(NotiModel noti, {String? payload}) async {
  //   if (noti.title?.trim().isEmpty ?? true) return;
  //   await _plugin.show(
  //     id: int.parse(noti.id),
  //     title: noti.title?.unescape,
  //     body: noti.message?.unescape,
  //     payload: payload,
  // );
  // }

  // Future<bool?> checkPermission() async {
  //   if (!Platform.isMacOS) return null;
  //   final macos = _plugin.resolvePlatformSpecificImplementation<
  //       MacOSFlutterLocalNotificationsPlugin>();
  //   return await macos?.requestPermissions(
  //       alert: true, badge: true, sound: true);
  // }

  // void openSettings() {
  //   if (!Platform.isMacOS) return;
  //   Process.run('open',
  //       ['x-apple.systempreferences:com.apple.preference.notifications']);
  // }
}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    logPrint(e, 'notification');
  }
}
