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
  final bool isDragable;
  final HeightConstraints? constraints;
  final Widget child;

  const MyBottomSheet({
    super.key,
    this.title,
    this.onClose,
    this.customTitle,
    this.titleBottomSpacing,
    required this.child,
  })  : isDragable = false,
        constraints = null,
        assert(title != null || customTitle != null);
  const MyBottomSheet.dragable({
    super.key,
    this.title,
    this.onClose,
    this.customTitle,
    this.titleBottomSpacing,
    this.constraints,
    required this.child,
  })  : isDragable = true,
        assert(title != null || customTitle != null);

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet>
    with TickerProviderStateMixin {
  final scrollController = DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    if (!widget.isDragable) {
      return BottomSheet(
          onClosing: () {},
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimens.borderDefault),
              topRight: Radius.circular(Dimens.borderDefault),
            ),
          ),
          animationController: BottomSheet.createAnimationController(this),
          builder: (_) =>
              Column(mainAxisSize: MainAxisSize.min, children: _builder()));
    }
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: MyColoredBox(
        color: Colors.transparent,
        child: DraggableScrollableSheet(
          maxChildSize: widget.constraints?.maxHeight ?? 0.8,
          minChildSize: widget.constraints?.minHeight ?? 0.5,
          initialChildSize: widget.constraints?.defaultHeight ?? 0.6,
          controller: scrollController,
          builder: (context, scrollController) {
            return GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: context.scheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(Dimens.borderDefault),
                    topRight: Radius.circular(Dimens.borderDefault),
                  ),
                ),
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  controller: scrollController,
                  children: _builder(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _builder() {
    return [
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
              onPopInvokedWithResult: (didPop, _) => widget.onClose?.call(),
              child: Padding(
                padding: const EdgeInsets.only(right: Dimens.sizeDefault),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                  child: Text(
                    StringRes.close.toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: Dimens.fontMed),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      SizedBox(height: widget.titleBottomSpacing ?? 0),
      const MyDivider(),
      widget.child,
    ];
  }
}

class HeightConstraints {
  final double maxHeight;
  final double minHeight;
  final double defaultHeight;
  HeightConstraints({
    required this.maxHeight,
    required this.minHeight,
    required this.defaultHeight,
  })  : assert(minHeight >= 0.0),
        assert(maxHeight <= 1.0),
        assert(minHeight <= defaultHeight),
        assert(defaultHeight <= maxHeight);
}

class MyCustomDragableSheet extends StatelessWidget {
  final Color? backgroundColor;
  final HeightConstraints? constraints;
  final Widget Function(BuildContext, ScrollController) builder;
  const MyCustomDragableSheet({
    super.key,
    this.constraints,
    this.backgroundColor,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: MyColoredBox(
        color: Colors.transparent,
        child: DraggableScrollableSheet(
          maxChildSize: constraints?.maxHeight ?? 0.8,
          minChildSize: constraints?.minHeight ?? 0.5,
          initialChildSize: constraints?.defaultHeight ?? 0.6,
          builder: (context, scrollController) {
            return GestureDetector(
              onTap: () {},
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimens.borderDefault),
                  topRight: Radius.circular(Dimens.borderDefault),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: backgroundColor ?? context.scheme.surface),
                  child: builder(context, scrollController),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
