import 'dart:math' as math;
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'statistics_base.dart';
import 'statistics_dynamic_int.dart';
import 'statistics_decimal.dart';

/// Extension for [Type].
extension NumericTypeExtension on Type {
  /// Returns `true` if `this` [Type] is an [int], [double], [num] or [BigInt].
  bool get isNumericType {
    var self = this;
    return self == int || self == double || self == num || self == BigInt;
  }

  /// Returns `true` if `this` [Type] is an [int], [double], [num], [BigInt] or a [DynamicNumber]
  /// See [isNumericType] and [isDynamicNumberType].
  bool get isNumericOrDynamicNumberType => isNumericType || isDynamicNumberType;

  /// Returns `true` if `this` [Type] is a [DynamicNumber], [DynamicInt] or [Decimal].
  bool get isDynamicNumberType {
    var self = this;
    return self == DynamicNumber || self == DynamicInt || self == Decimal;
  }
}

/// Extension for [Object] nullable.
extension NumberObjectExtension on Object? {
  /// Returns `true` if `this` object is a number ([num] or [BigInt]).
  bool get isNumericValue {
    var self = this;
    return self is num || self is BigInt;
  }

  /// Returns `true` if `this` object is a number ([num], [BigInt] or [DynamicNumber]).
  /// See [isNumericValue] and [isDynamicNumberValue].
  bool get isNumericOrDynamicNumberValue =>
      isNumericValue || isDynamicNumberValue;

  /// Returns `true` if `this` object is a [DynamicNumber].
  bool get isDynamicNumberValue => this is DynamicNumber;

  /// Returns [defaultValue] if `this == null`.
  T whenNull<T>(T defaultValue) {
    if (this == null) {
      return defaultValue;
    }
    return this as T;
  }
}

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

  /// Maps this numeric collection to a `List<DynamicInt>`.
  List<DynamicInt> toDynamicIntList() =>
      mapToList((e) => DynamicInt.fromNum(e));

  /// Maps this numeric collection to a `List<Decimal>`.
  List<Decimal> toDecimalList() => mapToList((e) => Decimal.fromNum(e));

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

    var first = itr.current - average;
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

  /// Maps this numeric collection to a `List<BigInt>`.
  List<BigInt> toBigIntList() => mapToList((e) => BigInt.from(e));

  /// Maps this numeric collection to a `List<DynamicInt>`.
  List<DynamicInt> toDynamicIntList() =>
      mapToList((e) => DynamicInt.fromNum(e));

  /// Maps this numeric collection to a `List<Decimal>`.
  List<Decimal> toDecimalList() => mapToList((e) => Decimal.fromDouble(e));

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

  /// Maps this numeric collection to a `List<BigInt>`.
  List<BigInt> toBigIntList() => mapToList((e) => BigInt.from(e));

  /// Maps this numeric collection to a `List<DynamicInt>`.
  List<DynamicInt> toDynamicIntList() =>
      mapToList((e) => DynamicInt.fromInt(e));

  /// Maps this numeric collection to a `List<Decimal>`.
  List<Decimal> toDecimalList() => mapToList((e) => Decimal.fromInt(e));

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

  /// Converts this `num` to [BigInt].
  BigInt toBigInt() => BigInt.from(this);

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

  /// Returns `true` if this [double] is a whole number.
  bool get isWholeNumber {
    var self = this;
    if (self is int) {
      return self.isWholeNumber;
    } else if (self is double) {
      return self.isWholeNumber;
    } else {
      return false;
    }
  }

  /// Returns an [int] for this [num] if [isWholeNumber] otherwise returns `this`.
  num compactType() {
    var self = this;
    if (self is double) {
      return self.compactType();
    } else {
      return this;
    }
  }
}

/// extension for `double`.
extension DoubleExtension on double {
  /// Converts this `double` to [BigInt].
  BigInt toBigInt() => BigInt.from(this);

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

  /// Returns `true` if this [double] is a whole number.
  bool get isWholeNumber {
    var n = toInt();
    return this == n;
  }

  /// Returns an [int] for this [double] if [isWholeNumber] otherwise returns `this`.
  num compactType() {
    if (isWholeNumber) {
      return toInt();
    } else {
      return this;
    }
  }
}

/// extension for `int`.
extension IntExtension on int {
  /// Returns the square of `this` number.
  int get square => this * this;

  /// Returns the square root of `this` number.
  double get squareRoot => math.sqrt(this);

  /// Returns the natural exponent, [e], to the power of `this` number.
  double get naturalExponent => math.exp(this);

  /// Converts this `int` to [BigInt].
  BigInt toBigInt() => BigInt.from(this);

  static final NumberFormat _numberFormat = NumberFormat.decimalPattern();

  /// Formats this `int` to a [String] with thousands separator.
  String get thousands => _numberFormat.format(this);

  /// Returns `true` for [int] numbers.
  bool get isWholeNumber => true;
}

/// extension for [BigInt].
extension BigIntExtension on BigInt {
  String get thousands => toInt().thousands;
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
}

extension ListIntExtension on List<int> {
  /// Similar to [String.compareTo].
  int compareWith(List<int> other) {
    final len1 = length;
    final len2 = other.length;
    final lim = math.min(len1, len2);

    var k = 0;
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

extension IterableComparablesExtension<T> on Iterable<Comparable<T>> {
  /// Compares two [Iterable]s.
  ///
  /// Similar to [String.compareTo].
  int compareWith(Iterable<T> other) {
    if (identical(this, other)) return 0;

    final len1 = length;
    final len2 = other.length;
    final lim = math.min(len1, len2);

    var k = 0;
    while (k < lim) {
      var c1 = elementAt(k);
      var c2 = other.elementAt(k);

      var cmp = c1.compareTo(c2);

      if (cmp != 0) {
        return cmp;
      }
      k++;
    }
    return len1 - len2;
  }
}

extension IterableUint8ListExtension on Iterable<Uint8List> {
  /// Compares two [Iterable]s of [Uint8List].
  ///
  /// Similar to [String.compareTo].
  int compareWith(Iterable<Uint8List> other) {
    if (identical(this, other)) return 0;

    int len1 = length;
    int len2 = other.length;
    int lim = math.min(len1, len2);

    int k = 0;
    while (k < lim) {
      var c1 = elementAt(k);
      var c2 = other.elementAt(k);

      var cmp = c1.compareWith(c2);
      if (cmp != 0) {
        return cmp;
      }

      k++;
    }
    return len1 - len2;
  }
}
