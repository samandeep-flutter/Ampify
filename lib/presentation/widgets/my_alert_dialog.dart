import 'package:flutter/material.dart';
import '../../data/utils/dimens.dart';
import '../../data/utils/string.dart';
import '../../services/theme_services.dart';
import 'top_widgets.dart';

class MyAlertDialog extends StatelessWidget {
  final String title;
  final TextStyle? titleTextStyle;
  final Widget? content;
  final List<Widget>? actions;
  final EdgeInsets? actionPadding;
  final EdgeInsets? contentPadding;

  const MyAlertDialog({
    super.key,
    required this.title,
    this.content,
    this.actions,
    this.actionPadding,
    this.contentPadding,
    this.titleTextStyle,
  });
  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return AlertDialog(
        backgroundColor: scheme.surface,
        title: Text(title, style: TextStyle(fontSize: Dimens.fontLarge)),
        titleTextStyle: titleTextStyle,
        content: content,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.borderDefault)),
        buttonPadding: const EdgeInsets.only(right: Dimens.sizeDefault),
        contentPadding: contentPadding,
        actionsPadding: actionPadding,
        actions: actions);
  }
}

class MyBottomSheet extends StatelessWidget {
  final String title;
  final TickerProvider vsync;
  final VoidCallback? onClose;
  final Widget child;

  const MyBottomSheet({
    super.key,
    required this.title,
    required this.vsync,
    this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
        onClosing: onClose ?? () {},
        animationController: BottomSheet.createAnimationController(vsync),
        builder: (_) {
          return SafeArea(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 75),
                Text(title,
                    style: TextStyle(
                      fontSize: Dimens.fontXXLarge,
                      fontWeight: FontWeight.w600,
                    )),
                Padding(
                  padding: const EdgeInsets.only(right: Dimens.sizeDefault),
                  child: TextButton(
                    onPressed: onClose ?? () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact),
                    child: Text(
                      StringRes.close.toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Dimens.fontDefault),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimens.sizeSmall),
            const MyDivider(),
            const SizedBox(height: Dimens.sizeDefault),
            child,
          ]));
        });
  }
}
