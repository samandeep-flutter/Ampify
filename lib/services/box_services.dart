import 'package:ampify/services/theme_services.dart';
import 'package:ampify/data/data_models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../data/utils/app_constants.dart';

typedef Dfunc = void Function(dynamic);

class BoxServices {
  static BoxServices? _instance;
  static BoxServices get instance => _instance ??= BoxServices._init();

  BoxServices._init();

  final box = GetStorage(BoxKeys.boxName);

  MyTheme get theme {
    String? title = box.read(BoxKeys.theme);
    return MyTheme.values.firstWhere(
      (element) => element.title == title,
      orElse: () => MyTheme.values.first,
    );
  }

  ProfileModel? get profile {
    try {
      final json = box.read(BoxKeys.profile);
      return ProfileModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTheme(MyTheme theme) async {
    await box.write(BoxKeys.theme, theme.title);
  }

  ThemeMode get themeMode {
    String? brightness = box.read(BoxKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (element) => element.name == brightness,
      orElse: () => ThemeMode.system,
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
