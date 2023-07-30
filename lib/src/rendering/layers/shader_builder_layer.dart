// A lot of this code is copied from flutter_shaders, so we copied their license
// as well:
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file of flutter_shaders.

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

typedef ShaderBuilder = void Function(
  ui.FragmentShader shader,
  ui.Image image,
  Size size,
);

/// A [Layer] that uses an [AnimatedSamplerBuilder] to create a [ui.Picture]
/// every time it is added to a scene.
class ShaderBuilderLayer extends OffsetLayer {
  ShaderBuilderLayer(this._callback, this.shader);

  ui.Picture? _lastPicture;
  ui.FragmentShader shader;

  Size get size => _size;
  Size _size = Size.zero;
  set size(Size value) {
    if (value == size) {
      return;
    }
    _size = value;
    markNeedsAddToScene();
  }

  double get devicePixelRatio => _devicePixelRatio;
  double _devicePixelRatio = 1;
  set devicePixelRatio(double value) {
    if (value == devicePixelRatio) {
      return;
    }
    _devicePixelRatio = value;
    markNeedsAddToScene();
  }

  ShaderBuilder get callback => _callback;
  ShaderBuilder _callback;
  set callback(ShaderBuilder value) {
    if (value == callback) {
      return;
    }
    _callback = value;
    markNeedsAddToScene();
  }

  ui.Image _buildChildScene(Rect bounds, double pixelRatio) {
    final builder = ui.SceneBuilder();
    final transform = Matrix4.diagonal3Values(pixelRatio, pixelRatio, 1);
    transform.translate(-bounds.left, -bounds.top);
    builder.pushTransform(transform.storage);
    addChildrenToScene(builder);
    return builder.build().toImageSync(
          (pixelRatio * bounds.width).ceil(),
          (pixelRatio * bounds.height).ceil(),
        );
  }

  @override
  void dispose() {
    _lastPicture?.dispose();
    super.dispose();
  }

  @override
  void addToScene(ui.SceneBuilder builder) {
    if (size.isEmpty) {
      return;
    }

    final ui.Image image = _buildChildScene(
      offset & size,
      devicePixelRatio,
    );

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    try {
      callback(shader, image, size);
      canvas.drawRect(
        Offset.zero & size,
        Paint()..shader = shader,
      );
    } finally {
      image.dispose();
    }

    final ui.Picture picture = pictureRecorder.endRecording();
    _lastPicture?.dispose();
    _lastPicture = picture;
    builder.addPicture(offset, picture);
  }
}
