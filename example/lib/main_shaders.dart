import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:visual_effect/visual_effect.dart';

late final ui.Image _noise;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final data = await rootBundle.load('assets/noise_3.png');
  final image = img.decodePng(data.buffer.asUint8List());
  _noise = await _imgImageToUiImage(image!);
  await ShaderVisualEffectCache.cache('shaders/dissolve.frag');
  runApp(const _MyApp());
}

Future<ui.Image> _imgImageToUiImage(img.Image image) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(
      image.getBytes(order: img.ChannelOrder.rgba));
  final id = ui.ImageDescriptor.raw(buffer,
      height: image.height,
      width: image.width,
      pixelFormat: ui.PixelFormat.rgba8888);
  final codec = await id.instantiateCodec(
      targetHeight: image.height, targetWidth: image.width);
  final fi = await codec.getNextFrame();
  final uiImage = fi.image;
  return uiImage;
}

class _MyApp extends StatelessWidget {
  const _MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visual Effect Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home: const _MyHomePage(),
    );
  }
}

class _MyHomePage extends StatelessWidget {
  const _MyHomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visual Effect')),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  Widget? _itemBuilder(BuildContext context, int index) {
    return _IndexScope(
      index: index,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: _ScrolledItem(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList.builder(
          addRepaintBoundaries: false,
          itemBuilder: _itemBuilder,
          itemCount: 20,
        ),
        SliverGrid.builder(
          addRepaintBoundaries: false,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: _itemBuilder,
        ),
      ],
    );
  }
}

class _IndexScope extends InheritedWidget {
  const _IndexScope({
    required this.index,
    required super.child,
  });

  final int index;

  static int of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_IndexScope>();
    return scope?.index ?? 0;
  }

  @override
  bool updateShouldNotify(_IndexScope oldWidget) {
    return oldWidget.index != index;
  }
}

class _ImageItem extends StatelessWidget {
  const _ImageItem();

  @override
  Widget build(BuildContext context) {
    final id = _IndexScope.of(context) * 10;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      child: Image.network(
        'https://picsum.photos/seed/$id/400/300',
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ScrolledItem extends StatelessWidget {
  const _ScrolledItem();

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    return ScrollEffect(
      onGenerateVisualEffect: (effect, phase) {
        final t = phase.ratioLerp(from: 0.25);

        return effect.shader(
          'shaders/dissolve.frag',
          devicePixelRatio,
          (shader, image, size) {
            shader
              ..setFloat(0, size.width)
              ..setFloat(1, size.height)
              ..setFloat(2, t)
              ..setImageSampler(0, image)
              ..setImageSampler(1, _noise);
          },
        );
      },
      child: const _ImageItem(),
    );
  }
}
