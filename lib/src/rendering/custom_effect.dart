import 'package:visual_effect/src/rendering/visual_effect.dart';
import 'package:visual_effect/src/visual_effects.dart';

typedef CustomEffectCallback = VisualEffect Function(VisualEffect effect);

class RenderCustomEffect extends RenderVisualEffect {
  RenderCustomEffect({
    required CustomEffectCallback callback,
  }) : _callback = callback;

  CustomEffectCallback get callback => _callback;
  CustomEffectCallback _callback;
  set callback(CustomEffectCallback value) {
    if (_callback == value) {
      return;
    }
    _callback = value;
    markNeedsPaint();
  }

  @override
  VisualEffect? computeVisualEffect(VisualEffect effect) {
    return _callback(effect);
  }
}
