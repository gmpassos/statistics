import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('Numerical Parsers', () {
    setUp(() {});

    test('parseInt', () {
      expect(parseInt(10), equals(10));
      expect(parseInt(10.1), equals(10));
      expect(parseInt('a b', 404), equals(404));

      expect(parseInt('10'), equals(10));
      expect(parseInt('10.0'), equals(10));
      expect(parseInt('10.1'), equals(10));
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
  });

  group('Statistics', () {
    setUp(() {});

    test('int(3)', () {
      var statistics = [10, 20, 30].statistics;

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

      expect(statistics.isMeanInRange(10, 30), isTrue);
      expect(statistics.isMeanInRange(10, 30, 20, 22), isTrue);

      expect(statistics.isMeanInRange(10, 19), isFalse);
      expect(statistics.isMeanInRange(10, 30, 20, 21), isFalse);
    });

    test('int(2)', () {
      var statistics = [10, 20].statistics;

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
    });

    test('int(1)', () {
      var statistics = [10].statistics;

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
    });

    test('int(0)', () {
      var statistics = <int>[].statistics;

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
          statistics.toString(), equals('{~20 +-21.6024 [10..(20)..30] #3.0}'));
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
