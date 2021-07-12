import 'dart:math' as math;

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

  if (precision <= 0) return p.toInt().toString();

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

  if (decimal.length > precision) {
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
  /// The length/size of the numeric collection.
  double length;

  /// Returns `true` if [length] == `0`.
  bool get isEmpty => length == 0;

  /// Returns `true` if [length] != `0`.
  bool get isNotEmpty => !isEmpty;

  /// The minimal value of the numeric collection.
  N min;

  /// The maximum value of the numeric collection.
  N max;

  /// The center value of the numeric collection.
  N center;

  /// The center value index of the numeric collection: ([length] ~/ `2`)
  int get centerIndex => length ~/ 2;

  /// The total sum of the numeric collection.
  num sum;

  /// The total sum of squares of the numeric collection.
  num squaresSum;

  /// Returns the mean/average of the numeric collection.
  double mean;

  /// The standard deviation of the numeric collection.
  double standardDeviation;

  /// Returns the computed [Statistics] of the lower part of the numeric collection, from index `0` (inclusive) to [centerIndex] (exclusive).
  Statistics? lowerStatistics;

  /// Returns the computed [Statistics] of the upper part of the numeric collection, from index [centerIndex] (inclusive) to [length] (exclusive).
  Statistics? upperStatistics;

  Statistics(
    num length,
    this.min,
    this.max,
    this.center, {
    double? mean,
    double? standardDeviation,
    num? sum,
    num? squaresSum,
    this.lowerStatistics,
    this.upperStatistics,
  })  : length = length.toDouble(),
        sum = sum ?? (mean! * length),
        squaresSum =
            squaresSum ?? ((standardDeviation! * standardDeviation) * length),
        mean = mean ?? (sum! / length),
        standardDeviation =
            standardDeviation ?? math.sqrt(squaresSum! / length);

  factory Statistics._empty(Iterable<N> list) {
    var zero = list.castElement(0);
    return Statistics(0, zero, zero, zero, sum: zero, squaresSum: zero);
  }

  factory Statistics._single(N n) {
    return Statistics(1, n, n, n,
        sum: n, squaresSum: n * n, mean: n.toDouble(), standardDeviation: 0);
  }

  /// Computes a [Statistics] summary from [collection].
  ///
  /// - [computeLowerAndUpper] if `true` will compute [lowerStatistics] and [upperStatistics].
  /// - [keepSeries] if `true` will keep a copy of [collection] at [series].
  factory Statistics.compute(Iterable<N> collection,
      {bool computeLowerAndUpper = true, bool keepSeries = false}) {
    var length = collection.length;
    if (length == 0) return Statistics._empty(collection);
    if (length == 1) return Statistics._single(collection.first);

    var listSorted = List<N>.from(collection);
    listSorted.sort();

    var first = listSorted.first;
    var min = first;
    var max = listSorted.last;
    var centerIndex = listSorted.length ~/ 2;
    var center = listSorted[centerIndex];

    num sum = first;
    var squaresSum = first * first;

    for (var i = 1; i < length; ++i) {
      var n = listSorted[i];
      sum += n;
      squaresSum += n * n;
    }

    var mean = sum / length;

    var standardDeviation = math.sqrt(squaresSum / length);

    Statistics? lowerStatistics;
    Statistics? upperStatistics;

    if (computeLowerAndUpper) {
      var lower = listSorted.sublist(0, centerIndex);
      var upper = listSorted.sublist(centerIndex);

      lowerStatistics = Statistics.compute(lower,
          computeLowerAndUpper: false, keepSeries: false);
      upperStatistics = Statistics.compute(upper,
          computeLowerAndUpper: false, keepSeries: false);
    }

    var statistics = Statistics(
      length,
      min,
      max,
      center,
      sum: sum,
      squaresSum: squaresSum,
      mean: mean,
      standardDeviation: standardDeviation,
      lowerStatistics: lowerStatistics,
      upperStatistics: upperStatistics,
    );

    if (keepSeries) {
      statistics.series = collection.toList();
    }

    return statistics;
  }

  List<N>? series;

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

    var minStr = precision > 0 ? formatDecimal(min, precision: precision) : min;
    var maxStr = precision > 0 ? formatDecimal(max, precision: precision) : max;
    var centerStr =
        precision > 0 ? formatDecimal(center, precision: precision) : center;

    var meanStr =
        precision > 0 ? formatDecimal(mean, precision: precision) : mean;
    var standardDeviationStr = precision > 0
        ? formatDecimal(standardDeviation, precision: precision)
        : standardDeviation;

    return '{~$meanStr +-$standardDeviationStr [$minStr..($centerStr)..$maxStr] #$length}';
  }

  Statistics<double> operator /(Statistics other) {
    return Statistics(
      length / other.length,
      min / other.min,
      max / other.max,
      center / other.center,
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
      (center + other.center) / 2,
      sum: sum + other.sum,
      squaresSum: squaresSum + other.squaresSum,
      mean: (sum + other.sum) / (length + other.length),
      standardDeviation:
          math.sqrt((squaresSum + other.squaresSum) / (length + other.length)),
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
