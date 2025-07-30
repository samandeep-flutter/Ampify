// ignore_for_file: library_private_types_in_public_api

import 'package:ampify/data/utils/exports.dart';
import 'package:flutter/material.dart';

class _Themes extends InheritedWidget {
  final _ThemeServiceState data;
  const _Themes({required super.child, required this.data});

  @override
  bool updateShouldNotify(_Themes oldWidget) => true;
}

class ThemeServices extends StatefulWidget {
  final Widget child;
  const ThemeServices({super.key, required this.child});

  static _ThemeServiceState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_Themes>()?.data;
  }

  static _ThemeServiceState of(BuildContext context) {
    assert(maybeOf(context) != null);
    return maybeOf(context)!;
  }

  @override
  State<ThemeServices> createState() => _ThemeServiceState();
}

extension MyThemeState on BuildContext {
  _ThemeServiceState get scheme => ThemeServices.of(this);
}

class _ThemeServiceState extends State<ThemeServices> {
  @protected
  final _box = BoxServices.instance;

  late String _text;
  late Color _primary;
  late Color _primaryAdaptive;
  late Color _onPrimary;
  late Color _background;
  late Color _backgroundDark;
  late Color _surface;
  late Color _textColor;
  late Color _textColorLight;
  late Color _error;
  late Color _onError;
  late Color _success;
  late Color _onSuccess;
  late Color _shimmer;
  late Color _disabled;
  late ThemeMode _themeMode;

  String get text => _text;
  Color get primary => _primary;
  Color get primaryAdaptive => _primaryAdaptive;
  Color get onPrimary => _onPrimary;
  Color get background => _background;
  Color get backgroundDark => _backgroundDark;
  Color get surface => _surface;
  Color get textColor => _textColor;
  Color get textColorLight => _textColorLight;
  Color get disabled => _disabled;
  Color get error => _error;
  Color get onError => _onError;
  Color get success => _success;
  Color get onSuccess => _onSuccess;
  Color get shimmer => _shimmer;
  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    _themeMode = _box.themeMode;
    _adaptiveTheme(_box.theme);
    super.initState();
  }

  void changeTheme(MyTheme? theme) {
    if ((theme ??= _box.theme) == _box.theme) return;
    _box.saveTheme(theme);
    _adaptiveTheme(theme, null, true);
  }

  Future<void> switchThemeMode(ThemeMode? mode) async {
    if ((mode ??= _box.themeMode) == themeMode) return;
    _themeMode = mode;
    await _box.saveThemeMode(mode);
    _adaptiveTheme(_box.theme, mode, true);
  }

  void _adaptiveTheme(MyTheme theme, [ThemeMode? mode, bool? reload]) {
    _text = theme.title;
    _primary = theme.primary;
    _onPrimary = theme.onPrimary;
    switch (mode?.brightness ?? _box.themeMode.brightness) {
      case Brightness.dark:
        _primaryAdaptive = theme.primaryDark;
        _background = const Color(0xFF212121);
        _backgroundDark = const Color(0xFF4F4F4F);
        _surface = const Color(0xFF303030);
        _textColor = const Color(0xFFEEEEEE);
        _textColorLight = const Color(0xFF9B9B9B);
        _onError = const Color(0xFF523C40);
        _onSuccess = const Color(0xFF4C5E4A);
        _shimmer = Color(0xFF404040);
        break;
      case Brightness.light:
        _primaryAdaptive = theme.primary;
        _background = const Color(0xFFFAFAFA);
        _backgroundDark = const Color(0xFFE0E0E0);
        _surface = Colors.white;
        _textColor = const Color(0xFF212121);
        _textColorLight = const Color(0xFF868686);
        _onError = const Color(0xFFFFEBEE);
        _onSuccess = const Color(0xFFD1EFCE);
        _shimmer = Color(0xFFE0E0E0);
        break;
    }
    _disabled = Colors.grey;
    _error = const Color(0xFFB71C1C);
    _success = const Color(0xFF2B722E);
    if (reload ?? false) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _Themes(data: this, child: widget.child);
  }
}

enum MyTheme {
  indigo(
    title: 'lavender-blue',
    primary: Color(0xFF7F7FD5),
    onPrimary: Color(0xFFF6F5FD),
    primaryDark: Color(0xFF505088),
  );

  final String title;
  final Color primary;
  final Color onPrimary;
  final Color primaryDark;

  const MyTheme({
    required this.title,
    required this.primary,
    required this.onPrimary,
    required this.primaryDark,
  });
}
