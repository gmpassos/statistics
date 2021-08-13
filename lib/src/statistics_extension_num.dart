import 'dart:math';

import 'package:collection/collection.dart';

import 'statistics_base.dart';

/// extension for `Iterable<N>` (`N` extends `num`).
extension IterableNExtension<N extends num> on Iterable<N> {
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

    var deviation = sqrt(total / length);

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
  List<double> get squareRoot => map(sqrt).toList();

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
  List<double> get squareRoot => map(sqrt).toList();

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
  List<double> get squareRoot => map(sqrt).toList();

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
  /// Returns the square of `this` number.
  num get square => this * this;

  /// Returns the square root of `this` number.
  double get squareRoot => sqrt(this);

  /// Returns the natural exponent, [e], to the power of `this` number.
  double get naturalExponent => exp(this);

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
  double get squareRoot => sqrt(this);

  /// Returns the natural exponent, [e], to the power of `this` number.
  double get naturalExponent => exp(this);

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

    var mod = pow(10.0, fractionDigits).toDouble();
    return ((this * mod).round().toDouble() / mod);
  }
}

/// extension for `int`.
extension IntExtension on int {
  /// Returns the square of `this` number.
  int get square => this * this;

  /// Returns the square root of `this` number.
  double get squareRoot => sqrt(this);

  /// Returns the natural exponent, [e], to the power of `this` number.
  double get naturalExponent => exp(this);
}
