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
      title: 'Visual Effect Parallax',
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
    return const Scaffold(
      body: Center(
        child: _TripListView(),
      ),
    );
  }
}

class _TripListView extends StatelessWidget {
  const _TripListView();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth - 60;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          addRepaintBoundaries: false,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            return _TripCard(
              image: trip.image,
              city: trip.city,
              country: trip.country,
              cardWidth: cardWidth,
            );
          },
        );
      },
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.image,
    required this.city,
    required this.country,
    required this.cardWidth,
  });

  final String image;
  final String city;
  final String country;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _CarouselEffect(
        child: SizedBox(
          height: 500,
          width: cardWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(5, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: Stack(
                  children: [
                    _ParallaxEffect(
                      ratio: 1.4,
                      child: _Image(image: image),
                    ),
                    Positioned.fill(
                      child: _OverlayView(city: city, country: country),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CarouselEffect extends StatelessWidget {
  const _CarouselEffect({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollEffect(
      onGenerateVisualEffect: (effect, phase) {
        final scale = phase.ratioLerp(from: 1, to: 0.95);
        return effect.scale(x: scale, y: scale);
      },
      addRepaintBoundaries: false,
      child: child,
    );
  }
}

class _ParallaxEffect extends StatelessWidget {
  const _ParallaxEffect({
    required this.child,
    required this.ratio,
  });

  final Widget child;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return ScrollEffect(
      onGenerateVisualEffect: (effect, phase) {
        final minX = phase.ratio * effect.childSize.width * ratio;
        return effect.translate(x: -minX * phase.sign);
      },
      child: child,
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({
    required this.image,
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      minWidth: 0,
      maxWidth: double.infinity,
      minHeight: 500,
      maxHeight: 500,
      child: Image.network(
        image,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _OverlayView extends StatelessWidget {
  const _OverlayView({
    required this.city,
    required this.country,
  });

  final String city;
  final String country;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.1),
            Colors.black.withOpacity(0.5),
            Colors.black,
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 30,
            bottom: 20,
            right: 30,
            top: 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city,
                style: textStyle.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                country,
                style: textStyle.titleSmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Trip {
  const Trip({
    required this.image,
    required this.city,
    required this.country,
  });

  final String image;
  final String city;
  final String country;
}

const trips = [
  Trip(
    image:
        'https://images.unsplash.com/photo-1508050919630-b135583b29ab?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2306&q=80',
    city: 'Paris',
    country: 'France',
  ),
  Trip(
    image:
        'https://images.unsplash.com/photo-1560930950-5cc20e80e392?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2340&q=80',
    city: 'Berlin',
    country: 'Germany',
  ),
  Trip(
    image:
        'https://images.unsplash.com/photo-1547636780-e41778614c28?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2342&q=80',
    city: 'Mardrid',
    country: 'Spain',
  ),
  Trip(
    image:
        'https://images.unsplash.com/photo-1525874684015-58379d421a52?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2340&q=80',
    city: 'Rome',
    country: 'Italy',
  ),
];
