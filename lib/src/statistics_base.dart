import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:data_serializer/data_serializer.dart';

import 'statistics_decimal.dart';
import 'statistics_dynamic_int.dart';
import 'statistics_extension_num.dart';

/// Parses [o] as `double`. If can't parse returns [def].
double? parseDouble(dynamic o, [double? def]) {
  if (o == null) return def;
  if (o is double) return o;
  if (o is num) return o.toDouble();

  var s = o.toString().trim();

  var d = double.tryParse(s);
  return d ?? def;
}

/// Parses [o] as `int`. If can't parse returns [def].
int? parseInt(dynamic o, [int? def]) {
  if (o == null) return def;
  if (o is int) return o;
  if (o is num) return o.toInt();

  var s = o.toString().trim();

  var d = int.tryParse(s);
  d ??= double.tryParse(s)?.toInt();

  return d ?? def;
}

/// Parses [o] as `num`. If can't parse returns [def].
num? parseNum(dynamic o, [num? def]) {
  if (o == null) return def;
  if (o is num) return o;

  var s = o.toString().trim();

  var d = num.tryParse(s);
  return d ?? def;
}

/// Parses [o] as [BigInt]. If can't parse returns [def].
BigInt? parseBigInt(dynamic o, [BigInt? def]) {
  if (o == null) return def;
  if (o is BigInt) return o;
  if (o is num) return BigInt.from(o);

  var s = o.toString().trim();
  return BigInt.tryParse(s) ?? parseNum(s)?.toBigInt() ?? def;
}

final RegExp _regexpDateTimeFormat = RegExp(
    r'(\d{1,4})[/.-](\d\d?)[/.-](\d{1,4})(?:\s+(\d\d?)[:.](\d\d?)(?:[:.](\d\d?))?(?:\s+(\S+))?)?');

/// Parses [o] as [DateTime], trying many formats. If can't parse returns [def].
DateTime? parseDateTime(dynamic o, [DateTime? def, String? locale]) {
  if (o == null) return def;
  if (o is DateTime) return o;

  var s = o.toString().trim();
  if (s.isEmpty) return def;

  var d = DateTime.tryParse(s);
  if (d != null) return d;

  var m = _regexpDateTimeFormat.firstMatch(s);

  if (m == null) {
    return def;
  }

  var yd1 = int.parse(m.group(1)!);
  var md = int.parse(m.group(2)!);
  var yd2 = int.parse(m.group(3)!);
  var hourStr = m.group(4);
  var minStr = m.group(5);
  var secStr = m.group(6);
  var zoneStr = m.group(7);

  int year;
  int day;
  int month;
  if (yd1 > 31 && yd2 <= 31) {
    year = yd1;
    day = yd2;
  } else if (yd2 > 31 && yd1 <= 31) {
    year = yd2;
    day = yd1;
  } else {
    return null;
  }

  if (year < 100) {
    if (year >= 70) {
      year = 1900 + year;
    } else {
      year = 2000 + year;
    }
  }

  if (md > 12) {
    month = day;
    day = md;
  } else {
    month = md;
  }

  if (hourStr != null) {
    var hour = int.parse(hourStr);
    var min = int.parse(minStr!);
    var sec = secStr != null ? int.parse(secStr) : 0;

    if (zoneStr == null) {
      return DateTime(year, month, day, hour, min, sec);
    }

    try {
      var dateStr = '$year-'
          '${month.toString().padLeft(2, '0')}-'
          '${day.toString().padLeft(2, '0')} '
          '$hour:$min:$sec $zoneStr';

      return DateTime.parse(dateStr);
    } on FormatException {
      return null;
    }
  } else {
    return DateTime(year, month, day);
  }
}

/// Formats [value] to a decimal value.
///
/// [precision] amount of decimal places.
/// [decimalSeparator] decimal separator, usually `.` or `,`.
String? formatDecimal(Object? value,
    {int precision = 2, String decimalSeparator = '.'}) {
  if (value == null) return null;

  var p = parseNum(value);
  if (p == null || p == 0 || p.isNaN) return '0';

  if (p.isInfinite) return p.isNegative ? '-∞' : '∞';

  if (precision == 0) return p.toInt().toString();

  var pStr = p.toString();

  var idx = pStr.indexOf('.');

  if (idx < 0) {
    var eIdx = pStr.indexOf('e');
    var eStr = eIdx >= 0 ? pStr.substring(eIdx) : '';
    if (eStr.length > 1) {
      return pStr;
    } else {
      return p.toInt().toString();
    }
  }

  var integer = pStr.substring(0, idx);
  var decimal = pStr.substring(idx + 1);

  if (decimal.isEmpty || decimal == '0') {
    return integer.toString();
  }

  if (precision > 0 && decimal.length > precision) {
    var eIdx = decimal.indexOf('e');
    var eStr = eIdx >= 0 ? decimal.substring(eIdx) : '';
    if (eStr.length > 1) {
      decimal =
          decimal.substring(0, math.max(precision - eStr.length, 1)) + eStr;
    } else {
      decimal = decimal.substring(0, precision);
    }
  }

  if (decimalSeparator.isEmpty) {
    decimalSeparator = '.';
  }

  return '$integer$decimalSeparator$decimal';
}

/// A statistics summary of a numeric collection.
class Statistics<N extends num> extends DataEntry {
  /// Represents the maximum safe integer in JavaScript: `(2^53 - 1)`
  static final int maxSafeInt = 9007199254740991;

  /// Square root of [maxSafeInt].
  static final int maxSafeIntSqrt = math.sqrt(maxSafeInt).toInt();

  /// The length/size of the numeric collection.
  num length;

  /// Returns `true` if [length] == `0`.
  bool get isEmpty => length == 0;

  /// Returns `true` if [length] != `0`.
  bool get isNotEmpty => !isEmpty;

  /// The minimal value of the numeric collection.
  N min;

  /// The maximum value of the numeric collection.
  N max;

  /// The center value of the numeric collection.
  /// (Equivalent to [medianHigh]).
  N get center => medianHigh;

  /// The center value index of the numeric collection: ([length] ~/ `2`)
  /// (Equivalent to [medianHighIndex]).
  int get centerIndex => medianHighIndex;

  /// The lower median value. See [median].
  N medianLow;

  /// The [medianLow] value index.
  int get medianLowIndex =>
      length % 2 == 0 ? medianHighIndex - 1 : medianHighIndex;

  /// The higher median value. See [median].
  N medianHigh;

  /// The [medianHigh] value index.
  int get medianHighIndex => length ~/ 2;

  /// The median value. Also the average between [medianLow] and [medianHigh].
  ///
  /// - For sets of odd size the median is a single value, that separates the
  ///   higher half from the lower half of the set. (In this case [medianLow] and [medianHigh] are the same value).
  /// - For sets of even size the median is the average of a pair of values, the [medianLow] and
  ///   [medianHigh] values.
  num get median {
    // To avoid any floating point precision loss:
    if (medianLow == medianHigh) {
      return medianHigh;
    }

    var median = (medianLow + medianHigh) / 2;
    return median;
  }

  /// The total sum of the numeric collection.
  num sum;

  /// The total sum of squares of the numeric collection.
  num squaresSum;

  /// Same as [sum] but as a [BigInt].
  BigInt sumBigInt;

  /// Same as [squaresSum] but as a [BigInt].
  BigInt squaresSumBigInt;

  /// Returns the mean/average of the numeric collection.
  double mean;

  /// The standard deviation of the numeric collection.
  double standardDeviation;

  /// Returns the computed [Statistics] of the lower part of the numeric collection, from index `0` (inclusive) to [centerIndex] (exclusive).
  Statistics<N>? lowerStatistics;

  /// Returns the computed [Statistics] of the upper part of the numeric collection, from index [centerIndex] (inclusive) to [length] (exclusive).
  Statistics<N>? upperStatistics;

  Statistics(
    this.length,
    this.min,
    this.max, {
    N? medianLow,
    required this.medianHigh,
    double? mean,
    double? standardDeviation,
    num? sum,
    num? squaresSum,
    BigInt? sumBigInt,
    BigInt? squaresSumBigInt,
    this.lowerStatistics,
    this.upperStatistics,
  })  : medianLow = medianLow ?? medianHigh,
        sum = sum ?? (mean! * length),
        squaresSum =
            squaresSum ?? ((standardDeviation! * standardDeviation) * length),
        sumBigInt = sumBigInt ?? sum?.toBigInt() ?? (mean! * length).toBigInt(),
        squaresSumBigInt = squaresSumBigInt ??
            squaresSum?.toBigInt() ??
            ((standardDeviation! * standardDeviation) * length).toBigInt(),
        mean = mean ?? (sum! / length),
        standardDeviation = standardDeviation ??
            _computeStandardDeviation(
                sum, squaresSum, sumBigInt, squaresSumBigInt, length);

  static double _computeStandardDeviation(num? sum, num? squaresSum,
      BigInt? sumBigInt, BigInt? squaresSumBigInt, num length) {
    if (sumBigInt != null || squaresSumBigInt != null) {
      sumBigInt ??= sum!.toBigInt();
      squaresSumBigInt ??= squaresSum!.toBigInt();

      return StandardDeviationComputerBigInt._compute(
              sumBigInt, squaresSumBigInt, length.toInt())
          .toDouble();
    } else {
      sum ??= sumBigInt!.toInt();
      squaresSum ??= squaresSumBigInt!.toInt();

      return StandardDeviationComputerNum._compute(sum, squaresSum, length);
    }
  }

  factory Statistics._empty(Iterable<N> list) {
    var zero = list.castElement(0);
    return Statistics(0, zero, zero,
        medianHigh: zero, sum: zero, squaresSum: zero);
  }

  factory Statistics._single(N n) {
    return Statistics(1, n, n,
        medianHigh: n,
        sum: n,
        squaresSum: n * n,
        mean: n.toDouble(),
        standardDeviation: 0);
  }

  /// Computes a [Statistics] summary from [data].
  ///
  /// - [alreadySortedData] if `true` will avoid sorting of [data].
  ///   This allows some usage optimization, do not pass an inconsistent value.
  /// - [computeLowerAndUpper] if `true` will compute [lowerStatistics] and [upperStatistics].
  /// - [keepData] if `true` will keep a copy of [data] at [data].
  /// - [useBigIntToCompute] if `true` will force use of [BigInt] for internal computation to avoid overflow.
  factory Statistics.compute(Iterable<N> data,
      {bool alreadySortedData = false,
      bool computeLowerAndUpper = true,
      bool keepData = false,
      bool useBigIntToCompute = false}) {
    var length = data.length;
    if (length == 0) {
      var statistics = Statistics._empty(data);
      if (keepData) {
        statistics.data = data.toList();
      }
      return statistics;
    }

    if (length == 1) {
      var statistics = Statistics._single(data.first);
      if (keepData) {
        statistics.data = data.toList();
      }
      return statistics;
    }

    var listSorted = List<N>.from(data);
    if (!alreadySortedData) {
      listSorted.sort();
    }

    var first = listSorted.first;
    var min = first;
    var max = listSorted.last;

    var evenSet = length % 2 == 0;
    var medianHighIndex = length ~/ 2;
    var medianHigh = listSorted[medianHighIndex];
    var medianLow = evenSet ? listSorted[medianHighIndex - 1] : medianHigh;

    if (alreadySortedData) {
      if (min > max || medianLow > medianHigh) {
        throw ArgumentError(
            "Inconsistent argument 'alreadySortedData': min:$min > max:$max ; medianLow:$medianLow > medianHigh:$medianHigh");
      }
    }

    num sum;
    num squaresSum;
    BigInt sumBigInt;
    BigInt squaresSumBigInt;

    double mean;
    double standardDeviation;

    if (useBigIntToCompute || max > (maxSafeIntSqrt ~/ length)) {
      var firstBigInt = first.toBigInt();
      sumBigInt = firstBigInt;
      squaresSumBigInt = firstBigInt * firstBigInt;

      for (var i = 1; i < length; ++i) {
        var n = listSorted[i];
        var nBigInt = n.toBigInt();
        sumBigInt += nBigInt;
        squaresSumBigInt += nBigInt * nBigInt;
      }

      sum = sumBigInt.toInt();
      squaresSum = squaresSumBigInt.toInt();

      var lengthBigInt = length.toBigInt();

      mean = sumBigInt / lengthBigInt;

      standardDeviation = math.sqrt(
              ((squaresSumBigInt * lengthBigInt) - (sumBigInt * sumBigInt)) /
                  lengthBigInt) /
          math.sqrt(length);
    } else {
      sum = first;
      squaresSum = first * first;

      for (var i = 1; i < length; ++i) {
        var n = listSorted[i];
        sum += n;
        squaresSum += n * n;
      }

      sumBigInt = sum.toBigInt();
      squaresSumBigInt = squaresSum.toBigInt();

      mean = sum / length;

      standardDeviation =
          math.sqrt((squaresSum - (sum * (sum / length))) / length);
    }

    Statistics<N>? lowerStatistics;
    Statistics<N>? upperStatistics;

    if (computeLowerAndUpper) {
      List<N> lower;
      List<N> upper;

      if (evenSet) {
        lower = listSorted.sublist(0, medianHighIndex);
        upper = listSorted.sublist(medianHighIndex);
      } else {
        lower = listSorted.sublist(0, medianHighIndex + 1);
        upper = listSorted.sublist(medianHighIndex);
      }

      lowerStatistics = Statistics.compute(lower,
          computeLowerAndUpper: false, keepData: false);
      upperStatistics = Statistics.compute(upper,
          computeLowerAndUpper: false, keepData: false);
    }

    var statistics = Statistics<N>(
      length,
      min,
      max,
      medianLow: medianLow,
      medianHigh: medianHigh,
      sum: sum,
      squaresSum: squaresSum,
      sumBigInt: sumBigInt,
      squaresSumBigInt: squaresSumBigInt,
      mean: mean,
      standardDeviation: standardDeviation,
      lowerStatistics: lowerStatistics,
      upperStatistics: upperStatistics,
    );

    if (keepData) {
      statistics.data = data.toList();
    }

    return statistics;
  }

  Type get nType => N;

  /// Casts this instance to `Statistics<T>`.
  Statistics<T> cast<T extends num>() {
    if (T == int) {
      if (this is Statistics<T>) {
        return this as Statistics<T>;
      }

      return Statistics<int>(
        length,
        min.toInt(),
        max.toInt(),
        medianLow: medianLow.toInt(),
        medianHigh: medianHigh.toInt(),
        mean: mean,
        standardDeviation: standardDeviation,
        sum: sum,
        squaresSum: squaresSum,
        lowerStatistics: lowerStatistics?.cast<int>(),
        upperStatistics: upperStatistics?.cast<int>(),
      ) as Statistics<T>;
    } else if (T == double) {
      if (this is Statistics<T>) {
        return this as Statistics<T>;
      }

      return Statistics<double>(
        length,
        min.toDouble(),
        max.toDouble(),
        medianLow: medianLow.toDouble(),
        medianHigh: medianHigh.toDouble(),
        mean: mean,
        standardDeviation: standardDeviation,
        sum: sum,
        squaresSum: squaresSum,
        lowerStatistics: lowerStatistics?.cast<double>(),
        upperStatistics: upperStatistics?.cast<double>(),
      ) as Statistics<T>;
    } else if (T == num) {
      if (nType == T) {
        return this as Statistics<T>;
      }

      return Statistics<num>(
        length,
        min,
        max,
        medianLow: medianLow,
        medianHigh: medianHigh,
        mean: mean,
        standardDeviation: standardDeviation,
        sum: sum,
        squaresSum: squaresSum,
        lowerStatistics: lowerStatistics?.cast<num>(),
        upperStatistics: upperStatistics?.cast<num>(),
      ) as Statistics<T>;
    } else {
      return this as Statistics<T>;
    }
  }

  List<N>? data;

  /// Returns `true` if [mean] is in range of [minMean] and [maxMean].
  /// Also checks if [standardDeviation] is in range of [minDeviation] and [maxDeviation] (if passed).
  bool isMeanInRange(double minMean, double maxMean,
      [double minDeviation = double.negativeInfinity,
      double maxDeviation = double.infinity]) {
    return (mean >= minMean && mean <= maxMean) &&
        (standardDeviation >= minDeviation &&
            standardDeviation <= maxDeviation);
  }

  /// Returns the mean of [squares].
  double get squaresMean => squaresSum / length;

  @override
  String toString({int precision = 4}) {
    if (length == 0) {
      return '{empty}';
    }

    var minStr = formatDecimal(min, precision: precision);
    var maxStr = formatDecimal(max, precision: precision);
    var centerStr = formatDecimal(center, precision: precision);

    var meanStr = formatDecimal(mean, precision: precision);
    var standardDeviationStr =
        formatDecimal(standardDeviation, precision: precision);

    return '{~$meanStr +-$standardDeviationStr [$minStr..($centerStr)..$maxStr] #$length}';
  }

  /// Multiply this statistics fields by [n].
  Statistics<num> multiplyBy(num n) {
    return Statistics(
      length * n,
      min * n,
      max * n,
      medianLow: medianLow * n,
      medianHigh: medianHigh * n,
      sum: sum * n,
      squaresSum: squaresSum * n,
      mean: mean * n,
      standardDeviation: (standardDeviation * n).ifNaN(0.0),
    );
  }

  /// Divide this statistics fields by [n].
  Statistics<double> divideBy(num n) {
    return Statistics(
      length / n,
      min / n,
      max / n,
      medianLow: medianLow / n,
      medianHigh: medianHigh / n,
      sum: sum / n,
      squaresSum: squaresSum / n,
      mean: mean / n,
      standardDeviation: (standardDeviation / n).ifNaN(0.0),
    );
  }

  /// Sum this statistics fields with [other] fields.
  Statistics<num> sumWith(Statistics other) {
    return Statistics(
      length + other.length,
      min + other.min,
      max + other.max,
      medianLow: medianLow + other.medianLow,
      medianHigh: medianHigh + other.medianHigh,
      sum: sum + other.sum,
      squaresSum: squaresSum + other.squaresSum,
      mean: mean + other.mean,
      standardDeviation:
          (standardDeviation + other.standardDeviation).ifNaN(0.0),
    );
  }

  Statistics<double> operator /(Statistics other) {
    return Statistics(
      length / other.length,
      min / other.min,
      max / other.max,
      medianLow: medianLow / other.medianLow,
      medianHigh: medianHigh / other.medianHigh,
      sum: sum / other.sum,
      squaresSum: squaresSum / other.squaresSum,
      mean: mean / other.mean,
      standardDeviation:
          (standardDeviation / other.standardDeviation).ifNaN(0.0),
    );
  }

  Statistics<double> operator +(Statistics other) {
    return Statistics(
      length + other.length,
      math.min(min.toDouble(), other.min.toDouble()),
      math.max(max.toDouble(), other.max.toDouble()),
      medianLow: (medianLow + other.medianLow) / 2,
      medianHigh: (medianHigh + other.medianHigh) / 2,
      sum: sum + other.sum,
      squaresSum: squaresSum + other.squaresSum,
      mean: (sum + other.sum) / (length + other.length),
      standardDeviation: _computeStandardDeviation(
          null,
          null,
          sumBigInt + other.sumBigInt,
          squaresSumBigInt + other.squaresSumBigInt,
          length + other.length),
    );
  }

  @override
  List<String> getDataFields() => [
        'mean',
        'standardDeviation',
        'length',
        'min',
        'max',
        'sum',
        'squaresSum'
      ];

  @override
  List getDataValues() =>
      [mean, standardDeviation, length, min, max, sum, squaresSum];
}

/// A statistics summary of a [BigInt] numeric collection.
/// See [Statistics].
class StatisticsBigInt extends DataEntry {
  /// The length/size of the numeric collection.
  int length;

  /// Returns `true` if [length] == `0`.
  bool get isEmpty => length == 0;

  /// Returns `true` if [length] != `0`.
  bool get isNotEmpty => !isEmpty;

  /// The minimal value of the numeric collection.
  BigInt min;

  /// The maximum value of the numeric collection.
  BigInt max;

  /// The center value of the numeric collection.
  /// (Equivalent to [medianHigh]).
  BigInt get center => medianHigh;

  /// The center value index of the numeric collection: ([length] ~/ `2`)
  /// (Equivalent to [medianHighIndex]).
  int get centerIndex => medianHighIndex;

  /// The lower median value. See [median].
  BigInt medianLow;

  /// The [medianLow] value index.
  int get medianLowIndex =>
      length % 2 == 0 ? medianHighIndex - 1 : medianHighIndex;

  /// The higher median value. See [median].
  BigInt medianHigh;

  /// The [medianHigh] value index.
  int get medianHighIndex => length ~/ 2;

  /// The median value. Also the average between [medianLow] and [medianHigh].
  ///
  /// - For sets of odd size the median is a single value, that separates the
  ///   higher half from the lower half of the set. (In this case [medianLow] and [medianHigh] are the same value).
  /// - For sets of even size the median is the average of a pair of values, the [medianLow] and
  ///   [medianHigh] values.
  Decimal get median {
    final medianHigh = this.medianHigh;
    // To avoid any unnecessary calculation:
    if (medianLow == medianHigh) {
      return medianHigh.toDecimal();
    }

    var median =
        (medianLow + medianHigh).toDynamicInt().divideBigInt(BigInt.two);
    return median.toDecimal();
  }

  /// The total sum of the numeric collection.
  BigInt sum;

  /// The total sum of squares of the numeric collection.
  BigInt squaresSum;

  /// Returns the mean/average of the numeric collection.
  Decimal mean;

  /// The standard deviation of the numeric collection.
  Decimal standardDeviation;

  /// Returns the computed [Statistics] of the lower part of the numeric collection, from index `0` (inclusive) to [centerIndex] (exclusive).
  StatisticsBigInt? lowerStatistics;

  /// Returns the computed [Statistics] of the upper part of the numeric collection, from index [centerIndex] (inclusive) to [length] (exclusive).
  StatisticsBigInt? upperStatistics;

  StatisticsBigInt(
    this.length,
    this.min,
    this.max, {
    BigInt? medianLow,
    required this.medianHigh,
    Decimal? mean,
    Decimal? standardDeviation,
    BigInt? sum,
    BigInt? squaresSum,
    this.lowerStatistics,
    this.upperStatistics,
  })  : medianLow = medianLow ?? medianHigh,
        sum = sum ?? mean!.multiplyInt(length).toBigInt(),
        squaresSum = squaresSum ??
            standardDeviation!
                .multiplyDecimal(standardDeviation)
                .multiplyInt(length),
        mean = mean ?? sum!.toDecimal().multiplyInt(length),
        standardDeviation = standardDeviation ??
            _computeStandardDeviation(sum!, squaresSum!, length);

  static Decimal _computeStandardDeviation(
      BigInt sum, BigInt squaresSum, int length) {
    return StandardDeviationComputerBigInt._compute(sum, squaresSum, length);
  }

  factory StatisticsBigInt._empty(Iterable<BigInt> list) {
    var zero = BigInt.zero;
    return StatisticsBigInt(0, zero, zero,
        medianHigh: zero, sum: zero, squaresSum: zero);
  }

  factory StatisticsBigInt._single(BigInt n) {
    var nDecimal = n.toDecimal();
    return StatisticsBigInt(1, n, n,
        medianHigh: n,
        sum: n,
        squaresSum: n * n,
        mean: nDecimal,
        standardDeviation: Decimal.zero);
  }

  /// Computes a [Statistics] summary from [data].
  ///
  /// - [alreadySortedData] if `true` will avoid sorting of [data].
  ///   This allows some usage optimization, do not pass an inconsistent value.
  /// - [computeLowerAndUpper] if `true` will compute [lowerStatistics] and [upperStatistics].
  /// - [keepData] if `true` will keep a copy of [data] at [data].
  /// - [useBigIntToCompute] if `true` will force use of [BigInt] for internal computation to avoid overflow.
  factory StatisticsBigInt.compute(Iterable<BigInt> data,
      {bool alreadySortedData = false,
      bool computeLowerAndUpper = true,
      bool keepData = false,
      bool useBigIntToCompute = false}) {
    var length = data.length;
    if (length == 0) {
      var statistics = StatisticsBigInt._empty(data);
      if (keepData) {
        statistics.data = data.toList();
      }
      return statistics;
    }

    if (length == 1) {
      var statistics = StatisticsBigInt._single(data.first);
      if (keepData) {
        statistics.data = data.toList();
      }
      return statistics;
    }

    var listSorted = data.toList();
    if (!alreadySortedData) {
      listSorted.sort();
    }

    var first = listSorted.first;
    var min = first;
    var max = listSorted.last;

    var evenSet = length % 2 == 0;
    var medianHighIndex = length ~/ 2;
    var medianHigh = listSorted[medianHighIndex];
    var medianLow = evenSet ? listSorted[medianHighIndex - 1] : medianHigh;

    if (alreadySortedData) {
      if (min > max || medianLow > medianHigh) {
        throw ArgumentError(
            "Inconsistent argument 'alreadySortedData': min:$min > max:$max ; medianLow:$medianLow > medianHigh:$medianHigh");
      }
    }

    BigInt sum;
    BigInt squaresSum;

    Decimal mean;
    Decimal standardDeviation;

    if (true) {
      sum = first;
      squaresSum = first * first;

      for (var i = 1; i < length; ++i) {
        var n = listSorted[i];
        sum += n;
        squaresSum += n * n;
      }

      mean = sum.toDecimal().divideInt(length);

      standardDeviation = _computeStandardDeviation(sum, squaresSum, length);
    }

    StatisticsBigInt? lowerStatistics;
    StatisticsBigInt? upperStatistics;

    if (computeLowerAndUpper) {
      List<BigInt> lower;
      List<BigInt> upper;

      if (evenSet) {
        lower = listSorted.sublist(0, medianHighIndex);
        upper = listSorted.sublist(medianHighIndex);
      } else {
        lower = listSorted.sublist(0, medianHighIndex + 1);
        upper = listSorted.sublist(medianHighIndex);
      }

      lowerStatistics = StatisticsBigInt.compute(lower,
          computeLowerAndUpper: false, keepData: false);
      upperStatistics = StatisticsBigInt.compute(upper,
          computeLowerAndUpper: false, keepData: false);
    }

    var statistics = StatisticsBigInt(
      length,
      min,
      max,
      medianLow: medianLow,
      medianHigh: medianHigh,
      sum: sum,
      squaresSum: squaresSum,
      mean: mean,
      standardDeviation: standardDeviation,
      lowerStatistics: lowerStatistics,
      upperStatistics: upperStatistics,
    );

    if (keepData) {
      statistics.data = data.toList();
    }

    return statistics;
  }

  /// Casts this instance to `Statistics<T>`.
  Statistics<T> cast<T extends num>() {
    if (T == int) {
      if (this is Statistics<T>) {
        return this as Statistics<T>;
      }

      return Statistics<int>(
        length,
        min.toInt(),
        max.toInt(),
        medianLow: medianLow.toInt(),
        medianHigh: medianHigh.toInt(),
        mean: mean.toDouble(),
        standardDeviation: standardDeviation.toDouble(),
        sum: sum.toInt(),
        squaresSum: squaresSum.toInt(),
        lowerStatistics: lowerStatistics?.cast<int>(),
        upperStatistics: upperStatistics?.cast<int>(),
      ) as Statistics<T>;
    } else if (T == double) {
      if (this is Statistics<T>) {
        return this as Statistics<T>;
      }

      return Statistics<double>(
        length,
        min.toDouble(),
        max.toDouble(),
        medianLow: medianLow.toDouble(),
        medianHigh: medianHigh.toDouble(),
        mean: mean.toDouble(),
        standardDeviation: standardDeviation.toDouble(),
        sum: sum.toDouble(),
        squaresSum: squaresSum.toDouble(),
        lowerStatistics: lowerStatistics?.cast<double>(),
        upperStatistics: upperStatistics?.cast<double>(),
      ) as Statistics<T>;
    } else if (T == num) {
      return Statistics<num>(
        length,
        min.toInt(),
        max.toInt(),
        medianLow: medianLow.toInt(),
        medianHigh: medianHigh.toInt(),
        mean: mean.toDouble(),
        standardDeviation: standardDeviation.toDouble(),
        sum: sum.toInt(),
        squaresSum: squaresSum.toInt(),
        lowerStatistics: lowerStatistics?.cast<num>(),
        upperStatistics: upperStatistics?.cast<num>(),
      ) as Statistics<T>;
    } else {
      return this as Statistics<T>;
    }
  }

  List<BigInt>? data;

  /// Returns `true` if [mean] is in range of [minMean] and [maxMean].
  /// Also checks if [standardDeviation] is in range of [minDeviation] and [maxDeviation] (if passed).
  bool isMeanInRange(DynamicNumber minMean, DynamicNumber maxMean,
      [DynamicNumber? minDeviation, DynamicNumber? maxDeviation]) {
    if (mean >= minMean && mean <= maxMean) {
      if (minDeviation != null || maxDeviation != null) {
        var stdv = standardDeviation;

        if (minDeviation != null && stdv < minDeviation) return false;

        if (maxDeviation != null && stdv > maxDeviation) return false;
      }

      return true;
    }

    return false;
  }

  /// Returns the mean of [squares].
  Decimal get squaresMean {
    if (length == 0) return Decimal.zero;
    return squaresSum.toDecimal().divideInt(length);
  }

  @override
  String toString({int precision = 4}) {
    if (length == 0) {
      return '{empty}';
    }

    var minStr = formatDecimal(min, precision: precision);
    var maxStr = formatDecimal(max, precision: precision);
    var centerStr = formatDecimal(center, precision: precision);

    var meanStr = formatDecimal(mean, precision: precision);
    var standardDeviationStr =
        formatDecimal(standardDeviation, precision: precision);

    return '{~$meanStr +-$standardDeviationStr [$minStr..($centerStr)..$maxStr] #$length}';
  }

  /// Multiply this statistics fields by [n].
  StatisticsBigInt multiplyBy(DynamicNumber n) {
    return StatisticsBigInt(
      n.multiplyInt(length).toInt(),
      n.multiplyBigInt(min).toBigInt(),
      n.multiplyBigInt(max).toBigInt(),
      medianLow: n.multiplyBigInt(medianLow).toBigInt(),
      medianHigh: n.multiplyBigInt(medianHigh).toBigInt(),
      sum: n.multiplyBigInt(sum).toBigInt(),
      squaresSum: n.multiplyBigInt(squaresSum).toBigInt(),
      mean: n.multiplyDecimal(mean).toDecimal(),
      standardDeviation: (standardDeviation * n),
    );
  }

  /// Divide this statistics fields by [n].
  StatisticsBigInt divideBy(DynamicNumber n) {
    if (isEmpty) return this;

    return StatisticsBigInt(
      (length.toDynamicInt() / n).toInt(),
      (min.toDynamicInt() / n).toBigInt(),
      (max.toDynamicInt() / n).toBigInt(),
      medianLow: (medianLow.toDynamicInt() / n).toBigInt(),
      medianHigh: (medianHigh.toDynamicInt() / n).toBigInt(),
      sum: (sum.toDynamicInt() / n).toBigInt(),
      squaresSum: (squaresSum.toDynamicInt() / n).toBigInt(),
      mean: mean / n,
      standardDeviation: (standardDeviation / n),
    );
  }

  /// Sum this statistics fields with [other] fields.
  StatisticsBigInt sumWith(StatisticsBigInt other) {
    return StatisticsBigInt(
      length + other.length,
      min + other.min,
      max + other.max,
      medianLow: medianLow + other.medianLow,
      medianHigh: medianHigh + other.medianHigh,
      sum: sum + other.sum,
      squaresSum: squaresSum + other.squaresSum,
      mean: mean + other.mean,
      standardDeviation: (standardDeviation + other.standardDeviation),
    );
  }

  StatisticsDynamicNumber<Decimal> operator /(StatisticsBigInt other) {
    return StatisticsDynamicNumber(
      (length / other.length).toInt(),
      (min.toDynamicInt() / other.min.toDynamicInt()),
      (max.toDynamicInt() / other.max.toDynamicInt()),
      medianLow: (medianLow.toDynamicInt() / other.medianLow.toDynamicInt()),
      medianHigh: (medianHigh.toDynamicInt() / other.medianHigh.toDynamicInt()),
      sum: (sum.toDynamicInt() / other.sum.toDynamicInt()),
      squaresSum: (squaresSum.toDynamicInt() / other.squaresSum.toDynamicInt()),
      mean: mean / other.mean,
      standardDeviation: (standardDeviation / other.standardDeviation),
    );
  }

  StatisticsBigInt operator +(StatisticsBigInt other) {
    return StatisticsBigInt(
      length + other.length,
      min.min(other.min),
      max.max(other.max),
      medianLow: (medianLow + other.medianLow)
          .toDynamicInt()
          .divideAsDynamicInt(DynamicInt.two)
          .toBigInt(),
      medianHigh: (medianHigh + other.medianHigh)
          .toDynamicInt()
          .divideAsDynamicInt(DynamicInt.two)
          .toBigInt(),
      sum: sum + other.sum,
      squaresSum: squaresSum + other.squaresSum,
      mean: (sum + other.sum)
          .toDynamicInt()
          .divideInt(length + other.length)
          .toDecimal(),
      standardDeviation: _computeStandardDeviation(sum + other.sum,
          squaresSum + other.squaresSum, length + other.length),
    );
  }

  @override
  List<String> getDataFields() => [
        'mean',
        'standardDeviation',
        'length',
        'min',
        'max',
        'sum',
        'squaresSum'
      ];

  @override
  List getDataValues() =>
      [mean, standardDeviation, length, min, max, sum, squaresSum];
}

/// A statistics summary of a [DynamicNumber] numeric collection.
/// See [Statistics].
class StatisticsDynamicNumber<N extends DynamicNumber<N>> extends DataEntry {
  /// The length/size of the numeric collection.
  int length;

  /// Returns `true` if [length] == `0`.
  bool get isEmpty => length == 0;

  /// Returns `true` if [length] != `0`.
  bool get isNotEmpty => !isEmpty;

  /// The minimal value of the numeric collection.
  N min;

  /// The maximum value of the numeric collection.
  N max;

  /// The center value of the numeric collection.
  /// (Equivalent to [medianHigh]).
  N get center => medianHigh;

  /// The center value index of the numeric collection: ([length] ~/ `2`)
  /// (Equivalent to [medianHighIndex]).
  int get centerIndex => medianHighIndex;

  /// The lower median value. See [median].
  N medianLow;

  /// The [medianLow] value index.
  int get medianLowIndex =>
      length % 2 == 0 ? medianHighIndex - 1 : medianHighIndex;

  /// The higher median value. See [median].
  N medianHigh;

  /// The [medianHigh] value index.
  int get medianHighIndex => length ~/ 2;

  /// The median value. Also the average between [medianLow] and [medianHigh].
  ///
  /// - For sets of odd size the median is a single value, that separates the
  ///   higher half from the lower half of the set. (In this case [medianLow] and [medianHigh] are the same value).
  /// - For sets of even size the median is the average of a pair of values, the [medianLow] and
  ///   [medianHigh] values.
  Decimal get median {
    final medianHigh = this.medianHigh;
    // To avoid any unnecessary calculation:
    if (medianLow == medianHigh) {
      return medianHigh.toDecimal();
    }

    var median =
        (medianLow + medianHigh).toDynamicInt().divideBigInt(BigInt.two);
    return median.toDecimal();
  }

  /// The total sum of the numeric collection.
  N sum;

  /// The total sum of squares of the numeric collection.
  N squaresSum;

  /// Returns the mean/average of the numeric collection.
  Decimal mean;

  /// The standard deviation of the numeric collection.
  Decimal standardDeviation;

  /// Returns the computed [Statistics] of the lower part of the numeric collection, from index `0` (inclusive) to [centerIndex] (exclusive).
  StatisticsDynamicNumber<N>? lowerStatistics;

  /// Returns the computed [Statistics] of the upper part of the numeric collection, from index [centerIndex] (inclusive) to [length] (exclusive).
  StatisticsDynamicNumber<N>? upperStatistics;

  StatisticsDynamicNumber(
    this.length,
    this.min,
    this.max, {
    N? medianLow,
    required this.medianHigh,
    Decimal? mean,
    Decimal? standardDeviation,
    N? sum,
    N? squaresSum,
    this.lowerStatistics,
    this.upperStatistics,
  })  : medianLow = medianLow ?? medianHigh,
        sum = sum ?? mean!.multiplyInt(length).cast(),
        squaresSum = squaresSum ??
            standardDeviation!
                .multiplyDecimal(standardDeviation)
                .multiplyInt(length),
        mean = mean ?? sum!.toDecimal().multiplyInt(length),
        standardDeviation = standardDeviation ??
            _computeStandardDeviation<N>(sum!, squaresSum!, length);

  static Decimal _computeStandardDeviation<N extends DynamicNumber<N>>(
      N sum, N squaresSum, int length) {
    return StandardDeviationComputerDynamicNumber._compute(
        sum, squaresSum, length);
  }

  factory StatisticsDynamicNumber._empty(Iterable<N> list) {
    var zero = DynamicInt.zero.cast<N>();
    return StatisticsDynamicNumber(0, zero, zero,
        medianHigh: zero, sum: zero, squaresSum: zero);
  }

  factory StatisticsDynamicNumber._single(N n) {
    var nDecimal = n.toDecimal();
    return StatisticsDynamicNumber(1, n, n,
        medianHigh: n,
        sum: n,
        squaresSum: (n * n).cast(),
        mean: nDecimal,
        standardDeviation: Decimal.zero);
  }

  /// Computes a [Statistics] summary from [data].
  ///
  /// - [alreadySortedData] if `true` will avoid sorting of [data].
  ///   This allows some usage optimization, do not pass an inconsistent value.
  /// - [computeLowerAndUpper] if `true` will compute [lowerStatistics] and [upperStatistics].
  /// - [keepData] if `true` will keep a copy of [data] at [data].
  /// - [useBigIntToCompute] if `true` will force use of [BigInt] for internal computation to avoid overflow.
  factory StatisticsDynamicNumber.compute(Iterable<N> data,
      {bool alreadySortedData = false,
      bool computeLowerAndUpper = true,
      bool keepData = false,
      bool useBigIntToCompute = false}) {
    var length = data.length;
    if (length == 0) {
      var statistics = StatisticsDynamicNumber<N>._empty(data);
      if (keepData) {
        statistics.data = data.toList();
      }
      return statistics;
    }

    if (length == 1) {
      var statistics = StatisticsDynamicNumber<N>._single(data.first);
      if (keepData) {
        statistics.data = data.toList();
      }
      return statistics;
    }

    var listSorted = data.toList();
    if (!alreadySortedData) {
      listSorted.sort();
    }

    var first = listSorted.first;
    var min = first;
    var max = listSorted.last;

    var evenSet = length % 2 == 0;
    var medianHighIndex = length ~/ 2;
    var medianHigh = listSorted[medianHighIndex];
    var medianLow = evenSet ? listSorted[medianHighIndex - 1] : medianHigh;

    if (alreadySortedData) {
      if (min > max || medianLow > medianHigh) {
        throw ArgumentError(
            "Inconsistent argument 'alreadySortedData': min:$min > max:$max ; medianLow:$medianLow > medianHigh:$medianHigh");
      }
    }

    N sum;
    N squaresSum;

    Decimal mean;
    Decimal standardDeviation;

    if (true) {
      sum = first;
      squaresSum = (first * first).cast();

      for (var i = 1; i < length; ++i) {
        var n = listSorted[i];
        sum = (sum + n).cast<N>();
        squaresSum = (squaresSum + (n * n)).cast<N>();
      }

      mean = sum.divideIntAsDecimal(length);

      standardDeviation = _computeStandardDeviation(sum, squaresSum, length);
    }

    StatisticsDynamicNumber<N>? lowerStatistics;
    StatisticsDynamicNumber<N>? upperStatistics;

    if (computeLowerAndUpper) {
      List<N> lower;
      List<N> upper;

      if (evenSet) {
        lower = listSorted.sublist(0, medianHighIndex);
        upper = listSorted.sublist(medianHighIndex);
      } else {
        lower = listSorted.sublist(0, medianHighIndex + 1);
        upper = listSorted.sublist(medianHighIndex);
      }

      lowerStatistics = StatisticsDynamicNumber.compute(lower,
          computeLowerAndUpper: false, keepData: false);
      upperStatistics = StatisticsDynamicNumber.compute(upper,
          computeLowerAndUpper: false, keepData: false);
    }

    var statistics = StatisticsDynamicNumber<N>(
      length,
      min,
      max,
      medianLow: medianLow,
      medianHigh: medianHigh,
      sum: sum,
      squaresSum: squaresSum,
      mean: mean,
      standardDeviation: standardDeviation,
      lowerStatistics: lowerStatistics,
      upperStatistics: upperStatistics,
    );

    if (keepData) {
      statistics.data = data.toList();
    }

    return statistics;
  }

  /// Casts this instance to `StatisticsDynamicNumber<T>`.
  StatisticsDynamicNumber<T> castDynamicNumber<T extends DynamicNumber<T>>() {
    if (T == DynamicInt) {
      if (this is StatisticsDynamicNumber<T>) {
        return this as StatisticsDynamicNumber<T>;
      }

      return StatisticsDynamicNumber<DynamicInt>(
        length,
        min.toDynamicInt(),
        max.toDynamicInt(),
        medianLow: medianLow.toDynamicInt(),
        medianHigh: medianHigh.toDynamicInt(),
        mean: mean,
        standardDeviation: standardDeviation,
        sum: sum.toDynamicInt(),
        squaresSum: squaresSum.toDynamicInt(),
        lowerStatistics: lowerStatistics?.castDynamicNumber<T>()
            as StatisticsDynamicNumber<DynamicInt>?,
        upperStatistics: upperStatistics?.castDynamicNumber<T>()
            as StatisticsDynamicNumber<DynamicInt>?,
      ) as StatisticsDynamicNumber<T>;
    } else if (T == Decimal) {
      if (this is StatisticsDynamicNumber<T>) {
        return this as StatisticsDynamicNumber<T>;
      }

      return StatisticsDynamicNumber<Decimal>(
        length,
        min.toDecimal(),
        max.toDecimal(),
        medianLow: medianLow.toDecimal(),
        medianHigh: medianHigh.toDecimal(),
        mean: mean,
        standardDeviation: standardDeviation,
        sum: sum.toDecimal(),
        squaresSum: squaresSum.toDecimal(),
        lowerStatistics: lowerStatistics?.castDynamicNumber<T>()
            as StatisticsDynamicNumber<Decimal>?,
        upperStatistics: upperStatistics?.castDynamicNumber<T>()
            as StatisticsDynamicNumber<Decimal>?,
      ) as StatisticsDynamicNumber<T>;
    } else {
      return this as StatisticsDynamicNumber<T>;
    }
  }

  /// Casts this instance to `Statistics<T>`.
  Statistics<T> cast<T extends num>() {
    if (T == int) {
      if (this is Statistics<T>) {
        return this as Statistics<T>;
      }

      return Statistics<int>(
        length,
        min.toInt(),
        max.toInt(),
        medianLow: medianLow.toInt(),
        medianHigh: medianHigh.toInt(),
        mean: mean.toDouble(),
        standardDeviation: standardDeviation.toDouble(),
        sum: sum.toInt(),
        squaresSum: squaresSum.toInt(),
        lowerStatistics: lowerStatistics?.cast<int>(),
        upperStatistics: upperStatistics?.cast<int>(),
      ) as Statistics<T>;
    } else if (T == double) {
      if (this is Statistics<T>) {
        return this as Statistics<T>;
      }

      return Statistics<double>(
        length,
        min.toDouble(),
        max.toDouble(),
        medianLow: medianLow.toDouble(),
        medianHigh: medianHigh.toDouble(),
        mean: mean.toDouble(),
        standardDeviation: standardDeviation.toDouble(),
        sum: sum.toDouble(),
        squaresSum: squaresSum.toDouble(),
        lowerStatistics: lowerStatistics?.cast<double>(),
        upperStatistics: upperStatistics?.cast<double>(),
      ) as Statistics<T>;
    } else if (T == num) {
      return Statistics<num>(
        length,
        min.toInt(),
        max.toInt(),
        medianLow: medianLow.toInt(),
        medianHigh: medianHigh.toInt(),
        mean: mean.toDouble(),
        standardDeviation: standardDeviation.toDouble(),
        sum: sum.toInt(),
        squaresSum: squaresSum.toInt(),
        lowerStatistics: lowerStatistics?.cast<num>(),
        upperStatistics: upperStatistics?.cast<num>(),
      ) as Statistics<T>;
    } else {
      return this as Statistics<T>;
    }
  }

  List<N>? data;

  /// Returns `true` if [mean] is in range of [minMean] and [maxMean].
  /// Also checks if [standardDeviation] is in range of [minDeviation] and [maxDeviation] (if passed).
  bool isMeanInRange(DynamicNumber minMean, DynamicNumber maxMean,
      [DynamicNumber? minDeviation, DynamicNumber? maxDeviation]) {
    if (mean >= minMean && mean <= maxMean) {
      if (minDeviation != null || maxDeviation != null) {
        var stdv = standardDeviation;

        if (minDeviation != null && stdv < minDeviation) return false;

        if (maxDeviation != null && stdv > maxDeviation) return false;
      }

      return true;
    }

    return false;
  }

  /// Returns the mean of [squares].
  Decimal get squaresMean {
    if (length == 0) return Decimal.zero;
    return squaresSum.toDecimal().divideInt(length);
  }

  @override
  String toString({int precision = 4}) {
    if (length == 0) {
      return '{empty}';
    }

    var minStr = formatDecimal(min, precision: precision);
    var maxStr = formatDecimal(max, precision: precision);
    var centerStr = formatDecimal(center, precision: precision);

    var meanStr = formatDecimal(mean, precision: precision);
    var standardDeviationStr =
        formatDecimal(standardDeviation, precision: precision);

    return '{~$meanStr +-$standardDeviationStr [$minStr..($centerStr)..$maxStr] #$length}';
  }

  /// Multiply this statistics fields by [n].
  StatisticsDynamicNumber<N> multiplyBy(DynamicNumber n) {
    return StatisticsDynamicNumber<N>(
      n.multiplyInt(length).toInt(),
      (n * min).cast<N>(),
      (n * max).cast<N>(),
      medianLow: (n * medianLow).cast<N>(),
      medianHigh: (n * medianHigh).cast<N>(),
      sum: (n * sum).cast<N>(),
      squaresSum: (n * squaresSum).cast<N>(),
      mean: (mean * n),
      standardDeviation: (standardDeviation * n),
    );
  }

  /// Divide this statistics fields by [n].
  StatisticsDynamicNumber<N> divideBy(DynamicNumber n) {
    if (isEmpty) return this;

    return StatisticsDynamicNumber<N>(
      (length.toDynamicInt() / n).toInt(),
      (min / n).cast<N>(),
      (max / n).cast<N>(),
      medianLow: (medianLow / n).cast<N>(),
      medianHigh: (medianHigh / n).cast<N>(),
      sum: (sum / n).cast<N>(),
      squaresSum: (squaresSum / n).cast<N>(),
      mean: mean / n,
      standardDeviation: (standardDeviation / n),
    );
  }

  /// Sum this statistics fields with [other] fields.
  StatisticsDynamicNumber<N> sumWith(StatisticsDynamicNumber<N> other) {
    return StatisticsDynamicNumber<N>(
      length + other.length,
      (min + other.min).cast<N>(),
      (max + other.max).cast<N>(),
      medianLow: (medianLow + other.medianLow).cast<N>(),
      medianHigh: (medianHigh + other.medianHigh).cast<N>(),
      sum: (sum + other.sum).cast<N>(),
      squaresSum: (squaresSum + other.squaresSum).cast<N>(),
      mean: mean + other.mean,
      standardDeviation: (standardDeviation + other.standardDeviation),
    );
  }

  StatisticsDynamicNumber<N> operator /(StatisticsDynamicNumber<N> other) {
    return StatisticsDynamicNumber<N>(
      (length / other.length).toInt(),
      (min.toDynamicInt() / other.min.toDynamicInt()).cast<N>(),
      (max.toDynamicInt() / other.max.toDynamicInt()).cast<N>(),
      medianLow:
          (medianLow.toDynamicInt() / other.medianLow.toDynamicInt()).cast<N>(),
      medianHigh: (medianHigh.toDynamicInt() / other.medianHigh.toDynamicInt())
          .cast<N>(),
      sum: (sum.toDynamicInt() / other.sum.toDynamicInt()).cast<N>(),
      squaresSum: (squaresSum.toDynamicInt() / other.squaresSum.toDynamicInt())
          .cast<N>(),
      mean: mean / other.mean,
      standardDeviation: (standardDeviation / other.standardDeviation),
    );
  }

  StatisticsDynamicNumber<N> operator +(StatisticsDynamicNumber<N> other) {
    return StatisticsDynamicNumber<N>(
      length + other.length,
      min.min(other.min),
      max.max(other.max),
      medianLow: (medianLow + other.medianLow)
          .divideDynamicIntAsDecimal(DynamicInt.two)
          .cast<N>(),
      medianHigh: (medianHigh + other.medianHigh)
          .divideDynamicIntAsDecimal(DynamicInt.two)
          .cast<N>(),
      sum: (sum + other.sum).cast<N>(),
      squaresSum: (squaresSum + other.squaresSum).cast<N>(),
      mean: (sum + other.sum)
          .toDynamicInt()
          .divideInt(length + other.length)
          .toDecimal(),
      standardDeviation: _computeStandardDeviation<N>(
          (sum + other.sum).cast<N>(),
          (squaresSum + other.squaresSum).cast<N>(),
          length + other.length),
    );
  }

  @override
  List<String> getDataFields() => [
        'mean',
        'standardDeviation',
        'length',
        'min',
        'max',
        'sum',
        'squaresSum'
      ];

  @override
  List getDataValues() =>
      [mean, standardDeviation, length, min, max, sum, squaresSum];
}

/// Interface for data entries.
abstract class DataEntry {
  /// Returns the fields names of this [DataEntry].
  List<String> getDataFields();

  /// Returns the fields values of this [DataEntry].
  List getDataValues();

  /// Returns the [DataEntry] as a [Map] of fields and values.
  Map<String, dynamic> getDataMap() =>
      Map.fromIterables(getDataFields(), getDataValues());
}

/// A pair of [T].
class Pair<T> implements Comparable<Pair<T>> {
  /// Element A of pair.
  final T a;

  /// Element B of pair.
  final T b;

  Pair(this.a, this.b);

  /// Returns this [Pair] as a [List] `[a,b]`.
  List<T> get asList => [a, b];

  /// Returns this [Pair] as a [MapEntry].
  MapEntry<T, T> get asMapEntry => MapEntry<T, T>(a, b);

  static final _iterableEquality = IterableEquality();

  /// Equality.
  ///
  /// - If [T] is [Iterable] uses [IterableEquality.equals].
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! Pair) return false;

    var a = this.a;

    if (a is Iterable) {
      var b = this.b as Iterable;
      return _iterableEquality.equals(a, other.a) &&
          _iterableEquality.equals(b, other.b);
    } else {
      return a == other.a && b == other.b;
    }
  }

  int? _hashCode;

  /// Pair Hash Code.
  ///
  /// - If [T] is [Iterable] uses [IterableEquality.hash].
  /// - NOTE: the Hash Code is computed only once,
  ///   even if an internal value has changed.
  @override
  int get hashCode => _hashCode ??= _hashCodeImpl();

  int _hashCodeImpl() {
    var a = this.a;

    if (a is Iterable) {
      var b = this.b as Iterable;
      return _iterableEquality.hash(a) ^ _iterableEquality.hash(b);
    } else {
      return a.hashCode ^ b.hashCode;
    }
  }

  /// Compare `this` with [other] if [T] implements [Comparable].
  @override
  int compareTo(Pair<T> other) {
    var a = this.a;
    if (a is Comparable) {
      var cmp = a.compareTo(other.a);
      if (cmp == 0) {
        var b = this.b as Comparable;
        cmp = b.compareTo(other.b);
      }
      return cmp;
    }

    throw UnimplementedError("Type `$T` does NOT implement `Comparable`");
  }

  @override
  String toString() {
    return '($a , $b)';
  }
}

/// Computes the standard deviation of a set online,
/// by [add]ing each element one by one,
/// without the need to have a [List] with all the elements.
abstract class StandardDeviationComputer<N, D> {
  /// Returns the length of the computed set. Is incremented by [add].
  int get length;

  /// Returns `true` if the computation set is empty.
  bool get isEmpty;

  /// Alias to ![isEmpty].
  bool get isNotEmpty;

  /// The sum of the computed set. Is incremented by [add].
  N get sum;

  /// Casts [sum] to [double].
  double get sumAsDouble;

  /// The sum of the squares of the computed set. Is incremented by [add].
  N get squaresSum;

  /// Casts [squaresSum] to [double].
  double get squaresSumAsDouble;

  /// Resets the computation.
  StandardDeviationComputer reset();

  /// Adds a number [n] ([num]) to the computation.
  StandardDeviationComputer add(num n);

  /// [add]s all the [ns] elements ([num]).
  StandardDeviationComputer addAll(Iterable<num> ns);

  /// Adds a number [n] ([BigInt]) to the computation.
  StandardDeviationComputer addBigInt(BigInt n);

  /// [add]s all the [ns] elements ([BigInt]).
  StandardDeviationComputer addAllBigInt(Iterable<BigInt> ns);

  /// Adds a number [n] ([DynamicNumber]) to the computation.
  StandardDeviationComputer addDynamicNumber(DynamicNumber<dynamic> n);

  /// [add]s all the [ns] elements ([DynamicNumber]).
  StandardDeviationComputer addAllDynamicNumber(
      Iterable<DynamicNumber<dynamic>> ns);

  /// The standard deviation of the current set.
  D get standardDeviation;

  /// Casts [standardDeviation] to [double].
  double get standardDeviationAsDouble;
}

/// [StandardDeviationComputer] implementation for [num].
class StandardDeviationComputerNum
    implements StandardDeviationComputer<num, double> {
  int _length = 0;

  @override
  int get length => _length;

  @override
  bool get isEmpty => _length == 0;

  @override
  bool get isNotEmpty => !isEmpty;

  num _sum = 0;

  @override
  num get sum => _sum;

  num _squaresSum = 0;

  @override
  num get squaresSum => _squaresSum;

  @override
  double get sumAsDouble => sum.toDouble();

  @override
  double get squaresSumAsDouble => squaresSum.toDouble();

  @override
  StandardDeviationComputerNum reset() {
    _length = 0;
    _sum = 0;
    _squaresSum = 0;

    _standardDeviation = null;

    return this;
  }

  /// Adds a number [n] to the computation.
  @override
  StandardDeviationComputerNum add(num n) {
    _length++;
    _sum += n;
    _squaresSum += n * n;

    _standardDeviation = null;

    return this;
  }

  @override
  StandardDeviationComputer addBigInt(BigInt n) {
    if (!n.isSafeInteger) {
      throw ArgumentError("Not a safe `int`: $n");
    }
    return add(n.toInt());
  }

  @override
  StandardDeviationComputer addDynamicNumber(DynamicNumber<dynamic> n) =>
      add(n.toNum());

  @override
  StandardDeviationComputerNum addAll(Iterable<num> ns) {
    for (var n in ns) {
      add(n);
    }
    return this;
  }

  @override
  StandardDeviationComputer addAllBigInt(Iterable<BigInt> ns) {
    for (var n in ns) {
      addBigInt(n);
    }
    return this;
  }

  @override
  StandardDeviationComputer addAllDynamicNumber(
      Iterable<DynamicNumber<dynamic>> ns) {
    for (var n in ns) {
      addDynamicNumber(n);
    }
    return this;
  }

  double? _standardDeviation;

  @override
  double get standardDeviation =>
      _standardDeviation ??= _standardDeviationImpl();

  double _standardDeviationImpl() {
    if (isEmpty) return 0.0;
    return _compute(_sum, _squaresSum, _length);
  }

  static double _compute(num sum, num squaresSum, num length) {
    return math.sqrt((squaresSum - (sum * (sum / length))) / length);
  }

  @override
  double get standardDeviationAsDouble => standardDeviation;
}

/// [StandardDeviationComputer] implementation for [BigInt].
class StandardDeviationComputerBigInt
    implements StandardDeviationComputer<BigInt, double> {
  int _length = 0;

  @override
  int get length => _length;

  @override
  bool get isEmpty => _length == 0;

  @override
  bool get isNotEmpty => !isEmpty;

  BigInt _sum = BigInt.zero;

  @override
  BigInt get sum => _sum;

  BigInt _squaresSum = BigInt.zero;

  @override
  BigInt get squaresSum => _squaresSum;

  @override
  double get sumAsDouble => sum.toDouble();

  @override
  double get squaresSumAsDouble => squaresSum.toDouble();

  @override
  StandardDeviationComputerBigInt reset() {
    _length = 0;
    _sum = BigInt.zero;
    _squaresSum = BigInt.zero;

    _standardDeviation = null;

    return this;
  }

  @override
  StandardDeviationComputerBigInt add(num n) => addBigInt(BigInt.from(n));

  @override
  StandardDeviationComputerBigInt addBigInt(BigInt n) {
    _length++;
    _sum += n;
    _squaresSum += n * n;

    _standardDeviation = null;

    return this;
  }

  @override
  StandardDeviationComputer addDynamicNumber(DynamicNumber<dynamic> n) =>
      add(n.toNum());

  @override
  StandardDeviationComputerBigInt addAll(Iterable<num> ns) {
    for (var n in ns) {
      add(n);
    }
    return this;
  }

  @override
  StandardDeviationComputerBigInt addAllBigInt(Iterable<BigInt> ns) {
    for (var n in ns) {
      addBigInt(n);
    }
    return this;
  }

  @override
  StandardDeviationComputer addAllDynamicNumber(
      Iterable<DynamicNumber<dynamic>> ns) {
    for (var n in ns) {
      addDynamicNumber(n);
    }
    return this;
  }

  double? _standardDeviation;

  @override
  double get standardDeviation =>
      _standardDeviation ??= _standardDeviationImpl();

  double _standardDeviationImpl() {
    if (isEmpty) return 0.0;
    return _compute(_sum, _squaresSum, _length).toDouble();
  }

  static Decimal _compute(BigInt sum, BigInt squaresSum, int length) {
    if (length == 0) return Decimal.zero;

    var a = ((squaresSum * length.toBigInt()) - (sum * sum)).toDecimal();
    var x = a.divide(length);
    return x.squareRoot / length.toDecimal().squareRoot;
  }

  @override
  double get standardDeviationAsDouble => standardDeviation.toDouble();
}

/// [StandardDeviationComputer] implementation for [DynamicNumber].
class StandardDeviationComputerDynamicNumber
    implements StandardDeviationComputer<DynamicNumber<dynamic>, Decimal> {
  int _length = 0;

  @override
  int get length => _length;

  @override
  bool get isEmpty => _length == 0;

  @override
  bool get isNotEmpty => !isEmpty;

  DynamicNumber<dynamic> _sum = DynamicInt.zero;

  @override
  DynamicNumber<dynamic> get sum => _sum;

  DynamicNumber<dynamic> _squaresSum = DynamicInt.zero;

  @override
  DynamicNumber<dynamic> get squaresSum => _squaresSum;

  @override
  double get sumAsDouble => sum.toDouble();

  @override
  double get squaresSumAsDouble => squaresSum.toDouble();

  @override
  StandardDeviationComputerDynamicNumber reset() {
    _length = 0;
    _sum = DynamicInt.zero;
    _squaresSum = DynamicInt.zero;

    _standardDeviation = null;

    return this;
  }

  @override
  StandardDeviationComputerDynamicNumber add(num n) =>
      addDynamicNumber(n.toDynamicNumber());

  @override
  StandardDeviationComputerDynamicNumber addBigInt(BigInt n) =>
      addDynamicNumber(n.toDynamicInt());

  @override
  StandardDeviationComputerDynamicNumber addDynamicNumber(
      DynamicNumber<dynamic> n) {
    _length++;
    _sum += n as DynamicNumber;
    _squaresSum += n * n;

    _standardDeviation = null;

    return this;
  }

  @override
  StandardDeviationComputerDynamicNumber addAll(Iterable<num> ns) {
    for (var n in ns) {
      add(n);
    }
    return this;
  }

  @override
  StandardDeviationComputerDynamicNumber addAllBigInt(Iterable<BigInt> ns) {
    for (var n in ns) {
      addBigInt(n);
    }
    return this;
  }

  @override
  StandardDeviationComputerDynamicNumber addAllDynamicNumber(
      Iterable<DynamicNumber<dynamic>> ns) {
    for (var n in ns) {
      addDynamicNumber(n);
    }
    return this;
  }

  Decimal? _standardDeviation;

  @override
  Decimal get standardDeviation =>
      _standardDeviation ??= _standardDeviationImpl();

  Decimal _standardDeviationImpl() {
    if (isEmpty) return Decimal.zero;
    return _compute(_sum, _squaresSum, _length);
  }

  static Decimal _compute(DynamicNumber<dynamic> sum,
      DynamicNumber<dynamic> squaresSum, num length) {
    var lengthDN = length.toDynamicInt();
    var a = squaresSum * lengthDN;
    var b = sum.square;
    var c = (a - b) / lengthDN;
    var d = c.squareRoot;
    var e = lengthDN.squareRoot;

    return d / e;
  }

  @override
  double get standardDeviationAsDouble => standardDeviation.toDouble();
}
