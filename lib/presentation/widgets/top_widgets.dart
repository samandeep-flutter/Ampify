import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import '../../data/utils/dimens.dart';
import '../../data/utils/string.dart';
import '../../config/theme_services.dart';
import 'my_cached_image.dart';

class MyDivider extends StatelessWidget {
  final double? width;
  final double? thickness;
  final double? margin;
  const MyDivider({super.key, this.width, this.thickness, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: margin ?? 0),
        width: width,
        child: Divider(
          color: Colors.grey[300],
          thickness: thickness,
        ));
  }
}

class PaginationDots extends StatelessWidget {
  final bool current;
  final Color? color;
  final double? margin;
  final VoidCallback? onTap;
  const PaginationDots({
    super.key,
    required this.current,
    this.onTap,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: margin ?? 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.borderDefault),
        onTap: onTap,
        child: CircleAvatar(
          radius: 3,
          backgroundColor: color ??
              (current ? scheme.primary : scheme.disabled.withOpacity(.3)),
        ),
      ),
    );
  }
}

class ToolTipWidget extends StatelessWidget {
  final EdgeInsets? margin;
  final dynamic _icon;
  final bool? _scrolable;
  final Alignment? alignment;
  final String? title;
  final bool _placeHolder;

  const ToolTipWidget({
    super.key,
    this.margin,
    Widget? icon,
    this.title,
    this.alignment,
  })  : _icon = icon,
        _scrolable = null,
        _placeHolder = false;

  const ToolTipWidget.placeHolder({
    super.key,
    String? icon,
    bool? scrolable,
    required this.title,
  })  : _icon = icon,
        _scrolable = scrolable,
        _placeHolder = true,
        margin = null,
        alignment = null;

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    if (_placeHolder) {
      final widget = Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(
          vertical: context.height * .15,
          horizontal: Dimens.sizeLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_icon != null) ...[
              Image.asset(
                _icon,
                width: context.width * .3,
                color: scheme.disabled,
              ),
              const SizedBox(height: Dimens.sizeDefault),
            ],
            Text(
              title ?? StringRes.errorUnknown,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.textColorLight),
            )
          ],
        ),
      );

      if (_scrolable ?? false) {
        return Expanded(
            child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: widget,
        ));
      }

      return widget;
    }

    return Container(
      margin: margin ?? EdgeInsets.only(top: context.height * .1),
      alignment: alignment ?? Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_icon != null) ...[
            _icon!,
            const SizedBox(height: Dimens.sizeDefault),
          ],
          Text(
            title ?? StringRes.errorUnknown,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.textColorLight),
          )
        ],
      ),
    );
  }
}

class MyAvatar extends StatelessWidget {
  final String? image;
  final bool? isAvatar;
  final EdgeInsets? padding;
  final double? avatarRadius;
  final double? borderRadius;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final VoidCallback? onTap;

  const MyAvatar(
    this.image, {
    super.key,
    this.onTap,
    this.padding,
    this.avatarRadius,
    this.isAvatar,
    this.fit,
    this.borderRadius,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius ?? 40),
      splashColor: scheme.disabled.withOpacity(.5),
      splashFactory: InkRipple.splashFactory,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(4),
        child: MyCachedImage(
          image,
          isAvatar: isAvatar ?? false,
          height: height,
          width: width,
          fit: fit,
          avatarRadius: avatarRadius,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
