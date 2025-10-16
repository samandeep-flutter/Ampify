import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../data/utils/exports.dart';

typedef Dfunc = void Function(dynamic);

class BoxServices {
  static BoxServices? _instance;
  static BoxServices get instance => _instance ??= BoxServices._init();

  BoxServices._init();

  final box = GetStorage(BoxKeys.boxName);

  MyTheme get theme {
    return MyTheme.values.firstWhere(
      (e) => e.title == box.read(BoxKeys.theme),
      orElse: () => MyTheme.values.first,
    );
  }

  String? get uid => box.read<String>(BoxKeys.uid);

  Future<void> saveTheme(MyTheme theme) async {
    await box.write(BoxKeys.theme, theme.title);
  }

  ThemeMode get themeMode {
    return ThemeMode.values.firstWhere(
      (e) => e.name == box.read(BoxKeys.themeMode),
      orElse: () => ThemeMode.dark,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await box.write(BoxKeys.themeMode, mode.name);
  }

  Future<void> write(String key, dynamic value) async {
    await box.write(key, value);
  }

  void listen(String key, Dfunc listener) => box.listenKey(key, listener);

  T? read<T>(String key) => box.read<T>(key);

  bool exist(String key) => box.hasData(key);

  Future<void> remove(String key) async => await box.remove(key);

  Future<void> clear() async => await box.erase();
}
