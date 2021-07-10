import 'dart:typed_data';

import 'package:collection/collection.dart';

/// extension for [Int32x4].
extension Int32x4Extension on Int32x4 {
  /// Converts to a [Float32x4].
  Float32x4 toFloat32x4() =>
      Float32x4(x.toDouble(), y.toDouble(), z.toDouble(), w.toDouble());

  /// Filter this with [mapper].
  Int32x4 filter(Int32x4 Function(Int32x4 e) mapper) => mapper(this);

  /// Filter each value with [mapper] and return a [Int32x4].
  Int32x4 filterValues(int Function(int e) mapper) {
    return Int32x4(
      mapper(x),
      mapper(y),
      mapper(z),
      mapper(w),
    );
  }

  /// Filter each value with [mapper] and return a [Float32x4].
  Float32x4 filterToDoubleValues(double Function(int e) mapper) {
    return Float32x4(
      mapper(x),
      mapper(y),
      mapper(z),
      mapper(w),
    );
  }

  /// Map using [mapper].
  T map<T>(T Function(Int32x4 e) mapper) => mapper(this);

  /// Returns values as `List<int>`.
  List<int> toInts() => <int>[x, y, z, w];

  Int32x4 operator *(Int32x4 other) => Int32x4(
        x * other.x,
        y * other.y,
        z * other.z,
        w * other.w,
      );

  Int32x4 operator ~/(Int32x4 other) => Int32x4(
        x ~/ other.x,
        y ~/ other.y,
        z ~/ other.z,
        w ~/ other.w,
      );

  /// Returns the minimal lane value.
  int get minInLane {
    var min = x;
    if (y < min) min = y;
    if (z < min) min = z;
    if (w < min) min = w;
    return min;
  }

  /// Returns the maximum lane value.
  int get maxInLane {
    var max = x;
    if (y > max) max = y;
    if (z > max) max = z;
    if (w > max) max = w;
    return max;
  }

  /// Sum lane.
  int get sumLane => x + y + z + w;

  /// Sum part of the lane, until [size].
  int sumLanePartial(int size) {
    switch (size) {
      case 1:
        return x;
      case 2:
        return x + y;
      case 3:
        return x + y + z;
      case 4:
        return x + y + z + w;
      default:
        throw StateError('Invalid length: $size / 4');
    }
  }

  /// Sum lane squares.
  int get sumSquaresLane => (x * x) + (y * y) + (z * z) + (w * w);

  /// Sum part of the lane squares, until [size].
  int sumSquaresLanePartial(int size) {
    switch (size) {
      case 1:
        return (x * x);
      case 2:
        return (x * x) + (y * y);
      case 3:
        return (x * x) + (y * y) + (z * z);
      case 4:
        return (x * x) + (y * y) + (z * z) + (w * w);
      default:
        throw StateError('Invalid length: $size / 4');
    }
  }

  /// Returns true if equals to [other] values.
  bool equalsValues(Int32x4 other) {
    var diff = this - other;
    return diff.x == 0 && diff.y == 0 && diff.z == 0 && diff.w == 0;
  }
}

/// extension for [Float32x4].
extension Float32x4Extension on Float32x4 {
  /// Converts to a [Int32x4].
  Int32x4 toInt32x4() => Int32x4(x.toInt(), y.toInt(), z.toInt(), w.toInt());

  /// Perform a `toInt()` in each value and return a [Float32x4].
  Float32x4 toIntAsFloat32x4() => Float32x4(x.toInt().toDouble(),
      y.toInt().toDouble(), z.toInt().toDouble(), w.toInt().toDouble());

  /// Filter this with [mapper].
  Float32x4 filter(Float32x4 Function(Float32x4 e) filter) => filter(this);

  /// Filter each value with [mapper] and return a [Float32x4].
  Float32x4 filterValues(double Function(double e) mapper) {
    return Float32x4(
      mapper(x),
      mapper(y),
      mapper(z),
      mapper(w),
    );
  }

  /// Filter each value with [mapper] and return a [Int32x4].
  Int32x4 filterToIntValues(int Function(double e) mapper) {
    return Int32x4(
      mapper(x),
      mapper(y),
      mapper(z),
      mapper(w),
    );
  }

  /// Map using [mapper].
  T map<T>(T Function(Float32x4 e) mapper) => mapper(this);

  /// Returns values as `List<double>`.
  List<double> toDoubles() => <double>[x, y, z, w];

  /// Returns the minimum lane value.
  double get minInLane {
    var min = x;
    if (y < min) min = y;
    if (z < min) min = z;
    if (w < min) min = w;
    return min;
  }

  /// Returns the maximum lane value.
  double get maxInLane {
    var max = x;
    if (y > max) max = y;
    if (z > max) max = z;
    if (w > max) max = w;
    return max;
  }

  /// Sum lane.
  double get sumLane => x + y + z + w;

  /// Sum part of the lane, until [size].
  double sumLanePartial(int size) {
    switch (size) {
      case 1:
        return x;
      case 2:
        return x + y;
      case 3:
        return x + y + z;
      case 4:
        return x + y + z + w;
      default:
        throw StateError('Invalid length: $size / 4');
    }
  }

  /// Sum lane squares.
  double get sumSquaresLane => (x * x) + (y * y) + (z * z) + (w * w);

  /// Sum part of the lane squares, until [size].
  double sumSquaresLanePartial(int size) {
    switch (size) {
      case 1:
        return (x * x);
      case 2:
        return (x * x) + (y * y);
      case 3:
        return (x * x) + (y * y) + (z * z);
      case 4:
        return (x * x) + (y * y) + (z * z) + (w * w);
      default:
        throw StateError('Invalid length: $size / 4');
    }
  }

  /// Returns true if equals to [other] values.
  bool equalsValues(Float32x4 other) {
    var diff = this - other;
    return diff.x == 0.0 && diff.y == 0.0 && diff.z == 0.0 && diff.w == 0.0;
  }
}

/// [Equality] for [Int32x4].
class Int32x4Equality implements Equality<Int32x4> {
  @override
  bool equals(Int32x4 e1, Int32x4 e2) => e1.equalsValues(e2);

  @override
  int hash(Int32x4 e) =>
      e.x.hashCode ^ e.y.hashCode ^ e.z.hashCode ^ e.w.hashCode;

  @override
  bool isValidKey(Object? o) {
    return o is Int32x4;
  }
}

/// [Equality] for [Float32x4].
class Float32x4Equality implements Equality<Float32x4> {
  @override
  bool equals(Float32x4 e1, Float32x4 e2) => e1.equalsValues(e2);

  @override
  int hash(Float32x4 e) =>
      e.x.hashCode ^ e.y.hashCode ^ e.z.hashCode ^ e.w.hashCode;

  @override
  bool isValidKey(Object? o) {
    return o is Float32x4;
  }
}
