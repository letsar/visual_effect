# visual_effect

VisualEffect API for Flutter to easily add paint effects on your widgets.

## Scroll Effect

The main purpose of this API is to provide an easy and efficiently way to apply scroll animations.

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
[card_stack]: https://raw.githubusercontent.com/letsar/visual_effect/screenshots/card_stack.gif