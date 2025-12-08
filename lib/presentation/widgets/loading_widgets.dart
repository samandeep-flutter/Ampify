import 'package:ampify/data/utils/exports.dart';

class LoadingButton extends StatelessWidget {
  final Widget child;
  final bool? isLoading;
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
    this.isLoading,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    return Container(
      margin: margin,
      width: defWidth ? null : width ?? 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? scheme.primaryAdaptive,
          foregroundColor: foregroundColor ?? scheme.onPrimary,
          visualDensity: compact ? VisualDensity.compact : null,
          shape: Utils.continuousBorder(border ?? Dimens.borderLarge),
          padding: padding ??
              (compact
                  ? Utils.insetsHoriz(Dimens.sizeMedSmall)
                  : EdgeInsets.all(Dimens.sizeMedSmall)),
        ),
        onPressed: enable && !(isLoading ?? false) ? onPressed : null,
        child: DefaultTextStyle.merge(
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: Dimens.fontXXXLarge),
          child: Builder(builder: (context) {
            if (isLoading ?? false) {
              return SizedBox.square(
                  dimension: Dimens.sizeLarge,
                  child: CircularProgressIndicator(
                      color: loaderColor ?? scheme.primaryAdaptive));
            }
            return child;
          }),
        ),
      ),
    );
  }
}

class LoadingIcon extends StatelessWidget {
  final Widget icon;
  final bool? loading;
  final double? iconSize;
  final double? loaderSize;
  final Widget? selectedIcon;
  final bool? isSelected;
  final ButtonStyle? style;
  final VoidCallback onPressed;
  const LoadingIcon({
    super.key,
    required this.icon,
    this.loading,
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
      iconSize: iconSize ?? Dimens.iconDefault,
      icon: Builder(builder: (context) {
        if (!(loading ?? false)) return icon;
        return Container(
          height: loaderSize,
          width: loaderSize,
          alignment: Alignment.center,
          child: SizedBox.square(
              dimension: Dimens.sizeLarge,
              child: CircularProgressIndicator(
                color: style?.foregroundColor?.resolve({}) ?? scheme.textColor,
              )),
        );
      }),
    );
  }
}
