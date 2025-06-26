import 'package:ampify/services/box_services.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';

class _Themes extends InheritedWidget {
  final ThemeServiceState data;
  const _Themes({required super.child, required this.data});

  @override
  bool updateShouldNotify(covariant _Themes oldWidget) => true;
}

class ThemeServices extends StatefulWidget {
  final Widget child;
  const ThemeServices({super.key, required this.child});

  static ThemeServiceState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_Themes>()?.data;
  }

  static ThemeServiceState of(BuildContext context) {
    assert(maybeOf(context) != null);
    return maybeOf(context)!;
  }

  @override
  State<ThemeServices> createState() => ThemeServiceState();
}

class ThemeServiceState extends State<ThemeServices> {
  final _box = BoxServices.instance;

  late String _text;
  late Color _primary;
  late Color _onPrimary;
  late Color _primaryContainer;
  late Color _onPrimaryContainer;
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
  Color get onPrimary => _onPrimary;
  Color get primaryContainer => _primaryContainer;
  Color get onPrimaryContainer => _onPrimaryContainer;
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
    _primaryContainer = theme.primaryContainer;
    _onPrimaryContainer = theme.onPrimaryContainer;
    switch (mode?.brightness ?? _box.themeMode.brightness) {
      case Brightness.dark:
        _background = const Color(0xFF212121);
        _backgroundDark = const Color(0xFF4F4F4F);
        _surface = const Color(0xFF303030);
        _textColor = const Color(0xFFEEEEEE);
        _textColorLight = const Color(0xFF757575);
        _onError = const Color(0xFF523C40);
        _onSuccess = const Color(0xFF4C5E4A);
        _shimmer = Color(0xFF404040);
        break;
      case Brightness.light:
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
    primary: Color(0xff7F7FD5),
    onPrimary: Color(0xFFF1F0FF),
    primaryContainer: Color(0xFFB4B5ED),
    onPrimaryContainer: Color(0xFF0D0D21),
  );

  final String title;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  const MyTheme({
    required this.title,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
  });
}
