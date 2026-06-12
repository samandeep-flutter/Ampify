import 'package:ampify/data/utils/exports.dart';

class MyDivider extends StatelessWidget {
  final double? width;
  final double? thickness;
  final double? margin;
  final Color? color;
  final bool dotted;
  const MyDivider(
      {super.key, this.width, this.thickness, this.margin, this.color})
      : dotted = false;
  const MyDivider.dotted(
      {super.key, this.width, this.thickness, this.margin, this.color})
      : dotted = true;

  @override
  Widget build(BuildContext context) {
    final bg = context.scheme.backgroundDark;
    return Container(
        width: width,
        margin: Utils.insetsHoriz(margin ?? 0),
        decoration: BoxDecoration(
          border: dotted
              ? DottedBoxBorder(topSide: DottedBorderSide(color: color ?? bg))
              : null,
        ),
        child: dotted
            ? SizedBox(height: thickness, width: double.infinity)
            : Divider(color: color ?? bg, height: thickness ?? 2));
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
      alignment: widget.alignment ?? Alignment.center,
      margin: widget.margin ??
          EdgeInsets.only(
            top: widget.alignment == null ? context.height * .15 : 0,
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
                color: scheme.textColorLight, fontSize: Dimens.fontDefault),
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
  const SliverSizedBox.shrink({super.key})
      : height = 0,
        width = 0;
  const SliverSizedBox.square({super.key, double? dimension})
      : height = dimension,
        width = dimension;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: SizedBox(height: height, width: width));
  }
}

class SubtitleWidget extends StatelessWidget {
  final TextStyle? style;
  final String? type;
  final String? subtitle;
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

    return DefaultTextStyle.merge(
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (type != null) ...[
            Text(
              type!,
              style: TextStyle(
                  color: style?.color ?? scheme.textColorLight,
                  fontSize: Dimens.fontDefault),
            ),
            if (subtitle?.isNotEmpty ?? false)
              PaginationDots(
                current: true,
                margin: Dimens.sizeSmall,
                color: style?.color ?? scheme.textColorLight,
              )
          ],
          if (expanded) Expanded(child: _sub(context)) else _sub(context),
        ],
      ),
    );
  }

  Widget _sub(BuildContext context) {
    return Text(
      subtitle ?? '',
      maxLines: 1,
      style: TextStyle(
          color: style?.color ?? context.scheme.textColorLight,
          fontSize: Dimens.fontDefault),
      overflow: TextOverflow.ellipsis,
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
            spreadRadius: spread ?? context.width * .5,
            blurRadius: spread ?? context.width * .4,
          ),
          if (darkShadow)
            BoxShadow(
              color: Colors.black12,
              spreadRadius: Dimens.sizeDefault,
              blurRadius: Dimens.sizeMidLarge,
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
  final IconData? icon;
  final bool? enable;
  final VoidCallback? onTap;
  const BottomSheetListTile({
    super.key,
    required this.title,
    this.leading,
    this.icon,
    this.onTap,
    this.enable,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return ListTile(
      enabled: enable ?? true,
      onTap: onTap,
      leading: leading ?? Icon(icon, size: Dimens.iconXXLarge),
      title: Text(title),
      horizontalTitleGap: Dimens.sizeXLarge,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: Dimens.fontXXXLarge - 1,
        color: scheme.textColor,
      ),
    );
  }
}

class DisabledWidget extends StatelessWidget {
  final bool? disabled;
  final String? tooltip;
  final Widget child;
  const DisabledWidget(
      {super.key, this.disabled, this.tooltip, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!(disabled ?? false)) return child;
    if (tooltip?.trim().isEmpty ?? true) return _builder();
    return Tooltip(message: tooltip ?? '', child: _builder());
  }

  Widget _builder() {
    return AnimatedOpacity(
      opacity: disabled ?? true ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: AbsorbPointer(
        absorbing: disabled ?? true,
        child: child,
      ),
    );
  }
}

class MyOpacity extends StatelessWidget {
  final double? opacity;
  final Widget child;
  const MyOpacity({super.key, this.opacity, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: opacity ?? 1, duration: Durations.short3, child: child);
  }
}

class InfoWidget extends StatelessWidget {
  final String title;
  final String? content;
  const InfoWidget(this.title, {this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: TextStyle(color: context.scheme.textColorLight)),
        ),
        const SizedBox(width: Dimens.sizeSmall),
        Text(':'),
        const SizedBox(width: Dimens.sizeSmall),
        Expanded(
          flex: 4,
          child: Text(
            content ?? 'NA',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class ClampingWidget extends StatelessWidget {
  final bool? large;
  final Widget child;
  const ClampingWidget({super.key, required this.child}) : large = false;

  const ClampingWidget.large({super.key, required this.child}) : large = true;

  @override
  Widget build(BuildContext context) {
    return Align(
        child: SizedBox(
            width: large ?? false
                ? Utils.largeClamp(context)
                : Utils.defClamp(context),
            child: child));
  }
}
