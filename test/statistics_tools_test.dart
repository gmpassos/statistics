import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('int', () {
    setUp(() {});

    test('toIntsList', () {
      expect(<int>[].toIntsList(), isEmpty);
      expect(<int>[].toIntsList(), isEmpty);
      expect(<int>[10].toIntsList(), equals([10]));
      expect(<int>[10, 20].toIntsList(), equals([10, 20]));
    });

    test('toDoublesList', () {
      expect(<int>[].toDoublesList(), isEmpty);
      expect(<int>[].toDoublesList(), isEmpty);
      expect(<int>[10].toDoublesList(), equals([10.0]));
      expect(<int>[10, 20].toDoublesList(), equals([10.0, 20.0]));
    });

    test('toStringsList', () {
      expect(<int>[].toStringsList(), isEmpty);
      expect(<int>[].toStringsList(), isEmpty);
      expect(<int>[10].toStringsList(), equals(['10']));
      expect(<int>[10, 20].toStringsList(), equals(['10', '20']));
    });

    test('mean', () {
      expect(<int>[].mean, isNaN);
      expect([0].mean, equals(0));
      expect([10].mean, equals(10));
      expect([10, 20].mean, equals(15));
      expect([10, 20, 30].mean, equals(20));
    });

    test('sum', () {
      expect(<int>[].sum, equals(0));
      expect([0].sum, equals(0));
      expect([10].sum, equals(10));
      expect([10, 20].sum, equals(30));
      expect([10, 20, 30].sum, equals(60));
    });

    test('sumSquares', () {
      expect(<int>[].sumSquares, equals(0));
      expect([0].sumSquares, equals(0));
      expect([10].sumSquares, equals(100));
      expect([10, 20].sumSquares, equals(500));
      expect([10, 20, 30].sumSquares, equals(1400));
    });

    test('square', () {
      expect(<int>[].square, isEmpty);
      expect([0].square, equals([0]));
      expect([10].square, equals([100]));
      expect([10, 20].square, equals([100, 400]));
      expect([10, 20, 30].square, equals([100, 400, 900]));

      expect(11.square, equals(121));
    });

    test('squareRoot', () {
      expect(<int>[].squareRoot, isEmpty);
      expect([0].squareRoot, equals([0]));
      expect([9].squareRoot, equals([3]));
      expect([100, 121].squareRoot, equals([10, 11]));
      expect([10000, 400, 900].squareRoot, equals([100, 20, 30]));

      expect(100.squareRoot, equals(10));
    });

    test('squaresMean', () {
      expect(<int>[].squaresMean, isNaN);
      expect([0].squaresMean, equals(0));
      expect([10].squaresMean, equals(100));
      expect([10, 20].squaresMean, equals(250));
      expect([10, 20, 30].squaresMean, equals(466.6666666666667));
    });

    test('standardDeviation', () {
      expect(<int>[].standardDeviation, equals(0));
      expect([0].standardDeviation, equals(0));
      expect([10].standardDeviation, equals(10));
      expect([10, 20].standardDeviation, equals(7.905694150420948));
      expect([10, 20, 30].standardDeviation, equals(8.16496580927726));
    });

    test('median', () {
      expect(<int>[].median, isNull);
      expect([0].median, equals(0));
      expect([10].median, equals(10));
      expect([10, 20].median, equals(15));
      expect([10, 20, 30].median, equals(20));
      expect([30, 20, 10].median, equals(20));
      expect([5, 10, 20, 30].median, equals(15));
      expect([30, 20, 10, 5].median, equals(15));
    });

    test('medianLow', () {
      expect(<int>[].medianLow, isNull);
      expect([0].medianLow, equals(0));
      expect([10].medianLow, equals(10));
      expect([10, 20].medianLow, equals(10));
      expect([10, 20, 30].medianLow, equals(20));
      expect([30, 20, 10].medianLow, equals(20));
      expect([5, 10, 20, 30].medianLow, equals(10));
      expect([30, 20, 10, 5].medianLow, equals(10));
    });

    test('medianHigh', () {
      expect(<int>[].medianHigh, isNull);
      expect([0].medianHigh, equals(0));
      expect([10].medianHigh, equals(10));
      expect([10, 20].medianHigh, equals(20));
      expect([10, 20, 30].medianHigh, equals(20));
      expect([30, 20, 10].medianHigh, equals(20));
      expect([5, 10, 20, 30].medianHigh, equals(20));
      expect([30, 20, 10, 5].medianHigh, equals(20));
    });

    test('abs', () {
      expect(<int>[].abs, isEmpty);
      expect([0].abs, equals([0]));
      expect([10].abs, equals([10]));
      expect([-10, 20].abs, equals([10, 20]));
      expect([10, -20, 30].abs, equals([10, 20, 30]));
    });

    test('movingAverage', () {
      expect(<int>[].movingAverage(2), isEmpty);
      expect([0].movingAverage(2), equals([0]));
      expect([10].movingAverage(3), equals([10]));
      expect([-10, 20].movingAverage(3), equals([5.0]));
      expect([10, -20, 30].movingAverage(3), equals([6.666666666666667]));
      expect([10, -20, 30, 40, 50, 60].movingAverage(3),
          equals([6.666666666666667, 16.666666666666668, 40.0, 50.0]));
    });

    test('operator +', () {
      expect(<int>[] + <int>[], isEmpty);
      expect(<int>[10] + <int>[20], equals([10, 20]));
      expect(<int>[100, 200] + <int>[10, 20], equals([100, 200, 10, 20]));
    });

    test('operator -', () {
      expect(<int>[] - <int>[], isEmpty);
      expect(<int>[10] - <int>[20], equals([-10]));
      expect(<int>[100, 200] - <int>[10, 20], equals([90, 180]));
      expect(<int>[100, 200, 300] - <int>[10, 20], equals([90, 180]));
      expect(<int>[100, 200, 300] - <int>[10, 20, 30], equals([90, 180, 270]));
    });

    test('operator *', () {
      expect(<int>[] * <int>[], isEmpty);
      expect(<int>[10] * <int>[20], equals([200]));
      expect(<int>[100, 200] * <int>[10, 20], equals([1000, 4000]));
      expect(<int>[100, 200, 300] * <int>[10, 20], equals([1000, 4000]));
      expect(
          <int>[100, 200, 300] * <int>[10, 20, 30], equals([1000, 4000, 9000]));
    });

    test('operator /', () {
      expect(<int>[] / <int>[], isEmpty);
      expect(<int>[10] / <int>[20], equals([0.5]));
      expect(<int>[100, 200] / <int>[10, 20], equals([10, 10]));
      expect(<int>[100, 200, 300] / <int>[10, 20], equals([10, 10]));
      expect(<int>[100, 200, 300] / <int>[10, 20, 30], equals([10, 10, 10]));
      expect(<int>[100, 200, 300] / <int>[40, 50, 30], equals([2.5, 4, 10]));
    });

    test('operator ~/', () {
      expect(<int>[] ~/ <int>[], isEmpty);
      expect(<int>[10] ~/ <int>[20], equals([0]));
      expect(<int>[100, 200] ~/ <int>[10, 20], equals([10, 10]));
      expect(<int>[100, 200, 300] ~/ <int>[10, 20], equals([10, 10]));
      expect(<int>[100, 200, 300] ~/ <int>[10, 20, 30], equals([10, 10, 10]));
      expect(<int>[100, 200, 300] ~/ <int>[40, 50, 30], equals([2, 4, 10]));
    });

    test('isSorted', () {
      expect(<int>[].isSorted, isFalse);

      expect(<int>[0].isSorted, isTrue);
      expect(<int>[10].isSorted, isTrue);
      expect(<int>[-10, 20].isSorted, isTrue);
      expect(<int>[10, 20, 30].isSorted, isTrue);

      expect(<int>[10, 5].isSorted, isFalse);
      expect(<int>[10, 200, 30].isSorted, isFalse);
    });

    test('equalsValues', () {
      expect(<int>[].equalsValues([]), isTrue);
      expect(<int>[].equalsValues([10]), isFalse);

      expect(<int>[10].equalsValues([10]), isTrue);
      expect(<int>[10].equalsValues([10.0], tolerance: 0.000001), isTrue);
      expect(<int>[10].equalsValues([10.0001]), isFalse);
      expect(<int>[10].equalsValues([10.0], tolerance: 0.01), isTrue);
      expect(<int>[10].equalsValues([10.0001], tolerance: 0.01), isTrue);
      expect(<int>[10].equalsValues([10.0001], tolerance: 0.000001), isFalse);

      expect(<int>[10, 20].equalsValues([10.0001, 20.001], tolerance: 0.01),
          isTrue);
      expect(<int>[10, 20].equalsValues([10.0001, 20.1], tolerance: 0.01),
          isFalse);
    });
  });

  group('tools', () {
    setUp(() {});

    test('Chronometer', () async {
      var chronometer = Chronometer('test');

      expect(chronometer.isStarted, isFalse);
      expect(chronometer.isFinished, isFalse);
      expect(chronometer.elapsedTimeMs, equals(0));

      chronometer.start();

      expect(chronometer.isStarted, isTrue);
      expect(chronometer.isFinished, isFalse);

      await Future.delayed(Duration(seconds: 1));
      chronometer.stop(operations: 10);

      expect(chronometer.isStarted, isTrue);
      expect(chronometer.isFinished, isTrue);

      expect(chronometer.elapsedTimeMs >= 1000, isTrue);
      expect(chronometer.elapsedTimeMs < 2000, isTrue);

      expect(chronometer.elapsedTimeSec >= 1, isTrue);
      expect(chronometer.elapsedTimeSec < 2, isTrue);

      expect(chronometer.elapsedTime.inMilliseconds,
          equals(chronometer.elapsedTimeMs));

      expect(chronometer.operations, equals(10));
      expect(chronometer.failedOperations, equals(0));

      expect(chronometer.hertz <= 10, isTrue);
      expect(chronometer.hertz >= 9, isTrue);

      expect(
          chronometer.stopTime!.millisecondsSinceEpoch >
              chronometer.startTime!.millisecondsSinceEpoch,
          isTrue);

      expect(chronometer.hertzAsString, matches(RegExp(r'^[\d.]+ Hz$')));
      expect(chronometer.operationsAsString, equals('10'));
      expect(chronometer.failedOperationsAsString, equals('0'));

      print(chronometer);
      print(chronometer.toString(withStartTime: false));

      expect(
          chronometer.toString(),
          matches(RegExp(
              r'^test\{ [\d.]+ \w+ · hertz: [\d.]+ Hz · ops: \d+ · start: [\d-]+ [\d:.-]+ \.\. \d+\.\d+ \}$')));

      expect(
          chronometer.toString(withStartTime: false),
          matches(
              RegExp(r'^test\{ [\d.]+ \w+ · hertz: [\d.]+ Hz · ops: \d+ \}$')));

      chronometer.totalOperation = 100;

      print(chronometer);
      print(chronometer.toString(withStartTime: false));

      expect(
          chronometer.toString(),
          matches(RegExp(
              r'^test\{ [\d.]+ \w+ · hertz: [\d.]+ Hz · ops: [\d,]+ » [\d.]+\% · ETOC: [\d.]+ \w+ · start: [\d-]+ [\d:.-]+ \.\. \d+\.\d+ \}$')));

      var chronometer2 = Chronometer('test2');

      print(chronometer2);
      print(chronometer2.toString(withStartTime: true));

      expect(chronometer2.toString(), matches(RegExp(r'^test2\{ 0 .*')));

      chronometer2.start();
      await Future.delayed(Duration(milliseconds: 100));

      expect(chronometer2.elapsedTimeMs >= 100, isTrue);
      expect(chronometer2.elapsedTimeMs < 200, isTrue);

      chronometer2.stop(operations: 1);

      var elapsedTime = chronometer2.elapsedTimeMs;

      await Future.delayed(Duration(milliseconds: 100));

      expect(chronometer2.elapsedTimeMs, equals(elapsedTime));

      expect(chronometer2.elapsedTimeSec >= 0.1, isTrue);
      expect(chronometer2.elapsedTimeSec < 0.2, isTrue);

      expect(chronometer2.elapsedTime.inMilliseconds,
          equals(chronometer2.elapsedTimeMs));

      expect(chronometer2.operations, equals(1));
      expect(chronometer2.failedOperations, equals(0));

      expect(chronometer2.hertz <= 10, isTrue);
      expect(chronometer2.hertz >= 9, isTrue);

      expect(
          chronometer.compareTo(chronometer2),
          equals(chronometer.hertz > chronometer2.hertz
              ? 1
              : (chronometer.hertz == chronometer2.hertz ? 0 : -1)));

      var chronometer3 = chronometer + chronometer2;

      expect(chronometer3.hertz <= 10, isTrue);
      expect(chronometer3.hertz >= 9, isTrue);

      expect(chronometer3.elapsedTimeMs > chronometer.elapsedTimeMs, isTrue);

      expect(chronometer3.elapsedTimeMs >= 1100, isTrue);
      expect(chronometer3.elapsedTimeMs < 2000, isTrue);

      chronometer.reset();
      expect(chronometer.isStarted, isFalse);
      expect(chronometer.isFinished, isFalse);
      expect(chronometer.operations, equals(0));
    });
  });
}
