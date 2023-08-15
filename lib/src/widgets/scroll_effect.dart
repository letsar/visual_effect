import 'package:flutter/widgets.dart';
import 'package:visual_effect/src/rendering/scroll_effect.dart';

class ScrollEffect extends SingleChildRenderObjectWidget {
  ScrollEffect({
    super.key,
    required this.onGenerateVisualEffect,
    bool addRepaintBoundaries = true,
    required Widget child,
  }) : super(
          child: addRepaintBoundaries ? RepaintBoundary(child: child) : child,
        );

  final ScrollEffectCallback onGenerateVisualEffect;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderScrollEffect(
      callback: onGenerateVisualEffect,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderScrollEffect renderObject,
  ) {
    renderObject.callback = onGenerateVisualEffect;
  }
}
