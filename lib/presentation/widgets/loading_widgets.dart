import 'package:flutter/material.dart';
import '../../data/utils/dimens.dart';
import '../../config/theme_services.dart';

class LoadingButton extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final bool enable;
  final Color? loaderColor;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? border;
  final EdgeInsets? margin;
  final double? width;
  final bool defWidth;
  final bool compact;
  final VoidCallback onPressed;
  const LoadingButton({
    super.key,
    this.padding,
    this.margin,
    this.width,
    this.enable = true,
    this.defWidth = false,
    this.compact = false,
    this.backgroundColor,
    this.foregroundColor,
    this.loaderColor,
    this.border,
    required this.isLoading,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      width: defWidth ? null : width ?? 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? scheme.primary,
            foregroundColor: foregroundColor ?? scheme.onPrimary,
            visualDensity: compact ? VisualDensity.compact : null,
            shape: border != null
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                    Radius.circular(border!),
                  ))
                : null,
            padding: padding ??
                const EdgeInsets.symmetric(vertical: Dimens.sizeDefault)),
        onPressed: enable && !isLoading ? onPressed : null,
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: loaderColor ?? scheme.onPrimary))
            : child,
      ),
    );
  }
}

class LoadingIcon extends StatelessWidget {
  final Widget icon;
  final bool loading;
  final double? iconSize;
  final double? loaderSize;
  final Widget? selectedIcon;
  final bool? isSelected;
  final ButtonStyle? style;
  final VoidCallback onPressed;
  const LoadingIcon({
    super.key,
    required this.icon,
    required this.loading,
    required this.onPressed,
    this.iconSize,
    this.loaderSize,
    this.isSelected,
    this.selectedIcon,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return IconButton(
      style: style ??
          IconButton.styleFrom(
            padding: const EdgeInsets.all(Dimens.sizeMedSmall),
            foregroundColor: scheme.textColor,
          ),
      isSelected: isSelected,
      selectedIcon: selectedIcon,
      onPressed: onPressed,
      iconSize: iconSize,
      icon: loading
          ? Container(
              height: loaderSize,
              width: loaderSize,
              alignment: Alignment.center,
              child: const SizedBox.square(
                  dimension: 24, child: CircularProgressIndicator()),
            )
          : icon,
    );
  }
}
