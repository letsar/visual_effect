import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';
import 'package:visual_effect/src/visual_effects.dart';

abstract class RenderVisualEffect extends RenderProxyBox {
  // We don't want it to be a repaint boundary because we want it to be repaint
  // at each frame in case of a scroll effect.
  // Maybe we could go further by making it a repaint boundary only if the
  // item is not totally visible.
  @override
  bool get isRepaintBoundary => false;

  @override
  bool get alwaysNeedsCompositing => true;

  final List<LayerHandle> _layerHandles = [];

  ContainerLayer? _updateLayer(VisualEffect effect, Offset offset, int index) {
    final ContainerLayer? layer;
    if (_layerHandles.length <= index) {
      // New layer.
      layer = effect.update(offset, null);
      _layerHandles.add(LayerHandle(layer));
    } else {
      final layerHandle = _layerHandles[index];
      // The layer already exists.
      final oldLayer = layerHandle.layer as ContainerLayer?;
      layer = effect.update(offset, oldLayer);

      layerHandle.layer = layer;
    }
    return layer;
  }

  @protected
  VisualEffect? computeVisualEffect(VisualEffect effect);

  @override
  void paint(PaintingContext context, Offset offset) {
    final emptyEffect = EmptyVisualEffect(childSize: size);
    VisualEffect? effect = computeVisualEffect(emptyEffect);

    if (effect == null || effect == emptyEffect) {
      super.paint(context, offset);
      return;
    }

    final effects = <VisualEffect>[];
    while (effect != null) {
      effects.add(effect);
      effect = effect.childEffect;
    }

    final painters = List.filled(effects.length + 1, super.paint);
    for (int i = 0; i < effects.length; i++) {
      painters[i] = (context, offset) {
        final effect = effects[i];
        final layer = _updateLayer(effect, offset, i);
        if (layer != null) {
          context.pushLayer(layer, painters[i + 1], offset);
        } else {
          painters[i + 1](context, offset);
        }
      };
    }

    painters.first(context, offset);
  }

  @override
  void dispose() {
    for (final layerHandle in _layerHandles) {
      layerHandle.layer = null;
    }
    super.dispose();
  }
}
