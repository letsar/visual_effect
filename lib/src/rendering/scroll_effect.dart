import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:visual_effect/src/rendering/visual_effect.dart';
import 'package:visual_effect/src/visual_effects.dart';

@immutable
class ScrollEffectPhase {
  const ScrollEffectPhase._({
    required this.leading,
    required this.trailing,
    required this.ratio,
  });

  final double leading;
  double leadingLerp({
    double from = 0,
    double to = 1,
    Curve curve = Curves.linear,
  }) {
    return _lerp(from, to, leading, curve);
  }

  final double trailing;
  double trailingLerp({
    double from = 0,
    double to = 1,
    Curve curve = Curves.linear,
  }) {
    return _lerp(from, to, trailing, curve);
  }

  final double ratio;
  double ratioLerp({
    double from = 0,
    double to = 1,
    Curve curve = Curves.linear,
  }) {
    return _lerp(from, to, ratio, curve);
  }

  double _lerp(double a, double b, double t, Curve curve) {
    final n = curve.transform(t);
    return a * (1.0 - n) + b * n;
  }

  bool get isLeading => leading > 0;
  bool get isIdentity => ratio == 0;
  bool get isTrailing => trailing > 0;

  double get sign {
    if (isLeading) {
      return -1;
    } else if (isTrailing) {
      return 1;
    } else {
      return 0;
    }
  }
}

typedef ScrollEffectCallback = VisualEffect Function(
  VisualEffect effect,
  ScrollEffectPhase phase,
);

class RenderScrollEffect extends RenderVisualEffect {
  RenderScrollEffect({
    required ScrollEffectCallback callback,
  }) : _callback = callback;

  ScrollEffectCallback get callback => _callback;
  ScrollEffectCallback _callback;
  set callback(ScrollEffectCallback value) {
    if (_callback == value) {
      return;
    }
    _callback = value;
  }

  RenderBox? _sliverChild;
  RenderSliver? _sliver;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _setParentsOfInterest();
  }

  void _setParentsOfInterest() {
    RenderObject? renderBox = this;
    while (renderBox is RenderObject &&
        renderBox.parentData is! SliverMultiBoxAdaptorParentData) {
      renderBox = renderBox.parent as RenderObject?;
    }
    _sliverChild = renderBox as RenderBox?;
    _sliver = _sliverChild?.parent as RenderSliver?;
  }

  ScrollEffectPhase? _computeScrollEffectPhase() {
    final renderObject = _sliverChild;
    final parentData = _sliverChild?.parentData;
    final sliverConstraints = _sliver?.constraints;

    if (renderObject != null &&
        parentData is SliverMultiBoxAdaptorParentData &&
        sliverConstraints != null) {
      final mainAxisDelta =
          (parentData.layoutOffset ?? 0) - sliverConstraints.scrollOffset;
      final childExtent = _paintExtentOf(sliverConstraints);

      final leadingObscuredExtent = sliverConstraints.overlap - mainAxisDelta;
      final trailingObscuredExtent =
          mainAxisDelta + childExtent - sliverConstraints.remainingPaintExtent;
      applyGrowthDirectionToAxisDirection(
        sliverConstraints.axisDirection,
        sliverConstraints.growthDirection,
      );
      final leading = (leadingObscuredExtent / childExtent).clamp(0.0, 1.0);
      final trailing = (trailingObscuredExtent / childExtent).clamp(0.0, 1.0);

      final value = leading > 0 && trailing > 0
          ?
          // The widget is obscured by both the leading and the trailing edge.
          // In this case we provide the most appropriate value depending on
          // the user scroll direction.
          switch (sliverConstraints.userScrollDirection) {
              ScrollDirection.forward => leading,
              ScrollDirection.reverse => trailing,
              ScrollDirection.idle => math.max(leading, trailing),
            }
          // The widget only obscured by the leading or the trailing edge.
          : math.max(leading, trailing);

      final result = ScrollEffectPhase._(
        leading: leading,
        trailing: trailing,
        ratio: value,
      );

      return result;
    }
    return null;
  }

  double _paintExtentOf(SliverConstraints constraints) {
    assert(hasSize);
    switch (constraints.axis) {
      case Axis.horizontal:
        return size.width;
      case Axis.vertical:
        return size.height;
    }
  }

  @override
  VisualEffect? computeVisualEffect(VisualEffect effect) {
    final phase = _computeScrollEffectPhase();

    if (phase == null || phase.isIdentity) {
      return null;
    }

    return _callback(effect, phase);
  }
}
