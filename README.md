# visual_effect

VisualEffect API for Flutter to easily add paint effects on your widgets.

> **Warning**
> This package is experimental for the moment. The API can change at any time.

## Scroll Effect

The main purpose of this API is to provide an easy and efficiently way to apply scroll animations.

> **Warning**
> The `addRepaintBoundaries` **MUST** be set to false in the parent Sliver/ScrollView because we explicitely want in that case to repaint for every single scroll so we can add the effect.

For example this Card Stack effect can be obtained with the code below:

![Card Stack][card_stack]

```dart
class _ScrolledItem extends StatelessWidget {
  const _ScrolledItem();

  @override
  Widget build(BuildContext context) {
    return ScrollEffect(
      onGenerateVisualEffect: (effect, phase) {
        return effect
            .grayscale(phase.leadingLerp(to: 0.5))
            .scale(
              phase.isLeading ? phase.leadingLerp(from: 1, to: 0.9) : 1,
              anchor: Alignment.topCenter,
            )
            .translate(y: effect.childSize.height * phase.leading);
      },
      child: const _CardItem(),
    );
  }
}
```

<!-- Links -->
[card_stack]: https://github.com/letsar/visual_effect/blob/83bff86af00715a18a071f1b133e3c0287b4b338/screenshots/card_stack.gif?raw=true