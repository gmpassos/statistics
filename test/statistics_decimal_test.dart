@Tags(['num', 'decimal'])
import 'dart:math' as math;

import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('Decimal', () {
    setUp(() {});

    test('basic', () {
      expect(Decimal.parse('0.2').toString(), equals('0.2'));
      expect(Decimal.parse('123').toString(), equals('123.0'));

      expect(Decimal.tryParse(''), isNull);
      expect(Decimal.tryParse(' a.b '), isNull);
      expect(Decimal.tryParse(' e '), isNull);
      expect(Decimal.tryParse('0.2').toString(), equals('0.2'));
      expect(Decimal.tryParse('123').toString(), equals('123.0'));

      expect(Decimal.from(null), isNull);
      expect(Decimal.from(''), isNull);
      expect(Decimal.from(' a.b '), isNull);
      expect(Decimal.from(' e '), isNull);
      expect(Decimal.from(123).toString(), equals('123.0'));
      expect(Decimal.from(123.45).toString(), equals('123.45'));
      expect(Decimal.from('0.2').toString(), equals('0.2'));
      expect(Decimal.from('123').toString(), equals('123.0'));

      {
        var d = Decimal.parse('0.2');
        expect(d.precision, equals(1));
        expect(d.toString(), equals('0.2'));
        expect(d.isPositive, isTrue);
        expect(d.isNegative, isFalse);
        expect(d.isBigInt, isFalse);
        expect(d.isSafeInteger, isFalse);
        expect(d.abs().toString(), equals('0.2'));
        expect(d.toBigInt().toString(), equals('0'));
      }

      {
        var d = Decimal.parse('-0.2');
        expect(d.precision, equals(1));
        expect(d.toString(), equals('-0.2'));
        expect(d.isPositive, isFalse);
        expect(d.isNegative, isTrue);
        expect(d.isBigInt, isFalse);
        expect(d.isSafeInteger, isFalse);
        expect(d.abs().toString(), equals('0.2'));
        expect(d.toBigInt().toString(), equals('0'));
      }

      {
        var d = Decimal.parse('1.2');
        expect(d.precision, equals(1));
        expect(d.toString(), equals('1.2'));
        expect(d.isPositive, isTrue);
        expect(d.isNegative, isFalse);
        expect(d.isBigInt, isFalse);
        expect(d.isSafeInteger, isFalse);
        expect(d.toBigInt().toString(), equals('1'));
      }

      {
        var d = Decimal.parse('-1.2');
        expect(d.precision, equals(1));
        expect(d.toString(), equals('-1.2'));
        expect(d.isPositive, isFalse);
        expect(d.isNegative, isTrue);
        expect(d.isBigInt, isFalse);
        expect(d.isSafeInteger, isFalse);
        expect(d.toBigInt().toString(), equals('-1'));
      }

      {
        var d = Decimal.parse('0');
        expect(d.precision, equals(0));
        expect(d.toString(), equals('0.0'));
        expect(d.isPositive, isFalse);
        expect(d.isNegative, isFalse);
        expect(d.isBigInt, isFalse);
        expect(d.isSafeInteger, isFalse);
      }

      expect(() => Decimal.parse('0.2', precision: -1), throwsArgumentError);

      expect((Decimal.parse('0.2') + Decimal.parse('0.1')).toString(),
          equals('0.3'));

      expect(
          (Decimal.parse('0.2') + Decimal.parse('0.1')).toString(compact: true),
          equals('0.3'));

      expect((Decimal.parse('0.22') + Decimal.parse('0.11')).toString(),
          equals('0.33'));

      expect(
          (Decimal.parse('0.22') + Decimal.parse('0.11'))
              .toString(compact: true),
          equals('0.33'));

      expect(Decimal.from('12345678901234567.890')?.precision, equals(3));

      expect(Decimal.from('12345678901234567890')?.hashCode,
          equals(BigInt.parse('12345678901234567890').hashCode));

      expect(Decimal.from('12345678901234567.890')?.hashCode,
          equals(BigInt.parse('12345678901234567890').hashCode ^ 3));

      expect(Decimal.from('-12345678901234567.890').toString(),
          equals('-12345678901234567.890'));

      expect(Decimal.from(DynamicInt.fromInt(123), precision: 2).toString(),
          equals('123.00'));

      expect(Decimal.from([1234, 567]).toString(), equals('1234.567'));
      expect(Decimal.from([-1234, 567]).toString(), equals('-1234.567'));

      expect(Decimal.from([1234, 567], precision: 2).toString(),
          equals('1234.56'));

      expect(Decimal.from([1234, 0.567]).toString(), equals('1234.567'));
      expect(Decimal.from([1234, -0.567]).toString(), equals('1234.567'));
      expect(Decimal.from([1234, 0.567], precision: 2).toString(),
          equals('1234.56'));

      expect(Decimal.from([1234, '567'], precision: 2).toString(),
          equals('1234.56'));

      expect(Decimal.fromDouble(1234567890123456.0).precision, equals(0));

      expect(Decimal.fromDouble(1234567890123456.0, precision: 2).precision,
          equals(2));

      expect(
          Decimal.fromDouble(1234567890123456.0, precision: 2)
              .compactedPrecision
              .precision,
          equals(0));

      expect(Decimal.fromDouble(1234567890123456.0, precision: 2).toString(),
          equals('1234567890123456.00'));

      expect(
          Decimal.fromDouble(1234567890123456.0, precision: 2)
              .toString(thousands: true),
          equals('1,234,567,890,123,456.00'));

      expect((Decimal.fromInt(32) << 1).toStringStandard(), equals('64'));
      expect(
          (Decimal.fromInt(32) << 24).toStringStandard(), equals('536870912'));
      expect((Decimal.fromInt(32) << 100).toStringStandard(),
          equals('40564819207303340847894502572032'));

      expect((Decimal.fromInt(32) >> 1).toStringStandard(), equals('16'));
      expect(
          (Decimal.fromInt(536870912) >> 24).toStringStandard(), equals('32'));
      expect(
          (Decimal.from('40564819207303340847894502572032')! >> 100)
              .toStringStandard(),
          equals('32'));

      expect((Decimal.fromInt(9007199254740991) >> 24).toStringStandard(),
          equals('536870911'));

      expect([10, 20, 30].toDecimalList().standardDeviation.toDouble(),
          equals(8.164965809277259));
    });

    test('equalsInt/BigInt', () {
      expect(Decimal.parse('1234567890').equalsInt(1234567890), isTrue);

      expect(Decimal.parse('12345', precision: 2).equalsInt(12345), isTrue);

      expect(
          Decimal.parse('12345678901234567890.00', precision: 2)
              .equalsInt(12345),
          isFalse);

      expect(Decimal.parse('1234567890', precision: 2).equalsInt(1234567890),
          isTrue);

      expect(Decimal.parse('1234567890.65', precision: 2).equalsInt(1234567890),
          isFalse);

      expect(
          Decimal.parse('123456789012345678901234567890.65', precision: 2)
              .equalsInt(123),
          isFalse);

      expect(
          Decimal.parse('123456789012345678901234567890.65', precision: 2)
              .equalsBigInt(BigInt.parse('123456789012345678901234567890')),
          isFalse);

      expect(
          Decimal.parse('123456789012345678901234567890.00', precision: 2)
              .equalsBigInt(BigInt.parse('123456789012345678901234567890')),
          isTrue);
    });

    test('withPrecision', () {
      expect(Decimal.parse('123456.123', precision: 2).toString(),
          equals('123456.12'));

      expect(
          Decimal.parse('123456.123', precision: 2).withPrecision(1).toString(),
          equals('123456.1'));

      expect(
          Decimal.parse('123456.123', precision: 2).withPrecision(3).toString(),
          equals('123456.120'));

      expect(
          Decimal.parse('123456.123', precision: 2).withPrecision(5).toString(),
          equals('123456.12000'));

      expect(
          Decimal.parse('123456.123', precision: 2)
              .withHigherPrecision(Decimal.parse('123456.123', precision: 3))
              .toString(),
          equals('123456.120'));

      expect(
          Decimal.parse('123456.123', precision: 2)
              .withLowerPrecision(Decimal.parse('123456.123', precision: 3))
              .toString(),
          equals('123456.12'));
    });

    test('higherPrecision/lowerPrecision', () {
      expect(
          Decimal.parse('123456.123', precision: 2)
              .higherPrecision(Decimal.parse('123456.123', precision: 3)),
          equals(3));

      expect(
          Decimal.parse('123456.123', precision: 0)
              .higherPrecision(Decimal.parse('123456.123', precision: 3)),
          equals(3));

      expect(
          Decimal.parse('123456.123', precision: 5)
              .higherPrecision(Decimal.parse('123456.123', precision: 3)),
          equals(5));

      expect(
          Decimal.parse('123456.123', precision: 2)
              .lowerPrecision(Decimal.parse('123456.123', precision: 3)),
          equals(2));

      expect(
          Decimal.parse('123456.123', precision: 0)
              .lowerPrecision(Decimal.parse('123456.123', precision: 3)),
          equals(0));

      expect(
          Decimal.parse('123456.123', precision: 4)
              .lowerPrecision(Decimal.parse('123456.123', precision: 3)),
          equals(3));
    });

    test('wholePartAsInt/Double/BigInt/String/Digits', () {
      expect(Decimal.parse('123456.123', precision: 2).wholePartAsInt,
          allOf(isA<int>(), equals(123456)));

      expect(Decimal.parse('123456.123', precision: 2).wholePartAsBigInt,
          allOf(isA<BigInt>(), equals(123456.toBigInt())));

      expect(Decimal.parse('-123456.123', precision: 2).wholePartAsBigInt,
          allOf(isA<BigInt>(), equals(-123456.toBigInt())));

      expect(Decimal.parse('123456.123', precision: 2).wholePartAsDouble,
          allOf(isA<double>(), equals(123456.0)));

      expect(Decimal.parse('-123456.123', precision: 2).wholePartAsDouble,
          allOf(isA<double>(), equals(-123456.0)));

      expect(Decimal.parse('123456.123', precision: 2).wholePartAsString,
          allOf(isA<String>(), equals('123456')));

      expect(Decimal.parse('-123456.123', precision: 2).wholePartAsString,
          allOf(isA<String>(), equals('-123456')));

      expect(Decimal.parse('0.123', precision: 2).wholePartDigits, equals(1));

      expect(Decimal.parse('1.123', precision: 2).wholePartDigits, equals(1));

      expect(Decimal.parse('10.123', precision: 2).wholePartDigits, equals(2));

      expect(Decimal.parse('12.123', precision: 2).wholePartDigits, equals(2));

      expect(Decimal.parse('100.123', precision: 2).wholePartDigits, equals(3));

      expect(Decimal.parse('123.123', precision: 2).wholePartDigits, equals(3));

      expect(
          Decimal.parse('1000.123', precision: 2).wholePartDigits, equals(4));

      expect(
          Decimal.parse('1234.123', precision: 2).wholePartDigits, equals(4));

      expect(
          Decimal.parse('10000.123', precision: 2).wholePartDigits, equals(5));

      expect(
          Decimal.parse('12345.123', precision: 2).wholePartDigits, equals(5));

      expect(
          Decimal.parse('123456.123', precision: 2).wholePartDigits, equals(6));

      expect(Decimal.parse('1234567890.123', precision: 2).wholePartDigits,
          equals(10));

      expect(Decimal.parse('12345678901.123', precision: 2).wholePartDigits,
          equals(11));

      expect(Decimal.parse('123456789012.123', precision: 2).wholePartDigits,
          equals(12));

      expect(
          Decimal.parse('1234567890123456789012345678901234567890.123456')
              .wholePartDigits,
          equals(40));

      expect(
          Decimal.parse('1234567890123456789012345678901234567890.123456',
                  precision: 2)
              .wholePartDigits,
          equals(40));
    });

    test('decimalPartAsString', () {
      expect(
          Decimal.parse('1234567890123456789012345678901234567890.654321')
              .decimalPartAsDouble,
          equals(0.654321));

      expect(
          Decimal.parse('1234567890123456789012345678901234567890.654321',
                  precision: 2)
              .decimalPartAsDouble,
          equals(0.65));

      expect(
          Decimal.parse('1234567890123456789012345678901234567890.654321')
              .decimalPartAsString,
          equals('654321'));

      expect(
          Decimal.parse('1234567890123456789012345678901234567890.654321',
                  precision: 2)
              .decimalPartAsString,
          equals('65'));
    });

    test('isZero', () {
      expect(Decimal.fromDouble(0.0, precision: 0).isZero, isTrue);
      expect(Decimal.fromDouble(0.1, precision: 0).isZero, isTrue);

      expect(Decimal.fromDouble(0.0, precision: 1).isZero, isTrue);
      expect(Decimal.fromDouble(0.1, precision: 1).isZero, isFalse);
      expect(Decimal.fromDouble(0.01, precision: 1).isZero, isTrue);

      expect(Decimal.fromDouble(0.0, precision: 2).isZero, isTrue);
      expect(Decimal.fromDouble(0.001, precision: 2).isZero, isTrue);
      expect(Decimal.fromDouble(0.01, precision: 2).isZero, isFalse);
    });

    test('isOne', () {
      expect(Decimal.fromDouble(1.0, precision: 0).isOne, isTrue);
      expect(Decimal.fromDouble(1.1, precision: 0).isOne, isTrue);

      expect(Decimal.fromDouble(1.0, precision: 1).isOne, isTrue);
      expect(Decimal.fromDouble(1.01, precision: 1).isOne, isTrue);
      expect(Decimal.fromDouble(1.1, precision: 1).isOne, isFalse);

      expect(Decimal.fromDouble(1.0, precision: 2).isOne, isTrue);
      expect(Decimal.fromDouble(1.01, precision: 2).isOne, isFalse);
    });

    test('precision', () {
      expect(Decimal.fromNum(10).precision, equals(0));
      expect(Decimal.fromNum(10, precision: 2).precision, equals(2));

      expect(Decimal.fromNum(10.0).precision, equals(0));
      expect(Decimal.fromNum(10.0, precision: 2).precision, equals(2));
      expect(Decimal.fromNum(10.12).precision, equals(2));
      expect(Decimal.fromNum(10.123).precision, equals(3));
    });

    test('parse error', () {
      expect(Decimal.parse('11.22').toString(), equals('11.22'));
    });

    test('parse -> toString', () {
      expect(Decimal.parse('0').toString(), equals('0.0'));
      expect(Decimal.parse('1').toString(), equals('1.0'));
      expect(Decimal.parse('2').toString(), equals('2.0'));
      expect(Decimal.parse('10').toString(), equals('10.0'));
      expect(Decimal.parse('11').toString(), equals('11.0'));
      expect(Decimal.parse('123').toString(), equals('123.0'));

      expect(Decimal.parse('11.22').toString(), equals('11.22'));
      expect(Decimal.parse('11.2200').toString(), equals('11.2200'));
      expect(Decimal.parse('11.22', precision: 2).toString(), equals('11.22'));
      expect(Decimal.parse('11.22', precision: 1).toString(), equals('11.2'));
      expect(Decimal.parse('11.22', precision: 0).toString(), equals('11.0'));
      expect(Decimal.parse('11.22', precision: 0).withPrecision(3).toString(),
          equals('11.000'));

      expect(Decimal.parse('.22').toString(), equals('0.22'));
      expect(Decimal.parse('.22', precision: 4).toString(), equals('0.2200'));
      expect(Decimal.parse('.22', precision: 3).toString(), equals('0.220'));
      expect(Decimal.parse('000.22').toString(), equals('0.22'));

      expect(Decimal.parse('.02').toString(), equals('0.02'));
      expect(Decimal.parse('.02', precision: 3).toString(), equals('0.020'));
      expect(Decimal.parse('000.02').toString(), equals('0.02'));

      expect(Decimal.parse('-0.02').toString(), equals('-0.02'));
      expect(Decimal.parse('-0.02', precision: 3).toString(), equals('-0.020'));

      expect(Decimal.parse('-.2').toString(), equals('-0.2'));
      expect(Decimal.parse('-.2', precision: 4).toString(), equals('-0.2000'));
      expect(Decimal.parse('-.02').toString(), equals('-0.02'));
    });

    test('fromDouble -> toString', () {
      expect(Decimal.fromDouble(0.0).toString(), equals('0.0'));
      expect(Decimal.fromDouble(1.0).toString(), equals('1.0'));
      expect(Decimal.fromDouble(2.0).toString(), equals('2.0'));
      expect(Decimal.fromDouble(10.0).toString(), equals('10.0'));
      expect(Decimal.fromDouble(123.0).toString(), equals('123.0'));

      expect(
          Decimal.fromDouble(1.234, precision: 2).toString(), equals('1.23'));
      expect(
          Decimal.fromDouble(12.34, precision: 2).toString(), equals('12.34'));
      expect(
          Decimal.fromDouble(12.345, precision: 2).toString(), equals('12.34'));

      expect(
          Decimal.fromDouble(12.34, precision: 1).toString(), equals('12.3'));
      expect(
          Decimal.fromDouble(12.34, precision: 0).toString(), equals('12.0'));

      expect(Decimal.fromDouble(12.345, precision: 3).decimalPartAsDouble,
          equals(0.345));
      expect(Decimal.fromDouble(12.34, precision: 3).decimalPartAsDouble,
          equals(0.340));
      expect(Decimal.fromDouble(12.34, precision: 2).decimalPartAsDouble,
          equals(0.34));
      expect(Decimal.fromDouble(12.34, precision: 1).decimalPartAsDouble,
          equals(0.3));
      expect(Decimal.fromDouble(12.34, precision: 0).decimalPartAsDouble,
          equals(0.0));

      expect(Decimal.fromDouble(12.034, precision: 3).decimalPartAsDouble,
          equals(0.034));
      expect(Decimal.fromDouble(12.034, precision: 3).decimalPartAsString,
          equals('034'));

      expect(Decimal.fromDouble(12.34, precision: 3).decimalPartAsDouble,
          equals(0.34));
      expect(Decimal.fromDouble(12.34, precision: 3).decimalPartAsString,
          equals('340'));

      expect(Decimal.fromDouble(12.34, precision: 0).decimalPartAsString,
          equals(''));

      expect(
          Decimal.fromDouble(12.34, precision: 1).withPrecision(0).toString(),
          equals('12.0'));

      expect(
          Decimal.fromDouble(12.34, precision: 1)
              .withPrecision(0)
              .withPrecision(1)
              .toString(),
          equals('12.0'));
    });

    test('fromInt -> toString', () {
      expect(Decimal.fromInt(0).toString(), equals('0.0'));
      expect(Decimal.fromInt(1).toString(), equals('1.0'));
      expect(Decimal.fromInt(2).toString(), equals('2.0'));
      expect(Decimal.fromInt(10).toString(), equals('10.0'));
      expect(Decimal.fromInt(123).toString(), equals('123.0'));

      expect(Decimal.fromInt(12, precision: 1).toString(), equals('12.0'));
      expect(Decimal.fromInt(123, precision: 1).toString(), equals('123.0'));
      expect(Decimal.fromInt(123, precision: 0).toString(), equals('123.0'));
    });

    test('from -> toString', () {
      expect(Decimal.from(0).toString(), equals('0.0'));
      expect(Decimal.from(1).toString(), equals('1.0'));
      expect(Decimal.from(2).toString(), equals('2.0'));
      expect(Decimal.from(10).toString(), equals('10.0'));
      expect(Decimal.from(123).toString(), equals('123.0'));

      expect(Decimal.from(0.0).toString(), equals('0.0'));
      expect(Decimal.from(1.0).toString(), equals('1.0'));
      expect(Decimal.from(2.0).toString(), equals('2.0'));
      expect(Decimal.from(10.0).toString(), equals('10.0'));
      expect(Decimal.from(123.0).toString(), equals('123.0'));

      expect(Decimal.from(123.12).toString(), equals('123.12'));

      expect(Decimal.from(BigInt.from(102)).toString(), equals('102.0'));

      expect(Decimal.from([10, 20]).toString(), equals('10.20'));

      expect(Decimal.from([10, 20]).toString(), equals('10.20'));
    });

    test('wholePart/decimalPart', () {
      expect(Decimal.fromDouble(1.234, precision: 3).wholePartAsInt, equals(1));
      expect(Decimal.fromDouble(1.234, precision: 3).decimalPartAsDouble,
          equals(0.234));
      expect(Decimal.fromDouble(1.234, precision: 3).decimalPartAsString,
          equals('234'));

      expect(Decimal.fromDouble(1.23, precision: 3).decimalPartAsString,
          equals('230'));

      expect(Decimal.fromDouble(1.0234, precision: 3).decimalPartAsString,
          equals('023'));

      expect(Decimal.parse('1.023', precision: 3).decimalPartAsString,
          equals('023'));

      expect(Decimal.parse('1.23', precision: 3).decimalPartAsString,
          equals('230'));
    });

    test('fromDouble -> toString + delimiter', () {
      expect(
          Decimal.fromDouble(12.345, precision: 2).toDouble(), equals(12.34));
      expect(
          Decimal.fromDouble(12.345, precision: 3).toDouble(), equals(12.345));

      expect(
          Decimal.fromDouble(1.234, precision: 3).toString(), equals('1.234'));
      expect(
          Decimal.fromDouble(1.234, precision: 3)
              .toString(decimalDelimiter: ','),
          equals('1,234'));

      expect(
          Decimal.fromDouble(1.234, precision: 4).toString(), equals('1.2340'));
      expect(
          Decimal.fromDouble(1.234, precision: 4)
              .toString(decimalDelimiter: ','),
          equals('1,2340'));

      expect(Decimal.fromDouble(12.34, precision: 4).toString(),
          equals('12.3400'));
      expect(
          Decimal.fromDouble(12.34, precision: 4)
              .toString(decimalDelimiter: ','),
          equals('12,3400'));

      expect(
          Decimal.fromDouble(12.34, precision: 4).withPrecision(4).toString(),
          equals('12.3400'));
      expect(
          Decimal.fromDouble(12.34, precision: 4).withPrecision(5).toString(),
          equals('12.34000'));
      expect(
          Decimal.fromDouble(12.34, precision: 4).withPrecision(2).toString(),
          equals('12.34'));
      expect(
          Decimal.fromDouble(12.34, precision: 4).withPrecision(1).toString(),
          equals('12.3'));

      expect(Decimal.fromDouble(1.987, precision: 1).toString(), equals('1.9'));
      expect(
          Decimal.fromDouble(12.987, precision: 1).toString(), equals('12.9'));
      expect(Decimal.fromDouble(123.987, precision: 2).toString(),
          equals('123.98'));
      expect(Decimal.fromDouble(1234.987, precision: 3).toString(),
          equals('1234.987'));
      expect(Decimal.fromDouble(1234.987, precision: 3).format(),
          equals('1,234.987'));
      expect(
          Decimal.fromDouble(1234.987, precision: 3)
              .toString(thousands: true, thousandsDelimiter: '.'),
          equals('1.234,987'));
      expect(
          Decimal.fromDouble(1234.987, precision: 3)
              .toString(decimalDelimiter: ','),
          equals('1234,987'));
      expect(
          Decimal.fromDouble(1234.987, precision: 3)
              .toString(thousands: true, decimalDelimiter: ','),
          equals('1.234,987'));

      expect(Decimal.fromDouble(12345.987, precision: 3).toString(),
          equals('12345.987'));
      expect(
          Decimal.fromDouble(12345.987, precision: 3).toString(thousands: true),
          equals('12,345.987'));
      expect(Decimal.fromDouble(123456.987, precision: 3).toString(),
          equals('123456.987'));
      expect(
          Decimal.fromDouble(123456.987, precision: 3)
              .toString(thousands: true),
          equals('123,456.987'));
      expect(Decimal.fromDouble(1234567.987, precision: 3).toString(),
          equals('1234567.987'));
      expect(
          Decimal.fromDouble(1234567.987, precision: 3)
              .toString(thousands: true),
          equals('1,234,567.987'));
      expect(Decimal.fromDouble(12345678.987, precision: 3).toString(),
          equals('12345678.987'));
      expect(
          Decimal.fromDouble(12345678.987, precision: 3)
              .toString(thousands: true),
          equals('12,345,678.987'));

      expect(
          Decimal.fromDouble(12345678.987, precision: 1)
              .toString(thousandsDelimiter: '.'),
          equals('12345678,9'));
      expect(
          Decimal.fromDouble(12345678.987, precision: 1)
              .toString(thousands: true, thousandsDelimiter: '.'),
          equals('12.345.678,9'));

      expect(
          Decimal.fromDouble(12345678.987, precision: 1)
              .toString(decimalDelimiter: ','),
          equals('12345678,9'));
      expect(
          Decimal.fromDouble(12345678.987, precision: 1)
              .toString(thousands: true, decimalDelimiter: ','),
          equals('12.345.678,9'));
    });

    test('precisionNeeded', () {
      expect(
          Decimal.fromDouble(10.10, precision: 0).precisionNeeded, equals(0));

      expect(Decimal.fromDouble(10.0, precision: 1).precisionNeeded, equals(0));
      expect(
          Decimal.fromDouble(10.10, precision: 1).precisionNeeded, equals(1));

      expect(Decimal.fromDouble(10.0, precision: 2).precisionNeeded, equals(0));
      expect(
          Decimal.fromDouble(10.10, precision: 2).precisionNeeded, equals(1));
      expect(
          Decimal.fromDouble(10.12, precision: 2).precisionNeeded, equals(2));

      expect(Decimal.fromDouble(10.0, precision: 3).precisionNeeded, equals(0));
      expect(
          Decimal.fromDouble(10.10, precision: 3).precisionNeeded, equals(1));
      expect(
          Decimal.fromDouble(10.12, precision: 3).precisionNeeded, equals(2));
      expect(
          Decimal.fromDouble(10.123, precision: 3).precisionNeeded, equals(3));

      expect(Decimal.fromDouble(10.0, precision: 4).precisionNeeded, equals(0));
      expect(
          Decimal.fromDouble(10.10, precision: 4).precisionNeeded, equals(1));
      expect(
          Decimal.fromDouble(10.11, precision: 4).precisionNeeded, equals(2));
      expect(
          Decimal.fromDouble(10.123, precision: 4).precisionNeeded, equals(3));
      expect(
          Decimal.fromDouble(10.1234, precision: 4).precisionNeeded, equals(4));

      expect(Decimal.fromDouble(10.0, precision: 5).precisionNeeded, equals(0));
      expect(
          Decimal.fromDouble(10.30, precision: 5).precisionNeeded, equals(1));
      expect(
          Decimal.fromDouble(10.11, precision: 5).precisionNeeded, equals(2));
      expect(
          Decimal.fromDouble(10.01, precision: 5).precisionNeeded, equals(2));
      expect(
          Decimal.fromDouble(10.124, precision: 5).precisionNeeded, equals(3));
      expect(
          Decimal.fromDouble(10.1234, precision: 5).precisionNeeded, equals(4));
      expect(Decimal.fromDouble(10.12345, precision: 5).precisionNeeded,
          equals(5));
    });

    test('operation +', () {
      for (var p = 0; p <= 10; ++p) {
        expect(
            (Decimal.fromDouble(10.10, precision: p) +
                    Decimal.fromDouble(20.20))
                .toDouble(),
            equals(p == 0 ? 30.2 : 30.30));
      }

      for (var p = 0; p <= 10; ++p) {
        expect(
            (Decimal.fromDouble(30.30, precision: p) +
                    Decimal.fromDouble(-20.20))
                .toDouble(),
            equals(p == 0 ? 9.80 : 10.10));
      }

      for (var p = 0; p <= 10; ++p) {
        expect(
            (Decimal.fromDouble(20.20, precision: p) +
                    Decimal.fromDouble(-30.30))
                .toDouble(),
            equals(p == 0 ? -10.30 : -10.10));
      }

      expect((Decimal.fromInt(-20) + Decimal.fromInt(-30)).toDouble(),
          equals(-50));

      expect((Decimal.fromInt(-20) + Decimal.fromDouble(-30.30)).toDouble(),
          equals(-50.30));

      expect(Decimal.fromInt(-20).sumInt(-30).toDouble(), equals(-50));

      expect(Decimal.fromInt(-20).sumDouble(-30.30).toDouble(), equals(-50.30));

      expect(Decimal.fromInt(-20).sum(-30).toDouble(), equals(-50));

      expect(Decimal.fromInt(-20).sum(-30.30).toDouble(), equals(-50.30));

      expect(Decimal.fromInt(-20).sumBigInt(-30.toBigInt()).toDouble(),
          equals(-50));

      expect(Decimal.fromInt(-20).sumDynamicInt(-30.toDynamicInt()).toDouble(),
          equals(-50));
    });

    test('operation -', () {
      for (var p = 0; p <= 10; ++p) {
        expect(
            (Decimal.fromDouble(20.20, precision: p) -
                    Decimal.fromDouble(10.10))
                .toDouble(),
            equals(p == 0 ? 9.90 : 10.10));
      }

      for (var p = 0; p <= 10; ++p) {
        expect(
            (Decimal.fromDouble(30.30, precision: p) -
                    Decimal.fromDouble(-20.20))
                .toDouble(),
            equals(p == 0 ? 50.20 : 50.50));
      }

      for (var p = 0; p <= 10; ++p) {
        expect(
            (Decimal.fromDouble(-20.20, precision: p) -
                    Decimal.fromDouble(-30.30))
                .toDouble(),
            equals(p == 0 ? 10.30 : 10.10));
      }

      expect(
          (Decimal.fromInt(-20) - Decimal.fromInt(-30)).toDouble(), equals(10));

      expect((Decimal.fromInt(-20) - Decimal.fromDouble(-30.30)).toDouble(),
          equals(10.30));

      expect((Decimal.zero - Decimal.fromDouble(30.30)).toDouble(),
          equals(-30.30));

      expect((Decimal.zero - Decimal.fromDouble(-30.30)).toDouble(),
          equals(30.30));

      expect(Decimal.fromInt(-20).subtractInt(-30).toDouble(), equals(10));

      expect(Decimal.fromInt(-20).subtractDouble(-30.30).toDouble(),
          equals(10.30));

      expect(Decimal.fromInt(-20).subtract(-30).toDouble(), equals(10));

      expect(Decimal.fromInt(-20).subtract(-30.30).toDouble(), equals(10.30));

      expect(Decimal.fromInt(-20).subtractBigInt(-30.toBigInt()).toDouble(),
          equals(10));

      expect(
          Decimal.fromInt(-20)
              .subtractDynamicInt(-30.toDynamicInt())
              .toDouble(),
          equals(10));
    });

    test('operation *', () {
      for (var p = 0; p <= 10; ++p) {
        expect(
            (Decimal.fromDouble(20.10, precision: p) * Decimal.fromDouble(10.0))
                .toDouble(),
            equals(p == 0 ? 200.0 : 201.0));
      }

      for (var p = 0; p <= 10; ++p) {
        expect(
            (Decimal.fromDouble(20.0, precision: p) * Decimal.fromDouble(10.10))
                .toDouble(),
            equals(202.0));
      }

      for (var p = 0; p <= 10; ++p) {
        expect(
            (Decimal.fromDouble(20.20, precision: p) *
                    Decimal.fromDouble(10.10))
                .toDouble(),
            equals(p == 0 ? 202.0 : 204.02));
      }

      expect(
          (Decimal.fromDouble(20.12345678, precision: 8) *
                  Decimal.fromDouble(10.1234567, precision: 7))
              .toString(),
          equals('203.718943366651'));

      expect(
          (Decimal.fromDouble(123456.12345678, precision: 8) *
                  Decimal.fromDouble(12345.1234567, precision: 7))
              .toString(thousands: false),
          equals('1524081085.547200254305'));

      expect(
          (Decimal.fromDouble(1234567.12345678, precision: 5) *
                  Decimal.fromDouble(1234567.1234567, precision: 5))
              .toString(thousands: false),
          equals('1524155982303.6075399025'));

      expect(
          (Decimal.fromDouble(12345678.12345678, precision: 7) *
                  Decimal.fromDouble(12345678.1234567, precision: 7))
              .toString(thousands: false),
          equals('152415768327997.345526756774'));

      expect(
          ((Decimal.fromDouble(123456789.12345678, precision: 8) *
                      Decimal.fromDouble(123456789.12345678, precision: 8)) -
                  Decimal.parse('15241578780673676.293400416527'))
              .toDouble(),
          _isNear(0, 2.5));

      expect(
          ((Decimal.fromDouble(123456789.12345678, precision: 15) *
                      Decimal.fromDouble(123456789.12345678, precision: 15)) -
                  Decimal.parse('15241578780673676.293400416527'))
              .toDouble(),
          _isNear(0, 2.5));

      expect(
          ((Decimal.fromDouble(1234.1234567000002, precision: 17) *
                      Decimal.fromDouble(1234.1234567000002, precision: 17)) -
                  Decimal.parse('1523060.70637715726853938268000004'))
              .toDouble(),
          _isNear(0, 2.5));

      expect(
          (Decimal.parse('1234.12', precision: 2) * Decimal.fromInt(10))
              .toString(thousands: false),
          equals('12341.2'));

      expect(
          (Decimal.parse('1234.12', precision: 2).multiply(10))
              .toString(thousands: false),
          equals('12341.2'));

      expect(
          (Decimal.parse('1234.12', precision: 2).multiply(10.1))
              .toString(thousands: false),
          equals('12464.612'));

      expect(
          (Decimal.parse('1234.12', precision: 2) * Decimal.fromInt(100))
              .toString(thousands: false),
          equals('123412.0'));

      expect(
          (Decimal.parse('1234.12', precision: 2).multiply(100))
              .toString(thousands: false),
          equals('123412.0'));

      expect(
          (Decimal.parse('1234.12', precision: 2).multiply(1000))
              .toString(thousands: false),
          equals('1234120.0'));

      for (var i = 0; i < 13; ++i) {
        var b = math.pow(10, i).toInt();

        const s = '1234567890123';
        var decimal = Decimal.parse('$s.$s');
        var exp = '$s${s.substring(0, i)}.${s.substring(i)}';

        expect((decimal * Decimal.fromInt(b)).toString(thousands: false),
            equals(exp));
        expect(decimal.multiply(b).toString(thousands: false), equals(exp));

        expect(
            (decimal.multiplyInt(b)).toString(thousands: false), equals(exp));
        expect(decimal.multiply(b).toString(thousands: false), equals(exp));
      }

      expect(
          (Decimal.parse('1234.12', precision: 2).multiplyInt(10))
              .toString(thousands: false),
          equals('12341.2'));

      expect(
          (Decimal.parse('1234.12', precision: 2).multiplyInt(3))
              .toString(thousands: false),
          equals('3702.36'));

      expect(
          (Decimal.parse('1234.12', precision: 2).multiplyBigInt(10.toBigInt()))
              .toString(thousands: false),
          equals('12341.2'));

      expect(
          (Decimal.parse('1234.12', precision: 2).multiplyBigInt(3.toBigInt()))
              .toString(thousands: false),
          equals('3702.36'));

      expect(
          (Decimal.parse('1234.12', precision: 2)
                  .multiplyDynamicInt(10.toDynamicInt()))
              .toString(thousands: false),
          equals('12341.2'));

      expect(
          (Decimal.parse('1234.12', precision: 2)
                  .multiplyDynamicInt(3.toDynamicInt()))
              .toString(thousands: false),
          equals('3702.36'));
    });

    test('operation /', () {
      expect(
          (Decimal.parse('1234.12', precision: 2) / Decimal.fromInt(10))
              .toString(thousands: false),
          equals('123.412'));

      expect(
          (Decimal.parse('1234.12', precision: 2).divide(10))
              .toString(thousands: false),
          equals('123.412'));

      expect(
          (Decimal.parse('1234.12', precision: 2) / Decimal.fromInt(100))
              .toString(thousands: false),
          equals('12.3412'));

      expect(
          (Decimal.parse('1234.12', precision: 2) / Decimal.fromInt(1000))
              .toString(thousands: false),
          equals('1.23412'));

      expect(
          (Decimal.parse('1234.12', precision: 2) / Decimal.fromInt(10000))
              .toString(thousands: false),
          equals('0.123412'));

      expect(
          (Decimal.parse('1234.12', precision: 2) / Decimal.fromInt(100000))
              .toString(thousands: false),
          equals('0.0123412'));

      expect(
          (Decimal.parse('1234.12', precision: 2).divide(100000))
              .toString(thousands: false),
          equals('0.0123412'));

      expect(
          (Decimal.parse('1234.12', precision: 2).divide(1000000))
              .toString(thousands: false),
          equals('0.00123412'));

      expect(
          (Decimal.parse('1234.12', precision: 2).divide(10000000))
              .toString(thousands: false),
          equals('0.000123412'));

      expect(
          (Decimal.parse('1234.12', precision: 2).divide(100000000))
              .toString(thousands: false),
          equals('0.0000123412'));

      expect(
          (Decimal.parse('1234.12', precision: 2).divide(1000000000))
              .toString(thousands: false),
          equals('0.00000123412'));

      expect(
          (Decimal.parse('1234.12', precision: 2).divide(10000000000))
              .toString(thousands: false),
          equals('0.000000123412'));

      expect(
          (Decimal.parse('1234.12', precision: 2).divide(100000000000))
              .toString(thousands: false),
          equals('0.0000000123412'));

      expect(
          (Decimal.parse('1234.12', precision: 2).divide(1000000000000))
              .toString(thousands: false),
          equals('0.00000000123412'));

      expect(
          (Decimal.parse('1234.12', precision: 2) / Decimal.fromInt(2))
              .toString(thousands: false),
          equals('617.06'));

      expect(
          (Decimal.parse('1234.12', precision: 2).divide(2))
              .toString(thousands: false),
          equals('617.06'));

      expect(
          (Decimal.parse('1234.12', precision: 2).divide(4))
              .toString(thousands: false),
          equals('308.53'));

      expect(
          (Decimal.parse('1234.12', precision: 2) / Decimal.fromInt(5))
              .toString(thousands: false),
          equals('246.824'));

      expect(
          (Decimal.parse('1234.12', precision: 2).divide(5))
              .toString(thousands: false),
          equals('246.824'));

      expect(
          (Decimal.parse('1234.12', precision: 2) / 2.toDynamicInt())
              .toString(),
          equals('617.06'));

      expect(
          (Decimal.parse('1234.12', precision: 2) / 2.toDecimal()).toString(),
          equals('617.06'));

      expect(
          (Decimal.parse('1234.12', precision: 2) / 2.toDecimal()).toString(),
          equals('617.06'));

      expect(
          (Decimal.parse('1234.12', precision: 2) ~/ 2.toDynamicInt())
              .toString(),
          equals('617'));

      expect(
          (Decimal.parse('1234.12', precision: 2) ~/ 2.toDecimal()).toString(),
          equals('617'));

      expect(() => Decimal.parse('1234.12', precision: 2) / Decimal.zero,
          throwsA(isA<UnsupportedError>()));

      expect(() => Decimal.parse('1234.12', precision: 2) ~/ Decimal.zero,
          throwsA(isA<UnsupportedError>()));

      expect(() => Decimal.parse('1234.12', precision: 2) / DynamicInt.zero,
          throwsA(isA<UnsupportedError>()));

      expect(() => Decimal.parse('1234.12', precision: 2) ~/ DynamicInt.zero,
          throwsA(isA<UnsupportedError>()));

      expect(() => Decimal.parse('1234.12', precision: 2).divide(0),
          throwsA(isA<UnsupportedError>()));

      expect(() => Decimal.parse('1234.12', precision: 2).divideDouble(0.0),
          throwsA(isA<UnsupportedError>()));

      expect(() => Decimal.parse('1234.12', precision: 2).divideInt(0),
          throwsA(isA<UnsupportedError>()));

      expect(() => Decimal.parse('1234.12', precision: 2).divideIntAsDecimal(0),
          throwsA(isA<UnsupportedError>()));

      expect(
          () =>
              Decimal.parse('1234.12', precision: 2).divideBigInt(0.toBigInt()),
          throwsA(isA<UnsupportedError>()));

      expect(
          (Decimal.parse('12345678901234567890.12', precision: 2) /
                  2.toDynamicInt())
              .toString(),
          equals('6172839450617283945.06'));

      expect(
          (Decimal.parse('12345678901234567890.12', precision: 2) /
                  Decimal.parse('2.1'))
              .toString(),
          equals('5878894714873603757.2'));

      expect((1001.toDecimal() / 2.toDecimal()).toString(), equals('500.5'));

      expect((1000.toDecimal().divideDouble(3.0)).toString(),
          equals('333.3333333333333333'));

      expect((1000.toDecimal().divideInt(3)).toString(),
          equals('333.3333333333333333'));

      expect((1000.toDecimal().divideInt(3)).toStringStandard(),
          equals('333.3333333333333333'));

      expect((1000000.toDecimal().divideInt(3)).toString(),
          equals('333333.3333333333333333'));

      expect((1000000.toDecimal().divideInt(3)).toStringStandard(),
          equals('333333.3333333333333333'));

      expect((1000000.toDecimal().divideInt(2)).toString(), equals('500000.0'));

      expect((1000000.toDecimal().divideInt(2)).toStringStandard(),
          equals('500000.0'));

      expect(
          (1000000.toDecimal().divideDynamicInt(2.toDynamicInt()))
              .toStringStandard(),
          equals('500000.0'));

      expect(
          (1000000.toDecimal().divideDynamicIntAsDynamicInt(2.toDynamicInt()))
              .toStringStandard(),
          equals('500000'));

      expect((1000000.toDecimal().divideIntAsDouble(2)), equals(500000.0));

      expect((1000000.toDecimal().divideDoubleAsDouble(2.0)), equals(500000.0));

      expect((1000000.toDecimal().divideNumAsDouble(2)), equals(500000.0));

      expect((1000000.toDecimal().divideNumAsDouble(2.0)), equals(500000.0));

      expect((1000000.toDecimal().divideBigIntAsDouble(2.toBigInt())),
          equals(500000.0));

      expect((1000000.toDecimal().divideDynamicIntAsDouble(2.toDynamicInt())),
          equals(500000.0));

      expect(
          (1000000.toDecimal().divideDynamicIntAsDecimal(2.toDynamicInt()))
              .toString(thousands: true),
          equals('500,000.0'));

      expect((1000000.toDecimal().divideDoubleAsDecimal(2)).toString(),
          equals('500000.0'));

      expect((1000000.toDecimal().divideDoubleAsDecimal(2)).toStringStandard(),
          equals('500000.0'));

      expect((1000000.toDecimal().divideNumAsDecimal(2)).toStringStandard(),
          equals('500000.0'));

      expect((1000000.toDecimal().divideNumAsDecimal(2.0)).toStringStandard(),
          equals('500000.0'));

      expect(
          (1000000.toDecimal().divideBigIntAsDecimal(2.toBigInt()))
              .toStringStandard(),
          equals('500000.0'));
    });

    test('operation %', () {
      expect(
          (Decimal.parse('12') % Decimal.parse('10'))
              .toString(thousands: false),
          equals('2.0'));

      expect(
          (Decimal.parse('12.3') % Decimal.parse('10'))
              .toString(thousands: false),
          equals('2.3'));

      expect(
          (Decimal.parse('22.3') % Decimal.parse('10'))
              .toString(thousands: false),
          equals('2.3'));

      expect(
          (Decimal.parse('22.3') % Decimal.parse('11'))
              .toString(thousands: false),
          equals('0.3'));

      expect(
          (Decimal.parse('22.3') % Decimal.parse('11.1'))
              .toString(thousands: false),
          equals('0.1'));

      expect(
          (Decimal.parse('22.3') % DynamicInt.parse('11'))
              .toString(thousands: false),
          equals('0.3'));

      expect((Decimal.parse('22.3').moduloInt(11)).toString(thousands: false),
          equals('0.3'));

      expect((Decimal.parse('23').moduloInt(11)).toString(thousands: false),
          equals('1.0'));

      expect(
          (Decimal.parse('123456789012345678901234567890').moduloInt(11))
              .toString(thousands: false),
          equals('7.0'));

      expect(
          (Decimal.parse('22.3').moduloBigInt(11.toBigInt()))
              .toString(thousands: false),
          equals('0.3'));

      expect(
          (Decimal.parse('23').moduloBigInt(11.toBigInt()))
              .toString(thousands: false),
          equals('1.0'));

      expect(
          (Decimal.parse('22.3').moduloDynamicInt(11.toDynamicInt()))
              .toString(thousands: false),
          equals('0.3'));

      expect(
          (Decimal.parse('23').moduloDynamicInt(11.toDynamicInt()))
              .toString(thousands: false),
          equals('1.0'));

      expect(
          (Decimal.parse('123456789012345678901234567890')
                  .moduloDynamicInt(11.toDynamicInt()))
              .toString(thousands: false),
          equals('7.0'));
    });

    test('operation -', () {
      expect((-Decimal.parse('123456')).toString(), equals('-123456.0'));
      expect((-Decimal.parse('-123456')).toString(), equals('123456.0'));

      expect((-Decimal.parse('123456.78')).toString(), equals('-123456.78'));
      expect((-Decimal.parse('-123456.78')).toString(), equals('123456.78'));
    });

    test('operation ~', () {
      expect((~Decimal.parse('0')).toHex(), equals('FFFFFFFF'));
      expect((~Decimal.parse('1')).toHex(), equals('FFFFFFFE'));
      expect((~Decimal.parse('-1')).toHex(), equals('00000000'));

      expect((~Decimal.parse('0.00')).toHex(), equals('FFFFFFFF'));
      expect((~Decimal.parse('1.00')).toHex(), equals('FFFFFFFE'));
      expect((~Decimal.parse('-1.00')).toHex(), equals('00000000'));

      expect(
          (~Decimal.parse('0.00', precision: 2)).toHex(), equals('FFFFFFFF'));
      expect(
          (~Decimal.parse('1.00', precision: 2)).toHex(), equals('FFFFFFFE'));
      expect(
          (~Decimal.parse('-1.00', precision: 2)).toHex(), equals('00000000'));
    });

    test('sin', () {
      expect(Decimal.fromInt(1).sin,
          equals(Decimal.fromDouble(0.8414709848078965)));
      expect(Decimal.fromInt(-1).sin,
          equals(Decimal.fromDouble(-0.8414709848078965)));

      expect(Decimal.fromInt(10).sin,
          equals(Decimal.fromDouble(-0.5440211108893699)));
      expect(Decimal.fromInt(-10).sin,
          equals(Decimal.fromDouble(0.5440211108893699)));
    });

    test('cos', () {
      expect(Decimal.fromInt(1).cos,
          equals(Decimal.fromDouble(0.5403023058681398)));
      expect(Decimal.fromInt(-1).cos,
          equals(Decimal.fromDouble(0.5403023058681398)));

      expect(Decimal.fromInt(10).cos,
          equals(Decimal.fromDouble(-0.8390715290764524)));
      expect(Decimal.fromInt(-10).cos,
          equals(Decimal.fromDouble(-0.8390715290764524)));
    });

    test('square', () {
      expect(Decimal.parse('0').square.toString(), equals('0.0'));
      expect(Decimal.parse('1').square.toString(), equals('1.0'));
      expect(Decimal.parse('2').square.toString(), equals('4.0'));
      expect(Decimal.parse('10').square.toString(), equals('100.0'));
      expect(Decimal.parse('11').square.toString(), equals('121.0'));
      expect(Decimal.parse('11.1').square.toString(), equals('123.21'));
    });

    test('power (browser)', () {
      expect(123456.toDecimal().power(2.2.toDecimal()).toString(),
          equals('158974271527.972720545792'));
    }, tags: ['num', 'decimal', 'browser']);

    test('power', () {
      expect(0.toDecimal().power(2.toDynamicInt()).toString(), equals('0.0'));
      expect(0.toDecimal().power(0.toDynamicInt()).toString(), equals('1.0'));
      expect(2.toDecimal().power(0.toDynamicInt()).toString(), equals('1.0'));
      expect(10.toDecimal().power(0.toDynamicInt()).toString(), equals('1.0'));

      expect(() => 2.toDecimal().powerAsDynamicInt((-1).toDynamicInt()),
          throwsA(isA<UnsupportedError>()));

      expect(2.toDecimal().powerAsDecimal((-1).toDynamicInt()).toString(),
          equals('0.5'));

      expect(() => 2.toDecimal().powerAsDynamicInt((-2).toDynamicInt()),
          throwsA(isA<UnsupportedError>()));

      expect(() => 2.toDecimal().powerAsDynamicInt((-3).toDynamicInt()),
          throwsA(isA<UnsupportedError>()));

      expect(2.toDecimal().power(2.toDynamicInt()).toString(), equals('4.0'));
      expect(4.toDecimal().power(2.toDynamicInt()).toString(), equals('16.0'));
      expect(5.toDecimal().power(2.toDynamicInt()).toString(), equals('25.0'));
      expect(8.toDecimal().power(2.toDynamicInt()).toString(), equals('64.0'));

      expect(
          (-2).toDecimal().power(2.toDynamicInt()).toString(), equals('4.0'));
      expect(
          (-4).toDecimal().power(2.toDynamicInt()).toString(), equals('16.0'));
      expect(
          (-5).toDecimal().power(2.toDynamicInt()).toString(), equals('25.0'));
      expect(
          (-8).toDecimal().power(2.toDynamicInt()).toString(), equals('64.0'));

      expect(2.toDecimal().power(3.toDynamicInt()).toString(), equals('8.0'));
      expect(4.toDecimal().power(3.toDynamicInt()).toString(), equals('64.0'));
      expect(5.toDecimal().power(3.toDynamicInt()).toString(), equals('125.0'));
      expect(8.toDecimal().power(3.toDynamicInt()).toString(), equals('512.0'));

      expect(
          (-2).toDecimal().power(3.toDynamicInt()).toString(), equals('-8.0'));
      expect(
          (-4).toDecimal().power(3.toDynamicInt()).toString(), equals('-64.0'));
      expect((-5).toDecimal().power(3.toDynamicInt()).toString(),
          equals('-125.0'));
      expect((-8).toDecimal().power(3.toDynamicInt()).toString(),
          equals('-512.0'));

      expect(2.toDecimal().power(2.2.toDecimal()).toString(),
          equals('4.594793419988'));

      expect((-2).toDecimal().power(2.2.toDecimal()).toString(),
          equals('-4.594793419988'));

      expect(123456.toDecimal().power(2.2.toDecimal()).toString(),
          equals('158974271527.972720545792'));

      expect((-123456).toDecimal().power(2.2.toDecimal()).toString(),
          equals('-158974271527.972720545792'));

      expect(1234567890.toDecimal().power(2.2.toDecimal()).toString(),
          equals('100307394518534338601.882103054300'));

      expect((-1234567890).toDecimal().power(2.2.toDecimal()).toString(),
          equals('-100307394518534338601.882103054300'));

      expect(
          (DynamicInt.parse('12345678901234567890')
                  .toDecimal()
                  .power(2.2.toDecimal()) -
              Decimal.parse(
                  '1003073945406026304562947426382490991920732.343838280700')),
          _isNearDecimal(
              Decimal.zero, Decimal.parse('304831575064776735003810400')));

      expect(
          (DynamicInt.parse('-12345678901234567890')
                  .toDecimal()
                  .power(2.2.toDecimal()) -
              Decimal.parse(
                  '-1003073945406026304562947426382490991920732.343838280700')),
          _isNearDecimal(
              Decimal.zero, Decimal.parse('304831575064776735003810400')));

      expect(123.toDecimal().power(12.toDynamicInt()).toString(),
          equals('11991163848716906297072721.0'));

      expect((-123).toDecimal().power(12.toDynamicInt()).toString(),
          equals('11991163848716906297072721.0'));

      expect(123.toDecimal().power(13.toDynamicInt()).toString(),
          equals('1474913153392179474539944683.0'));

      expect((-123).toDecimal().power(13.toDynamicInt()).toString(),
          equals('-1474913153392179474539944683.0'));

      expect(123.toDecimal().power(20.toDynamicInt()).toString(),
          equals('628206215175202159781085149496179361969201.0'));

      expect(
          123.toDecimal().power(30.toDynamicInt()).toString(),
          equals(
              '497912859868342793044999075260564303046944727069807798026337449.0'));

      expect(
          (-123).toDecimal().power(30.toDynamicInt()).toString(),
          equals(
              '497912859868342793044999075260564303046944727069807798026337449.0'));

      expect(
          (123).toDecimal().power(31.toDynamicInt()).toString(),
          equals(
              '61243281763806163544534886257049409274774201429586359157239506227.0'));

      expect(
          (-123).toDecimal().power(31.toDynamicInt()).toString(),
          equals(
              '-61243281763806163544534886257049409274774201429586359157239506227.0'));

      expect(
          123.toDecimal().power(41.toDynamicInt()).toString(),
          equals(
              '48541095000524544750127162673405880068636916264012200797813591925035550682238127143323.0'));

      expect(
          (-123).toDecimal().power(41.toDynamicInt()).toString(),
          equals(
              '-48541095000524544750127162673405880068636916264012200797813591925035550682238127143323.0'));
    });

    test('squareRoot', () {
      expect(Decimal.parse('0').squareRoot.toString(), equals('0.0'));
      expect(Decimal.parse('1').squareRoot.toString(), equals('1.0'));
      expect(Decimal.parse('4.0').squareRoot.toString(), equals('2.0'));
      expect(Decimal.parse('100').squareRoot.toString(), equals('10.0'));
      expect(Decimal.parse('121').squareRoot.toString(), equals('11.0'));

      expect(Decimal.parse('123.4321').squareRoot.toString(), equals('11.11'));

      expect(Decimal.parse('123.21').squareRoot.toString(), equals('11.1'));

      expect(Decimal.parse('0.6666').squareRoot.toString(),
          equals('0.8164557550780078'));

      expect(Decimal.parse('0.666666').squareRoot.toString(),
          equals('0.816496172679333506745764'));
    });

    test('extension', () {
      expect([1, 2, 3].asDecimal,
          equals([1.toDecimal(), 2.toDecimal(), 3.toDecimal()]));

      expect([1, 2.2, 3].asDecimal,
          equals([1.toDecimal(), 2.2.toDecimal(), 3.toDecimal()]));

      expect([1.1, 2.2, 3.3].asDecimal,
          equals([1.1.toDecimal(), 2.2.toDecimal(), 3.3.toDecimal()]));

      expect([1.toBigInt(), 2.toBigInt(), 3.toBigInt()].asDecimal,
          equals([1.toDecimal(), 2.toDecimal(), 3.toDecimal()]));

      expect([1.toBigInt(), 2.toBigInt(), 3.toBigInt()].asDecimal.asInt,
          equals([1, 2, 3]));

      expect([1.toBigInt(), 2.toBigInt(), 3.toBigInt()].asDecimal.asDouble,
          equals([1.0, 2.0, 3.0]));

      expect([1.toBigInt(), 2.toBigInt(), 3.toBigInt()].asDecimal.asNum,
          equals([1, 2, 3]));

      expect([1.toBigInt(), 2.toBigInt(), 3.toBigInt()].asDecimal.sum,
          equals(6.toDecimal()));

      expect(
          <DynamicNumber>[1.toDecimal(), 2.toDecimal(), 3.toDecimal()]
              .asDynamicInt,
          equals([1.toDynamicInt(), 2.toDynamicInt(), 3.toDynamicInt()]));

      expect(<DynamicNumber>[1.toDecimal(), 2.toDecimal(), 3.toDecimal()].sum,
          equals(6.toDynamicInt()));

      expect(<DynamicNumber>[].sum, equals(0.toDynamicInt()));

      expect(<Decimal>[1.toDecimal(), 2.toDecimal(), 3.toDecimal()].sumSquares,
          equals((1 + 4 + 9).toDynamicInt()));

      expect(<Decimal>[1.toDecimal(), 2.toDecimal(), 3.toDecimal()].mean,
          equals(2.toDynamicInt()));

      expect(
          <DynamicNumber>[1.toDecimal(), 2.toDecimal(), 3.toDecimal()]
              .standardDeviation,
          equals(Decimal.parse(
              '0.8164965809277259919075989785156611400798550887964415634737670678')));

      expect(
          <DynamicNumber>[1.toDecimal(), 2.toDecimal(), 3.toDecimal()]
              .standardDeviation,
          equals(Decimal.parse(
              '0.8164965809277259919075989785156611400798550887964415634737670678')));

      expect(<Decimal>[1.toDecimal(), 2.toDecimal(), 3.toDecimal()].squaresMean,
          equals(Decimal.parse('4.6666666666666666')));

      expect(<Decimal>[1.toDecimal(), 2.toDecimal(), 3.toDecimal()].squares,
          equals([1, 4, 9].asDecimal));

      expect(
          <Decimal>[1.toDecimal(), 2.toDecimal(), 3.toDecimal()].squaresRoots,
          equals([
            Decimal.one,
            Decimal.parse('1.414213562373095'),
            Decimal.parse('1.732050807568877')
          ].asDecimal));

      expect(<Decimal>[1.toDecimal(), -2.toDecimal(), 3.toDecimal()].abs,
          equals([1, 2, 3].asDecimal));
    });

    test('withMaximumPrecision/withMinimumPrecision/clipPrecision', () {
      var d1 = Decimal.parse('12.3456');
      expect(d1.precision, equals(4));
      expect(d1.toString(), equals('12.3456'));

      var d2 = d1.withMaximumPrecision(5);
      expect(d2.precision, equals(4));
      expect(d2.toString(), equals('12.3456'));

      var d3 = d1.withMaximumPrecision(3);
      expect(d3.precision, equals(3));
      expect(d3.toString(), equals('12.345'));

      var d4 = d1.withMinimumPrecision(6);
      expect(d4.precision, equals(6));
      expect(d4.toString(), equals('12.345600'));

      var d5 = d1.clipPrecision(2, 6);
      expect(d5.precision, equals(4));
      expect(d5.toString(), equals('12.3456'));

      var d6 = d1.clipPrecision(5, 6);
      expect(d6.precision, equals(5));
      expect(d6.toString(), equals('12.34560'));

      var d7 = d1.clipPrecision(0, 2);
      expect(d7.precision, equals(2));
      expect(d7.toString(), equals('12.34'));
    });
  });
}

Matcher _isNear(num value, [double tolerance = 0.0001]) {
  var min = value - tolerance;
  var max = value + tolerance;
  return inInclusiveRange(min, max);
}

Matcher _isNearDecimal(Decimal value, [Decimal? tolerance]) {
  tolerance ??= Decimal.parse('0.0001');
  var min = value - tolerance;
  var max = value + tolerance;
  return allOf(greaterThanOrEqualTo(min), lessThanOrEqualTo(max));
}
