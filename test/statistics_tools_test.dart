import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('int', () {
    setUp(() {});

    test('toIntsList', () {
      expect(<int>[].toIntsList(), isEmpty);
      expect(<int>[].toBigIntList(), isEmpty);
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
      expect([10].standardDeviation, equals(0));
      expect([10, 20].standardDeviation, equals(5));
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

  group('BigInt', () {
    setUp(() {});

    test('toIntsList', () {
      expect(<BigInt>[].toIntsList(), isEmpty);
      expect(<BigInt>[].toBigIntList(), isEmpty);
      expect(<BigInt>[10.toBigInt()].toIntsList(), equals([10]));
      expect(<BigInt>[10.toBigInt(), 20.toBigInt()].toIntsList(),
          equals([10, 20]));
    });

    test('toDoublesList', () {
      expect(<BigInt>[].toDoublesList(), isEmpty);
      expect(<BigInt>[].toDoublesList(), isEmpty);
      expect(<BigInt>[10.toBigInt()].toDoublesList(), equals([10.0]));
      expect(<BigInt>[10.toBigInt(), 20.toBigInt()].toDoublesList(),
          equals([10.0, 20.0]));
    });

    test('toStringsList', () {
      expect(<BigInt>[].toStringsList(), isEmpty);
      expect(<BigInt>[].toStringsList(), isEmpty);
      expect(<BigInt>[10.toBigInt()].toStringsList(), equals(['10']));
      expect(<BigInt>[10.toBigInt(), 20.toBigInt()].toStringsList(),
          equals(['10', '20']));
    });

    test('mean', () {
      expect(() => <BigInt>[].mean, throwsUnsupportedError);
      expect([0].mean, equals(0));
      expect([10].mean, equals(10));
      expect([10, 20].mean, equals(15));
      expect([10, 20, 30].mean, equals(20));
    });

    test('sum', () {
      expect(<BigInt>[].sum, equals(0.toBigInt()));
      expect([0].sum, equals(0));
      expect([10].sum, equals(10));
      expect([10, 20].sum, equals(30));
      expect([10, 20, 30].sum, equals(60));
    });

    test('sumSquares', () {
      expect(<BigInt>[].sumSquares, equals(0.toBigInt()));
      expect([0].sumSquares, equals(0));
      expect([10].sumSquares, equals(100));
      expect([10, 20].sumSquares, equals(500));
      expect([10, 20, 30].sumSquares, equals(1400));
    });

    test('square', () {
      expect(<BigInt>[].square, isEmpty);
      expect([0].square, equals([0]));
      expect([10].square, equals([100]));
      expect([10, 20].square, equals([100, 400]));
      expect([10, 20, 30].square, equals([100, 400, 900]));

      expect(11.square, equals(121));
    });

    test('squareRoot', () {
      expect(<BigInt>[].squareRoot, isEmpty);
      expect([0].squareRoot, equals([0]));
      expect([9].squareRoot, equals([3]));
      expect([100, 121].squareRoot, equals([10, 11]));
      expect([10000, 400, 900].squareRoot, equals([100, 20, 30]));

      expect(100.squareRoot, equals(10));
    });

    test('squaresMean', () {
      expect(() => <BigInt>[].squaresMean, throwsUnsupportedError);
      expect([0].squaresMean, equals(0));
      expect([10].squaresMean, equals(100));
      expect([10, 20].squaresMean, equals(250));
      expect([10, 20, 30].squaresMean, equals(466.6666666666667));
    });

    test('standardDeviation', () {
      expect(<BigInt>[].standardDeviation, equals(0.toDecimal()));
      expect([0].standardDeviation, equals(0));
      expect([10].standardDeviation, equals(0));
      expect([10, 20].standardDeviation, equals(5));
      expect([10, 20, 30].standardDeviation, equals(8.16496580927726));
    });

    test('median', () {
      expect(<BigInt>[].median, isNull);
      expect([0].median, equals(0));
      expect([10].median, equals(10));
      expect([10, 20].median, equals(15));
      expect([10, 20, 30].median, equals(20));
      expect([30, 20, 10].median, equals(20));
      expect([5, 10, 20, 30].median, equals(15));
      expect([30, 20, 10, 5].median, equals(15));
    });

    test('medianLow', () {
      expect(<BigInt>[].medianLow, isNull);
      expect([0].medianLow, equals(0));
      expect([10].medianLow, equals(10));
      expect([10, 20].medianLow, equals(10));
      expect([10, 20, 30].medianLow, equals(20));
      expect([30, 20, 10].medianLow, equals(20));
      expect([5, 10, 20, 30].medianLow, equals(10));
      expect([30, 20, 10, 5].medianLow, equals(10));
    });

    test('medianHigh', () {
      expect(<BigInt>[].medianHigh, isNull);
      expect([0].medianHigh, equals(0));
      expect([10].medianHigh, equals(10));
      expect([10, 20].medianHigh, equals(20));
      expect([10, 20, 30].medianHigh, equals(20));
      expect([30, 20, 10].medianHigh, equals(20));
      expect([5, 10, 20, 30].medianHigh, equals(20));
      expect([30, 20, 10, 5].medianHigh, equals(20));
    });

    test('abs', () {
      expect(<BigInt>[].abs, isEmpty);
      expect([0].abs, equals([0]));
      expect([10].abs, equals([10]));
      expect([-10, 20].abs, equals([10, 20]));
      expect([10, -20, 30].abs, equals([10, 20, 30]));
    });

    test('movingAverage', () {
      expect(<BigInt>[].movingAverage(2), isEmpty);
      expect([0].movingAverage(2), equals([0]));
      expect([10].movingAverage(3), equals([10]));
      expect([-10, 20].movingAverage(3), equals([5.0]));
      expect([10, -20, 30].movingAverage(3), equals([6.666666666666667]));
      expect([10, -20, 30, 40, 50, 60].movingAverage(3),
          equals([6.666666666666667, 16.666666666666668, 40.0, 50.0]));
    });

    test('operator +', () {
      expect(<BigInt>[] + <BigInt>[], isEmpty);
      expect(<BigInt>[10.toBigInt()] + <BigInt>[20.toBigInt()],
          equals([10.toBigInt(), 20.toBigInt()]));
      expect(
          <BigInt>[100.toBigInt(), 200.toBigInt()] +
              <BigInt>[10.toBigInt(), 20.toBigInt()],
          equals([100, 200, 10, 20].toBigIntList()));
    });

    test('operator -', () {
      expect(<BigInt>[] - <BigInt>[], isEmpty);
      expect(<BigInt>[10.toBigInt()] - <BigInt>[20.toBigInt()],
          equals([-10.toBigInt()]));
      expect(
          <BigInt>[100.toBigInt(), 200.toBigInt()] -
              <BigInt>[10.toBigInt(), 20.toBigInt()],
          equals([90, 180].toBigIntList()));
      expect(
          <BigInt>[100.toBigInt(), 200.toBigInt(), 300.toBigInt()] -
              <BigInt>[10.toBigInt(), 20.toBigInt()],
          equals([90, 180].toBigIntList()));
      expect(
          <BigInt>[100.toBigInt(), 200.toBigInt(), 300.toBigInt()] -
              <BigInt>[10.toBigInt(), 20.toBigInt(), 30.toBigInt()],
          equals([90, 180, 270].toBigIntList()));
    });

    test('operator *', () {
      expect(<BigInt>[] * <BigInt>[], isEmpty);
      expect(<BigInt>[10.toBigInt()] * <BigInt>[20.toBigInt()],
          equals([200].toBigIntList()));
      expect([100, 200].toBigIntList() * [10, 20].toBigIntList(),
          equals([1000, 4000].toBigIntList()));
      expect([100, 200, 300].toBigIntList() * [10, 20].toBigIntList(),
          equals([1000, 4000].toBigIntList()));
      expect([100, 200, 300].toBigIntList() * [10, 20, 30].toBigIntList(),
          equals([1000, 4000, 9000].toBigIntList()));
    });

    test('operator /', () {
      expect(<BigInt>[] / <BigInt>[], isEmpty);
      expect([10].toBigIntList() / [20].toBigIntList(),
          equals([0.5].toDecimalList()));
      expect([100, 200].toBigIntList() / [10, 20].toBigIntList(),
          equals([10, 10].toDecimalList()));
      expect([100, 200, 300].toBigIntList() / [10, 20].toBigIntList(),
          equals([10, 10].toDecimalList()));
      expect([100, 200, 300].toBigIntList() / [10, 20, 30].toBigIntList(),
          equals([10, 10, 10].toDecimalList()));
      expect([100, 200, 300].toBigIntList() / [40, 50, 30].toBigIntList(),
          equals([2.5, 4, 10].toDecimalList()));
    });

    test('operator ~/', () {
      expect(<BigInt>[] ~/ <BigInt>[], isEmpty);
      expect([10].toBigIntList() ~/ [20].toBigIntList(),
          equals([0].toBigIntList()));
      expect([100, 200].toBigIntList() ~/ [10, 20].toBigIntList(),
          equals([10, 10].toBigIntList()));
      expect([100, 200, 300].toBigIntList() ~/ [10, 20].toBigIntList(),
          equals([10, 10].toBigIntList()));
      expect([100, 200, 300].toBigIntList() ~/ [10, 20, 30].toBigIntList(),
          equals([10, 10, 10].toBigIntList()));
      expect([100, 200, 300].toBigIntList() ~/ [40, 50, 30].toBigIntList(),
          equals([2, 4, 10].toBigIntList()));
    });

    test('isSorted', () {
      expect(<BigInt>[].isSorted, isFalse);

      expect(<BigInt>[0.toBigInt()].isSorted, isTrue);
      expect(<BigInt>[10.toBigInt()].isSorted, isTrue);
      expect(<BigInt>[-10.toBigInt(), 20.toBigInt()].isSorted, isTrue);
      expect(<BigInt>[10.toBigInt(), 20.toBigInt(), 30.toBigInt()].isSorted,
          isTrue);

      expect(<BigInt>[10.toBigInt(), 5.toBigInt()].isSorted, isFalse);
      expect(<BigInt>[10.toBigInt(), 200.toBigInt(), 30.toBigInt()].isSorted,
          isFalse);
    });

    test('equalsValues', () {
      expect(<BigInt>[].equalsValues([]), isTrue);
      expect(<BigInt>[].equalsValues([10]), isFalse);

      expect(<BigInt>[10.toBigInt()].equalsValues([10.toBigInt()]), isTrue);
      expect(<BigInt>[10.toBigInt()].equalsValues([10.0], tolerance: 0.000001),
          isTrue);
      expect(<BigInt>[10.toBigInt()].equalsValues([10.0001]), isFalse);
      expect(<BigInt>[10.toBigInt()].equalsValues([10.0], tolerance: 0.01),
          isTrue);
      expect(<BigInt>[10.toBigInt()].equalsValues([10.0001], tolerance: 0.01),
          isTrue);
      expect(
          <BigInt>[10.toBigInt()].equalsValues([10.0001], tolerance: 0.000001),
          isFalse);

      expect(
          <BigInt>[10.toBigInt(), 20.toBigInt()]
              .equalsValues([10.0001, 20.001], tolerance: 0.01),
          isTrue);
      expect(
          <BigInt>[10.toBigInt(), 20.toBigInt()]
              .equalsValues([10.0001, 20.1], tolerance: 0.01),
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
              r'^test\{ [\d.]+ \w+ · hertz: [\d.]+ Hz · ops: [\d,]+ » [\d.]+% · ETOC: [\d.]+ \w+ · start: [\d-]+ [\d:.-]+ \.\. \d+\.\d+ \}$')));

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
    }, retry: 3);

    test('CountTable', () {
      var counter = CountTable<String>();

      expect(counter.isEmpty, isTrue);
      expect(counter.isNotEmpty, isFalse);
      expect(counter.length, equals(0));
      expect(counter.keys, isEmpty);
      expect(counter.keysSorted, isEmpty);

      expect(counter.keysSorted, isEmpty);

      expect(counter.get('x'), isNull);

      counter.increment('x');
      expect(counter.get('x'), equals(1));
      expect(counter.isEmpty, isFalse);
      expect(counter.isNotEmpty, isTrue);
      expect(counter.length, equals(1));

      counter.increment('x');
      expect(counter.get('x'), equals(2));

      counter.incrementBy('x', 3);
      expect(counter.get('x'), equals(5));

      counter.incrementBy('y', 2);
      expect(counter.get('y'), equals(2));

      expect(counter.get('x'), equals(5));

      counter.increment('x');
      expect(counter.get('x'), equals(6));

      expect(counter.length, equals(2));
      expect(counter.keys, equals(['x', 'y']));
      expect(counter.keysSorted, equals(['y', 'x']));

      expect(counter.isEmpty, isFalse);

      expect(
          counter.entries.toList().map((e) => '${e.key}=${e.value}').toList(),
          equals(['x=6', 'y=2']));
      expect(counter.toMap(), equals({'x': 6, 'y': 2}));

      expect(counter.highest, equals('x'));
      expect(counter.lowest, equals('y'));

      counter.decrement('x');
      expect(counter.toMap(), equals({'x': 5, 'y': 2}));

      counter.incrementBy('x', 10);
      expect(counter.toMap(), equals({'x': 15, 'y': 2}));

      counter.decrementBy('x', 5);
      expect(counter.toMap(), equals({'x': 10, 'y': 2}));

      counter.decrementBy('x', 5);
      expect(counter.toMap(), equals({'x': 5, 'y': 2}));

      expect(counter.highest, equals('x'));
      expect(counter.lowest, equals('y'));

      expect(counter['x'], equals(5));
      expect(counter['y'], equals(2));

      counter.set('y', 100);
      expect(counter.toMap(), equals({'x': 5, 'y': 100}));

      counter['y'] = 10;
      expect(counter.toMap(), equals({'x': 5, 'y': 10}));

      expect(counter.toString(), equals('CountTable{ length: 2 }'));

      expect(counter.copy().toMap(), equals({'x': 5, 'y': 10}));

      expect(
          counter.copy(filter: (k, v) => v >= 10).toMap(), equals({'y': 10}));

      expect(counter.highest, equals('y'));
      expect(counter.lowest, equals('x'));

      expect(counter.remove('x'), equals(5));

      expect(counter.highest, equals('y'));
      expect(counter.lowest, equals('y'));

      counter.clear();
      expect(counter.toMap(), equals({}));
      expect(counter.isEmpty, isTrue);
      expect(counter.length, equals(0));

      expect(counter.toString(), equals('CountTable{ length: 0 }'));
    });
  });
}
