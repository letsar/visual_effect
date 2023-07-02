import 'dart:math' as math;

import 'package:meta/meta.dart';

@immutable
class Angle implements Comparable<Angle> {
  const Angle.radians(this.radians);
  const Angle.degrees(double degrees) : radians = degrees * math.pi / 180;

  static const Angle zero = Angle.radians(0);

  final double radians;

  @override
  int compareTo(Angle other) {
    if (this == other) {
      return 0;
    } else if (this > other) {
      return 1;
    } else {
      return -1;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is Angle && other.radians == radians;
  }

  @override
  int get hashCode => radians.hashCode;

  /// Whether this [Angle] is smaller than [other].
  bool operator <(Angle other) => radians < other.radians;

  /// Whether this [Duration] is greater than [other].
  bool operator >(Angle other) => radians > other.radians;

  /// Whether this [Angle] is smaller than or equal to [other].
  bool operator <=(Angle other) => radians <= other.radians;

  /// Whether this [Angle] is greater than or equal to [other].
  bool operator >=(Angle other) => radians >= other.radians;

  /// Adds this [Angle] by another one and returns the result as a new
  /// Angle object.
  Angle operator +(Angle other) => Angle.radians(radians + other.radians);

  /// Substracts this [Angle] by another one and returns the result as a new
  /// Angle object.
  Angle operator -(Angle other) => Angle.radians(radians - other.radians);

  /// Multiplies this [Angle] by another one and returns the result as a new
  /// Angle object.
  Angle operator *(Angle other) => Angle.radians(radians * other.radians);

  /// Divides this [Angle] by another one and returns the result as a new
  /// Angle object.
  Angle operator /(Angle other) => Angle.radians(radians / other.radians);
}
