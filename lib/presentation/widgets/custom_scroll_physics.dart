import 'package:flutter/widgets.dart';

/// Scroll physics that only bounces when hitting the bottom (trailing edge).
/// The top edge is always clamped (no bounce / no gap).
class BottomBounceScrollPhysics extends BouncingScrollPhysics {
  const BottomBounceScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent ?? const AlwaysScrollableScrollPhysics());

  @override
  BottomBounceScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return BottomBounceScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.minScrollExtent) {
      return value - position.minScrollExtent;
    } else if (value > position.maxScrollExtent) {
      return super.applyBoundaryConditions(position, value);
    } else {
      return 0.0;
    }
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if (position.pixels < position.minScrollExtent) {
      return super.createBallisticSimulation(
        position.copyWith(pixels: position.minScrollExtent),
        velocity,
      );
    }
    return super.createBallisticSimulation(position, velocity);
  }
}
