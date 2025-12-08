import 'package:ampify/data/utils/exports.dart';

class BaseWidget extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final BorderRadius? shapeRadius;
  final EdgeInsets? padding;
  final EdgeInsets? bodyPadding;
  final Color? color;
  final bool? extendBody;
  final bool? safeAreaBottom;
  final bool? resizeBottom;
  final Widget? bottom;
  final Widget child;

  const BaseWidget({
    super.key,
    this.appBar,
    this.bodyPadding,
    this.color,
    this.extendBody,
    this.safeAreaBottom,
    this.resizeBottom,
    this.padding,
    this.shapeRadius,
    this.bottom,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: shapeRadius ?? BorderRadius.zero,
        child: Scaffold(
          appBar: appBar,
          backgroundColor: color ?? scheme.background,
          extendBody: extendBody ?? false,
          resizeToAvoidBottomInset: resizeBottom,
          bottomNavigationBar: bottom,
          body: SafeArea(
            bottom: safeAreaBottom ?? false,
            child:
                Padding(padding: bodyPadding ?? EdgeInsets.zero, child: child),
          ),
        ),
      ),
    );
  }
}
