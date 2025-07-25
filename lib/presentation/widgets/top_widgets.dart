import 'package:flutter/material.dart';
import 'package:ampify/data/utils/exports.dart';

class MyDivider extends StatelessWidget {
  final double? width;
  final double? thickness;
  final double? margin;
  final Color? color;
  const MyDivider({
    super.key,
    this.width,
    this.thickness,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Utils.insetsHoriz(margin ?? 0),
      width: width,
      child: Divider(
        color: color ?? context.scheme.backgroundDark,
        thickness: thickness,
      ),
    );
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
      padding: Utils.insetsHoriz(margin ?? 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.borderDefault),
        onTap: onTap,
        child: CircleAvatar(
          radius: Dimens.iconTiny,
          backgroundColor: color ??
              (current ? scheme.primary : scheme.disabled.withAlpha(80)),
        ),
      ),
    );
  }
}

class ToolTipWidget extends StatefulWidget {
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
  State<ToolTipWidget> createState() => _ToolTipWidgetState();
}

class _ToolTipWidgetState extends State<ToolTipWidget> {
  Widget _builder() {
    final scheme = context.scheme;
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(
        top: context.height * .15,
        left: Dimens.sizeDefault,
        right: Dimens.sizeDefault,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget._icon != null) ...[
            Builder(builder: (context) {
              if (!widget._placeHolder) return widget._icon!;
              return Image.asset(widget._icon,
                  width: context.width * .3, color: scheme.disabled);
            }),
            const SizedBox(height: Dimens.sizeDefault),
          ],
          Text(
            widget.title ?? StringRes.errorUnknown,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: scheme.textColorLight, fontSize: Dimens.fontXXXLarge),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!(widget._scrolable ?? false)) return _builder();
    return Expanded(
        child: SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: _builder(),
    ));
  }
}

class SliverSizedBox extends StatelessWidget {
  final double? height;
  final double? width;
  const SliverSizedBox({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(height: height, width: width),
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
    final radius = borderRadius ?? Dimens.borderLarge;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
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

class SubtitleWidget extends StatelessWidget {
  final TextStyle? style;
  final String type;
  final String subtitle;
  final bool expanded;
  const SubtitleWidget({
    super.key,
    this.style,
    this.expanded = true,
    required this.type,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    final sub = Text(
      subtitle,
      maxLines: 1,
      style: TextStyle(
          color: style?.color ?? scheme.textColorLight,
          fontSize: Dimens.fontDefault),
      overflow: TextOverflow.ellipsis,
    );

    return DefaultTextStyle.merge(
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            type,
            style: TextStyle(
                color: style?.color ?? scheme.textColorLight,
                fontSize: Dimens.fontDefault),
          ),
          PaginationDots(
            current: true,
            margin: Dimens.sizeSmall,
            color: style?.color ?? scheme.textColorLight,
          ),
          if (expanded) Expanded(child: sub) else sub,
        ],
      ),
    );
  }
}

class ShadowWidget extends StatelessWidget {
  final Color color;
  final EdgeInsets? margin;
  final double? spread;
  final Offset? offset;
  final bool darkShadow;
  final double? borderRadius;
  final Widget child;

  const ShadowWidget({
    super.key,
    this.margin,
    this.spread,
    this.offset,
    this.borderRadius,
    this.darkShadow = true,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(Dimens.sizeMedium),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        boxShadow: [
          BoxShadow(
            color: color,
            offset: offset ?? Offset.zero,
            spreadRadius: spread ?? context.width * .35,
            blurRadius: spread ?? context.width * .35,
          ),
          if (darkShadow)
            BoxShadow(
              color: Colors.black12,
              spreadRadius: Dimens.sizeSmall,
              blurRadius: Dimens.sizeExtraDoubleLarge,
            ),
        ],
      ),
      child: child,
    );
  }
}

class LikedSongsCover extends StatelessWidget {
  final double size;
  final double? iconSize;
  const LikedSongsCover({required this.size, this.iconSize, super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.sizeMini),
        gradient: LinearGradient(
          colors: [scheme.primaryAdaptive, Color(0xFFB4B5ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.favorite, size: iconSize, color: scheme.onPrimary),
    );
  }
}

class BottomSheetListTile extends StatelessWidget {
  final String title;
  final Widget? leading;
  final bool? enable;
  final VoidCallback? onTap;
  const BottomSheetListTile({
    super.key,
    required this.title,
    this.leading,
    this.onTap,
    this.enable,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return ListTile(
      enabled: enable ?? true,
      onTap: onTap,
      leading: leading,
      title: Text(title),
      horizontalTitleGap: Dimens.sizeLarge,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: Dimens.fontXXXLarge,
        color: scheme.textColor,
      ),
    );
  }
}
