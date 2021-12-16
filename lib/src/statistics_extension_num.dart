import 'dart:convert' as dart_convert;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:base_codecs/base_codecs.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'statistics_base.dart';
import 'statistics_platform.dart';

final StatisticsPlatform _platform = StatisticsPlatform.instance;

/// extension for `Iterable<N>` (`N` extends `num`).
extension IterableNExtension<N extends num> on Iterable<N> {
  bool get castsToDouble => N == double;

  /// Casts [n] to [N].
  N castElement(num n) {
    if (N == int) {
      return n.toInt() as N;
    } else if (N == double) {
      return n.toDouble() as N;
    } else {
      return n as N;
    }
  }

  /// Returns a [Statistics] of this numeric collection.
  Statistics<N> get statistics => Statistics.compute(this);

  /// Returns a [Statistics] of this numeric collection (with populated field [Statistics.data]).
  Statistics<N> get statisticsWithData =>
      Statistics.compute(this, keepData: true);
}

/// extension for `Iterable<N>` (`N` extends `num`).
extension IterableNumExtension on Iterable<num> {
  /// Maps this numeric collection to a `List<T>` using [f] to map each element.
  List<T> mapToList<T>(T Function(num n) f) => map(f).toList();

  /// Maps this numeric collection to a `Set<T>` using [f] to map each element.
  Set<T> mapToSet<T>(T Function(num n) f) => map(f).toSet();

  /// Maps this numeric collection to a `List<int>`.
  List<int> toIntsList() => mapToList((e) => e.toInt());

  /// Maps this numeric collection to a `List<double>`.
  List<double> toDoublesList() => mapToList((e) => e.toDouble());

  /// Maps this numeric collection to a `List<String>`.
  List<String> toStringsList() => mapToList((e) => e.toString());

  /// Returns the sum of this numeric collection.
  num get sum {
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

  /// Returns the sum of squares of this numeric collection.
  num get sumSquares {
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

    var deviation = math.sqrt(total / length);

    return deviation;
  }

  /// Returns `true` if this numeric collection is sorted.
  bool get isSorted {
    var itr = iterator;

    if (!itr.moveNext()) {
      return false;
    }

    var prev = itr.current;

    while (itr.moveNext()) {
      var n = itr.current;
      if (n < prev) return false;
      prev = n;
    }

    return true;
  }

  /// Returns a sorted `List<double>` of this numeric collection.
  /// If this instance is already sorted and already a `List<int>`,
  /// returns `this` instance.
  List<num> asSortedList() {
    List<num> list;
    if (this is List<num> && isSorted) {
      list = this as List<num>;
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
  List<num> get square => map((n) => n * n).toList();

  /// Returns the square roots of this numeric collection.
  List<double> get squareRoot => map(math.sqrt).toList();

  /// Returns the absolute values of this numeric collection.
  List<num> get abs => map((n) => n.abs()).toList();

  /// Returns the moving average of [samplesSize] of this numeric collection.
  List<double> movingAverage(int samplesSize) {
    var length = this.length;
    if (length == 0) return <double>[];

    if (samplesSize >= length) return <double>[mean];

    var list = this is List<num> ? (this as List<num>) : toList();

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
  List<num> merge(Iterable<num> other, num Function(num a, num b) merger) =>
      mergeTo<num>(other, merger, <num>[]);

  /// Merges this numeric collection with [other] using the [merge] function to [destiny].
  List<R> mergeTo<R>(
      Iterable<num> other, R Function(num a, num b) merger, List<R> destiny) {
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

  /// Subtracts elements of `this` instance with [other] instance elements.
  List<num> operator -(Iterable<num> other) => merge(other, (a, b) => a - b);

  /// Multiplies elements of `this` instance with [other] instance elements.
  List<num> operator *(Iterable<num> other) => merge(other, (a, b) => a * b);

  /// Divides elements of `this` instance with [other] instance elements.
  List<double> operator /(Iterable<num> other) =>
      mergeTo(other, (a, b) => a / b, <double>[]);

  /// Divides (as `int`) elements of `this` instance with [other] instance elements.
  List<int> operator ~/(List<num> other) =>
      mergeTo(other, (a, b) => a ~/ b, <int>[]);

  static final ListEquality<num> _listEquality = ListEquality<num>();

  /// Returns `true` if [other] values are all equals, regarding the [tolerance].
  bool equalsValues(List<num> other, {num tolerance = 0}) {
    if (tolerance != 0) {
      var length = this.length;
      if (length != other.length) return false;

      tolerance = tolerance.abs();

      var list = this is List<num> ? (this as List<num>) : toList();

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
      var list = this is List<num> ? (this as List<num>) : toList();
      return _listEquality.equals(list, other);
    }
  }
}

/// extension for `Iterable<double>`.
extension IterableDoubleExtension on Iterable<double> {
  /// Maps this numeric collection to a `List<T>` using [f] to map each element.
  List<T> mapToList<T>(T Function(double n) f) => map(f).toList();

  /// Maps this numeric collection to a `Set<T>` using [f] to map each element.
  Set<T> mapToSet<T>(T Function(double n) f) => map(f).toSet();

  /// Maps this numeric collection to a `List<int>`.
  List<int> toIntsList() => mapToList((e) => e.toInt());

  /// Maps this numeric collection to a `List<double>`.
  List<double> toDoublesList() => toList();

  /// Maps this numeric collection to a `List<String>`.
  List<String> toStringsList() => mapToList((e) => e.toString());

  /// Returns a [Statistics] of this numeric collection.
  Statistics<double> get statistics => Statistics.compute(this);

  /// Returns a [Statistics] of this numeric collection (with populated field [Statistics.data]).
  Statistics<double> get statisticsWithData =>
      Statistics.compute(this, keepData: true);

  /// Returns the sum of this numeric collection.
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

  /// Returns the sum of squares of this numeric collection.
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

    var deviation = math.sqrt(total / length);

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
      prev = n;
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

  /// Returns the mean/average of squares of this numeric collection.
  double get squaresMean => sumSquares / length;

  /// Returns the squares of this numeric collection.
  List<double> get square => map((n) => n * n).toList();

  /// Returns the square roots of this numeric collection.
  List<double> get squareRoot => map(math.sqrt).toList();

  /// Returns the absolute values of this numeric collection.
  List<double> get abs => map((n) => n.abs()).toList();

  /// Returns the moving average of [samplesSize] of this numeric collection.
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

  /// Merges this numeric collection with [other] using the [merge] function.
  List<double> merge(
          Iterable<num> other, double Function(double a, num b) merger) =>
      mergeTo<double>(other, merger, <double>[]);

  /// Merges this numeric collection with [other] using the [merge] function to [destiny].
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

  /// Subtracts elements of `this` instance with [other] instance elements.
  List<num> operator -(Iterable<num> other) => merge(other, (a, b) => a - b);

  /// Multiplies elements of `this` instance with [other] instance elements.
  List<num> operator *(Iterable<num> other) => merge(other, (a, b) => a * b);

  /// Divides elements of `this` instance with [other] instance elements.
  List<double> operator /(Iterable<num> other) =>
      mergeTo(other, (a, b) => a / b, <double>[]);

  /// Divides (as `int`) elements of `this` instance with [other] instance elements.
  List<int> operator ~/(List<num> other) =>
      mergeTo(other, (a, b) => a ~/ b, <int>[]);

  static final ListEquality<num> _listEquality = ListEquality<num>();

  /// Returns `true` if [other] values are all equals, regarding the [tolerance].
  bool equalsValues(List<num> other, {num tolerance = 0.0}) {
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
      return _listEquality.equals(list, other);
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
  List<int> toIntsList() => toList();

  /// Maps this numeric collection to a `List<double>`.
  List<double> toDoublesList() => mapToList((e) => e.toDouble());

  /// Maps this numeric collection to a `List<String>`.
  List<String> toStringsList() => mapToList((e) => e.toString());

  /// Returns a [Statistics] of this numeric collection.
  Statistics<int> get statistics => Statistics.compute(this);

  /// Returns a [Statistics] of this numeric collection (with populated field [Statistics.data]).
  Statistics<int> get statisticsWithData =>
      Statistics.compute(this, keepData: true);

  /// Returns the sum of this numeric collection.
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

  /// Returns the sum of squares of this numeric collection.
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
    var total = (first * first).toDouble();

    while (itr.moveNext()) {
      var n = itr.current - average;
      total += n * n;
    }

    var deviation = math.sqrt(total / length);

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
      prev = n;
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
  int? get medianLow {
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
  int? get medianHigh {
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
  List<int> get square => map((n) => n * n).toList();

  /// Returns the square roots of this numeric collection.
  List<double> get squareRoot => map(math.sqrt).toList();

  /// Returns the absolute values of this numeric collection.
  List<int> get abs => map((n) => n.abs()).toList();

  /// Returns the moving average of [samplesSize] of this numeric collection.
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

  /// Merges this numeric collection with [other] using the [merge] function.
  List<num> merge(Iterable<num> other, num Function(int a, num b) merger) =>
      mergeTo<num>(other, merger, <num>[]);

  /// Merges this numeric collection with [other] using the [merge] function to [destiny].
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

  /// Subtracts elements of `this` instance with [other] instance elements.
  List<num> operator -(Iterable<num> other) => merge(other, (a, b) => a - b);

  /// Multiplies elements of `this` instance with [other] instance elements.
  List<num> operator *(Iterable<num> other) => merge(other, (a, b) => a * b);

  /// Divides elements of `this` instance with [other] instance elements.
  List<double> operator /(Iterable<num> other) =>
      mergeTo(other, (a, b) => a / b, <double>[]);

  /// Divides (as `int`) elements of `this` instance with [other] instance elements.
  List<int> operator ~/(List<num> other) =>
      mergeTo(other, (a, b) => a ~/ b, <int>[]);

  static final ListEquality<num> _listEquality = ListEquality<num>();

  /// Returns `true` if [other] values are all equals, regarding the [tolerance].
  bool equalsValues(List<num> other, {num tolerance = 0}) {
    if (tolerance != 0) {
      var length = this.length;
      if (length != other.length) return false;

      tolerance = tolerance.abs();

      var list = this is List<int> ? (this as List<int>) : toList();

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
      var list = this is List<int> ? (this as List<int>) : toList();
      return _listEquality.equals(list, other);
    }
  }
}

/// extension for `num`.
extension NumExtension on num {
  /// Cast this number to [N], where [N] extends [num].
  /// Calls [toInt] or [toDouble] to perform the casting.
  N cast<N extends num>() {
    if (N == int) {
      return toInt() as N;
    } else if (N == double) {
      return toDouble() as N;
    } else {
      return this as N;
    }
  }

  /// Returns the square of `this` number.
  num get square => this * this;

  /// Returns the square root of `this` number.
  double get squareRoot => math.sqrt(this);

  /// Returns the natural exponent, [e], to the power of `this` number.
  double get naturalExponent => math.exp(this);

  /// Returns the sign of `this` number, regarding the [zeroTolerance].
  ///
  /// - If `this` number is in range of -[zeroTolerance] to +[zeroTolerance],
  ///   returns `0`.
  /// - Returns `1` for positive numbers and `-1` for negative numbers (when
  ///   out of [zeroTolerance] range).
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
  /// Returns the square of `this` number.
  double get square => this * this;

  /// Returns the square root of `this` number.
  double get squareRoot => math.sqrt(this);

  /// Returns the natural exponent, [e], to the power of `this` number.
  double get naturalExponent => math.exp(this);

  /// If `this` number [isNaN] returns [n]. If NOT, returns `this`.
  double ifNaN(double n) => isNaN ? n : this;

  /// If `this` number [isInfinite] returns [n]. If NOT, returns `this`.
  double ifInfinite(double n) => isInfinite ? n : this;

  /// If `this` number is NOT finite (![isFinite]) returns [n]. If NOT, returns `this`.
  ///
  /// - NOTE: A number is NOT finite if [isNaN] or [isInfinite].
  double ifNotFinite(double n) => !isFinite ? n : this;

  /// Returns the sign of `this` number, regarding the [zeroTolerance].
  ///
  /// - If `this` number is in range of -[zeroTolerance] to +[zeroTolerance],
  ///   returns `0`.
  /// - Returns `1` for positive numbers and `-1` for negative numbers (when
  ///   out of [zeroTolerance] range).
  int signWithZeroTolerance([double zeroTolerance = 0.0000000000001]) {
    if (this > 0) {
      return this < zeroTolerance ? 0 : 1;
    } else {
      return this > -zeroTolerance ? 0 : -1;
    }
  }

  /// Truncate the decimal part of this double number. This function is very useful
  /// for compere two double numbers.
  /// - [fractionDigits] : number of decimal digits
  ///
  /// Example:
  /// ```dart
  ///   var d = 1.4747474747474747 ;
  ///   print( d.truncate(3) );
  /// ```
  ///
  /// Output:
  /// ```text
  /// 1.475;
  /// ```
  ///
  /// Reference:
  /// - SciDart: https://pub.dev/packages/scidart
  /// - https://pub.dev/documentation/scidart/latest/numdart/truncate.html (Apache-2.0 License)
  ///
  /// ```
  double truncateDecimals(int fractionDigits) {
    if (isNaN || isInfinite) return this;
    if (fractionDigits <= 0) {
      return truncateToDouble();
    }

    var mod = math.pow(10.0, fractionDigits).toDouble();
    return ((this * mod).round().toDouble() / mod);
  }

  /// Converts to a percentage string (multiplying by `100`).
  ///
  /// - [fractionDigits] is the number of fraction digits.
  /// - [suffix] the percentage suffix. Default: `%`
  String toPercentage({int fractionDigits = 2, String suffix = '%'}) =>
      (this * 100).toStringAsFixed(fractionDigits) + suffix;
}

/// extension for `int`.
extension IntExtension on int {
  /// Returns `true` if this `int` is safe for the current platform ([StatisticsPlatform]).
  bool get isSafeInteger => _platform.isSafeInteger(this);

  /// Checks if this `int` is safe for the current platform ([StatisticsPlatform]).
  void checkSafeInteger() {
    _platform.checkSafeInteger(this);
  }

  /// Returns the square of `this` number.
  int get square => this * this;

  /// Returns the square root of `this` number.
  double get squareRoot => math.sqrt(this);

  /// Returns the natural exponent, [e], to the power of `this` number.
  double get naturalExponent => math.exp(this);

  /// Converts this `int` to [BigInt].
  BigInt toBigInt() => BigInt.from(this);

  /// Returns this `int` as a bits [String].
  String get bits => toRadixString(2);

  /// Returns this `int` as a bits [String] of minimal length [width].
  String bitsPadded(int width) => bits.numericalPadLeft(width);

  /// Returns this `int` as a 8 bits [String].
  String get bits8 => bitsPadded(8);

  /// Returns this `int` as a 16 bits [String].
  String get bits16 => bitsPadded(16);

  /// Returns this `int` as a 32 bits [String].
  String get bits32 => bitsPadded(32);

  /// Returns this `int` as a 64 bits [String].
  String get bits64 => bitsPadded(64);

  static final NumberFormat _numberFormat = NumberFormat.decimalPattern();

  /// Formats this `int` to a [String] with thousands separator.
  String get thousands => _numberFormat.format(this);

  /// Converts this 32 bits `int` to 4 bytes.
  Uint8List toUint8List32() {
    var bs = Uint8List(4);
    var data = bs.asByteData();
    data.setUint32(0, this);
    return bs;
  }

  /// Converts this 64 bits `int` to 8 bytes.
  Uint8List toUint8List64() {
    var bs = Uint8List(8);
    _platform.writeUint64(bs, this);
    return bs;
  }

  /// Same as [toUint8List32], but with bytes in reversed order.
  Uint8List toUint8List32Reversed() => toUint8List32().reverseBytes();

  /// Same as [toUint8List64], but with bytes in reversed order.
  Uint8List toUint8List64Reversed() => toUint8List64().reverseBytes();

  /// Converts this 32 bits `int` to HEX.
  String toHex32() => toUint8List32().toHex();

  /// Converts this 64 bits `int` to HEX.
  String toHex64() => toUint8List64().toHex();

  /// Converts to a [String] of [width] and left padded with `0`.
  String toStringPadded(int width) {
    var s = toString();
    return s.numericalPadLeft(width);
  }
}

/// extension for [BigInt].
extension BigIntExtension on BigInt {
  /// Returns `true` if this as `int` is safe for the current platform ([StatisticsPlatform]).
  bool get isSafeInteger => _platform.isSafeIntegerByBigInt(this);

  /// Checks if this as `int` is safe for the current platform ([StatisticsPlatform]).
  void checkSafeInteger() {
    _platform.checkSafeIntegerByBigInt(this);
  }

  String toHex({int width = 0}) {
    var hex = toRadixString(16).toUpperCase();
    if (width > 0) {
      if (isNegative) {
        hex = hex.substring(1);
        return '-' + hex.padLeft(width, '0');
      } else {
        return hex.padLeft(width, '0');
      }
    }
    return hex;
  }

  String toHexUnsigned({int width = 0}) {
    if (isNegative) {
      var hex = toHex();
      if (hex.startsWith('-')) {
        hex = hex.substring(1);
      }

      if (hex.length % 2 != 0) {
        hex = '0' + hex;
      }

      var bs = hex.decodeHex();
      var bs2 = Uint8List.fromList(bs.map((e) => 256 - e).toList());

      var hex2 = bs2.toHex();
      if (width > 0) {
        hex2 = hex2.padLeft(width, 'F');
      }
      return hex2;
    } else {
      var hex = toHex();
      if (width > 0) {
        hex = hex.padLeft(width, '0');
      }
      return hex;
    }
  }

  String toHex32() {
    if (isNegative) {
      return toHexUnsigned(width: 8);
    } else {
      return toHex(width: 8);
    }
  }

  String toHex64() {
    if (isNegative) {
      return toHexUnsigned(width: 16);
    } else {
      return toHex(width: 16);
    }
  }

  Uint8List toUint8List32() => toInt().toUint8List32();

  Uint8List toUint8List64() => toInt().toUint8List64();
}

/// Numeric extension for [String].
extension StringToNumExtension on String {
  /// Parses this [String] to a [num].
  num toNum() => num.parse(this);

  /// Parses this [String] to a [int].
  int toInt() => int.parse(this);

  /// Parses this [String] to a [double].
  double toDouble() => double.parse(this);

  /// Converts this [String] to a [BigInt] parsing as a integer text.
  BigInt toBigInt() => BigInt.parse(this);

  /// Converts this [String] to a [BigInt] parsing as a HEX sequence.
  BigInt toBigIntFromHex() => BigInt.parse(this, radix: 16);

  /// Same as [padLeft] with `0`, but respects the numerical signal.
  String numericalPadLeft(int width) {
    var s = this;
    if (s.startsWith('-')) {
      var n = s.substring(1);
      return '-' + n.padLeft(width, '0');
    } else {
      return s.padLeft(width, '0');
    }
  }

  /// Decodes this [String] as an `HEX` sequence of bytes ([Uint8List]).
  Uint8List decodeHex() => base16.decode(this);
}

/// Extension for [Uint8List].
extension Uint8ListExtension on Uint8List {
  /// Returns this bytes as [String] of bits of length [width].
  String bitsPadded(int width) =>
      map((e) => e.bits8).join().numericalPadLeft(width);

  /// Returns this bytes as [String] of bits.
  String get bits => map((e) => e.bits8).join();

  /// Returns this bytes as 8 bits [String].
  String get bits8 => bitsPadded(8);

  /// Returns this bytes as 16 bits [String].
  String get bits16 => bitsPadded(16);

  /// Returns this bytes as 32 bits [String].
  String get bits32 => bitsPadded(32);

  /// Returns this bytes as 64 bits [String].
  String get bits64 => bitsPadded(64);

  static final ListEquality<int> _listIntEquality = ListEquality<int>();

  /// Returns `true` of [other] elements are equals.
  bool equals(Uint8List other) => _listIntEquality.equals(this, other);

  /// Returns a hashcode of this bytes.
  int bytesHashCode() => _listIntEquality.hash(this);

  /// A sub `Uint8List` view of regeion.
  Uint8List subView([int offset = 0, int? length]) {
    length ??= this.length - offset;
    return buffer.asUint8List(offset, length);
  }

  /// A sub `Uint8List` view of the tail.
  Uint8List subViewTail(int tailLength) {
    var length = this.length;
    var offset = length - tailLength;
    var lng = length - offset;
    return subView(offset, lng);
  }

  /// Returns a [ByteData] of `this` [buffer] with the respective offset and length.
  ByteData asByteData() => buffer.asByteData(offsetInBytes, lengthInBytes);

  /// Returns a copy of `this` instance.
  Uint8List copy() => Uint8List.fromList(this);

  /// Returns an unmodifiable copy of `this` instance.
  Uint8List copyAsUnmodifiable() => UnmodifiableUint8ListView(copy());

  /// Returns an unmodifiable view of `this` instance.
  ///
  /// - Will just cast if is already an [UnmodifiableUint8ListView].
  UnmodifiableUint8ListView get asUnmodifiableView {
    var self = this;
    return self is UnmodifiableUint8ListView
        ? self
        : UnmodifiableUint8ListView(self);
  }

  /// Decodes `this` bytes as a `LATIN-1` [String].
  String toStringLatin1() => dart_convert.latin1.decode(this);

  /// Decodes `this` bytes as a `UTF-8` [String].
  String toStringUTF8() => dart_convert.utf8.decode(this);

  /// Returns `this` instance in a reversed order.
  Uint8List reverseBytes() => Uint8List.fromList(reversed.toList());

  /// Converts `this` bytes to HEX.
  String toHex({Endian endian = Endian.big}) {
    return endian == Endian.big ? toHexBigEndian() : toHexLittleEndian();
  }

  /// Converts `this` bytes to HEX (big-endian).
  String toHexBigEndian() => base16.encode(this);

  /// Converts `this` bytes to HEX (little-endian).
  String toHexLittleEndian() => base16.encode(reverseBytes());

  /// Converts `this` bytes to a [BigInt] (through [toHex]).
  BigInt toBigInt({Endian endian = Endian.big}) =>
      toHex(endian: endian).toBigIntFromHex();

  /// Returns a `Uint8` at [byteOffset] of this bytes buffer (reads 1 byte).
  int getUint8([int byteOffset = 0]) => asByteData().getUint8(byteOffset);

  /// Returns a `Uint16` at [byteOffset] of this bytes buffer (reads 2 bytes).
  int getUint16([int byteOffset = 0]) => asByteData().getUint16(byteOffset);

  /// Returns a `Uint32` at [byteOffset] of this bytes buffer (reads 4 bytes).
  int getUint32([int byteOffset = 0]) => asByteData().getUint32(byteOffset);

  /// Returns a `Uint64` at [byteOffset] of this bytes buffer (reads 8 bytes).
  int getUint64([int byteOffset = 0]) {
    return _platform.readUint64(this, byteOffset);
  }

  /// Returns a `Int8` at [byteOffset] of this bytes buffer (reads 1 byte).
  int getInt8([int byteOffset = 0]) => asByteData().getInt8(byteOffset);

  /// Returns a `Int16` at [byteOffset] of this bytes buffer (reads 2 bytes).
  int getInt16([int byteOffset = 0]) => asByteData().getInt16(byteOffset);

  /// Returns a `Int32` at [byteOffset] of this bytes buffer (reads 4 bytes).
  int getInt32([int byteOffset = 0]) => asByteData().getInt32(byteOffset);

  /// Returns a `Int64` at [byteOffset] of this bytes buffer (reads 8 bytes).
  int getInt64([int byteOffset = 0]) => _platform.readInt64(this, byteOffset);

  /// Converts this bytes to a [List] of `Uint8`.
  List<int> toListOfUint8() => List<int>.from(this);

  /// Converts this bytes to a [List] of `Uint16`.
  List<int> toListOfUint16() {
    final byteData = asByteData();
    return List<int>.generate(length ~/ 2, (i) => byteData.getUint16(i * 2));
  }

  /// Converts this bytes to a [List] of `Uint32`.
  List<int> toListOfUint32() {
    final byteData = asByteData();
    return List<int>.generate(length ~/ 4, (i) => byteData.getUint32(i * 4));
  }

  /// Converts this bytes to a [List] of `Uint64`.
  List<int> toListOfUint64() {
    return List<int>.generate(
        length ~/ 8, (i) => _platform.readUint64(this, i * 8));
  }

  /// Converts this bytes to a [List] of `Int8`.
  List<int> toListOfInt8() {
    final byteData = asByteData();
    return List<int>.generate(length, (i) => byteData.getInt8(i));
  }

  /// Converts this bytes to a [List] of `Int16`.
  List<int> toListOfInt16() {
    final byteData = asByteData();
    return List<int>.generate(length ~/ 2, (i) => byteData.getInt16(i * 2));
  }

  /// Converts this bytes to a [List] of `Int32`.
  List<int> toListOfInt32() {
    final byteData = asByteData();
    return List<int>.generate(length ~/ 4, (i) => byteData.getInt32(i * 4));
  }

  /// Converts this bytes to a [List] of `Int64`.
  List<int> toListOfInt64() {
    return List<int>.generate(
        length ~/ 8, (i) => _platform.readInt64(this, i * 8));
  }
}

extension ListIntExtension on List<int> {
  /// Same as [encodeUint8List].
  Uint8List toUint8List() => encodeUint8List();

  /// Ensures that this [List] is a [Uint8List].
  ///
  /// Calls [encodeUint8List] if needed, or just cast to [Uint8List].
  Uint8List get asUint8List =>
      this is Uint8List ? (this as Uint8List) : encodeUint8List();

  /// Encodes this [List] to a [Uint8List] of `Uint8`.
  Uint8List encodeUint8List() => Uint8List.fromList(this);

  /// Encodes this [List] to a [Uint8List] of `Uint16`.
  Uint8List encodeUint16List() {
    final length = this.length;

    final bs = Uint8List(length * 2);
    final byteData = bs.asByteData();
    var byteDataOffset = 0;

    for (var i = 0; i < length; ++i) {
      var n = this[i];
      byteData.setUint16(byteDataOffset, n);
      byteDataOffset += 2;
    }

    return bs;
  }

  /// Encodes this [List] to a [Uint8List] of `Uint32`.
  Uint8List encodeUint32List() {
    final length = this.length;

    final bs = Uint8List(length * 4);
    final byteData = bs.asByteData();
    var byteDataOffset = 0;

    for (var i = 0; i < length; ++i) {
      var n = this[i];
      byteData.setUint32(byteDataOffset, n);
      byteDataOffset += 4;
    }

    return bs;
  }

  /// Encodes this [List] to a [Uint8List] of `Uint64`.
  Uint8List encodeUint64List() {
    final p = _platform;

    final length = this.length;
    final bs = Uint8List(length * 8);

    var byteDataOffset = 0;

    for (var i = 0; i < length; ++i) {
      var n = this[i];

      p.writeUint64(bs, n, byteDataOffset);

      byteDataOffset += 8;
    }

    return bs;
  }

  /// Similar to [String.compareTo].
  int compareWith(List<int> other) {
    int len1 = length;
    int len2 = other.length;
    int lim = math.min(len1, len2);

    int k = 0;
    while (k < lim) {
      var c1 = this[k];
      var c2 = other[k];
      if (c1 != c2) {
        return c1 - c2;
      }
      k++;
    }
    return len1 - len2;
  }
}
