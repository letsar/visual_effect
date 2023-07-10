import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:visual_effect/src/angle.dart';
import 'package:visual_effect/src/rendering/layers/shader_builder_layer.dart';

abstract class VisualEffect<T extends ContainerLayer> {
  const VisualEffect({
    required this.childSize,
    this.childEffect,
  });

  final VisualEffect? childEffect;

  final Size childSize;

  T? update(Offset offset, ContainerLayer? oldLayer) {
    final layer = _tryCastLayer(oldLayer);
    return updateLayer(offset, layer);
  }

  T? _tryCastLayer(ContainerLayer? layer) {
    if (layer is T) {
      return layer;
    }
    return null;
  }

  @protected
  T? updateLayer(Offset offset, T? oldLayer);
}

class EmptyVisualEffect extends VisualEffect<ContainerLayer> {
  const EmptyVisualEffect({
    required super.childSize,
  }) : super(childEffect: null);

  @override
  ContainerLayer? updateLayer(Offset offset, ContainerLayer? oldLayer) {
    return null;
  }
}

class _ColorFilterVisualEffect extends VisualEffect<ColorFilterLayer> {
  const _ColorFilterVisualEffect({
    required this.colorFilter,
    required super.childSize,
    required super.childEffect,
  });

  final ColorFilter colorFilter;

  @override
  ColorFilterLayer? updateLayer(Offset offset, ColorFilterLayer? oldLayer) {
    final layer = oldLayer ?? ColorFilterLayer();
    layer.colorFilter = colorFilter;
    return layer;
  }
}

class _ImageFilterVisualEffect extends VisualEffect<ImageFilterLayer> {
  _ImageFilterVisualEffect({
    required this.imageFilter,
    required super.childSize,
    required super.childEffect,
  });

  final ui.ImageFilter imageFilter;

  @override
  ImageFilterLayer? updateLayer(Offset offset, ImageFilterLayer? oldLayer) {
    final layer = oldLayer ?? ImageFilterLayer();
    layer.imageFilter = imageFilter;
    return layer;
  }
}

class _OpacityVisualEffect extends VisualEffect<OpacityLayer> {
  _OpacityVisualEffect({
    required double opacity,
    required super.childSize,
    required super.childEffect,
  }) : alpha = ui.Color.getAlphaFromOpacity(opacity);

  final int alpha;

  @override
  OpacityLayer? updateLayer(Offset offset, OpacityLayer? oldLayer) {
    final layer = oldLayer ?? OpacityLayer();
    layer.alpha = alpha;
    return layer;
  }
}

class ShaderVisualEffectCache {
  const ShaderVisualEffectCache._();

  static final Map<String, ui.FragmentProgram> _cache = {};
  static final Set<String> _caching = {};

  static Future<void> cache(String assetKey) async {
    if (_cache.containsKey(assetKey) || _caching.contains(assetKey)) {
      // This asset is already cached or is being cached.
      return;
    }

    _caching.add(assetKey);

    final program = await ui.FragmentProgram.fromAsset(assetKey);
    _cache[assetKey] = program;

    _caching.remove(assetKey);
  }
}

class _ShaderVisualEffect extends VisualEffect<ShaderBuilderLayer> {
  const _ShaderVisualEffect({
    required this.assetKey,
    required this.onGenerateShader,
    required this.devicePixelRatio,
    required super.childSize,
    required super.childEffect,
  });

  final String assetKey;
  final ShaderBuilder onGenerateShader;

  final double devicePixelRatio;

  @override
  ShaderBuilderLayer? updateLayer(Offset offset, ShaderBuilderLayer? oldLayer) {
    unawaited(ShaderVisualEffectCache.cache(assetKey));
    final program = ShaderVisualEffectCache._cache[assetKey];
    if (program == null) {
      return null;
    }

    final layer = oldLayer ??
        ShaderBuilderLayer(onGenerateShader, program.fragmentShader());
    layer
      ..offset = offset
      ..size = childSize
      ..devicePixelRatio = devicePixelRatio
      ..callback = onGenerateShader;
    return layer;
  }
}

class _TransformVisualEffect extends VisualEffect<TransformLayer> {
  const _TransformVisualEffect({
    required this.transform,
    required this.anchor,
    required super.childSize,
    required super.childEffect,
  });

  final Matrix4 transform;
  final Alignment anchor;

  @override
  TransformLayer? updateLayer(Offset offset, TransformLayer? oldLayer) {
    final Matrix4 result = Matrix4.identity();
    final Offset translation = anchor.alongSize(childSize);
    result.translate(translation.dx, translation.dy);
    result.multiply(transform);
    result.translate(-translation.dx, -translation.dy);

    final Matrix4 effectiveTransform =
        Matrix4.translationValues(offset.dx, offset.dy, 0)
          ..multiply(result)
          ..translate(-offset.dx, -offset.dy);

    final layer = oldLayer ?? TransformLayer();
    layer.transform = effectiveTransform;
    return layer;
  }
}

extension VisualEffectExtensions on VisualEffect {
  VisualEffect blur(double radius) {
    if (radius == 0) {
      return this;
    }

    return _ImageFilterVisualEffect(
      imageFilter: ui.ImageFilter.blur(sigmaX: radius, sigmaY: radius),
      childSize: childSize,
      childEffect: this,
    );
  }

  VisualEffect grayscale(double amount) {
    if (amount == 0) {
      return this;
    }

    final effectiveValue = 1 - amount.clamp(0.0, 1.0);

    final a = 0.2126 + 0.7874 * effectiveValue;
    final b = 0.7152 - 0.7152 * effectiveValue;
    final c = 0.0722 - 0.0722 * effectiveValue;
    final f = 0.2126 - 0.2126 * effectiveValue;
    final g = 0.7152 + 0.2848 * effectiveValue;
    final h = c;
    final k = f;
    final l = b;
    final m = 0.0722 + 0.9278 * effectiveValue;

    // See: https://www.w3.org/TR/filter-effects-1/#grayscaleEquivalent
    final colorFilter = ColorFilter.matrix(
      [
        a, b, c, 0, 0,
        //
        f, g, h, 0, 0,
        //
        k, l, m, 0, 0,
        //
        0, 0, 0, 1, 0,
      ],
    );

    return _ColorFilterVisualEffect(
      colorFilter: colorFilter,
      childSize: childSize,
      childEffect: this,
    );
  }

  VisualEffect opacity(double opacity) {
    if (opacity == 1) {
      return this;
    }

    return _OpacityVisualEffect(
      opacity: opacity,
      childSize: childSize,
      childEffect: this,
    );
  }

  VisualEffect rotation(
    Angle angle, {
    Alignment anchor = Alignment.center,
  }) {
    if (angle == Angle.zero) {
      return this;
    }

    final transform = Matrix4.rotationZ(angle.radians);
    return _TransformVisualEffect(
      transform: transform,
      anchor: anchor,
      childSize: childSize,
      childEffect: this,
    );
  }

  VisualEffect rotation3D(
    Angle angle, {
    required ({double x, double y, double z}) axis,
    double perspective = 1,
    Alignment anchor = Alignment.center,
  }) {
    if (angle == Angle.zero) {
      return this;
    }

    final vector = Vector3(axis.x, axis.y, axis.z);

    final transform = Matrix4.identity()
      ..setEntry(3, 2, perspective / 100)
      ..rotate(vector, angle.radians);
    return _TransformVisualEffect(
      transform: transform,
      anchor: anchor,
      childSize: childSize,
      childEffect: this,
    );
  }

  VisualEffect scale(
    double scale, {
    Alignment anchor = Alignment.center,
  }) {
    if (scale == 1) {
      return this;
    }

    final transform = Matrix4.diagonal3Values(scale, scale, 1);
    return _TransformVisualEffect(
      transform: transform,
      anchor: anchor,
      childSize: childSize,
      childEffect: this,
    );
  }

  VisualEffect shader(
    String assetKey,
    double devicePixelRatio,
    ShaderBuilder onGenerateShader,
  ) {
    return _ShaderVisualEffect(
      assetKey: assetKey,
      onGenerateShader: onGenerateShader,
      devicePixelRatio: devicePixelRatio,
      childSize: childSize,
      childEffect: this,
    );
  }

  VisualEffect transform(
    Matrix4 transform, {
    Alignment anchor = Alignment.center,
  }) {
    final det = transform.determinant();
    if (det == 0 || !det.isFinite) {
      return this;
    }

    return _TransformVisualEffect(
      transform: transform,
      anchor: anchor,
      childSize: childSize,
      childEffect: this,
    );
  }

  VisualEffect translate({
    double x = 0,
    double y = 0,
    Alignment anchor = Alignment.center,
  }) {
    if (x == 0 && y == 0) {
      return this;
    }

    final transform = Matrix4.translationValues(x, y, 0);
    return _TransformVisualEffect(
      transform: transform,
      anchor: anchor,
      childSize: childSize,
      childEffect: this,
    );
  }
}
