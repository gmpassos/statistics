import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('int', () {
    setUp(() {});

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
  });

  group('double', () {
    setUp(() {});

    test('mean', () {
      expect(<double>[].mean, isNaN);
      expect([0.0].mean, equals(0));
      expect([10.0].mean, equals(10));
      expect([10.0, 20.0].mean, equals(15));
      expect([10.0, 20.0, 30.0].mean, equals(20));
    });

    test('sum', () {
      expect(<double>[].sum, equals(0));
      expect([0.0].sum, equals(0));
      expect([10.0].sum, equals(10));
      expect([10.0, 20.0].sum, equals(30));
      expect([10.0, 20.0, 30.0].sum, equals(60));
    });

    test('sumSquares', () {
      expect(<double>[].sumSquares, equals(0));
      expect([0.0].sumSquares, equals(0));
      expect([10.0].sumSquares, equals(100));
      expect([10.0, 20.0].sumSquares, equals(500));
      expect([10.0, 20.0, 30.0].sumSquares, equals(1400));
    });

    test('square', () {
      expect(<double>[].square, isEmpty);
      expect([0.0].square, equals([0]));
      expect([10.0].square, equals([100]));
      expect([10.0, 20.0].square, equals([100, 400]));
      expect([10.0, 20.0, 30.0].square, equals([100, 400, 900]));
    });

    test('squaresMean', () {
      expect(<double>[].squaresMean, isNaN);
      expect([0.0].squaresMean, equals(0));
      expect([10.0].squaresMean, equals(100));
      expect([10.0, 20.0].squaresMean, equals(250));
      expect([10.0, 20.0, 30.0].squaresMean, equals(466.6666666666667));
    });

    test('standardDeviation', () {
      expect(<double>[].standardDeviation, equals(0));
      expect([0.0].standardDeviation, equals(0));
      expect([10.0].standardDeviation, equals(10));
      expect([10.0, 20.0].standardDeviation, equals(7.905694150420948));
      expect([10.0, 20.0, 30.0].standardDeviation, equals(8.16496580927726));
    });

    test('abs', () {
      expect(<double>[].abs, isEmpty);
      expect([0.0].abs, equals([0]));
      expect([10.0].abs, equals([10]));
      expect([-10.0, 20.0].abs, equals([10, 20]));
      expect([10.0, -20.0, 30.0].abs, equals([10, 20, 30]));
    });

    test('movingAverage', () {
      expect(<double>[].movingAverage(2), isEmpty);
      expect([0.0].movingAverage(2), equals([0]));
      expect([10.0].movingAverage(3), equals([10]));
      expect([-10.0, 20.0].movingAverage(3), equals([5.0]));
      expect([10.0, -20.0, 30.0].movingAverage(3), equals([6.666666666666667]));
      expect([10.0, -20.0, 30.0, 40.0, 50.0, 60.0].movingAverage(3),
          equals([6.666666666666667, 16.666666666666668, 40.0, 50.0]));
    });

    test('operator +', () {
      expect(<double>[] + <double>[], isEmpty);
      expect([10.0] + <double>[20], equals([10, 20]));
      expect([100.0, 200.0] + <double>[10, 20], equals([100, 200, 10, 20]));
    });

    test('operator -', () {
      expect(<double>[] - <int>[], isEmpty);
      expect(<double>[10] - <int>[20], equals([-10]));
      expect(<double>[100, 200] - <int>[10, 20], equals([90, 180]));
      expect(<double>[100, 200, 300] - <int>[10, 20], equals([90, 180]));
      expect(
          [100.0, 200.0, 300.0] - [10.0, 20.0, 30.0], equals([90, 180, 270]));
    });

    test('operator *', () {
      expect(<double>[] * <int>[], isEmpty);
      expect(<double>[10] * <int>[20], equals([200]));
      expect(<double>[100, 200] * <int>[10, 20], equals([1000, 4000]));
      expect(<double>[100, 200, 300] * <int>[10, 20], equals([1000, 4000]));
      expect(<double>[100, 200, 300] * <int>[10, 20, 30],
          equals([1000, 4000, 9000]));
    });

    test('operator /', () {
      expect(<double>[] / <int>[], isEmpty);
      expect(<double>[10] / <int>[20], equals([0.5]));
      expect(<double>[100, 200] / <int>[10, 20], equals([10, 10]));
      expect(<double>[100, 200, 300] / <int>[10, 20], equals([10, 10]));
      expect(<double>[100, 200, 300] / <int>[10, 20, 30], equals([10, 10, 10]));
      expect(<double>[100, 200, 300] / <int>[40, 50, 30], equals([2.5, 4, 10]));
    });

    test('operator ~/', () {
      expect(<double>[] ~/ <int>[], isEmpty);
      expect(<double>[10] ~/ <int>[20], equals([0]));
      expect(<double>[100, 200] ~/ <int>[10, 20], equals([10, 10]));
      expect(<double>[100, 200, 300] ~/ <int>[10, 20], equals([10, 10]));
      expect(
          <double>[100, 200, 300] ~/ <int>[10, 20, 30], equals([10, 10, 10]));
      expect(<double>[100, 200, 300] ~/ <int>[40, 50, 30], equals([2, 4, 10]));
    });
  });

  group('num', () {
    setUp(() {});

    test('mean', () {
      expect(<num>[].mean, isNaN);
      expect(<num>[0.0].mean, equals(0));
      expect(<num>[10.0].mean, equals(10));
      expect([10, 20.0].mean, equals(15));
      expect([10.0, 20, 30.0].mean, equals(20));
    });

    test('sum', () {
      expect(<num>[].sum, equals(0));
      expect(<num>[0.0].sum, equals(0));
      expect(<num>[10.0].sum, equals(10));
      expect([10, 20.0].sum, equals(30));
      expect([10.0, 20, 30.0].sum, equals(60));
    });

    test('sumSquares', () {
      expect(<num>[].sumSquares, equals(0));
      expect(<num>[0.0].sumSquares, equals(0));
      expect(<num>[10.0].sumSquares, equals(100));
      expect([10.0, 20].sumSquares, equals(500));
      expect([10.0, 20.0, 30].sumSquares, equals(1400));
    });

    test('square', () {
      expect(<num>[].square, isEmpty);
      expect(<num>[0.0].square, equals([0]));
      expect(<num>[10.0].square, equals([100]));
      expect([10, 20.0].square, equals([100, 400]));
      expect([10.0, 20, 30.0].square, equals([100, 400, 900]));
    });

    test('squaresMean', () {
      expect(<num>[].squaresMean, isNaN);
      expect(<num>[0.0].squaresMean, equals(0));
      expect(<num>[10].squaresMean, equals(100));
      expect([10, 20.0].squaresMean, equals(250));
      expect([10, 20.0, 30].squaresMean, equals(466.6666666666667));
    });

    test('standardDeviation', () {
      expect(<num>[].standardDeviation, equals(0));
      expect(<num>[0.0].standardDeviation, equals(0));
      expect(<num>[10].standardDeviation, equals(10));
      expect([10, 20.0].standardDeviation, equals(7.905694150420948));
      expect([10.0, 20, 30.0].standardDeviation, equals(8.16496580927726));
    });

    test('abs', () {
      expect(<num>[].abs, isEmpty);
      expect(<num>[0.0].abs, equals([0]));
      expect(<num>[10.0].abs, equals([10]));
      expect(<num>[-10.0, 20.0].abs, equals([10, 20]));
      expect(<num>[10.0, -20.0, 30.0].abs, equals([10, 20, 30]));
    });

    test('movingAverage', () {
      expect(<num>[].movingAverage(2), isEmpty);
      expect(<num>[0.0].movingAverage(2), equals([0]));
      expect(<num>[10.0].movingAverage(3), equals([10]));
      expect([-10, 20.0].movingAverage(3), equals([5.0]));
      expect([10.0, -20, 30.0].movingAverage(3), equals([6.666666666666667]));
      expect([10.0, -20, 30.0, 40.0, 50, 60.0].movingAverage(3),
          equals([6.666666666666667, 16.666666666666668, 40.0, 50.0]));
    });

    test('operator +', () {
      expect(<num>[] + <double>[], isEmpty);
      expect(<num>[10.0] + <double>[20], equals([10, 20]));
      expect([100, 200.0] + <double>[10, 20], equals([100, 200, 10, 20]));
    });

    test('operator -', () {
      expect(<num>[] - <int>[], isEmpty);
      expect(<num>[10] - <int>[20], equals([-10]));
      expect(<num>[100, 200] - <int>[10, 20], equals([90, 180]));
      expect(<num>[100, 200, 300] - <int>[10, 20], equals([90, 180]));
      expect([100, 200.0, 300.0] - [10.0, 20.0, 30.0], equals([90, 180, 270]));
    });

    test('operator *', () {
      expect(<num>[] * <int>[], isEmpty);
      expect(<num>[10] * <int>[20], equals([200]));
      expect(<num>[100, 200] * <int>[10, 20], equals([1000, 4000]));
      expect(<num>[100, 200, 300] * <int>[10, 20], equals([1000, 4000]));
      expect(
          <num>[100, 200, 300] * <int>[10, 20, 30], equals([1000, 4000, 9000]));
    });

    test('operator /', () {
      expect(<num>[] / <int>[], isEmpty);
      expect(<num>[10] / <int>[20], equals([0.5]));
      expect(<num>[100, 200] / <int>[10, 20], equals([10, 10]));
      expect(<num>[100, 200, 300] / <int>[10, 20], equals([10, 10]));
      expect(<num>[100, 200, 300] / <int>[10, 20, 30], equals([10, 10, 10]));
      expect(<num>[100, 200, 300] / <int>[40, 50, 30], equals([2.5, 4, 10]));
    });

    test('operator ~/', () {
      expect(<num>[] ~/ <int>[], isEmpty);
      expect(<num>[10] ~/ <int>[20], equals([0]));
      expect(<num>[100, 200] ~/ <int>[10, 20], equals([10, 10]));
      expect(<num>[100, 200, 300] ~/ <int>[10, 20], equals([10, 10]));
      expect(<num>[100, 200, 300] ~/ <int>[10, 20, 30], equals([10, 10, 10]));
      expect(<num>[100, 200, 300] ~/ <int>[40, 50, 30], equals([2, 4, 10]));
    });
  });
}
