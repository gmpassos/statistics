import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('Numerical Parsers', () {
    setUp(() {});

    test('Pair', () {
      var p1 = Pair(10, 20);

      expect(p1.a, equals(10));
      expect(p1.b, equals(20));

      var p2 = Pair(10, 20);
      var p3 = Pair(10, 30);

      expect(p3.a, equals(10));
      expect(p3.b, equals(30));

      expect(p1 == p2, isTrue);
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1.compareTo(p2), equals(0));

      expect(p1 == p3, isFalse);
      expect(p1.hashCode, isNot(equals(p3.hashCode)));
      expect(p1.compareTo(p3), lessThan(0));
      expect(p3.compareTo(p1), greaterThan(0));
    });

    test('parseInt', () {
      expect(parseInt(10), equals(10));
      expect(parseInt(10.1), equals(10));
      expect(parseInt('a b', 404), equals(404));

      expect(parseInt('10'), equals(10));
      expect(parseInt('10.0'), equals(10));
      expect(parseInt('10.1'), equals(10));
    });

    test('parseBigInt', () {
      expect(parseBigInt(10), equals(10.toBigInt()));
      expect(parseBigInt(10.1), equals(10.toBigInt()));
      expect(parseBigInt('a b', 404.toBigInt()), equals(404.toBigInt()));

      expect(parseBigInt('10'), equals(10.toBigInt()));
      expect(parseBigInt('10.0'), equals(10.toBigInt()));
      expect(parseBigInt('10.1'), equals(10.toBigInt()));
    });

    test('parseDouble', () {
      expect(parseDouble(10), equals(10));
      expect(parseDouble(10.2), equals(10.20));
      expect(parseDouble('a b', 404), equals(404));

      expect(parseDouble('10'), equals(10));
      expect(parseDouble('10.0'), equals(10));
      expect(parseDouble('10.20'), equals(10.2));
    });

    test('parseNum', () {
      expect(parseNum(10), equals(10));
      expect(parseNum(10.2), equals(10.20));
      expect(parseNum('a b', 404), equals(404));

      expect(parseNum('10'), equals(10));
      expect(parseNum('10.0'), equals(10));
      expect(parseNum('10.20'), equals(10.2));
    });

    test('parseDateTime', () {
      expect(parseDateTime(null), isNull);
      expect(parseDateTime(DateTime(2021, 8, 2)), equals(DateTime(2021, 8, 2)));
      expect(parseDateTime(DateTime(2021, 8, 2).formatToYMD()),
          equals(DateTime(2021, 8, 2)));

      expect(parseDateTime(DateTime(2021, 8, 2).formatTo('yyyy/MM/dd')),
          equals(DateTime(2021, 8, 2)));

      expect(
          parseDateTime(
              DateTime(2021, 8, 2, 10, 11, 12).formatTo('yyyy/MM/dd')),
          equals(DateTime(2021, 8, 2)));

      expect(
          parseDateTime(
              DateTime(2021, 8, 2, 10, 11, 12).formatTo('yyyy/MM/dd HH.mm.ss')),
          equals(DateTime(2021, 8, 2, 10, 11, 12)));

      expect(parseDateTime('2021/08/30'), equals(DateTime(2021, 8, 30)));

      expect(parseDateTime('2021/8/30'), equals(DateTime(2021, 8, 30)));

      expect(parseDateTime('2021/8/3'), equals(DateTime(2021, 8, 3)));

      expect(parseDateTime('30/8/2021'), equals(DateTime(2021, 8, 30)));

      expect(parseDateTime('8/30/2021'), equals(DateTime(2021, 8, 30)));

      expect(parseDateTime('2021/08/30 12:11:10'),
          equals(DateTime(2021, 8, 30, 12, 11, 10)));

      expect(parseDateTime('2021/08/30 12.11.10'),
          equals(DateTime(2021, 8, 30, 12, 11, 10)));

      expect(parseDateTime('30/08/2021 12.11.10'),
          equals(DateTime(2021, 8, 30, 12, 11, 10)));

      expect(parseDateTime('30/08/2021 12.11'),
          equals(DateTime(2021, 8, 30, 12, 11)));

      expect(parseDateTime('2021/8/30 12.11.10 -0300'),
          equals(DateTime.utc(2021, 8, 30, 15, 11, 10)));

      expect(parseDateTime('90/8/30 12.11.10 -0300'),
          equals(DateTime.utc(1990, 8, 30, 15, 11, 10)));

      expect(parseDateTime('50/8/30 12.11.10 -0300'),
          equals(DateTime.utc(2050, 8, 30, 15, 11, 10)));

      expect(parseDateTime('50/8/30 12.11.10 -0300X'), isNull);
    });

    test('cast', () {
      num n = 123;

      expect(n.cast<int>(), allOf(isA<int>(), equals(123)));
      expect(n.cast<double>(), allOf(isA<double>(), equals(123)));

      num d = 3.14;

      expect(d.cast<int>(), allOf(isA<int>(), equals(3)));
      expect(d.cast<double>(), allOf(isA<double>(), equals(3.14)));
    });

    test('formatDecimal', () {
      expect(formatDecimal(10.0), equals('10'));
      expect(formatDecimal(10.10), equals('10.1'));
      expect(formatDecimal(100.101), equals('100.10'));
      expect(formatDecimal(100.101, precision: 4), equals('100.101'));
      expect(formatDecimal(1000.10), equals('1000.1'));
      expect(formatDecimal(10000), equals('10000'));
      expect(formatDecimal(10000.10), equals('10000.1'));
      expect(formatDecimal(100000.10), equals('100000.1'));

      expect(formatDecimal(0.000000012345), equals('1.2e-8'));
      expect(formatDecimal(0.00000001), equals('1e-8'));
    });
  });

  group('Statistics', () {
    setUp(() {});

    test('int(4)', () {
      var data = [10, 20, 30, 40];
      var statistics = data.statistics;

      expect(statistics.length, equals(4));
      expect(statistics.isEmpty, isFalse);
      expect(statistics.isNotEmpty, isTrue);

      expect(statistics.sum, equals(100));
      expect(statistics.mean, equals(25));
      expect(statistics.standardDeviation, equals(27.386127875258307));
      expect(statistics.squaresSum, equals(3000));
      expect(statistics.squaresMean, equals(750.0));

      expect(statistics.centerIndex, equals(2));
      expect(statistics.center, equals(30));

      expect(statistics.medianLow, equals(20));
      expect(statistics.medianHigh, equals(30));
      expect(statistics.median, equals(25));

      expect(statistics.medianLowIndex, equals(1));
      expect(statistics.medianHighIndex, equals(2));

      expect(statistics.isMeanInRange(10, 30), isTrue);
      expect(statistics.isMeanInRange(10, 30, 25, 28), isTrue);

      expect(statistics.isMeanInRange(10, 19), isFalse);
      expect(statistics.isMeanInRange(10, 30, 20, 21), isFalse);

      expect(statistics.toString(precision: 2),
          equals('{~25 +-27.38 [10..(30)..40] #4}'));
      expect(statistics.toString(precision: 0),
          equals('{~25 +-27 [10..(30)..40] #4}'));

      expect(data.statisticsWithData.data, equals(data));
    });

    test('int(3)', () {
      var data = [10, 20, 30];
      var statistics = data.statistics;

      expect(statistics.length, equals(3));
      expect(statistics.isEmpty, isFalse);
      expect(statistics.isNotEmpty, isTrue);

      expect(statistics.sum, equals(60));
      expect(statistics.mean, equals(20));
      expect(statistics.standardDeviation, equals(21.602468994692867));
      expect(statistics.squaresSum, equals(1400));
      expect(statistics.squaresMean, equals(466.6666666666667));

      expect(statistics.centerIndex, equals(1));
      expect(statistics.center, equals(20));

      expect(statistics.medianLow, equals(20));
      expect(statistics.medianHigh, equals(20));
      expect(statistics.median, equals(20));

      expect(statistics.medianLowIndex, equals(1));
      expect(statistics.medianHighIndex, equals(1));

      expect(statistics.isMeanInRange(10, 30), isTrue);
      expect(statistics.isMeanInRange(10, 30, 20, 22), isTrue);

      expect(statistics.isMeanInRange(10, 19), isFalse);
      expect(statistics.isMeanInRange(10, 30, 20, 21), isFalse);

      expect(
          statistics.toString(), equals('{~20 +-21.6024 [10..(20)..30] #3}'));
      expect(statistics.toString(precision: 0),
          equals('{~20 +-21 [10..(20)..30] #3}'));

      expect(data.statisticsWithData.data, equals(data));
    });

    test('int(2)', () {
      var data = [10, 20];
      var statistics = data.statistics;

      expect(statistics.length, equals(2));
      expect(statistics.isEmpty, isFalse);
      expect(statistics.isNotEmpty, isTrue);

      expect(statistics.sum, equals(30));
      expect(statistics.mean, equals(15));
      expect(statistics.standardDeviation, equals(15.811388300841896));
      expect(statistics.squaresSum, equals(500));
      expect(statistics.squaresMean, equals(250.0));

      expect(statistics.centerIndex, equals(1));
      expect(statistics.center, equals(20));

      expect(statistics.medianLow, equals(10));
      expect(statistics.medianHigh, equals(20));
      expect(statistics.median, equals(15));

      expect(statistics.medianLowIndex, equals(0));
      expect(statistics.medianHighIndex, equals(1));

      expect(data.statisticsWithData.data, equals(data));
    });

    test('int(1)', () {
      var data = [10];
      var statistics = data.statistics;

      expect(statistics.length, equals(1));
      expect(statistics.isEmpty, isFalse);
      expect(statistics.isNotEmpty, isTrue);

      expect(statistics.sum, equals(10));
      expect(statistics.mean, equals(10));
      expect(statistics.standardDeviation, equals(0));
      expect(statistics.squaresSum, equals(100));
      expect(statistics.squaresMean, equals(100));

      expect(statistics.centerIndex, equals(0));
      expect(statistics.center, equals(10));

      expect(statistics.centerIndex, equals(0));
      expect(statistics.center, equals(10));

      expect(statistics.medianLow, equals(10));
      expect(statistics.medianHigh, equals(10));
      expect(statistics.median, equals(10));

      expect(statistics.medianLowIndex, equals(0));
      expect(statistics.medianHighIndex, equals(0));

      expect(data.statisticsWithData.data, equals(data));
    });

    test('int(0)', () {
      var data = <int>[];
      var statistics = data.statistics;

      expect(statistics.length, equals(0));
      expect(statistics.isEmpty, isTrue);
      expect(statistics.isNotEmpty, isFalse);

      expect(statistics.sum, equals(0));
      expect(statistics.mean, isNaN);
      expect(statistics.standardDeviation, isNaN);
      expect(statistics.squaresSum, equals(0));
      expect(statistics.squaresMean, equals(isNaN));

      expect(statistics.centerIndex, equals(0));
      expect(statistics.center, equals(0));

      expect(statistics.medianLow, equals(0));
      expect(statistics.medianHigh, equals(0));
      expect(statistics.median, equals(0));
      expect(data.statisticsWithData.data, equals(data));
    });

    test('BigInt', () {
      var statistics = Statistics.compute([
        Statistics.maxSafeInt ~/ 2,
        Statistics.maxSafeInt,
        Statistics.maxSafeInt ~/ 2
      ], useBigIntToCompute: true);

      expect(
          statistics.sumBigInt,
          equals(BigInt.from(Statistics.maxSafeInt) +
              BigInt.from(Statistics.maxSafeInt) -
              BigInt.one));

      expect(
          statistics.mean,
          equals(
              (BigInt.from(Statistics.maxSafeInt) ~/ 3.toBigInt() * BigInt.two)
                  .toDouble()));
    });

    test('error(alreadySortedData)', () {
      expect(() => Statistics.compute([10, 20, 30], alreadySortedData: false),
          isNot(throwsArgumentError));

      expect(() => Statistics.compute([30, 20, 10], alreadySortedData: false),
          isNot(throwsArgumentError));

      expect(() => Statistics.compute([10, 20, 30], alreadySortedData: false),
          isNot(throwsArgumentError));

      expect(() => Statistics.compute([30, 20, 10], alreadySortedData: true),
          throwsArgumentError);
    });

    test('multiplyBy', () {
      var statistics1 = [10, 20, 30].statistics;
      var statistics = statistics1.multiplyBy(3);

      expect(statistics.sum, equals(statistics1.sum * 3));
      expect(statistics.mean, equals(statistics1.mean * 3));
      expect(statistics.standardDeviation,
          equals(statistics1.standardDeviation * 3));

      expect(statistics.squaresSum, equals(statistics1.squaresSum * 3));
    });

    test('divideBy', () {
      var statistics1 = [10, 20, 30].statistics;
      var statistics = statistics1.divideBy(2);

      expect(statistics.sum, equals(statistics1.sum / 2));
      expect(statistics.mean, equals(statistics1.mean / 2));
      expect(statistics.standardDeviation,
          equals(statistics1.standardDeviation / 2));

      expect(statistics.squaresSum, equals(statistics1.squaresSum / 2));
    });

    test('sumWith', () {
      var statistics1 = [10, 20, 30].statistics;
      var statistics2 = [100, 200, 300].statistics;
      var statistics = statistics1.sumWith(statistics2);

      expect(statistics.sum, equals(statistics1.sum + statistics2.sum));
      expect(statistics.mean, equals(statistics1.mean + statistics2.mean));
      expect(
          statistics.standardDeviation,
          equals(
              statistics1.standardDeviation + statistics2.standardDeviation));

      expect(statistics.squaresSum,
          equals(statistics1.squaresSum + statistics2.squaresSum));
    });

    test('statisticsMean', () {
      var statistics1 = [10, 20, 30].statistics;

      var statistics2 = statistics1.cast<int>();
      expect(statistics2.min, isA<int>());

      var statistics3 = statistics1.cast<double>();
      expect(statistics3.min, isA<double>());

      var statistics4 = statistics1.cast<num>();
      expect(statistics4.min, isA<num>());
    });

    test('statisticsMean', () {
      var statistics1 = [10, 20, 30].statistics;
      var statistics2 = [100, 200, 300].statistics;

      var statistics = [statistics1, statistics2].statisticsMean;

      expect(statistics.sum, equals((statistics1.sum + statistics2.sum) / 2));

      expect(
          statistics.mean, equals((statistics1.mean + statistics2.mean) / 2));

      expect(
          statistics.standardDeviation,
          equals(
              (statistics1.standardDeviation + statistics2.standardDeviation) /
                  2));

      expect(statistics.squaresSum,
          equals((statistics1.squaresSum + statistics2.squaresSum) / 2));
    });

    test('operator +', () {
      var statistics1 = [10, 20, 30].statistics;
      var statistics2 = [100, 200].statistics;

      var statistics3 = [10, 20, 30, 100, 200].statistics;

      var statistics = statistics1 + statistics2;

      expect(statistics.sum, equals(statistics3.sum));
      expect(statistics.mean, equals(statistics3.mean));
      expect(
          statistics.standardDeviation, equals(statistics3.standardDeviation));
      expect(statistics.squaresSum, equals(statistics3.squaresSum));
      expect(statistics.squaresMean, equals(statistics3.squaresMean));
    });

    test('operator / (3)', () {
      var statistics1 = [10, 20, 30].statistics;
      var statistics2 = [20, 30, 40].statistics;

      var statistics = statistics1 / statistics2;

      expect(statistics.sum, equals(0.6666666666666666));
      expect(statistics.mean, equals(0.6666666666666666));
      expect(statistics.standardDeviation, equals(0.6948083337796512));
      expect(statistics.squaresSum, equals(0.4827586206896552));
      expect(statistics.squaresMean, equals(0.4827586206896552));
    });

    test('operator / (1)', () {
      var statistics1 = [10].statistics;
      var statistics2 = [20].statistics;

      var statistics = statistics1 / statistics2;

      expect(statistics.sum, equals(0.5));
      expect(statistics.mean, equals(0.5));
      expect(statistics.standardDeviation, equals(0.0));
      expect(statistics.squaresSum, equals(0.25));
      expect(statistics.squaresMean, equals(0.25));
    });

    test('DataEntry', () {
      var statistics = [10, 20, 30].statistics;

      expect(
          statistics.toString(), equals('{~20 +-21.6024 [10..(20)..30] #3}'));
    });

    test('DataEntry', () {
      var statistics = [10, 20, 30].statistics;

      expect(
          statistics.getDataFields(),
          equals([
            'mean',
            'standardDeviation',
            'length',
            'min',
            'max',
            'sum',
            'squaresSum'
          ]));
      expect(statistics.getDataValues(),
          equals([20.0, 21.602468994692867, 3.0, 10, 30, 60, 1400]));
      expect(
          statistics.getDataMap(),
          equals({
            'mean': 20.0,
            'standardDeviation': 21.602468994692867,
            'length': 3.0,
            'min': 10,
            'max': 30,
            'sum': 60,
            'squaresSum': 1400
          }));
    });
  });
}
