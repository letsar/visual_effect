import 'package:flutter/material.dart';
import 'package:visual_effect/visual_effect.dart';

void main() async {
  runApp(const _MyApp());
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      addRepaintBoundaries: false,
      itemBuilder: (context, index) {
        return _IndexScope(
          index: index,
          child: const _ScrolledItem(),
        );
      },
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

class _CardItem extends StatelessWidget {
  const _CardItem();

  @override
  Widget build(BuildContext context) {
    final index = _IndexScope.of(context);
    final color = Colors.primaries[index % Colors.primaries.length];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: color,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        child: const SizedBox(height: 300, width: 400),
      ),
    );
  }
}

class _ScrolledItem extends StatelessWidget {
  const _ScrolledItem();

  @override
  Widget build(BuildContext context) {
    final index = _IndexScope.of(context);

    return ScrollEffect(
      onGenerateVisualEffect: (effect, phase) {
        final isEven = index.isEven;
        final sign = isEven ? 1 : -1;
        final anchor = phase.isLeading
            ? (isEven ? Alignment.bottomLeft : Alignment.bottomRight)
            : (isEven ? Alignment.topLeft : Alignment.topRight);
        final angle = Angle.degrees(
          45 * sign * phase.sign * phase.ratioLerp(curve: Curves.easeOut),
        );
        return effect.rotation(angle, anchor: anchor);
      },
      child: const _CardItem(),
    );
  }
}
