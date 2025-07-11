import 'package:flutter/material.dart';

sealed class ResponsiveFont {
  // static late double _screenWidth;
  static late TextScaler _scaleFactor;

  // static const double _minScale = 0.85;
  // static const double _maxScale = 1.2;
  // static const double _baseWidth = 393;

  // static void init(BuildContext context) {
  //   final mediaQuery = MediaQuery.of(context);
  //   _screenWidth = mediaQuery.size.width;
  //   _screenHeight = mediaQuery.size.height;

  //   double scale = _screenWidth / _baseWidth;
  //   _scaleFactor = scale.clamp(_minScale, _maxScale);
  // }

  static void init(BuildContext context) {
    _scaleFactor = MediaQuery.textScalerOf(context);
  }

  // static double scale(double value) => value * _scaleFactor;
  static double scale(double value) => _scaleFactor.scale(value);
}

extension MyDouble on double {
  double get scale => ResponsiveFont.scale(this);
}

extension ResponsiveExtension on num {
  double get scale => ResponsiveFont.scale(toDouble());
}
