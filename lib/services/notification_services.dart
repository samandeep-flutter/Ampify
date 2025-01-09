import 'package:ampify/config/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/utils/app_constants.dart';

class MyNotifications {
  static final messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    try {
      await messaging.requestPermission();
      await messaging.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        logPrint('notification: init ${initialMessage.notification!.body}');
      }
    } catch (e) {
      logPrint('fb init: $e');
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logPrint("notification: dataMap ${message.toMap()}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logPrint("notification: onAppOpen ${message.toMap()}");
    });
  }
}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFBOptions.currentPlatform);
  } catch (e) {
    logPrint(e.toString());
  }
}
