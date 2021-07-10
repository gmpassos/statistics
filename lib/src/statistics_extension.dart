import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'statistics_base.dart';
import 'statistics_tools.dart';

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

/// extension for `List<T>`.
extension ListExtension<T> on List<T> {
  int get lastIndex => length - 1;

  T getReversed(int reversedIndex) => this[lastIndex - reversedIndex];

  T? getValueIfExists(int index) =>
      index >= 0 && index < length ? this[index] : null;

  int setAllWithValue(T n) {
    var lng = length;
    for (var i = 0; i < lng; ++i) {
      this[i] = n;
    }
    return lng;
  }

  int setAllWith(T Function(int index, T value) f) {
    var lng = length;
    for (var i = 0; i < lng; ++i) {
      this[i] = f(i, this[i]);
    }
    return lng;
  }

  int setAllWithList(List<T> list, [int offset = 0]) {
    var lng = length;
    for (var i = 0; i < lng; ++i) {
      this[i] = list[offset + i];
    }
    return lng;
  }

  bool allEquals(T element) {
    if (length == 0) return false;

    for (var e in this) {
      if (e != element) return false;
    }

    return true;
  }

  List<String> toStringElements() => map((e) => '$e').toList();

  bool equalsValues(List<T> other) {
    return ListEquality<T>().equals(this, other);
  }

  int computeHashcode() {
    return ListEquality<T>().hash(this);
  }

  int ensureMaximumSize(int maximumSize,
      {bool removeFromEnd = false, int removeExtras = 0}) {
    var toRemove = length - maximumSize;
    if (toRemove <= 0) return 0;

    if (removeExtras > 0) {
      toRemove += removeExtras;
    }

    if (removeFromEnd) {
      return this.removeFromEnd(toRemove);
    } else {
      return removeFromBegin(toRemove);
    }
  }

  int removeFromBegin(int amount) {
    if (amount <= 0) return 0;
    var length = this.length;
    if (amount > length) amount = length;
    removeRange(0, amount);
    return amount;
  }

  int removeFromEnd(int amount) {
    if (amount <= 0) return 0;
    var length = this.length;
    if (amount > length) amount = length;
    removeRange(length - amount, length);
    return amount;
  }

  List<double> asDoubles() => this is List<double>
      ? this as List<double>
      : map((v) => parseDouble(v)!).toList();

  List<int> asInts() =>
      this is List<int> ? this as List<int> : map((v) => parseInt(v)!).toList();
}

/// extension for `Set<T>`.
extension SetExtension<T> on Set<T> {
  bool allEquals(T element) {
    if (length == 0) return false;

    for (var e in this) {
      if (e != element) return false;
    }

    return true;
  }

  List<String> toStringElements() => map((e) => '$e').toList();

  int computeHashcode() {
    return SetEquality<T>().hash(this);
  }
}

/// extension for `Iterable<T>`.
extension IterableExtension<T> on Iterable<T> {
  Map<G, List<T>> groupBy<G>(G Function(T e) grouper) {
    var groups = <G, List<T>>{};

    for (var e in this) {
      var g = grouper(e);
      var list = groups.putIfAbsent(g, () => <T>[]);
      list.add(e);
    }

    return groups;
  }
}

/// extension for `Iterable<N>` (`N` extends `num`).
extension IterableNumExtension<N extends num> on Iterable<N> {
  /// Casts [n] to [N].
  N castElement(num n) {
    if (N == int) {
      return n.toInt() as N;
    } else {
      return n.toDouble() as N;
    }
  }

  /// Maps this numeric collection to a `List<T>` using [f] to map each element.
  List<T> mapToList<T>(T Function(N n) f) => map(f).toList();

  /// Maps this numeric collection to a `Set<T>` using [f] to map each element.
  Set<T> mapToSet<T>(T Function(N n) f) => map(f).toSet();

  /// Maps this numeric collection to a `List<int>`.
  List<int> toInts() => mapToList((e) => e.toInt());

  /// Maps this numeric collection to a `List<double>`.
  List<double> toDoubles() => mapToList((e) => e.toDouble());

  /// Maps this numeric collection to a `List<String>`.
  List<String> toStrings() => mapToList((e) => e.toString());

  DataStatistics<num> get statistics => DataStatistics.compute(this);

  /// Returns the sum of this numeric collection.
  N get sum {
    var itr = iterator;

    if (!itr.moveNext()) {
      return castElement(0);
    }

    num total = itr.current;

    while (itr.moveNext()) {
      total += itr.current;
    }

    return castElement(total);
  }

  /// Returns the sum of squares of this numeric collection.
  N get sumSquares {
    var itr = iterator;

    if (!itr.moveNext()) {
      return castElement(0);
    }

    var first = itr.current;
    var total = first * first;

    while (itr.moveNext()) {
      var n = itr.current;
      total += n * n;
    }

    return castElement(total);
  }

  /// Returns the mean/average of this numeric collection.
  double get mean => sum / length;

  /// Returns the standard deviation of this numeric collection.
  double get standardDeviation {
    var itr = iterator;

    if (!itr.moveNext()) {
      return 0.0;
    }

    var average = mean;

    var first = itr.current;
    var total = first * first;

    while (itr.moveNext()) {
      var n = itr.current - average;
      total += n * n;
    }

    var deviation = sqrt(total / length);

    return deviation;
  }

  /// Returns `true` if this numeric collection is sorted.
  bool get isSorted {
    var itr = iterator;

    if (!itr.moveNext()) {
      return false;
    }

    num prev = itr.current;

    while (itr.moveNext()) {
      var n = itr.current;
      if (n < prev) return false;
    }

    return true;
  }

  /// Returns a sorted `List<double>` of this numeric collection.
  /// If this instance is already sorted and already a `List<int>`,
  /// returns `this` instance.
  List<N> asSortedList() {
    List<N> list;
    if (this is List<N> && isSorted) {
      list = this as List<N>;
    } else {
      list = toList();
      list.sort();
    }
    return list;
  }

  /// Return the median (middle value) of this numeric collection.
  /// If [data] is empty, returns `null`.
  num? get median {
    var data = asSortedList();

    var n = data.length;
    if (n < 1) {
      return null;
    }

    var halfN = (n ~/ 2);

    if (n % 2 == 1) {
      return data[halfN];
    } else {
      return (data[halfN - 1] + data[halfN]) / 2;
    }
  }

  /// Return the low median (middle value) this collection.
  /// If [data] is empty, returns `null`.
  num? get medianLow {
    var data = asSortedList();

    var n = data.length;
    if (n < 1) {
      return null;
    }

    var halfN = (n ~/ 2);

    if (n % 2 == 1) {
      return data[halfN];
    } else {
      return data[halfN - 1];
    }
  }

  /// Return the low median (middle value) this collection.
  /// If [data] is empty, returns `null`.
  num? get medianHigh {
    var data = asSortedList();

    var n = data.length;
    if (n < 1) {
      return null;
    }

    var halfN = (n ~/ 2);
    return data[halfN];
  }

  /// Returns the mean/average of squares of this numeric collection.
  double get squaresMean => sumSquares / length;

  /// Returns the squares of this numeric collection.
  List<N> get square => map((n) => castElement(n * n)).toList();

  List<N> get abs => map((n) => castElement(n.abs())).toList();

  /// Returns the moving average of [samplesSize] of this numeric collection.
  List<double> movingAverage(int samplesSize) {
    var length = this.length;
    if (length == 0) return <double>[];

    if (samplesSize >= length) return <double>[mean];

    var list = this is List<N> ? (this as List<N>) : toList();

    var movingAverage = <double>[];
    for (var i = 0; i < length; ++i) {
      var end = i + samplesSize;
      if (end > length) break;

      var total = 0.0;
      for (var j = i; j < end; ++j) {
        var e = list[j];
        total += e;
      }

      var average = total / samplesSize;
      movingAverage.add(average);
    }

    return movingAverage;
  }

  /// Merges this numeric collection with [other] using the [merge] function.
  List<num> merge(Iterable<num> other, num Function(N a, num b) merger) =>
      mergeTo<num>(other, merger, <num>[]);

  /// Merges this numeric collection with [other] using the [merge] function to [destiny].
  List<R> mergeTo<R>(
      Iterable<num> other, R Function(N a, num b) merger, List<R> destiny) {
    var itr1 = iterator;
    if (!itr1.moveNext()) {
      return destiny;
    }

    var itr2 = other.iterator;
    if (!itr2.moveNext()) {
      return destiny;
    }

    do {
      var n1 = itr1.current;
      var n2 = itr2.current;
      var d = merger(n1, n2);
      destiny.add(d);
    } while (itr1.moveNext() && itr2.moveNext());

    return destiny;
  }

  List<num> operator -(Iterable<num> other) => merge(other, (a, b) => a - b);

  List<num> operator *(Iterable<num> other) => merge(other, (a, b) => a * b);

  List<double> operator /(Iterable<num> other) =>
      mergeTo(other, (a, b) => a / b, <double>[]);

  List<int> operator ~/(List<num> other) =>
      mergeTo(other, (a, b) => a ~/ b, <int>[]);
}

/// extension for `Iterable<double>`.
extension IterableDoubleExtension on Iterable<double> {
  /// Maps this numeric collection to a `List<T>` using [f] to map each element.
  List<T> mapToList<T>(T Function(double n) f) => map(f).toList();

  /// Maps this numeric collection to a `Set<T>` using [f] to map each element.
  Set<T> mapToSet<T>(T Function(double n) f) => map(f).toSet();

  /// Maps this numeric collection to a `List<int>`.
  List<int> toInts() => mapToList((e) => e.toInt());

  /// Maps this numeric collection to a `List<double>`.
  List<double> toDoubles() => mapToList((e) => e.toDouble());

  /// Maps this numeric collection to a `List<String>`.
  List<String> toStrings() => mapToList((e) => e.toString());

  DataStatistics<num> get statistics => DataStatistics.compute(this);

  double get sum {
    var itr = iterator;

    if (!itr.moveNext()) {
      return 0.0;
    }

    var total = itr.current;

    while (itr.moveNext()) {
      total += itr.current;
    }

    return total;
  }

  double get sumSquares {
    var itr = iterator;

    if (!itr.moveNext()) {
      return 0.0;
    }

    var first = itr.current;
    var total = first * first;

    while (itr.moveNext()) {
      var n = itr.current;
      total += n * n;
    }

    return total;
  }

  double get mean => sum / length;

  double get standardDeviation {
    var itr = iterator;

    if (!itr.moveNext()) {
      return 0.0;
    }

    var average = mean;

    var first = itr.current;
    var total = first * first;

    while (itr.moveNext()) {
      var n = itr.current - average;
      total += n * n;
    }

    var deviation = sqrt(total / length);

    return deviation;
  }

  /// Returns `true` if this numeric collection is sorted.
  bool get isSorted {
    var itr = iterator;

    if (!itr.moveNext()) {
      return false;
    }

    num prev = itr.current;

    while (itr.moveNext()) {
      var n = itr.current;
      if (n < prev) return false;
    }

    return true;
  }

  /// Returns a sorted `List<double>` of this numeric collection.
  /// If this instance is already sorted and already a `List<int>`,
  /// returns `this` instance.
  List<double> asSortedList() {
    List<double> list;
    if (this is List<double> && isSorted) {
      list = this as List<double>;
    } else {
      list = toList();
      list.sort();
    }
    return list;
  }

  /// Return the median (middle value) of this numeric collection.
  /// If [data] is empty, returns `null`.
  num? get median {
    var data = asSortedList();

    var n = data.length;
    if (n < 1) {
      return null;
    }

    var halfN = (n ~/ 2);

    if (n % 2 == 1) {
      return data[halfN];
    } else {
      return (data[halfN - 1] + data[halfN]) / 2;
    }
  }

  /// Return the low median (middle value) this collection.
  /// If [data] is empty, returns `null`.
  num? get medianLow {
    var data = asSortedList();

    var n = data.length;
    if (n < 1) {
      return null;
    }

    var halfN = (n ~/ 2);

    if (n % 2 == 1) {
      return data[halfN];
    } else {
      return data[halfN - 1];
    }
  }

  /// Return the low median (middle value) this collection.
  /// If [data] is empty, returns `null`.
  num? get medianHigh {
    var data = asSortedList();

    var n = data.length;
    if (n < 1) {
      return null;
    }

    var halfN = (n ~/ 2);
    return data[halfN];
  }

  double get squaresMean => sumSquares / length;

  List<double> get square => map((n) => n * n).toList();

  List<double> get abs => map((n) => n.abs()).toList();

  List<double> movingAverage(int samplesSize) {
    var length = this.length;
    if (length == 0) return <double>[];

    if (samplesSize >= length) return <double>[mean];

    var list = this is List<double> ? (this as List<double>) : toList();

    var movingAverage = <double>[];
    for (var i = 0; i < length; ++i) {
      var end = i + samplesSize;
      if (end > length) break;

      var total = 0.0;
      for (var j = i; j < end; ++j) {
        var e = list[j];
        total += e;
      }

      var average = total / samplesSize;
      movingAverage.add(average);
    }

    return movingAverage;
  }

  List<double> merge(
          Iterable<num> other, double Function(double a, num b) merger) =>
      mergeTo<double>(other, merger, <double>[]);

  List<R> mergeTo<R>(Iterable<num> other, R Function(double a, num b) merger,
      List<R> destiny) {
    var itr1 = iterator;
    if (!itr1.moveNext()) {
      return destiny;
    }

    var itr2 = other.iterator;
    if (!itr2.moveNext()) {
      return destiny;
    }

    do {
      var n1 = itr1.current;
      var n2 = itr2.current;
      var d = merger(n1, n2);
      destiny.add(d);
    } while (itr1.moveNext() && itr2.moveNext());

    return destiny;
  }

  List<num> operator -(Iterable<num> other) => merge(other, (a, b) => a - b);

  List<num> operator *(Iterable<num> other) => merge(other, (a, b) => a * b);

  List<double> operator /(Iterable<num> other) =>
      mergeTo(other, (a, b) => a / b, <double>[]);

  List<int> operator ~/(List<num> other) =>
      mergeTo(other, (a, b) => a ~/ b, <int>[]);

  static final ListEquality<double> listEquality = ListEquality<double>();

  bool equalsValues(List<double> other, {double tolerance = 0.0}) {
    if (tolerance != 0) {
      var length = this.length;
      if (length != other.length) return false;

      tolerance = tolerance.abs();

      var list = this is List<double> ? (this as List<double>) : toList();

      for (var i = 0; i < length; ++i) {
        var a = list[i];
        var b = other[i];
        var diff = (a - b).abs();

        if (diff > tolerance) {
          return false;
        }
      }

      return true;
    } else {
      var list = this is List<double> ? (this as List<double>) : toList();
      return listEquality.equals(list, other);
    }
  }
}

/// extension for `Iterable<int>`.
extension IterableIntExtension on Iterable<int> {
  /// Maps this numeric collection to a `List<T>` using [f] to map each element.
  List<T> mapToList<T>(T Function(int n) f) => map(f).toList();

  /// Maps this numeric collection to a `Set<T>` using [f] to map each element.
  Set<T> mapToSet<T>(T Function(int n) f) => map(f).toSet();

  /// Maps this numeric collection to a `List<int>`.
  List<int> toInts() => mapToList((e) => e.toInt());

  /// Maps this numeric collection to a `List<double>`.
  List<double> toDoubles() => mapToList((e) => e.toDouble());

  /// Maps this numeric collection to a `List<String>`.
  List<String> toStrings() => mapToList((e) => e.toString());

  DataStatistics<num> get statistics => DataStatistics.compute(this);

  int get sum {
    var itr = iterator;

    if (!itr.moveNext()) {
      return 0;
    }

    var total = itr.current;

    while (itr.moveNext()) {
      total += itr.current;
    }

    return total;
  }

  int get sumSquares {
    var itr = iterator;

    if (!itr.moveNext()) {
      return 0;
    }

    var first = itr.current;
    var total = first * first;

    while (itr.moveNext()) {
      var n = itr.current;
      total += n * n;
    }

    return total;
  }

  double get mean => sum / length;

  double get standardDeviation {
    var itr = iterator;

    if (!itr.moveNext()) {
      return 0.0;
    }

    var average = mean;

    var first = itr.current;
    var total = (first * first).toDouble();

    while (itr.moveNext()) {
      var n = itr.current - average;
      total += n * n;
    }

    var deviation = sqrt(total / length);

    return deviation;
  }

  /// Returns `true` if this numeric collection is sorted.
  bool get isSorted {
    var itr = iterator;

    if (!itr.moveNext()) {
      return false;
    }

    num prev = itr.current;

    while (itr.moveNext()) {
      var n = itr.current;
      if (n < prev) return false;
    }

    return true;
  }

  /// Returns a sorted `List<int>` of this numeric collection.
  /// If this instance is already sorted and already a `List<int>`,
  /// returns `this` instance.
  List<int> asSortedList() {
    List<int> list;
    if (this is List<int> && isSorted) {
      list = this as List<int>;
    } else {
      list = toList();
      list.sort();
    }
    return list;
  }

  /// Return the median (middle value) of this numeric collection.
  /// If [data] is empty, returns `null`.
  num? get median {
    var data = asSortedList();

    var n = data.length;
    if (n < 1) {
      return null;
    }

    var halfN = (n ~/ 2);

    if (n % 2 == 1) {
      return data[halfN];
    } else {
      return (data[halfN - 1] + data[halfN]) / 2;
    }
  }

  /// Return the low median (middle value) this collection.
  /// If [data] is empty, returns `null`.
  num? get medianLow {
    var data = asSortedList();

    var n = data.length;
    if (n < 1) {
      return null;
    }

    var halfN = (n ~/ 2);

    if (n % 2 == 1) {
      return data[halfN];
    } else {
      return data[halfN - 1];
    }
  }

  /// Return the low median (middle value) this collection.
  /// If [data] is empty, returns `null`.
  num? get medianHigh {
    var data = asSortedList();

    var n = data.length;
    if (n < 1) {
      return null;
    }

    var halfN = (n ~/ 2);
    return data[halfN];
  }

  double get squaresMean => sumSquares / length;

  List<int> get square => map((n) => n * n).toList();

  List<int> get abs => map((n) => n.abs()).toList();

  List<double> movingAverage(int samplesSize) {
    var length = this.length;
    if (length == 0) return <double>[];

    if (samplesSize >= length) return <double>[mean];

    var list = this is List<int> ? (this as List<int>) : toList();

    var movingAverage = <double>[];
    for (var i = 0; i < length; ++i) {
      var end = i + samplesSize;
      if (end > length) break;

      var total = 0;
      for (var j = i; j < end; ++j) {
        var e = list[j];
        total += e;
      }

      var average = total / samplesSize;
      movingAverage.add(average);
    }

    return movingAverage;
  }

  List<num> merge(Iterable<num> other, num Function(int a, num b) merger) =>
      mergeTo<num>(other, merger, <num>[]);

  List<R> mergeTo<R>(
      Iterable<num> other, R Function(int a, num b) merger, List<R> destiny) {
    var itr1 = iterator;
    if (!itr1.moveNext()) {
      return destiny;
    }

    var itr2 = other.iterator;
    if (!itr2.moveNext()) {
      return destiny;
    }

    do {
      var n1 = itr1.current;
      var n2 = itr2.current;
      var d = merger(n1, n2);
      destiny.add(d);
    } while (itr1.moveNext() && itr2.moveNext());

    return destiny;
  }

  List<num> operator -(Iterable<num> other) => merge(other, (a, b) => a - b);

  List<num> operator *(Iterable<num> other) => merge(other, (a, b) => a * b);

  List<double> operator /(Iterable<num> other) =>
      mergeTo(other, (a, b) => a / b, <double>[]);

  List<int> operator ~/(List<num> other) =>
      mergeTo(other, (a, b) => a ~/ b, <int>[]);
}

/// extension for `num`.
extension NumExtension on num {
  num get square => this * this;

  double get squareRoot => sqrt(this);

  double get naturalExponent => exp(this);

  num clamp(num min, num max) {
    if (this < min) {
      return min;
    } else if (this > max) {
      return max;
    } else {
      return this;
    }
  }

  int signWithZeroTolerance([double zeroTolerance = 1.0E-20]) {
    if (this > 0) {
      return this < zeroTolerance ? 0 : 1;
    } else {
      return this > -zeroTolerance ? 0 : -1;
    }
  }
}

/// extension for `double`.
extension DoubleExtension on double {
  double get square => this * this;

  double clamp(double min, double max) {
    if (this < min) {
      return min;
    } else if (this > max) {
      return max;
    } else {
      return this;
    }
  }

  int signWithZeroTolerance([double zeroTolerance = 0.0000000000001]) {
    if (this > 0) {
      return this < zeroTolerance ? 0 : 1;
    } else {
      return this > -zeroTolerance ? 0 : -1;
    }
  }
}

/// extension for `int`.
extension IntExtension on int {
  int get square => this * this;

  int clamp(int min, int max) {
    if (this < min) {
      return min;
    } else if (this > max) {
      return max;
    } else {
      return this;
    }
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

/// extension for [Duration].
extension DurationExtension on Duration {
  String toStringUnit({
    bool days = true,
    bool hours = true,
    bool minutes = true,
    bool seconds = true,
    bool milliseconds = true,
    bool microseconds = true,
  }) {
    if (days && inDays > 0) {
      return '$inDays d';
    } else if (hours && inHours > 0) {
      return '$inHours h';
    } else if (minutes && inMinutes > 0) {
      return '$inMinutes min';
    } else if (seconds && inSeconds > 0) {
      return '$inSeconds sec';
    } else if (milliseconds && inMilliseconds > 0) {
      return '$inMilliseconds ms';
    } else if (microseconds && inMicroseconds > 0) {
      return '$inMicroseconds μs';
    } else {
      return toString();
    }
  }
}
