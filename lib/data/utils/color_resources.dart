import 'package:flutter/material.dart';

sealed class ColorRes {
  static const Color shimmer = Color(0xFFE0E0E0);
  static const Color secondaryLight = Color(0xFFD6D6D6);
  static const Color sucess = Color(0xFF2B722E);
  static const Color onSucess = Color(0xFFD1EFCE);
  static const Color error = Color(0xFFB71C1C);
  static const Color onError = Color(0xFFFFEBEE);
  static const Color onTeritary = Color(0xFFF1E3BE);
  static const Color teritary = Color(0xFFC68F04);
}

enum MyTheme {
  indigo.light(
    title: 'Indigo Dye',
    primary: Color(0xFF344966),
    onPrimary: Color(0xFFDDDBCB),
    primaryContainer: Color(0xFFB4CDED),
    onPrimaryContainer: Color(0xFF0D1821),
  );

  final String title;
  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color background;
  final Color surface;
  final Color textColor;
  final Color textColorLight;
  final Color disabled;

  // const MyTheme.dark({
  //   required this.title,
  //   required this.primary,
  //   required this.onPrimary,
  //   required this.primaryContainer,
  //   required this.onPrimaryContainer,
  // })  : brightness = Brightness.dark,
  //       background = const Color(0xFF212121),
  //       surface = const Color(0xFF303030),
  //       textColor = const Color(0xFFEEEEEE),
  //       textColorLight = const Color(0xFF757575),
  //       disabled = Colors.grey;

  // ignore: unused_element
  const MyTheme.light({
    required this.title,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
  })  : brightness = Brightness.light,
        background = const Color(0xFFFAFAFA),
        surface = const Color(0xFFF0F4EF),
        textColor = const Color(0xFF1B1C1E),
        textColorLight = const Color(0xFF616161),
        disabled = Colors.grey;
}
