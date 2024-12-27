import 'dart:developer' as dev;
import 'package:ampify/data/utils/string.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

sealed class AppConstants {
  static const String baseUrl = 'https://api.spotify.com';
  static const String token = 'https://accounts.spotify.com/api/token';
  static const String search = '$baseUrl/v1/search';
}

sealed class BoxKeys {
  static const String boxName = 'ampify';
  static const String theme = '$boxName:theme';
  static const String token = '$boxName:token';
  static const String refreshToken = '$boxName:refresh-token';
}

void logPrint(String? value, {Object? error}) {
  if (kReleaseMode) return;
  dev.log(value ?? 'null', error: error, name: StringRes.appName);
}

void dprint(String? value) {
  if (kReleaseMode) return;
  debugPrint(value ?? 'null');
}

class MyColoredBox extends StatelessWidget {
  final Color? color;
  final Widget child;
  const MyColoredBox({super.key, this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: color ?? Colors.black12, child: child);
  }
}

showToast(String text, {int? timeInSec}) {
  Fluttertoast.showToast(msg: text, timeInSecForIosWeb: timeInSec ?? 1);
}
