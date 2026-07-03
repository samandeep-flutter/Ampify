import 'package:flutter/material.dart';

/// A dotted [BoxBorder] similar to [Border], but renders dashes instead of solid lines.
class DottedBoxBorder extends BoxBorder {
  const DottedBoxBorder({
    this.topSide = DottedBorderSide.none,
    this.rightSide = DottedBorderSide.none,
    this.bottomSide = DottedBorderSide.none,
    this.leftSide = DottedBorderSide.none,
  });

  /// Creates a border where all four sides have the same style.
  factory DottedBoxBorder.all({
    Color color = Colors.black,
    double width = 1.0,
    double dashLength = 6.0,
    double gapLength = 4.0,
  }) {
    final side = DottedBorderSide(
      color: color,
      width: width,
      dashLength: dashLength,
      gapLength: gapLength,
    );
    return DottedBoxBorder(
        topSide: side, rightSide: side, bottomSide: side, leftSide: side);
  }

  /// Creates a border with symmetrical vertical and horizontal sides.
  factory DottedBoxBorder.symmetric({
    DottedBorderSide vertical = DottedBorderSide.none,
    DottedBorderSide horizontal = DottedBorderSide.none,
  }) {
    return DottedBoxBorder(
      leftSide: vertical,
      rightSide: vertical,
      topSide: horizontal,
      bottomSide: horizontal,
    );
  }

  /// Creates a border for only the given sides.
  factory DottedBoxBorder.only({
    DottedBorderSide top = DottedBorderSide.none,
    DottedBorderSide right = DottedBorderSide.none,
    DottedBorderSide bottom = DottedBorderSide.none,
    DottedBorderSide left = DottedBorderSide.none,
  }) {
    return DottedBoxBorder(
        topSide: top, rightSide: right, bottomSide: bottom, leftSide: left);
  }

  final DottedBorderSide topSide;
  final DottedBorderSide rightSide;
  final DottedBorderSide bottomSide;
  final DottedBorderSide leftSide;

  @override
  BorderSide get top => BorderSide(color: topSide.color, width: topSide.width);
  @override
  BorderSide get bottom =>
      BorderSide(color: bottomSide.color, width: bottomSide.width);

  BorderSide get right =>
      BorderSide(color: rightSide.color, width: rightSide.width);
  BorderSide get left =>
      BorderSide(color: leftSide.color, width: leftSide.width);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.fromLTRB(
      leftSide.width, topSide.width, rightSide.width, bottomSide.width);

  @override
  bool get isUniform =>
      topSide == rightSide && rightSide == bottomSide && bottomSide == leftSide;

  @override
  ShapeBorder scale(double t) {
    return DottedBoxBorder(
      topSide: topSide.scale(t),
      rightSide: rightSide.scale(t),
      bottomSide: bottomSide.scale(t),
      leftSide: leftSide.scale(t),
    );
  }

  @override
  BoxBorder? add(ShapeBorder other, {bool reversed = false}) => null;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect.deflate(dimensions.horizontal / 2));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect.inflate(dimensions.horizontal / 2));
  }

  @override
  void paint(Canvas canvas, Rect rect,
      {TextDirection? textDirection,
      BoxShape shape = BoxShape.rectangle,
      BorderRadius? borderRadius}) {
    if (shape == BoxShape.circle) return;
    _paintSide(canvas, rect.topLeft, rect.topRight, topSide);
    _paintSide(canvas, rect.topRight, rect.bottomRight, rightSide);
    _paintSide(canvas, rect.bottomRight, rect.bottomLeft, bottomSide);
    _paintSide(canvas, rect.bottomLeft, rect.topLeft, leftSide);
  }

  void _paintSide(
      Canvas canvas, Offset start, Offset end, DottedBorderSide side) {
    if (side == DottedBorderSide.none || side.width == 0) return;

    final paint = Paint()
      ..color = side.color
      ..strokeWidth = side.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
    final dashed = _dashPath(path, side.dashLength, side.gapLength);

    canvas.drawPath(dashed, paint);
  }

  Path _dashPath(Path source, double dash, double gap) {
    final Path dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next = distance + dash;
        dest.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + gap;
      }
    }
    return dest;
  }
}

class DottedBorderSide {
  const DottedBorderSide({
    this.color = Colors.black,
    this.width = 1.0,
    this.dashLength = 6.0,
    this.gapLength = 4.0,
  });

  final Color color;
  final double width;
  final double dashLength;
  final double gapLength;

  static const DottedBorderSide none = DottedBorderSide(width: 0);

  DottedBorderSide scale(double t) => DottedBorderSide(
        color: color,
        width: width * t,
        dashLength: dashLength * t,
        gapLength: gapLength * t,
      );

  @override
  bool operator ==(Object other) {
    return other is DottedBorderSide &&
        other.color == color &&
        other.width == width &&
        other.dashLength == dashLength &&
        other.gapLength == gapLength;
  }

  @override
  int get hashCode => Object.hash(color, width, dashLength, gapLength);
}
