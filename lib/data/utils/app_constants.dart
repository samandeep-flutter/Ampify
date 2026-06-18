import 'dart:developer' as dev;
import 'package:ampify/data/utils/exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:oktoast/oktoast.dart';

typedef FirestoreRef = CollectionReference<Map<String, dynamic>>;

sealed class AppConstants {
  static FirestoreRef get usersCollection =>
      FirebaseFirestore.instance.collection(_FBKeys.users);
  static FirestoreRef get searchCollection =>
      FirebaseFirestore.instance.collection(_FBKeys.search);
  static FirestoreRef get historyCollection =>
      FirebaseFirestore.instance.collection(_FBKeys.history);
  static FirestoreRef get libraryCollection =>
      FirebaseFirestore.instance.collection(_FBKeys.library);
  static FirestoreRef likedCollection(String uid) =>
      libraryCollection.doc(uid).collection(_FBKeys.likedTracks);
}

sealed class _FBKeys {
  // static const String about = 'about';
  static const String users = 'users';
  static const String search = 'search';
  static const String history = 'history';
  static const String library = 'library';
  static const String likedTracks = 'liked-tracks';
}

sealed class BoxKeys {
  static const String theme = 'theme';
  static const String themeMode = 'theme-mode';
  static const String deviceInfo = 'device-info';
  static const String logger = 'logger';
  static const String log = 'log';

  static const String uid = 'uid';
  static const String profile = 'profile';

  static bool isGlobal(String key) =>
      [theme, themeMode, log, logger, deviceInfo].contains(key);
  static String get boxName =>
      StringRes.appName.toLowerCase().replaceAll(' ', '-');
}

sealed class UniqueIds {
  static const String artistId = '00-artist';
  static const String likedSongs = '00-liked-songs';
  static const String emptyTrack = '00-empty-track';
  static String radioID(String track) => 'radio:$track';
}

sealed class PlayerActions {
  static const String clearQueue = 'clear-queue';
  static const String removeRange = 'remove-range';
  static const String removeUpcomming = 'remove-upcomming';
}

void _debugLog(Object? value, [String? name, LogType? type]) {
  try {
    final log = value is String? ? value : value.toString();
    if (type == LogType.error) FirebaseCrashlytics.instance.log('[$name] $log');
    if (!kReleaseMode) dev.log(log ?? 'null', name: name ?? StringRes.appName);
    // getIt<LoggerServices>().addLog(log, name: name, type: type);
  } catch (_) {}
}

void debugLog(Object? value, [String? name]) =>
    _debugLog(value, name, LogType.info);
void logPrint(Object? value, [String? name]) =>
    _debugLog(value, name, LogType.error);

void dprint(Object? value, {String? name, String? extra}) {
  final _name = name != null ? '[$name]' : '';
  final log = value is String? ? value : value.toString();
  if (!kReleaseMode) debugPrint('$_name ${log ?? 'null'}');
  // try {
  // if (!getIt.isRegistered<AuthServices>()) return;
  // final LoggerServices auth = getIt();
  // auth.addLog(log, name: name, extra: extra, type: LogType.info);
  // } catch (_) {}
}

class MyColoredBox extends StatelessWidget {
  final Color? color;
  final Widget child;
  const MyColoredBox({super.key, this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: color ?? context.scheme.textColor.withAlpha(50), child: child);
  }
}

void showToast(String text, {int? timeInSec}) {
  if (text.trim().isEmpty) return;
  dismissAllToast();

  final brightness = BoxServices.instance.themeMode.brightness;
  showToastWidget(
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: brightness.isDark ? Colors.grey.shade700 : Colors.black87,
        borderRadius: BorderRadius.circular(Dimens.sizeSmall),
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    ),
    duration: Duration(seconds: timeInSec ?? 2),
    position: ToastPosition.bottom,
    dismissOtherToast: true,
  );
}

void showSnackBar(BuildContext context, {required String text}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      margin: Utils.insetsHoriz(Dimens.sizeSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.borderSmall),
      )));
}
