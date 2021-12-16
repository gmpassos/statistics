@Tags(['num'])
import 'dart:typed_data';

import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('int', () {
    setUp(() {});

    test('toBigInt', () {
      expect(123.toBigInt(), equals(BigInt.from(123)));
      expect(-123.toBigInt(), equals(BigInt.from(-123)));
    });

    test('bits', () {
      expect(123.bits, equals('1111011'));
      expect(123.bits8, equals('01111011'));
      expect(123.bitsPadded(11), equals('00001111011'));
      expect(123.bits16, equals('0000000001111011'));
      expect(123.bits32, equals('00000000000000000000000001111011'));
      expect(
          123.bits64,
          equals(
              '0000000000000000000000000000000000000000000000000000000001111011'));
    });

    test('thousands', () {
      expect(123.thousands, equals('123'));
      expect(1123.thousands, equals('1,123'));
      expect(1123456.thousands, equals('1,123,456'));

      expect((-123).thousands, equals('-123'));
      expect((-1123).thousands, equals('-1,123'));
      expect((-1123456).thousands, equals('-1,123,456'));
    });

    test('toUint8List32/64', () {
      expect(123.toUint8List32(), equals(Uint8List.fromList([0, 0, 0, 123])));
      expect((-123).toUint8List32(),
          equals(Uint8List.fromList([255, 255, 255, 133])));

      expect(123.toUint8List32Reversed(),
          equals(Uint8List.fromList([123, 0, 0, 0])));
      expect((-123).toUint8List32Reversed(),
          equals(Uint8List.fromList([133, 255, 255, 255])));

      expect((0xFFFFFFFF), equals(4294967295));

      expect((0xFFFFFFFF).toUint8List32(),
          equals(Uint8List.fromList([255, 255, 255, 255])));

      expect((-123).toUint8List64(),
          equals(Uint8List.fromList([255, 255, 255, 255, 255, 255, 255, 133])));

      expect((-123).toUint8List64Reversed(),
          equals(Uint8List.fromList([133, 255, 255, 255, 255, 255, 255, 255])));

      expect(int.parse('000000FDFCFBFAF9', radix: 16).toUint8List64(),
          equals(Uint8List.fromList([0, 0, 0, 253, 252, 251, 250, 249])));

      expect(int.parse('0000FEFDFCFBFAF9', radix: 16).toUint8List64(),
          equals(Uint8List.fromList([0, 0, 254, 253, 252, 251, 250, 249])));
    });

    test('toHex32', () {
      expect(1.toHex32(), equals('00000001'));
      expect((-1).toHex32(), equals('FFFFFFFF'));

      expect(123.toHex32(), equals('0000007B'));
      expect((-123).toHex32(), equals('FFFFFF85'));
    });

    test('toHex64', () {
      expect(123.toHex64(), equals('000000000000007B'));
      expect((-123).toHex64(), equals('FFFFFFFFFFFFFF85'));
    });

    test('toHex64', () {
      expect(123.toStringPadded(4), equals('0123'));
      expect(123.toStringPadded(1), equals('123'));
      expect(123.toStringPadded(6), equals('000123'));
      expect((-123).toStringPadded(6), equals('-000123'));
    });

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

    test('mapToSet', () {
      expect(<int>[].mapToSet((n) => n), equals(<num>{}));
      expect(<int>[10, 20].mapToSet((n) => n), equals({10, 20}));
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

    test('statistics', () {
      expect(<int>[10, 20, 30].statistics.mean, equals(20));
      expect(<int>[10, 20, 30].statisticsWithData.data, equals([10, 20, 30]));
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

    test('to...()', () {
      var bigInt1 = 1.toBigInt();
      var bigIntN1 = (-1).toBigInt();
      var bigInt123 = 123.toBigInt();
      var bigIntN123 = (-123).toBigInt();

      expect(bigInt1, equals(BigInt.from(1)));
      expect(bigIntN1, equals(BigInt.from(-1)));

      expect(bigInt123, equals(BigInt.from(123)));
      expect(bigIntN123, equals(BigInt.from(-123)));

      expect(bigInt1.toHex(), equals('1'));
      expect(bigIntN1.toHex(), equals('-1'));
      expect(bigInt1.toHex(width: 2), equals('01'));
      expect(bigIntN1.toHex(width: 2), equals('-01'));

      expect(bigInt123.toHex(), equals('7B'));
      expect(bigIntN123.toHex(), equals('-7B'));
      expect(bigInt123.toHex(width: 4), equals('007B'));
      expect(bigIntN123.toHex(width: 4), equals('-007B'));

      expect(bigInt1.toHexUnsigned(), equals('1'));
      expect(bigIntN1.toHexUnsigned(), equals('FF'));
      expect(bigInt1.toHexUnsigned(width: 2), equals('01'));
      expect(bigIntN1.toHexUnsigned(width: 2), equals('FF'));

      expect(bigInt123.toHexUnsigned(), equals('7B'));
      expect(bigIntN123.toHexUnsigned(), equals('85'));
      expect(bigInt123.toHexUnsigned(width: 4), equals('007B'));
      expect(bigIntN123.toHexUnsigned(width: 4), equals('FF85'));

      expect(bigInt1.toHex32(), equals('00000001'));
      expect(bigIntN1.toHex32(), equals('FFFFFFFF'));

      expect(bigInt123.toHex32(), equals('0000007B'));
      expect(bigIntN123.toHex32(), equals('FFFFFF85'));

      expect(bigInt123.toHex64(), equals('000000000000007B'));
      expect(bigIntN123.toHex64(), equals('FFFFFFFFFFFFFF85'));

      expect(bigInt1.toUint8List32(), equals([0, 0, 0, 1]));
      expect(bigIntN1.toUint8List32(), equals([255, 255, 255, 255]));

      expect(bigInt123.toUint8List32(), equals([0, 0, 0, 123]));
      expect(bigIntN123.toUint8List32(), equals([255, 255, 255, 133]));

      expect(bigInt1.toUint8List64(), equals([0, 0, 0, 0, 0, 0, 0, 1]));
      expect(bigIntN1.toUint8List64(),
          equals([255, 255, 255, 255, 255, 255, 255, 255]));

      expect(bigInt123.toUint8List64(), equals([0, 0, 0, 0, 0, 0, 0, 123]));
      expect(bigIntN123.toUint8List64(),
          equals([255, 255, 255, 255, 255, 255, 255, 133]));
    });
  });

  group('double', () {
    setUp(() {});

    test('toPercentage', () {
      expect(0.1122.toPercentage(), equals('11.22%'));
      expect(0.1122.toPercentage(suffix: ' pct'), equals('11.22 pct'));

      expect(0.11.toPercentage(fractionDigits: 0), equals('11%'));
      expect(0.1122.toPercentage(fractionDigits: 0), equals('11%'));

      expect(1.1122.toPercentage(), equals('111.22%'));
      expect(1.1122.toPercentage(fractionDigits: 0), equals('111%'));
    });

    test('ifNaN', () {
      expect(10.0.ifNaN(11), equals(10));
      expect(double.nan.ifNaN(11), equals(11));
    });

    test('ifInfinite', () {
      expect(10.0.ifInfinite(11), equals(10));
      expect(double.infinity.ifInfinite(11), equals(11));
      expect(double.negativeInfinity.ifInfinite(11), equals(11));
    });

    test('ifNotFinite', () {
      expect(10.0.ifNotFinite(11), equals(10));
      expect(double.nan.ifNotFinite(11), equals(11));
      expect(double.infinity.ifNotFinite(11), equals(11));
      expect(double.negativeInfinity.ifNotFinite(11), equals(11));
    });

    test('naturalExponent', () {
      expect(10.0.naturalExponent, equals(22026.465794806718));
      expect(10.naturalExponent, equals(22026.465794806718));
      expect(_asNum(10).naturalExponent, equals(22026.465794806718));
    });

    test('naturalExponent', () {
      expect(10.0.truncate(), equals(10));
      expect(10.10.truncate(), equals(10));

      expect(10.12345.truncateDecimals(2), equals(10.12));
      expect(10.12345.truncateDecimals(1), equals(10.1));
      expect(10.12345.truncateDecimals(0), equals(10.0));

      expect(10.naturalExponent, equals(22026.465794806718));
      expect(_asNum(10).naturalExponent, equals(22026.465794806718));
    });

    test('toIntsList', () {
      expect(<double>[].toIntsList(), isEmpty);
      expect(<double>[].toIntsList(), isEmpty);
      expect(<double>[10.10].toIntsList(), equals([10]));
      expect(<double>[10, 20.20].toIntsList(), equals([10, 20]));
    });

    test('toDoublesList', () {
      expect(<double>[].toDoublesList(), isEmpty);
      expect(<double>[].toDoublesList(), isEmpty);
      expect(<double>[10.10].toDoublesList(), equals([10.10]));
      expect(<double>[10.0, 20.20].toDoublesList(), equals([10.0, 20.20]));
    });

    test('toStringsList', () {
      expect(<double>[].toStringsList(), isEmpty);
      expect(<double>[].toStringsList(), isEmpty);
      expect(<double>[10.1].toStringsList(), equals(['10.1']));
      expect(<double>[10.1, 20.2].toStringsList(), equals(['10.1', '20.2']));
    });

    test('mapToSet', () {
      expect(<double>[].mapToSet((n) => n), equals(<num>{}));
      expect(<double>[10, 20].mapToSet((n) => n), equals({10, 20}));
    });

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

      expect(10.0.square, equals(100));
    });

    test('squareRoot', () {
      expect(<double>[].squareRoot, isEmpty);
      expect([0.0].squareRoot, equals([0]));
      expect([9.0].squareRoot, equals([3]));
      expect([100.0, 121.0].squareRoot, equals([10, 11]));
      expect([10000.0, 400.0, 900.0].squareRoot, equals([100, 20, 30]));

      expect(100.0.squareRoot, equals(10));
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

    test('median', () {
      expect(<double>[].median, isNull);
      expect([0.0].median, equals(0));
      expect([10.0].median, equals(10));
      expect([10.0, 20.0].median, equals(15));
      expect([10.0, 20.0, 30.0].median, equals(20));
      expect([30.0, 20.0, 10.0].median, equals(20));
      expect([5.0, 10.0, 20.0, 30.0].median, equals(15));
      expect([30.0, 20.0, 10.0, 5.0].median, equals(15));
    });

    test('medianLow', () {
      expect(<double>[].medianLow, isNull);
      expect([0.0].medianLow, equals(0));
      expect([10.0].medianLow, equals(10));
      expect([10.0, 20.0].medianLow, equals(10));
      expect([10.0, 20.0, 30.0].medianLow, equals(20));
      expect([30.0, 20.0, 10.0].medianLow, equals(20));
      expect([5.0, 10.0, 20.0, 30.0].medianLow, equals(10));
      expect([30.0, 20.0, 10.0, 5.0].medianLow, equals(10));
    });

    test('medianHigh', () {
      expect(<double>[].medianHigh, isNull);
      expect([0.0].medianHigh, equals(0));
      expect([10.0].medianHigh, equals(10));
      expect([10.0, 20.0].medianHigh, equals(20));
      expect([10.0, 20.0, 30.0].medianHigh, equals(20));
      expect([30.0, 20.0, 10.0].medianHigh, equals(20));
      expect([5.0, 10.0, 20.0, 30].medianHigh, equals(20));
      expect([30.0, 20.0, 10.0, 5].medianHigh, equals(20));
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

    test('statistics', () {
      expect(<double>[10, 20, 30].statistics.mean, equals(20));
      expect(
          <double>[10, 20, 30].statisticsWithData.data, equals([10, 20, 30]));
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

    test('isSorted', () {
      expect(<double>[].isSorted, isFalse);

      expect(<double>[0.0].isSorted, isTrue);
      expect(<double>[10.0].isSorted, isTrue);
      expect(<double>[-10.0, 20.0].isSorted, isTrue);
      expect(<double>[10.0, 20.0, 30.0].isSorted, isTrue);

      expect(<double>[10.0, 5.0].isSorted, isFalse);
      expect(<double>[10.0, 200.0, 30.0].isSorted, isFalse);
    });

    test('equalsValues', () {
      expect(<double>[].equalsValues([]), isTrue);
      expect(<double>[].equalsValues([10]), isFalse);

      expect(<double>[10.0].equalsValues([10]), isTrue);
      expect(<double>[10.0].equalsValues([10.0], tolerance: 0.000001), isTrue);
      expect(<double>[10.0].equalsValues([10.0001]), isFalse);
      expect(<double>[10.0].equalsValues([10.0], tolerance: 0.01), isTrue);
      expect(<double>[10.0].equalsValues([10.0001], tolerance: 0.01), isTrue);
      expect(
          <double>[10.0].equalsValues([10.0001], tolerance: 0.000001), isFalse);

      expect(
          <double>[10.0, 20].equalsValues([10.0001, 20.001], tolerance: 0.01),
          isTrue);
      expect(<double>[10.0, 20].equalsValues([10.0001, 20.1], tolerance: 0.01),
          isFalse);
    });

    test('equalsValues', () {
      expect(10.0.signWithZeroTolerance(), equals(1));
      expect(-10.0.signWithZeroTolerance(), equals(-1));
      expect(0.0.signWithZeroTolerance(), equals(0));

      expect(0.01.signWithZeroTolerance(0.001), equals(1));
      expect(-0.01.signWithZeroTolerance(0.001), equals(-1));
      expect(0.01.signWithZeroTolerance(0.1), equals(0));
      expect(-0.01.signWithZeroTolerance(0.1), equals(0));
    });
  });

  group('num', () {
    setUp(() {});

    test('toIntsList', () {
      expect(<num>[].toIntsList(), isEmpty);
      expect(<num>[].toIntsList(), isEmpty);
      expect(<num>[10].toIntsList(), equals([10]));
      expect(<num>[10, 20.20].toIntsList(), equals([10, 20]));
    });

    test('toDoublesList', () {
      expect(<num>[].toDoublesList(), isEmpty);
      expect(<num>[].toDoublesList(), isEmpty);
      expect(<num>[10].toDoublesList(), equals([10.0]));
      expect(<num>[10, 20.20].toDoublesList(), equals([10.0, 20.20]));
    });

    test('toStringsList', () {
      expect(<num>[].toStringsList(), isEmpty);
      expect(<num>[].toStringsList(), isEmpty);
      expect(<num>[10].toStringsList(), equals(['10']));
      expect(<num>[10, 20.20].toStringsList(), equals(['10', '20.2']));
    });

    test('mapToSet', () {
      expect(<num>[].mapToSet((n) => n), equals(<num>{}));
      expect(<num>[10, 20].mapToSet((n) => n), equals({10, 20}));
    });

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

      expect(_asNum(10).square, equals(100));
    });

    test('squareRoot', () {
      expect(<num>[].squareRoot, isEmpty);
      expect(<num>[0.0].squareRoot, equals([0]));
      expect(<num>[9.0].squareRoot, equals([3]));
      expect([100, 121.0].squareRoot, equals([10, 11]));
      expect([10000, 400.0, 900.0].squareRoot, equals([100, 20, 30]));

      expect(_asNum(100).squareRoot, equals(10));
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

    test('median', () {
      expect(<num>[].median, isNull);
      expect(<num>[0.0].median, equals(0));
      expect(<num>[10.0].median, equals(10));
      expect([10.0, 20].median, equals(15));
      expect([10.0, 20, 30.0].median, equals(20));
      expect([30.0, 20.0, 10].median, equals(20));
      expect([5.0, 10, 20, 30].median, equals(15));
      expect([30.0, 20, 10.0, 5].median, equals(15));
    });

    test('medianLow', () {
      expect(<num>[].medianLow, isNull);
      expect(<num>[0.0].medianLow, equals(0));
      expect(<num>[10.0].medianLow, equals(10));
      expect([10.0, 20].medianLow, equals(10));
      expect([10.0, 20, 30].medianLow, equals(20));
      expect([30.0, 20, 10].medianLow, equals(20));
      expect([5.0, 10, 20, 30].medianLow, equals(10));
      expect([30.0, 20, 10, 5].medianLow, equals(10));
    });

    test('medianHigh', () {
      expect(<double>[].medianHigh, isNull);
      expect(<num>[0.0].medianHigh, equals(0));
      expect(<num>[10.0].medianHigh, equals(10));
      expect([10, 20.0].medianHigh, equals(20));
      expect([10, 20.0, 30].medianHigh, equals(20));
      expect([30, 20.0, 10].medianHigh, equals(20));
      expect([5, 10.0, 20, 30].medianHigh, equals(20));
      expect([30, 20.0, 10, 5].medianHigh, equals(20));
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

    test('statistics', () {
      expect(<num>[10, 20, 30].statistics.mean, equals(20));
      expect(<num>[10, 20, 30].statisticsWithData.data, equals([10, 20, 30]));
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

    test('isSorted', () {
      expect(<num>[].isSorted, isFalse);

      expect(<num>[0.0].isSorted, isTrue);
      expect(<num>[10.0].isSorted, isTrue);
      expect(<num>[-10.0, 20.0].isSorted, isTrue);
      expect(<num>[10.0, 20.0, 30.0].isSorted, isTrue);

      expect(<num>[10.0, 5.0].isSorted, isFalse);
      expect(<num>[10.0, 200.0, 30.0].isSorted, isFalse);
    });

    test('equalsValues', () {
      expect(<num>[].equalsValues([]), isTrue);
      expect(<num>[].equalsValues([10]), isFalse);

      expect(<num>[10.0].equalsValues([10]), isTrue);
      expect(<num>[10.0].equalsValues([10.0], tolerance: 0.000001), isTrue);
      expect(<num>[10.0].equalsValues([10.0001]), isFalse);
      expect(<num>[10.0].equalsValues([10.0], tolerance: 0.01), isTrue);
      expect(<num>[10.0].equalsValues([10.0001], tolerance: 0.01), isTrue);
      expect(<num>[10.0].equalsValues([10.0001], tolerance: 0.000001), isFalse);

      expect(<num>[10.0, 20].equalsValues([10.0001, 20.001], tolerance: 0.01),
          isTrue);
      expect(<num>[10.0, 20].equalsValues([10.0001, 20.1], tolerance: 0.01),
          isFalse);
    });

    test('equalsValues', () {
      expect(_asNum(10.0).signWithZeroTolerance(), equals(1));
      expect(_asNum(-10.0).signWithZeroTolerance(), equals(-1));
      expect(_asNum(0.0).signWithZeroTolerance(), equals(0));

      expect(_asNum(0.01).signWithZeroTolerance(0.001), equals(1));
      expect(_asNum(-0.01).signWithZeroTolerance(0.001), equals(-1));
      expect(_asNum(0.01).signWithZeroTolerance(0.1), equals(0));
      expect(_asNum(-0.01).signWithZeroTolerance(0.1), equals(0));
    });
  });

  group('N', () {
    setUp(() {});

    test('toIntsList', () {
      f<N extends num>(List<N> l) {
        expect(l, isNotEmpty);
        expect(l.toIntsList(), isNotEmpty);
        expect(l.toDoublesList(), isNotEmpty);
        expect(l.toStringsList(), isNotEmpty);

        expect(l.asInts(), equals(l.toIntsList()));
        expect(l.asDoubles(), equals(l.toDoublesList()));
      }

      f(<int>[10, 20]);
      f(<double>[10.0, 20.20]);
      f(<num>[10, 20.20]);
    });

    test('castElement', () {
      f<N extends num>(List<N> l) {
        var element = l.castElement(l.castsToDouble ? 1.1 : 1);
        // ignore: unnecessary_type_check
        expect(element is N, isTrue);

        if (N != num) {
          expect(element.runtimeType, equals(N),
              reason: 'Value: $element ; Type: ${element.runtimeType} != $N');
        }
      }

      f(<int>[10, 20]);
      f(<double>[10.1, 20.20]);
      f(<num>[10, 20.20]);
    });
  });

  group('Numeric String', () {
    setUp(() {});

    test('to...()', () {
      expect('123'.toInt(), equals(123));
      expect('123.4'.toDouble(), equals(123.4));

      expect('123'.toNum(), equals(123));
      expect('123.4'.toNum(), equals(123.4));

      expect('123'.toBigInt(), equals(BigInt.from(123)));
      expect('-123'.toBigInt(), equals(BigInt.from(-123)));

      expect('01'.toBigIntFromHex(), equals(BigInt.from(1)));
      expect('FF'.toBigIntFromHex(), equals(BigInt.from(255)));

      expect('000001'.toBigIntFromHex(), equals(BigInt.from(1)));
      expect('0000FF'.toBigIntFromHex(), equals(BigInt.from(255)));

      expect('0102'.toBigIntFromHex(), equals(BigInt.from(258)));
      expect('FFFF'.toBigIntFromHex(), equals(BigInt.from(65535)));

      expect('FFFFFFFF'.toBigIntFromHex(), equals(BigInt.from(4294967295)));

      expect('FFFFFFFFFFFFFFFF'.toBigIntFromHex(),
          equals(BigInt.parse('18446744073709551615')));

      expect('FFFFFFFFFFFFFFFFFFFF'.toBigIntFromHex(),
          equals(BigInt.parse('1208925819614629174706175')));

      expect('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'.toBigIntFromHex(),
          equals(BigInt.parse('340282366920938463463374607431768211455')));
    });
  });

  group('Numeric Uint8List', () {
    setUp(() {});

    test('equals', () {
      expect(
          Uint8List.fromList([0, 0, 0, 123])
              .equals(Uint8List.fromList([0, 0, 0, 123])),
          isTrue);

      expect(
          Uint8List.fromList([1, 10, 20, 30]).copy(), equals([1, 10, 20, 30]));

      expect(Uint8List.fromList([1, 10, 20, 30]).copyAsUnmodifiable(),
          equals([1, 10, 20, 30]));

      expect(() => Uint8List.fromList([1, 2, 3]).copy()..[0] = 10,
          returnsNormally);

      expect(() => Uint8List.fromList([1, 2, 3]).copyAsUnmodifiable()..[0] = 10,
          throwsA(isA<Error>()));

      expect(() => Uint8List.fromList([1, 2, 3]).asUnmodifiableView..[0] = 10,
          throwsA(isA<Error>()));

      expect(Uint8List.fromList([1, 10, 20, 30]).bytesHashCode(),
          equals(1176475097));

      expect(Uint8List.fromList([1, 10, 20, 30]).reverseBytes(),
          equals([30, 20, 10, 1]));

      expect(Uint8List.fromList([65, 66, 67, 68]).toStringLatin1(),
          equals('ABCD'));

      expect(Uint8List.fromList([226, 130, 172]).toStringUTF8(), equals('€'));

      expect(
          Uint8List.fromList([0, 0, 0, 123])
              .equals(Uint8List.fromList([0, 0, 1, 123])),
          isFalse);

      expect(Uint8List.fromList([0, 0, 0, 123, 0, 0, 0, 123]).subView(2, 4),
          equals([0, 123, 0, 0]));

      expect(Uint8List.fromList([0, 0, 0, 123, 0, 0, 0, 123]).subView(3),
          equals([123, 0, 0, 0, 123]));

      expect(Uint8List.fromList([0, 0, 0, 123, 0, 1, 2, 3, 4]).subViewTail(4),
          equals([1, 2, 3, 4]));

      expect(Uint8List.fromList([0, 0, 0, 123]).toHexBigEndian(),
          equals('0000007B'));

      expect(Uint8List.fromList([0, 0, 0, 123]).toHexLittleEndian(),
          equals('7B000000'));

      expect(Uint8List.fromList([0, 0, 0, 123]).toBigInt(),
          equals(BigInt.parse('123')));

      expect(Uint8List.fromList([0, 0, 0, 123]).toBigInt(endian: Endian.little),
          equals(BigInt.parse('2063597568')));

      expect(Uint8List.fromList([255, 255, 255, 255]).toBigInt(),
          equals(BigInt.parse('4294967295')));

      expect(Uint8List.fromList([32, 64]).bits, equals('0010000001000000'));

      expect(Uint8List.fromList([32, 64, 128, 255]).bits,
          equals('00100000010000001000000011111111'));

      expect(Uint8List.fromList([125]).bits8, equals('01111101'));

      expect(Uint8List.fromList([255, 128]).bits16, equals('1111111110000000'));

      expect(Uint8List.fromList([255, 128]).bits32,
          equals('00000000000000001111111110000000'));

      expect(
          Uint8List.fromList([255, 128]).bits64,
          equals(
              '0000000000000000000000000000000000000000000000001111111110000000'));

      expect(
          Uint8List.fromList([255, 255, 255, 255])
              .toBigInt(endian: Endian.little),
          equals(BigInt.parse('4294967295')));

      expect(
          Uint8List.fromList([255, 255, 255, 255, 255, 255, 255, 255])
              .toBigInt(),
          equals(BigInt.parse('18446744073709551615')));

      expect(Uint8List.fromList([255, 0, 0, 0, 0, 0, 0, 0]).toBigInt(),
          equals(BigInt.parse('18374686479671623680')));

      expect(Uint8List.fromList([1, 2, 3, 4]).getUint8(0), equals(1));
      expect(Uint8List.fromList([1, 2, 3, 4]).getUint8(1), equals(2));
      expect(Uint8List.fromList([1, 2, 3, 4]).getUint8(2), equals(3));

      expect(Uint8List.fromList([1, 2, 3, 4]).getUint16(0), equals(258));
      expect(Uint8List.fromList([1, 2, 3, 4]).getUint16(1), equals(515));

      expect(Uint8List.fromList([1, 2, 3, 4]).getUint32(0), equals(16909060));
      expect(
          Uint8List.fromList([1, 2, 3, 4, 0]).getUint32(1), equals(33752064));

      expect(
          Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7])
              .getUint64(0)
              .toString(),
          equals('1108152157446'));

      expect(
          Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8])
              .getUint64(1)
              .toString(),
          equals('283686952306183'));

      expect(
          Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8])
              .getInt8(4)
              .toString(),
          equals('3'));

      expect(
          Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8])
              .getInt16(4)
              .toString(),
          equals('772'));

      expect(
          Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8])
              .getInt32(4)
              .toString(),
          equals('50595078'));

      expect(
          Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8])
              .getInt64(1)
              .toString(),
          equals('283686952306183'));

      expect(Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]).toListOfUint8(),
          equals([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]));

      expect(
          Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]).toListOfUint16(),
          equals([0, 258, 772, 1286, 1800]));

      expect(
          Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]).toListOfUint32(),
          equals([258, 50595078]));

      expect(
          Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]).toListOfUint64(),
          equals([1108152157446]));

      //

      expect(Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]).toListOfInt8(),
          equals([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]));

      expect(Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]).toListOfInt16(),
          equals([0, 258, 772, 1286, 1800]));

      expect(Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]).toListOfInt32(),
          equals([258, 50595078]));

      expect(Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]).toListOfInt64(),
          equals([1108152157446]));

      //

      expect(Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]).toUint8List(),
          equals([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]));

      {
        var ns = [0, 0, 1, 2, 3, 4, 5, 6, 7, 8];
        var bs = Uint8List.fromList(ns);

        expect(bs.asUint8List, equals(bs));
        expect(bs.toUint8List(), equals(bs));

        expect(identical(bs.asUint8List, bs), isTrue);
        expect(identical(bs.toUint8List(), bs), isFalse);
      }

      expect(
          Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]).encodeUint8List(),
          equals([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]));

      expect(
          Uint8List.fromList([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]).encodeUint16List(),
          equals([0, 0, 0, 0, 0, 1, 0, 2, 0, 3, 0, 4, 0, 5, 0, 6, 0, 7, 0, 8]));

      expect(Uint8List.fromList([0, 1, 2]).encodeUint32List(),
          equals([0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 2]));

      expect(
          Uint8List.fromList([0, 1, 2]).encodeUint64List(),
          equals([
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            2
          ]));
    });
  });
}

num _asNum(num n) => n;
