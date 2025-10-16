import 'package:flutter/material.dart';
import 'package:ampify/data/utils/exports.dart';

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

class MyBottomSheet extends StatefulWidget {
  final String? title;
  final Widget? customTitle;
  final double? titleBottomSpacing;
  final VoidCallback? onClose;
  final Widget child;

  const MyBottomSheet({
    super.key,
    this.title,
    this.onClose,
    this.customTitle,
    this.titleBottomSpacing,
    required this.child,
  }) : assert(title != null || customTitle != null);

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
        onClosing: () {},
        animationController: BottomSheet.createAnimationController(this),
        builder: (_) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: Dimens.sizeMedSmall),
                    height: Dimens.sizeExtraSmall,
                    width: Dimens.sizeUltraLarge,
                    decoration: BoxDecoration(
                      color: context.scheme.textColorLight,
                      borderRadius: BorderRadius.circular(Dimens.sizeMini),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimens.sizeDefault),
              Builder(builder: (context) {
                if (widget.customTitle != null) return widget.customTitle!;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 75),
                    Text(widget.title!,
                        style: TextStyle(
                          fontSize: Dimens.fontXXLarge,
                          fontWeight: FontWeight.w600,
                        )),
                    PopScope(
                      onPopInvokedWithResult: (didPop, _) =>
                          widget.onClose?.call(),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: Dimens.sizeDefault),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact),
                          child: Text(
                            StringRes.close.toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Dimens.fontMed),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(height: widget.titleBottomSpacing ?? 0),
              const MyDivider(),
              const SizedBox(height: Dimens.sizeDefault),
              widget.child,
            ],
          );
        });
  }
}
