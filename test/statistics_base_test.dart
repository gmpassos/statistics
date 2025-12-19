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
      var dataBigInt = data.toBigIntList();
      var dataDynamicInt = data.toDynamicIntList();
      var dataDecimal = data.toDecimalList();

      var statistics = data.statistics;
      var statisticsBigInt = dataBigInt.statistics;
      var statisticsDynamicInt = dataDynamicInt.statistics;
      var statisticsDecimal = dataDecimal.statistics;

      expect(statistics.length, equals(4));
      expect(statistics.isEmpty, isFalse);
      expect(statistics.isNotEmpty, isTrue);

      expect(statisticsBigInt.length, equals(4));
      expect(statisticsBigInt.isEmpty, isFalse);
      expect(statisticsBigInt.isNotEmpty, isTrue);

      expect(statisticsDynamicInt.length, equals(4));
      expect(statisticsDynamicInt.isEmpty, isFalse);
      expect(statisticsDynamicInt.isNotEmpty, isTrue);

      expect(statisticsDecimal.length, equals(4));
      expect(statisticsDecimal.isEmpty, isFalse);
      expect(statisticsDecimal.isNotEmpty, isTrue);

      expect(statistics.sum, equals(100));
      expect(statistics.mean, equals(25));
      expect(statistics.standardDeviation, equals(11.180339887498949));
      expect(statistics.squaresSum, equals(3000));
      expect(statistics.squaresMean, equals(750.0));

      expect(statisticsBigInt.sum, equals(100.toBigInt()));
      expect(statisticsBigInt.mean, equals(25.toDecimal()));
      expect(statisticsBigInt.standardDeviation,
          equals(Decimal.parse('11.180339887498948')));
      expect(statisticsBigInt.squaresSum, equals(3000.toBigInt()));
      expect(statisticsBigInt.squaresMean, equals(750.toDecimal()));

      expect(statisticsDynamicInt.sum, equals(100.toDynamicInt()));
      expect(statisticsDynamicInt.mean, equals(25.toDecimal()));
      expect(statisticsDynamicInt.standardDeviation,
          equals(Decimal.parse('11.180339887498948')));
      expect(statisticsDynamicInt.squaresSum, equals(3000.toDynamicInt()));
      expect(statisticsDynamicInt.squaresMean, equals(750.toDecimal()));

      expect(statisticsDecimal.sum, equals(100.toDynamicInt()));
      expect(statisticsDecimal.mean, equals(25.toDecimal()));
      expect(statisticsDecimal.standardDeviation,
          equals(Decimal.parse('11.180339887498948')));
      expect(statisticsDecimal.squaresSum, equals(3000.toDynamicInt()));
      expect(statisticsDecimal.squaresMean, equals(750.toDecimal()));

      expect(statistics.centerIndex, equals(2));
      expect(statistics.center, equals(30));

      expect(statisticsBigInt.centerIndex, equals(2));
      expect(statisticsBigInt.center, equals(30.toBigInt()));

      expect(statisticsDynamicInt.centerIndex, equals(2));
      expect(statisticsDynamicInt.center, equals(30.toDynamicInt()));

      expect(statisticsDecimal.centerIndex, equals(2));
      expect(statisticsDecimal.center, equals(30.toDynamicInt()));

      expect(statistics.medianLow, equals(20));
      expect(statistics.medianHigh, equals(30));
      expect(statistics.median, equals(25));

      expect(statisticsBigInt.medianLow, equals(20.toBigInt()));
      expect(statisticsBigInt.medianHigh, equals(30.toBigInt()));
      expect(statisticsBigInt.median, equals(25.toDecimal()));

      expect(statisticsDynamicInt.medianLow, equals(20.toDynamicInt()));
      expect(statisticsDynamicInt.medianHigh, equals(30.toDynamicInt()));
      expect(statisticsDynamicInt.median, equals(25.toDecimal()));

      expect(statisticsDecimal.medianLow, equals(20.toDynamicInt()));
      expect(statisticsDecimal.medianHigh, equals(30.toDynamicInt()));
      expect(statisticsDecimal.median, equals(25.toDecimal()));

      expect(statistics.medianLowIndex, equals(1));
      expect(statistics.medianHighIndex, equals(2));

      expect(statisticsBigInt.medianLowIndex, equals(1));
      expect(statisticsBigInt.medianHighIndex, equals(2));

      expect(statisticsDynamicInt.medianLowIndex, equals(1));
      expect(statisticsDynamicInt.medianHighIndex, equals(2));

      expect(statisticsDecimal.medianLowIndex, equals(1));
      expect(statisticsDecimal.medianHighIndex, equals(2));

      expect(statistics.isMeanInRange(10, 30), isTrue);
      expect(statistics.isMeanInRange(10, 30, 11, 12), isTrue);

      expect(
          statisticsBigInt.isMeanInRange(10.toDynamicInt(), 30.toDynamicInt()),
          isTrue);
      expect(
          statisticsBigInt.isMeanInRange(10.toDynamicInt(), 30.toDynamicInt(),
              11.toDynamicInt(), 12.toDynamicInt()),
          isTrue);

      expect(
          statisticsDynamicInt.isMeanInRange(
              10.toDynamicInt(), 30.toDynamicInt()),
          isTrue);
      expect(
          statisticsDynamicInt.isMeanInRange(10.toDynamicInt(),
              30.toDynamicInt(), 11.toDynamicInt(), 12.toDynamicInt()),
          isTrue);

      expect(
          statisticsDecimal.isMeanInRange(10.toDynamicInt(), 30.toDynamicInt()),
          isTrue);
      expect(
          statisticsDecimal.isMeanInRange(10.toDynamicInt(), 30.toDynamicInt(),
              11.toDynamicInt(), 12.toDynamicInt()),
          isTrue);

      expect(statistics.isMeanInRange(10, 19), isFalse);
      expect(statistics.isMeanInRange(10, 30, 10, 11), isFalse);

      expect(
          statisticsBigInt.isMeanInRange(10.toDynamicInt(), 19.toDynamicInt()),
          isFalse);
      expect(
          statisticsBigInt.isMeanInRange(10.toDynamicInt(), 30.toDynamicInt(),
              10.toDynamicInt(), 11.toDynamicInt()),
          isFalse);

      expect(
          statisticsDynamicInt.isMeanInRange(
              10.toDynamicInt(), 19.toDynamicInt()),
          isFalse);
      expect(
          statisticsDynamicInt.isMeanInRange(10.toDynamicInt(),
              30.toDynamicInt(), 10.toDynamicInt(), 11.toDynamicInt()),
          isFalse);

      expect(
          statisticsDecimal.isMeanInRange(10.toDynamicInt(), 19.toDynamicInt()),
          isFalse);
      expect(
          statisticsDecimal.isMeanInRange(10.toDynamicInt(), 30.toDynamicInt(),
              10.toDynamicInt(), 11.toDynamicInt()),
          isFalse);

      expect(statistics.toString(precision: 2),
          equals('{~25 +-11.18 [10..(30)..40] #4}'));
      expect(statistics.toString(precision: 0),
          equals('{~25 +-11 [10..(30)..40] #4}'));

      expect(statisticsBigInt.toString(precision: 2),
          equals('{~25 +-11.18 [10..(30)..40] #4}'));
      expect(statisticsBigInt.toString(precision: 0),
          equals('{~25 +-11 [10..(30)..40] #4}'));

      expect(statisticsDynamicInt.toString(precision: 2),
          equals('{~25 +-11.18 [10..(30)..40] #4}'));
      expect(statisticsDynamicInt.toString(precision: 0),
          equals('{~25 +-11 [10..(30)..40] #4}'));

      expect(statisticsDecimal.toString(precision: 2),
          equals('{~25 +-11.18 [10..(30)..40] #4}'));
      expect(statisticsDecimal.toString(precision: 0),
          equals('{~25 +-11 [10..(30)..40] #4}'));

      ///////

      expect(statistics.cast<int>(), isA<Statistics<int>>());
      expect(statistics.cast<int>().toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #4}'));

      expect(statistics.cast<double>(), isA<Statistics<double>>());
      expect(statistics.cast<double>().toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #4}'));

      expect(statisticsBigInt.cast<int>(), isA<Statistics<int>>());
      expect(statisticsBigInt.cast<int>().toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #4}'));

      expect(statisticsBigInt.cast<double>(), isA<Statistics<double>>());
      expect(statisticsBigInt.cast<double>().toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #4}'));

      expect(statisticsBigInt.cast<num>(), isA<Statistics<num>>());
      expect(statisticsBigInt.cast<num>().toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #4}'));

      ///////

      expect(statisticsDynamicInt.cast<int>(), isA<Statistics<int>>());
      expect(statisticsDynamicInt.cast<int>().toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #4}'));

      expect(statisticsDynamicInt.cast<double>(), isA<Statistics<double>>());
      expect(statisticsDynamicInt.cast<double>().toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #4}'));

      expect(statisticsDynamicInt.castDynamicNumber<DynamicInt>(),
          isA<StatisticsDynamicNumber<DynamicInt>>());
      expect(statisticsDynamicInt.castDynamicNumber<DynamicInt>().toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #4}'));

      expect(statisticsDynamicInt.castDynamicNumber<Decimal>(),
          isA<StatisticsDynamicNumber<Decimal>>());
      expect(statisticsDynamicInt.castDynamicNumber<Decimal>().toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #4}'));

      ///////

      expect(statisticsDecimal.cast<int>(), isA<Statistics<int>>());
      expect(statisticsDecimal.cast<int>().toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #4}'));

      expect(statisticsDecimal.cast<double>(), isA<Statistics<double>>());
      expect(statisticsDecimal.cast<double>().toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #4}'));

      expect(statisticsDecimal.cast<num>(), isA<Statistics<num>>());
      expect(statisticsDecimal.cast<num>().toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #4}'));

      expect(statisticsDecimal.castDynamicNumber<DynamicInt>(),
          isA<StatisticsDynamicNumber<DynamicInt>>());
      expect(statisticsDecimal.castDynamicNumber<DynamicInt>().toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #4}'));

      expect(statisticsDecimal.castDynamicNumber<Decimal>(),
          isA<StatisticsDynamicNumber<Decimal>>());
      expect(statisticsDecimal.castDynamicNumber<Decimal>().toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #4}'));

      ///////

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
          equals([25.0, 11.180339887498949, 4, 10, 40, 100, 3000]));

      expect(
          statisticsDecimal.getDataFields(),
          equals([
            'mean',
            'standardDeviation',
            'length',
            'min',
            'max',
            'sum',
            'squaresSum'
          ]));
      expect(
          statisticsDecimal.getDataValues(),
          equals([
            25.toDecimal(),
            Decimal.parse('11.180339887498948'),
            4,
            10.toDecimal(),
            40.toDecimal(),
            100.toDecimal(),
            3000.toDecimal()
          ]));

      expect(
          statisticsDynamicInt.getDataFields(),
          equals([
            'mean',
            'standardDeviation',
            'length',
            'min',
            'max',
            'sum',
            'squaresSum'
          ]));
      expect(
          statisticsDynamicInt.getDataValues(),
          equals([
            25.toDecimal(),
            Decimal.parse('11.180339887498948'),
            4,
            10.toDynamicInt(),
            40.toDynamicInt(),
            100.toDynamicInt(),
            3000.toDynamicInt()
          ]));

      expect(
          statisticsBigInt.getDataFields(),
          equals([
            'mean',
            'standardDeviation',
            'length',
            'min',
            'max',
            'sum',
            'squaresSum'
          ]));
      expect(
          statisticsBigInt.getDataValues(),
          equals([
            25.toDecimal(),
            Decimal.parse('11.180339887498948'),
            4,
            10.toBigInt(),
            40.toBigInt(),
            100.toBigInt(),
            3000.toBigInt()
          ]));

      ///////

      expect(statistics.multiplyBy(2).toString(),
          equals('{~50 +-22.3606 [20..(60)..80] #8}'));

      expect(statisticsBigInt.multiplyBy(DynamicInt.two).toString(),
          equals('{~50 +-22.3606 [20..(60)..80] #8}'));

      expect(statisticsDynamicInt.multiplyBy(DynamicInt.two).toString(),
          equals('{~50 +-22.3606 [20..(60)..80] #8}'));

      expect(statisticsDecimal.multiplyBy(DynamicInt.two).toString(),
          equals('{~50 +-22.3606 [20..(60)..80] #8}'));

      ///////

      expect(statistics.sumWith(statistics).toString(),
          equals('{~50 +-22.3606 [20..(60)..80] #8}'));

      expect(statisticsBigInt.sumWith(statisticsBigInt).toString(),
          equals('{~50 +-22.3606 [20..(60)..80] #8}'));

      expect(statisticsDynamicInt.sumWith(statisticsDynamicInt).toString(),
          equals('{~50 +-22.3606 [20..(60)..80] #8}'));

      expect(statisticsDecimal.sumWith(statisticsDecimal).toString(),
          equals('{~50 +-22.3606 [20..(60)..80] #8}'));

      ///////

      expect(
          statistics.divideBy(2).toString(),
          anyOf(equals('{~12.5 +-5.5901 [5..(15)..20] #2.0}'),
              equals('{~12.5 +-5.5901 [5..(15)..20] #2}')));

      expect(
          statisticsBigInt.divideBy(DynamicInt.two).toString(),
          anyOf(equals('{~12.5 +-5.5901 [5..(15)..20] #2.0}'),
              equals('{~12.5 +-5.5901 [5..(15)..20] #2}')));

      expect(
          statisticsDynamicInt.divideBy(DynamicInt.two).toString(),
          anyOf(equals('{~12.5 +-5.5901 [5..(15)..20] #2.0}'),
              equals('{~12.5 +-5.5901 [5..(15)..20] #2}')));

      expect(
          statisticsDecimal.divideBy(DynamicInt.two).toString(),
          anyOf(equals('{~12.5 +-5.5901 [5..(15)..20] #2.0}'),
              equals('{~12.5 +-5.5901 [5..(15)..20] #2}')));

      ///////

      expect(data.statisticsWithData.data, equals(data));
      expect(dataBigInt.statisticsWithData.data, equals(dataBigInt));
      expect(dataDynamicInt.statisticsWithData.data, equals(dataDynamicInt));
      expect(dataDecimal.statisticsWithData.data, equals(dataDecimal));

      ///////

      var statistics2 = statistics + statistics;
      expect(
          statistics2.toString(), equals('{~25 +-11.1803 [10..(30)..40] #8}'));

      var statisticsBigInt2 = statisticsBigInt + statisticsBigInt;
      expect(statisticsBigInt2.toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #8}'));

      var statisticsDynamicInt2 = statisticsDynamicInt + statisticsDynamicInt;
      expect(statisticsDynamicInt2.toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #8}'));

      var statisticsDecimal2 = statisticsDecimal + statisticsDecimal;
      expect(statisticsDecimal2.toString(),
          equals('{~25 +-11.1803 [10..(30)..40] #8}'));

      var statistics3 = statistics / statistics;
      expect(
          statistics3.toString(),
          anyOf(equals('{~1 +-1 [1..(1)..1] #1.0}'),
              equals('{~1 +-1 [1..(1)..1] #1}')));

      var statisticsBigInt3 = statisticsBigInt / statisticsBigInt;
      expect(statisticsBigInt3.toString(), equals('{~1 +-1 [1..(1)..1] #1}'));

      var statisticsDynamicInt3 = statisticsDynamicInt / statisticsDynamicInt;
      expect(
          statisticsDynamicInt3.toString(), equals('{~1 +-1 [1..(1)..1] #1}'));

      var statisticsDecimal3 = statisticsDecimal / statisticsDecimal;
      expect(statisticsDecimal3.toString(), equals('{~1 +-1 [1..(1)..1] #1}'));
    });

    test('int(3)', () {
      var data = [10, 20, 30];
      var dataBigInt = data.toBigIntList();

      var statistics = data.statistics;
      var statisticsBigInt = dataBigInt.statistics;

      expect(statistics.length, equals(3));
      expect(statistics.isEmpty, isFalse);
      expect(statistics.isNotEmpty, isTrue);

      expect(statisticsBigInt.length, equals(3));
      expect(statisticsBigInt.isEmpty, isFalse);
      expect(statisticsBigInt.isNotEmpty, isTrue);

      expect(statistics.sum, equals(60));
      expect(statistics.mean, equals(20));
      expect(statistics.standardDeviation, equals(8.16496580927726));
      expect(statistics.squaresSum, equals(1400));
      expect(statistics.squaresMean, equals(466.6666666666667));

      expect(statisticsBigInt.sum, equals(60.toBigInt()));
      expect(statisticsBigInt.mean, equals(20.toDecimal()));
      expect(
          statisticsBigInt.standardDeviation,
          equals(
              Decimal.parse('8.1649658092772614292692508470403064717305671')));
      expect(statisticsBigInt.squaresSum, equals(1400.toBigInt()));
      expect(statisticsBigInt.squaresMean,
          equals(Decimal.parse('466.6666666666666666')));

      expect(statistics.centerIndex, equals(1));
      expect(statistics.center, equals(20));

      expect(statisticsBigInt.centerIndex, equals(1));
      expect(statisticsBigInt.center, equals(20.toBigInt()));

      expect(statistics.medianLow, equals(20));
      expect(statistics.medianHigh, equals(20));
      expect(statistics.median, equals(20));

      expect(statisticsBigInt.medianLow, equals(20.toBigInt()));
      expect(statisticsBigInt.medianHigh, equals(20.toBigInt()));
      expect(statisticsBigInt.median, equals(20.toDecimal()));

      expect(statistics.medianLowIndex, equals(1));
      expect(statistics.medianHighIndex, equals(1));

      expect(statisticsBigInt.medianLowIndex, equals(1));
      expect(statisticsBigInt.medianHighIndex, equals(1));

      expect(statistics.isMeanInRange(10, 30), isTrue);
      expect(statistics.isMeanInRange(10, 30, 7, 9), isTrue);

      expect(
          statisticsBigInt.isMeanInRange(10.toDynamicInt(), 30.toDynamicInt()),
          isTrue);
      expect(
          statisticsBigInt.isMeanInRange(10.toDynamicInt(), 30.toDynamicInt(),
              7.toDynamicInt(), 9.toDynamicInt()),
          isTrue);

      expect(statistics.isMeanInRange(10, 19), isFalse);
      expect(statistics.isMeanInRange(10, 30, 7, 8), isFalse);

      expect(
          statisticsBigInt.isMeanInRange(10.toDynamicInt(), 19.toDynamicInt()),
          isFalse);
      expect(
          statisticsBigInt.isMeanInRange(10.toDynamicInt(), 30.toDynamicInt(),
              7.toDynamicInt(), 8.toDynamicInt()),
          isFalse);

      expect(statistics.toString(), equals('{~20 +-8.1649 [10..(20)..30] #3}'));
      expect(statistics.toString(precision: 0),
          equals('{~20 +-8 [10..(20)..30] #3}'));

      expect(statisticsBigInt.toString(),
          equals('{~20 +-8.1649 [10..(20)..30] #3}'));
      expect(statisticsBigInt.toString(precision: 0),
          equals('{~20 +-8 [10..(20)..30] #3}'));

      expect(data.statisticsWithData.data, equals(data));
      expect(dataBigInt.statisticsWithData.data, equals(dataBigInt));
    });

    test('int(2)', () {
      var data = [10, 20];
      var dataBigInt = data.toBigIntList();

      var statistics = data.statistics;
      var statisticsBigInt = dataBigInt.statistics;

      expect(statistics.length, equals(2));
      expect(statistics.isEmpty, isFalse);
      expect(statistics.isNotEmpty, isTrue);

      expect(statisticsBigInt.length, equals(2));
      expect(statisticsBigInt.isEmpty, isFalse);
      expect(statisticsBigInt.isNotEmpty, isTrue);

      expect(statistics.sum, equals(30));
      expect(statistics.mean, equals(15));
      expect(statistics.standardDeviation, equals(5.0));
      expect(statistics.squaresSum, equals(500));
      expect(statistics.squaresMean, equals(250.0));

      expect(statisticsBigInt.sum, equals(30.toBigInt()));
      expect(statisticsBigInt.mean, equals(15.toDecimal()));
      expect(statisticsBigInt.standardDeviation, equals(Decimal.parse('5.0')));
      expect(statisticsBigInt.squaresSum, equals(500.toBigInt()));
      expect(statisticsBigInt.squaresMean, equals(Decimal.parse('250.0')));

      expect(statistics.centerIndex, equals(1));
      expect(statistics.center, equals(20));

      expect(statisticsBigInt.centerIndex, equals(1));
      expect(statisticsBigInt.center, equals(20.toBigInt()));

      expect(statistics.medianLow, equals(10));
      expect(statistics.medianHigh, equals(20));
      expect(statistics.median, equals(15));

      expect(statisticsBigInt.medianLow, equals(10.toBigInt()));
      expect(statisticsBigInt.medianHigh, equals(20.toBigInt()));
      expect(statisticsBigInt.median, equals(15.toDecimal()));

      expect(statistics.medianLowIndex, equals(0));
      expect(statistics.medianHighIndex, equals(1));

      expect(statisticsBigInt.medianLowIndex, equals(0));
      expect(statisticsBigInt.medianHighIndex, equals(1));

      expect(data.statisticsWithData.data, equals(data));
      expect(dataBigInt.statisticsWithData.data, equals(dataBigInt));

      var statistics2 = statistics + statistics;
      expect(statistics2.toString(), equals('{~15 +-5 [10..(20)..20] #4}'));

      var statisticsBigInt2 = statisticsBigInt + statisticsBigInt;
      expect(
          statisticsBigInt2.toString(), equals('{~15 +-5 [10..(20)..20] #4}'));

      var statistics3 = statistics / statistics;
      expect(
          statistics3.toString(),
          anyOf(equals('{~1 +-1 [1..(1)..1] #1.0}'),
              equals('{~1 +-1 [1..(1)..1] #1}')));

      var statisticsBigInt3 = statisticsBigInt / statisticsBigInt;
      expect(statisticsBigInt3.toString(), equals('{~1 +-1 [1..(1)..1] #1}'));
    });

    test('int(1)', () {
      var data = [10];
      var dataBigInt = data.toBigIntList();

      var statistics = data.statistics;
      var statisticsBigInt = dataBigInt.statistics;

      expect(statistics.length, equals(1));
      expect(statistics.isEmpty, isFalse);
      expect(statistics.isNotEmpty, isTrue);

      expect(statisticsBigInt.length, equals(1));
      expect(statisticsBigInt.isEmpty, isFalse);
      expect(statisticsBigInt.isNotEmpty, isTrue);

      expect(statistics.sum, equals(10));
      expect(statistics.mean, equals(10));
      expect(statistics.standardDeviation, equals(0));
      expect(statistics.squaresSum, equals(100));
      expect(statistics.squaresMean, equals(100));

      expect(statisticsBigInt.sum, equals(10.toBigInt()));
      expect(statisticsBigInt.mean, equals(10.toDecimal()));
      expect(statisticsBigInt.standardDeviation, equals(Decimal.zero));
      expect(statisticsBigInt.squaresSum, equals(100.toBigInt()));
      expect(statisticsBigInt.squaresMean, equals(100.toDecimal()));

      expect(statistics.centerIndex, equals(0));
      expect(statistics.center, equals(10));

      expect(statisticsBigInt.centerIndex, equals(0));
      expect(statisticsBigInt.center, equals(10.toBigInt()));

      expect(statistics.medianLow, equals(10));
      expect(statistics.medianHigh, equals(10));
      expect(statistics.median, equals(10));

      expect(statisticsBigInt.medianLow, equals(10.toBigInt()));
      expect(statisticsBigInt.medianHigh, equals(10.toBigInt()));
      expect(statisticsBigInt.median, equals(10.toDecimal()));

      expect(statistics.medianLowIndex, equals(0));
      expect(statistics.medianHighIndex, equals(0));

      expect(statisticsBigInt.medianLowIndex, equals(0));
      expect(statisticsBigInt.medianHighIndex, equals(0));

      expect(data.statisticsWithData.data, equals(data));
      expect(dataBigInt.statisticsWithData.data, equals(dataBigInt));
    });

    test('int(0)', () {
      var data = <int>[];
      var dataBigInt = data.toBigIntList();

      var statistics = data.statistics;
      var statisticsBigInt = dataBigInt.statistics;

      expect(statistics.length, equals(0));
      expect(statistics.isEmpty, isTrue);
      expect(statistics.isNotEmpty, isFalse);

      expect(statisticsBigInt.length, equals(0));
      expect(statisticsBigInt.isEmpty, isTrue);
      expect(statisticsBigInt.isNotEmpty, isFalse);

      expect(statistics.sum, equals(0));
      expect(statistics.mean, isNaN);
      expect(statistics.standardDeviation, isNaN);
      expect(statistics.squaresSum, equals(0));
      expect(statistics.squaresMean, equals(isNaN));

      expect(statisticsBigInt.sum, equals(0.toBigInt()));
      expect(statisticsBigInt.mean, Decimal.zero);
      expect(statisticsBigInt.standardDeviation, Decimal.zero);
      expect(statisticsBigInt.squaresSum, equals(0.toBigInt()));
      expect(statisticsBigInt.squaresMean, equals(Decimal.zero));

      expect(statistics.centerIndex, equals(0));
      expect(statistics.center, equals(0));

      expect(statisticsBigInt.centerIndex, equals(0));
      expect(statisticsBigInt.center, equals(0.toBigInt()));

      expect(statistics.medianLow, equals(0));
      expect(statistics.medianHigh, equals(0));
      expect(statistics.median, equals(0));

      expect(statisticsBigInt.medianLow, equals(0.toBigInt()));
      expect(statisticsBigInt.medianHigh, equals(0.toBigInt()));
      expect(statisticsBigInt.median, equals(Decimal.zero));

      expect(data.statisticsWithData.data, equals(data));
      expect(dataBigInt.statisticsWithData.data, equals(dataBigInt));
    });

    test('num(3)', () {
      var data = <num>[10, 20.2, 30];

      var statistics = data.statistics;

      expect(statistics.length, equals(3));
      expect(statistics.isEmpty, isFalse);
      expect(statistics.isNotEmpty, isTrue);

      expect(statistics.sum, equals(60.2));
      expect(statistics.mean, equals(20.066666666666666));
      expect(statistics.standardDeviation, equals(8.165510122188053));
      expect(statistics.squaresSum, equals(1408.04));
      expect(statistics.squaresMean, equals(469.34666666666664));

      expect(statistics.centerIndex, equals(1));
      expect(statistics.center, equals(20.2));

      expect(statistics.medianLow, equals(20.2));
      expect(statistics.medianHigh, equals(20.2));
      expect(statistics.median, equals(20.2));

      expect(statistics.medianLowIndex, equals(1));
      expect(statistics.medianHighIndex, equals(1));

      expect(statistics.isMeanInRange(10, 30), isTrue);
      expect(statistics.isMeanInRange(10, 30, 7, 9), isTrue);

      expect(statistics.isMeanInRange(10, 19), isFalse);
      expect(statistics.isMeanInRange(10, 30, 7, 8), isFalse);

      expect(statistics.toString(),
          equals('{~20.0666 +-8.1655 [10..(20.2)..30] #3}'));
      expect(statistics.toString(precision: 0),
          equals('{~20 +-8 [10..(20)..30] #3}'));
      expect(statistics.toString(precision: 1),
          equals('{~20.0 +-8.1 [10..(20.2)..30] #3}'));

      expect(data.statisticsWithData.data, equals(data));
    });

    test('useBigIntToCompute: true', () {
      var statistics =
          Statistics.compute([10, 20, 30], useBigIntToCompute: true);

      expect(statistics.sumBigInt,
          equals(BigInt.from(10) + BigInt.from(20) + BigInt.from(30)));

      expect(
          statistics.mean,
          equals((BigInt.from(10) + BigInt.from(20) + BigInt.from(30)) /
              BigInt.from(3)));

      expect(statistics.standardDeviation, equals(8.16496580927726));
    });

    test('useBigIntToCompute: true (maxSafeInt)', () {
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

    test('standardDeviation = 0 (int)', () {
      final data1 = <int>[94, 94, 94, 94, 94, 94, 94];
      var standardDeviation = data1.standardDeviation;
      final stdDev1 = standardDeviation;
      print('Standard Deviation of data1: $stdDev1');

      expect(standardDeviation, equals(0.0));
    });

    test('standardDeviation = 0 (double)', () {
      final data1 = <double>[94.97, 94.97, 94.97, 94.97, 94.97, 94.97, 94.97];
      var standardDeviation = data1.standardDeviation;
      final stdDev1 = standardDeviation;
      print('Standard Deviation of data1: $stdDev1');

      expect(standardDeviation, equals(0.0));
    });

    test('standardDeviation = 0 (num)', () {
      final data = <num>[53.97, 53.97, 53.97, 53.97, 53.97, 53.97, 53.97];
      var standardDeviation = data.standardDeviation;
      final stdDev = standardDeviation;
      print('Standard Deviation of data: $stdDev');

      expect(standardDeviation, equals(0.0));
    });

    test('standardDeviation = 0 (BigInt)', () {
      final data = [94, 94, 94, 94, 94, 94, 94].toBigIntList();
      var standardDeviation = data.standardDeviation;
      final stdDev = standardDeviation;
      print('Standard Deviation of data: $stdDev');

      expect(standardDeviation, equals(Decimal.zero));
    });

    test('standardDeviation = 0 (DynamicInt)', () {
      final data = [94, 94, 94, 94, 94, 94, 94].toDynamicIntList();
      var standardDeviation = data.standardDeviation;
      final stdDev = standardDeviation;
      print('Standard Deviation of data: $stdDev');

      expect(standardDeviation, equals(Decimal.zero));
    });

    test('standardDeviation = 0 (Decimal)', () {
      final data =
          [94.97, 94.97, 94.97, 94.97, 94.97, 94.97, 94.97].toDecimalList();
      var standardDeviation = data.standardDeviation;
      final stdDev = standardDeviation;
      print('Standard Deviation of data: $stdDev');

      expect(standardDeviation, equals(Decimal.zero));
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

      // BigInt:

      expect(
          () => StatisticsBigInt.compute([10, 20, 30].toBigIntList(),
              alreadySortedData: false),
          isNot(throwsArgumentError));

      expect(
          () => StatisticsBigInt.compute([30, 20, 10].toBigIntList(),
              alreadySortedData: false),
          isNot(throwsArgumentError));

      expect(
          () => StatisticsBigInt.compute([10, 20, 30].toBigIntList(),
              alreadySortedData: false),
          isNot(throwsArgumentError));

      expect(
          () => StatisticsBigInt.compute([30, 20, 10].toBigIntList(),
              alreadySortedData: true),
          throwsArgumentError);

      //

      expect(
          () => StatisticsDynamicNumber.compute([10, 20, 30].toDecimalList(),
              alreadySortedData: false),
          isNot(throwsArgumentError));

      expect(
          () => StatisticsDynamicNumber.compute([30, 20, 10].toDecimalList(),
              alreadySortedData: false),
          isNot(throwsArgumentError));

      expect(
          () => StatisticsDynamicNumber.compute([10, 20, 30].toDecimalList(),
              alreadySortedData: false),
          isNot(throwsArgumentError));

      expect(
          () => StatisticsDynamicNumber.compute([30, 20, 10].toDecimalList(),
              alreadySortedData: true),
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
          statistics.standardDeviation,
          inInclusiveRange(statistics3.standardDeviation - 0.000001,
              statistics3.standardDeviation + 0.000001));
      expect(statistics.squaresSum, equals(statistics3.squaresSum));
      expect(statistics.squaresMean, equals(statistics3.squaresMean));
    });

    test('operator / (3)', () {
      var statistics1 = [10, 20, 30].statistics;
      var statistics2 = [20, 30, 40].statistics;

      var statistics = statistics1 / statistics2;

      expect(statistics.sum, equals(0.6666666666666666));
      expect(statistics.mean, equals(0.6666666666666666));
      expect(statistics.standardDeviation, equals(1.0));
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

      expect(statistics.toString(), equals('{~20 +-8.1649 [10..(20)..30] #3}'));
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
          equals([20.0, 8.16496580927726, 3.0, 10, 30, 60, 1400]));
      expect(
          statistics.getDataMap(),
          equals({
            'mean': 20.0,
            'standardDeviation': 8.16496580927726,
            'length': 3.0,
            'min': 10,
            'max': 30,
            'sum': 60,
            'squaresSum': 1400
          }));
    });
  });

  group('StandardDeviation', () {
    testStandardDeviationComputer<N, D>(StandardDeviationComputer stdv) {
      expect(stdv.addAll([10, 20, 30]).standardDeviationAsDouble,
          equals(8.16496580927726));
      expect(stdv.isEmpty, isFalse);
      expect(stdv.isNotEmpty, isTrue);
      expect(stdv.length, equals(3));
      expect(stdv.sumAsDouble, equals(60));
      expect(stdv.squaresSumAsDouble, equals(1400));

      expect(
          stdv.addAllBigInt([40, 50].toBigIntList()).standardDeviationAsDouble,
          inInclusiveRange(14.14213562373094, 14.14213562373096));
      expect(stdv.isEmpty, isFalse);
      expect(stdv.isNotEmpty, isTrue);
      expect(stdv.length, equals(5));
      expect(stdv.sumAsDouble, equals(150));
      expect(stdv.squaresSumAsDouble, equals(5500));

      expect(
          stdv
              .addAllDynamicNumber([60, 70].toDynamicIntList())
              .standardDeviationAsDouble,
          inInclusiveRange(19.9999, 20.0001));
      expect(stdv.isEmpty, isFalse);
      expect(stdv.isNotEmpty, isTrue);
      expect(stdv.length, equals(7));
      expect(stdv.sumAsDouble, equals(280));
      expect(stdv.squaresSumAsDouble, equals(14000));

      expect(stdv.reset().standardDeviationAsDouble, equals(0));
      expect(stdv.isEmpty, isTrue);
      expect(stdv.isNotEmpty, isFalse);
      expect(stdv.length, equals(0));
      expect(stdv.sumAsDouble, equals(0));
      expect(stdv.squaresSumAsDouble, equals(0));
    }

    test('num', () {
      var stdv = StandardDeviationComputerNum();
      testStandardDeviationComputer(stdv);
    });

    test('BigInt', () {
      var stdv = StandardDeviationComputerBigInt();
      testStandardDeviationComputer(stdv);
    });

    test('DynamicNumber', () {
      var stdv = StandardDeviationComputerDynamicNumber();
      testStandardDeviationComputer(stdv);
    });
  });
}
