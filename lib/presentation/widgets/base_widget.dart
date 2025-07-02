import 'package:ampify/data/utils/utils.dart';
import 'package:flutter/material.dart';
import '../../data/utils/dimens.dart';
import '../../services/theme_services.dart';

class BaseWidget extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final BoxDecoration? decoration;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final bool? extendBody;
  final bool? safeAreaBottom;
  final bool? resizeBottom;
  final Widget? bottom;
  final Widget child;

  const BaseWidget({
    super.key,
    this.appBar,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.extendBody,
    this.safeAreaBottom,
    this.resizeBottom,
    this.bottom,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return Scaffold(
      appBar: appBar,
      backgroundColor: color ?? scheme.background,
      extendBody: extendBody ?? false,
      resizeToAvoidBottomInset: resizeBottom,
      bottomNavigationBar: bottom,
      body: Container(
        decoration: decoration,
        child: SafeArea(
            bottom: safeAreaBottom ?? false,
            child: Container(
              margin: margin,
              padding: padding ?? Utils.insetsHoriz(Dimens.sizeLarge),
              child: child,
            )),
      ),
    );
  }
}
