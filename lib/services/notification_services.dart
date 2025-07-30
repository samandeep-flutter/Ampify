import 'package:ampify/config/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../data/utils/app_constants.dart';

class MyNotifications {
  @protected
  static final messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    try {
      await messaging.requestPermission();
      await messaging.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        logPrint('init ${initialMessage.notification!.body}', 'notification');
      }
    } catch (e) {
      logPrint(e, 'fb init');
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logPrint('dataMap ${message.toMap()}', 'notification');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logPrint('onAppOpen ${message.toMap()}', 'notification');
    });
  }
}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFBOptions.currentPlatform);
  } catch (e) {
    logPrint(e, 'notification');
  }
}
