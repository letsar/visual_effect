import 'package:flutter/widgets.dart';
import 'package:visual_effect/src/rendering/custom_effect.dart';

class CustomEffect extends SingleChildRenderObjectWidget {
  CustomEffect({
    super.key,
    required this.onGenerateVisualEffect,
    bool addRepaintBoundaries = true,
    required Widget child,
  }) : super(
          child: addRepaintBoundaries ? RepaintBoundary(child: child) : child,
        );

  final CustomEffectCallback onGenerateVisualEffect;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomEffect(
      callback: onGenerateVisualEffect,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCustomEffect renderObject,
  ) {
    renderObject.callback = onGenerateVisualEffect;
  }
}
