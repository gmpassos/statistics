@Tags(['num'])
library;

import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('DynamicNumber', () {
    test('basic', () {
      expect(DynamicNumber.isIntSafeInteger(123), isTrue);
      expect(DynamicNumber.isIntSafeInteger(-123), isTrue);
      expect(DynamicNumber.isIntSafeInteger(2147483647), isTrue);
      expect(DynamicNumber.isIntSafeInteger(-2147483647), isTrue);

      expect(DynamicNumber.isIntSafeInteger(DynamicInt.maxSafeInteger), isTrue);
      expect(DynamicNumber.isIntSafeInteger(DynamicInt.minSafeInteger), isTrue);

      expect(
          DynamicNumber.isBigIntSafeInteger(
              DynamicInt.maxSafeInteger.toBigInt()),
          isTrue);
      expect(
          DynamicNumber.isBigIntSafeInteger(
              DynamicInt.minSafeInteger.toBigInt()),
          isTrue);

      expect(DynamicNumber.fromInt(123).toString(), equals('123'));
      expect(DynamicNumber.fromInt(-123).toString(), equals('-123'));

      expect(
          DynamicNumber.fromInt(2147483647).toString(), equals('2147483647'));
      expect(
          DynamicNumber.fromInt(-2147483647).toString(), equals('-2147483647'));

      expect(DynamicNumber.fromBigInt(2147483647.toBigInt()).toString(),
          equals('2147483647'));
      expect(DynamicNumber.fromBigInt((-2147483647).toBigInt()).toString(),
          equals('-2147483647'));

      expect(DynamicNumber.fromDouble(1.2).toString(), equals('1.2'));
      expect(DynamicNumber.fromDouble(-1.2).toString(), equals('-1.2'));

      expect(DynamicNumber.fromNum(12).toString(), equals('12'));
      expect(DynamicNumber.fromNum(1.2).toString(), equals('1.2'));

      expect(DynamicNumber.parse('123').toString(), equals('123'));
      expect(DynamicNumber.parse('1.23').toString(), equals('1.23'));
      expect(DynamicNumber.parse('-1.23').toString(), equals('-1.23'));

      expect(DynamicNumber.tryParse(''), isNull);
      expect(DynamicNumber.tryParse(' x '), isNull);
      expect(DynamicNumber.tryParse(' e '), isNull);
      expect(DynamicNumber.tryParse(' a.b '), isNull);
      expect(DynamicNumber.tryParse('123').toString(), equals('123'));
      expect(DynamicNumber.tryParse('1.23').toString(), equals('1.23'));
      expect(DynamicNumber.tryParse('-1.23').toString(), equals('-1.23'));

      expect(DynamicNumber.from(null), isNull);
      expect(DynamicNumber.from(''), isNull);
      expect(DynamicNumber.from(' x '), isNull);
      expect(DynamicNumber.from(' e '), isNull);
      expect(DynamicNumber.from(' a.b '), isNull);
      expect(DynamicNumber.from(123).toString(), equals('123'));
      expect(DynamicNumber.from(123.45).toString(), equals('123.45'));
      expect(DynamicNumber.from('123').toString(), equals('123'));
      expect(DynamicNumber.from('1.23').toString(), equals('1.23'));
      expect(DynamicNumber.from('-1.23').toString(), equals('-1.23'));

      expect(DynamicNumber.from(123).toString(), equals('123'));
      expect(DynamicNumber.from(123.toBigInt()).toString(), equals('123'));
      expect(DynamicNumber.from(1.234).toString(), equals('1.234'));
      expect(DynamicNumber.from('1.23').toString(), equals('1.23'));

      expect(DynamicNumber.from(123.toDynamicInt()).toString(), equals('123'));
      expect(DynamicNumber.from(123.toDecimal()).toString(), equals('123.0'));
      expect(
          DynamicNumber.from(123.toDecimal())!
              .toDecimal()
              .toString(decimal: false),
          equals('123'));
      expect(
          DynamicNumber.from(123.45.toDecimal()).toString(), equals('123.45'));

      expect(DynamicNumber.from(123)?.isDynamicInt, isTrue);
      expect(DynamicNumber.from(123.toBigInt())?.isDynamicInt, isTrue);
      expect(DynamicNumber.from(123.45)?.isDynamicInt, isFalse);
      expect(DynamicNumber.from(123.45)?.isDecimal, isTrue);

      expect(DynamicNumber.from(123)?.hashCode, equals(123.hashCode));
      expect(DynamicNumber.from('12345678901234567890')?.hashCode,
          equals(BigInt.parse('12345678901234567890').hashCode));

      expect(DynamicNumber.fromInt(123).toDouble(), equals(123.0));
      expect(DynamicNumber.fromInt(123).toInt(), equals(123));
      expect(DynamicNumber.fromInt(123).toNum(), equals(123));
      expect(DynamicNumber.fromInt(123).toBigInt(), equals(123.toBigInt()));
      expect(DynamicNumber.fromInt(123).toDynamicInt(),
          equals(123.toDynamicInt()));
      expect(DynamicNumber.fromInt(123).toDecimal(), equals(123.toDecimal()));

      expect(DynamicNumber.fromDouble(123.1).toDouble(), equals(123.1));
      expect(DynamicNumber.fromDouble(123.1).toInt(), equals(123));
      expect(DynamicNumber.fromDouble(123.1).toNum(), equals(123.1));
      expect(
          DynamicNumber.fromDouble(123.1).toBigInt(), equals(123.1.toBigInt()));
      expect(DynamicNumber.fromDouble(123.1).toDynamicInt(),
          equals(123.1.toDynamicInt()));
      expect(DynamicNumber.fromDouble(123.1).toDecimal(),
          equals(123.1.toDecimal()));

      expect([10, 20, 30].toDynamicIntList().standardDeviation.toDouble(),
          equals(8.164965809277259));
    });
  });

  group('DynamicInt', () {
    setUp(() {});

    test('basic', () {
      expect(DynamicInt.maxSafeInteger, equals(DynamicNumber.maxSafeInteger));
      expect(DynamicInt.minSafeInteger, equals(DynamicNumber.minSafeInteger));

      expect(DynamicInt.safeIntegerBits, equals(DynamicNumber.safeIntegerBits));

      expect(DynamicInt.maxSafeIntegerDigits,
          equals(DynamicNumber.maxSafeIntegerDigits));
      expect(DynamicInt.minSafeIntegerDigits,
          equals(DynamicNumber.minSafeIntegerDigits));

      expect(DynamicInt.fromInt(1234).toString(), equals('1234'));
      expect(
          DynamicInt.fromBigInt(BigInt.from(1234)).toString(), equals('1234'));
      expect(DynamicInt.fromNum(12345).toString(), equals('12345'));
      expect(DynamicInt.fromNum(12.345).toString(), equals('12'));

      expect(DynamicInt.from(null), isNull);

      expect(DynamicInt.from(123).toString(), equals('123'));
      expect(DynamicInt.from(123.toBigInt()).toString(), equals('123'));
      expect(DynamicInt.from(12.234).toString(), equals('12'));
      expect(DynamicInt.from('12.23').toString(), equals('12'));

      expect(DynamicInt.from(123.toDynamicInt()).toString(), equals('123'));
      expect(DynamicInt.from(123.toDecimal()).toString(), equals('123'));
      expect(DynamicInt.from(123.45.toDecimal()).toString(), equals('123'));

      expect(DynamicInt.fromInt(123).equalsInt(123), isTrue);
      expect(DynamicInt.fromInt(123).equalsInt(120), isFalse);

      expect(DynamicInt.fromBigInt(123.toBigInt()).equalsInt(123), isTrue);
      expect(DynamicInt.fromBigInt(123.toBigInt()).equalsInt(120), isFalse);

      expect(DynamicInt.fromInt(123).equalsBigInt(123.toBigInt()), isTrue);
      expect(DynamicInt.fromInt(123).equalsBigInt(120.toBigInt()), isFalse);

      expect(DynamicInt.fromBigInt(123.toBigInt()).equalsBigInt(123.toBigInt()),
          isTrue);
      expect(DynamicInt.fromBigInt(123.toBigInt()).equalsBigInt(120.toBigInt()),
          isFalse);

      expect((-DynamicInt.fromInt(123)).toString(), equals('-123'));
      expect((-DynamicInt.fromInt(-123)).toString(), equals('123'));

      expect((~DynamicInt.fromInt(0)).toHex(), equals('FFFFFFFF'));
      expect((~DynamicInt.fromInt(1)).toHex(), equals('FFFFFFFE'));
      expect((~DynamicInt.fromInt(-1)).toHex(), equals('00000000'));

      expect((~DynamicInt.fromInt(0).asDynamicIntBig).toString(), equals('-1'));
      expect((~DynamicInt.fromInt(1).asDynamicIntBig).toString(), equals('-2'));
      expect((~DynamicInt.fromInt(-1).asDynamicIntBig).toString(), equals('0'));

      expect((DynamicInt.fromInt(0) << 0).toString(), equals('0'));
      expect((DynamicInt.fromInt(1) << 0).toString(), equals('1'));
      expect((DynamicInt.fromInt(1) << 1).toString(), equals('2'));
      expect((DynamicInt.fromInt(2) << 1).toString(), equals('4'));

      expect((DynamicInt.fromInt(0) >> 0).toString(), equals('0'));
      expect((DynamicInt.fromInt(1) >> 0).toString(), equals('1'));
      expect((DynamicInt.fromInt(1) >> 1).toString(), equals('0'));
      expect((DynamicInt.fromInt(2) >> 1).toString(), equals('1'));
      expect((DynamicInt.fromInt(4) >> 1).toString(), equals('2'));

      expect((DynamicInt.fromInt(3721041) << 1).toBigInt().toString(),
          equals('7442082'));
      expect((DynamicInt.fromInt(3721041) << 2).toBigInt().toString(),
          equals('14884164'));
      expect((DynamicInt.fromInt(3721041) << 8).toBigInt().toString(),
          equals('952586496'));
      expect((DynamicInt.fromInt(3721041) << 10).toBigInt().toString(),
          equals('3810345984'));
      expect((DynamicInt.fromInt(3721041) << 11).toBigInt().toString(),
          equals('7620691968'));
      expect((DynamicInt.fromInt(3721041) << 12).toBigInt().toString(),
          equals('15241383936'));
      expect((DynamicInt.fromInt(3721041) << 13).toBigInt().toString(),
          equals('30482767872'));
      expect((DynamicInt.fromInt(3721041) << 14).toBigInt().toString(),
          equals('60965535744'));
      expect((DynamicInt.fromInt(3721041) << 15).toBigInt().toString(),
          equals('121931071488'));

      expect(
          (DynamicInt.fromBigInt(0.toBigInt()) << 0).toString(), equals('0'));
      expect(
          (DynamicInt.fromBigInt(1.toBigInt()) << 0).toString(), equals('1'));
      expect(
          (DynamicInt.fromBigInt(1.toBigInt()) << 1).toString(), equals('2'));
      expect(
          (DynamicInt.fromBigInt(2.toBigInt()) << 1).toString(), equals('4'));

      expect(
          (DynamicInt.fromBigInt(0.toBigInt()) >> 0).toString(), equals('0'));
      expect(
          (DynamicInt.fromBigInt(1.toBigInt()) >> 0).toString(), equals('1'));
      expect(
          (DynamicInt.fromBigInt(1.toBigInt()) >> 1).toString(), equals('0'));
      expect(
          (DynamicInt.fromBigInt(2.toBigInt()) >> 1).toString(), equals('1'));
      expect(
          (DynamicInt.fromBigInt(4.toBigInt()) >> 1).toString(), equals('2'));

      expect(123.toDynamicInt().isBigInt, isFalse);
      expect(123.toDynamicInt().asDynamicIntNative.isBigInt, isFalse);
      expect(123.toDynamicInt().asDynamicIntBig.isBigInt, isTrue);

      expect(DynamicInt.parse('123').toString(), equals('123'));
      expect(DynamicInt.parse('12345678901234567890').isBigInt, isTrue);
      expect(DynamicInt.parse('12345678901234567890').asDynamicIntBig.isBigInt,
          isTrue);
      expect(() => DynamicInt.parse('12345678901234567890').asDynamicIntNative,
          throwsA(isA<UnsupportedError>()));

      expect(DynamicInt.tryParse('123.3'), isNull);
      expect(DynamicInt.tryParse(' a.b '), isNull);
      expect(DynamicInt.tryParse(''), isNull);
      expect(DynamicInt.tryParse('123').toString(), equals('123'));
      expect(DynamicInt.tryParse('12345678901234567890').toString(),
          equals('12345678901234567890'));

      expect(DynamicInt.from(null), isNull);
      expect(DynamicInt.from(' a.b '), isNull);
      expect(DynamicInt.from(''), isNull);
      expect(DynamicInt.from(123).toString(), equals('123'));
      expect(DynamicInt.from('123.3').toString(), equals('123'));
      expect(DynamicInt.from('123').toString(), equals('123'));
      expect(DynamicInt.from('12345678901234567890').toString(),
          equals('12345678901234567890'));

      expect(DynamicInt.fromInt(123456).format(thousands: false),
          equals('123456'));
      expect(DynamicInt.fromInt(123456).format(thousands: true),
          equals('123,456'));

      expect(
          DynamicInt.fromInt(123456)
              .format(thousands: false, thousandsDelimiter: '.'),
          equals('123456'));
      expect(
          DynamicInt.fromInt(123456)
              .format(thousands: true, thousandsDelimiter: '.'),
          equals('123.456'));

      expect(
          DynamicInt.fromInt(123456)
              .format(thousands: false, thousandsDelimiter: ';'),
          equals('123456'));
      expect(
          DynamicInt.fromInt(123456)
              .format(thousands: true, thousandsDelimiter: ';'),
          equals('123;456'));

      expect(DynamicInt.fromInt(123456).toDouble(), equals(123456.0));
      expect(DynamicInt.fromBigInt(123456.toBigInt()).toDouble(),
          equals(123456.0));

      expect(DynamicInt.fromInt(1).bitLength, equals(1));
      expect(DynamicInt.fromInt(1 << 1).bitLength, equals(2));
      expect(DynamicInt.fromInt(1 << 2).bitLength, equals(3));

      for (var i = 0; i < DynamicInt.safeIntegerBits; ++i) {
        var n = DynamicInt.one << i;
        expect(n.bitLength, equals(i + 1));
      }

      expect(
          DynamicInt.parse('1234567890123456789012345678901234567890')
              .bitLength,
          equals(130));

      expect((DynamicInt.fromInt(32) << 1).toStringStandard(), equals('64'));
      expect((DynamicInt.fromInt(32) << 24).toStringStandard(),
          equals('536870912'));
      expect((DynamicInt.fromInt(32) << 100).toStringStandard(),
          equals('40564819207303340847894502572032'));

      expect((DynamicInt.fromInt(32) >> 1).toStringStandard(), equals('16'));
      expect((DynamicInt.fromInt(536870912) >> 24).toStringStandard(),
          equals('32'));
      expect(
          (DynamicInt.from('40564819207303340847894502572032')! >> 100)
              .toStringStandard(),
          equals('32'));

      expect((DynamicInt.fromInt(9007199254740991) >> 24).toStringStandard(),
          equals('536870911'));
    });

    test('parse', () {
      {
        var n = DynamicInt.parse('123');

        expect(n.isPositive, isTrue);
        expect(n.isNegative, isFalse);

        expect(n.isBigInt, isFalse);
        expect(n.isSafeInteger, isTrue);
        expect(n.toInt(), equals(123));
        expect(n.toString(), equals('123'));

        expect(n.isBigInt, isFalse);
        expect(n.toBigInt(), equals(BigInt.from(123)));

        expect(n.asDynamicIntBig.isBigInt, isTrue);
        expect(n.asDynamicIntBig.toInt(), equals(123));
        expect(n.asDynamicIntBig.toBigInt(), equals(BigInt.from(123)));
        expect(n.asDynamicIntBig.toString(), equals('123'));
      }

      {
        var n = DynamicInt.parse('-123');

        expect(n.isPositive, isFalse);
        expect(n.isNegative, isTrue);

        expect(n.isBigInt, isFalse);
        expect(n.isSafeInteger, isTrue);
        expect(n.toInt(), equals(-123));

        expect(n.isBigInt, isFalse);
        expect(n.toBigInt(), equals(BigInt.from(-123)));
      }

      {
        var n = DynamicInt.parse('12345678901234567890');

        expect(n.isBigInt, isTrue);
        expect(n.isSafeInteger, isFalse);
        expect(n.toBigInt(), equals(BigInt.parse('12345678901234567890')));
      }

      {
        var n = DynamicInt.parse('-12345678901234567890');

        expect(n.isBigInt, isTrue);
        expect(n.isSafeInteger, isFalse);
        expect(n.toBigInt(), equals(BigInt.parse('-12345678901234567890')));

        expect(() => n.toInt(), throwsA(isA<UnsupportedError>()));
      }

      expect(() => DynamicInt.parse('-zasd'), throwsA(isA<FormatException>()));

      expect(DynamicInt.tryParse('123').toString(), equals('123'));
      expect(DynamicInt.tryParse('-123').toString(), equals('-123'));
      expect(DynamicInt.tryParse('-zasd'), isNull);

      expect(DynamicInt.tryParse('12345678901234567890').toString(),
          equals('12345678901234567890'));
    });

    test('equals', () {
      expect((DynamicInt.fromInt(123) == DynamicInt.fromInt(123)), isTrue);
      expect((DynamicInt.fromInt(123) == DynamicInt.fromInt(-123)), isFalse);

      expect(
          (123.toBigInt().toDynamicInt() == DynamicInt.fromInt(123)), isTrue);
      expect(
          (123.toBigInt().toDynamicInt() == DynamicInt.fromInt(-123)), isFalse);

      expect((123.toBigInt().toDynamicInt() == 123.toBigInt().toDynamicInt()),
          isTrue);
      expect(
          (123.toBigInt().toDynamicInt() == (-123).toBigInt().toDynamicInt()),
          isFalse);
    });

    test('compareTo', () {
      expect((123.toDynamicInt().compareTo(123.toDynamicInt())), equals(0));
      expect(((-123).toDynamicInt().compareTo(123.toDynamicInt())), equals(-1));
      expect((123.toDynamicInt().compareTo((-123).toDynamicInt())), equals(1));

      expect((123.toBigInt().toDynamicInt().compareTo(123.toDynamicInt())),
          equals(0));
      expect(((-123).toBigInt().toDynamicInt().compareTo(123.toDynamicInt())),
          equals(-1));
      expect((123.toBigInt().toDynamicInt().compareTo((-123).toDynamicInt())),
          equals(1));

      expect(
          (123
              .toBigInt()
              .toDynamicInt()
              .compareTo(123.toBigInt().toDynamicInt())),
          equals(0));
      expect(
          ((-123)
              .toBigInt()
              .toDynamicInt()
              .compareTo(123.toBigInt().toDynamicInt())),
          equals(-1));
      expect(
          (123
              .toBigInt()
              .toDynamicInt()
              .compareTo((-123).toBigInt().toDynamicInt())),
          equals(1));

      expect((123.toBigInt().toDynamicInt().compareTo(12.2.toDecimal())),
          greaterThanOrEqualTo(1));

      expect(((-123).toBigInt().toDynamicInt().compareTo(12.2.toDecimal())),
          lessThanOrEqualTo(1));

      expect(((13).toBigInt().toDynamicInt().compareTo(12.2.toDecimal())),
          greaterThanOrEqualTo(1));

      expect(((12).toBigInt().toDynamicInt().compareTo(12.2.toDecimal())),
          lessThanOrEqualTo(1));

      expect(((-12).toBigInt().toDynamicInt().compareTo(12.2.toDecimal())),
          lessThanOrEqualTo(1));

      expect(((12).toBigInt().toDynamicInt().compareTo(12.toDecimal())),
          equals(0));
    });

    test('compare operators (int int)', () {
      expect((123.toDynamicInt() == 123.toDynamicInt()), isTrue);
      expect((123.toDynamicInt() == 1234.toDynamicInt()), isFalse);
      expect((1234.toDynamicInt() == 123.toDynamicInt()), isFalse);

      expect((123.toDynamicInt() < 123.toDynamicInt()), isFalse);
      expect((123.toDynamicInt() < 1234.toDynamicInt()), isTrue);
      expect((1234.toDynamicInt() < 123.toDynamicInt()), isFalse);

      expect((123.toDynamicInt() > 123.toDynamicInt()), isFalse);
      expect((123.toDynamicInt() > 1234.toDynamicInt()), isFalse);
      expect((1234.toDynamicInt() > 123.toDynamicInt()), isTrue);

      expect((123.toDynamicInt() <= 123.toDynamicInt()), isTrue);
      expect((123.toDynamicInt() <= 1234.toDynamicInt()), isTrue);
      expect((1234.toDynamicInt() <= 123.toDynamicInt()), isFalse);

      expect((123.toDynamicInt() >= 123.toDynamicInt()), isTrue);
      expect((123.toDynamicInt() >= 1234.toDynamicInt()), isFalse);
      expect((1234.toDynamicInt() >= 123.toDynamicInt()), isTrue);
    });

    test('compare operators (BigInt int)', () {
      expect((123.toBigInt().toDynamicInt() == 123.toDynamicInt()), isTrue);
      expect((123.toBigInt().toDynamicInt() == 1234.toDynamicInt()), isFalse);
      expect((1234.toBigInt().toDynamicInt() == 123.toDynamicInt()), isFalse);

      expect((123.toBigInt().toDynamicInt() < 123.toDynamicInt()), isFalse);
      expect((123.toBigInt().toDynamicInt() < 1234.toDynamicInt()), isTrue);
      expect((1234.toBigInt().toDynamicInt() < 123.toDynamicInt()), isFalse);

      expect((123.toBigInt().toDynamicInt() > 123.toDynamicInt()), isFalse);
      expect((123.toBigInt().toDynamicInt() > 1234.toDynamicInt()), isFalse);
      expect((1234.toBigInt().toDynamicInt() > 123.toDynamicInt()), isTrue);

      expect((123.toBigInt().toDynamicInt() <= 123.toDynamicInt()), isTrue);
      expect((123.toBigInt().toDynamicInt() <= 1234.toDynamicInt()), isTrue);
      expect((1234.toBigInt().toDynamicInt() <= 123.toDynamicInt()), isFalse);

      expect((123.toBigInt().toDynamicInt() >= 123.toDynamicInt()), isTrue);
      expect((123.toBigInt().toDynamicInt() >= 1234.toDynamicInt()), isFalse);
      expect((1234.toBigInt().toDynamicInt() >= 123.toDynamicInt()), isTrue);
    });

    test('compare operators (BigInt BigInt)', () {
      expect((123.toBigInt().toDynamicInt() == 123.toBigInt().toDynamicInt()),
          isTrue);
      expect((123.toBigInt().toDynamicInt() == 1234.toBigInt().toDynamicInt()),
          isFalse);
      expect((1234.toBigInt().toDynamicInt() == 123.toBigInt().toDynamicInt()),
          isFalse);

      expect((123.toBigInt().toDynamicInt() < 123.toBigInt().toDynamicInt()),
          isFalse);
      expect((123.toBigInt().toDynamicInt() < 1234.toBigInt().toDynamicInt()),
          isTrue);
      expect((1234.toBigInt().toDynamicInt() < 123.toBigInt().toDynamicInt()),
          isFalse);

      expect((123.toBigInt().toDynamicInt() > 123.toBigInt().toDynamicInt()),
          isFalse);
      expect((123.toBigInt().toDynamicInt() > 1234.toBigInt().toDynamicInt()),
          isFalse);
      expect((1234.toBigInt().toDynamicInt() > 123.toBigInt().toDynamicInt()),
          isTrue);

      expect((123.toBigInt().toDynamicInt() <= 123.toBigInt().toDynamicInt()),
          isTrue);
      expect((123.toBigInt().toDynamicInt() <= 1234.toBigInt().toDynamicInt()),
          isTrue);
      expect((1234.toBigInt().toDynamicInt() <= 123.toBigInt().toDynamicInt()),
          isFalse);

      expect((123.toBigInt().toDynamicInt() >= 123.toBigInt().toDynamicInt()),
          isTrue);
      expect((123.toBigInt().toDynamicInt() >= 1234.toBigInt().toDynamicInt()),
          isFalse);
      expect((1234.toBigInt().toDynamicInt() >= 123.toBigInt().toDynamicInt()),
          isTrue);
    });

    test('compare operators (int Decime)', () {
      // ignore: unrelated_type_equality_checks
      expect((123.toDynamicInt() == 123.toDecimal()), isTrue);
      // ignore: unrelated_type_equality_checks
      expect((123.toDynamicInt() == 1234.toDecimal()), isFalse);
      // ignore: unrelated_type_equality_checks
      expect((1234.toDynamicInt() == 123.toDecimal()), isFalse);

      expect((123.toDynamicInt() < 123.toDecimal()), isFalse);
      expect((123.toDynamicInt() < 1234.toDecimal()), isTrue);
      expect((1234.toDynamicInt() < 123.toDecimal()), isFalse);

      expect((123.toDynamicInt() > 123.toDecimal()), isFalse);
      expect((123.toDynamicInt() > 1234.toDecimal()), isFalse);
      expect((1234.toDynamicInt() > 123.toDecimal()), isTrue);

      expect((123.toDynamicInt() <= 123.toDecimal()), isTrue);
      expect((123.toDynamicInt() <= 1234.toDecimal()), isTrue);
      expect((1234.toDynamicInt() <= 123.toDecimal()), isFalse);

      expect((123.toDynamicInt() >= 123.toDecimal()), isTrue);
      expect((123.toDynamicInt() >= 1234.toDecimal()), isFalse);
      expect((1234.toDynamicInt() >= 123.toDecimal()), isTrue);
    });

    test('sign', () {
      expect(123.toDynamicInt().sign, equals(1));
      expect((-123).toDynamicInt().sign, equals(-1));
      expect(0.toDynamicInt().sign, equals(0));

      expect(123.toBigInt().toDynamicInt().sign, equals(1));
      expect((-123).toBigInt().toDynamicInt().sign, equals(-1));
      expect(0.toBigInt().toDynamicInt().sign, equals(0));
    });

    test('isNegative', () {
      expect(123.toDynamicInt().isNegative, isFalse);
      expect((-123).toDynamicInt().isNegative, isTrue);
      expect(0.toDynamicInt().isNegative, isFalse);

      expect(123.toBigInt().toDynamicInt().isNegative, isFalse);
      expect((-123).toBigInt().toDynamicInt().isNegative, isTrue);
      expect(0.toBigInt().toDynamicInt().isNegative, isFalse);
    });

    test('isPositive', () {
      expect(123.toDynamicInt().isPositive, isTrue);
      expect((-123).toDynamicInt().isPositive, isFalse);
      expect(0.toDynamicInt().isPositive, isFalse);

      expect(123.toBigInt().toDynamicInt().isPositive, isTrue);
      expect((-123).toBigInt().toDynamicInt().isPositive, isFalse);
      expect(0.toBigInt().toDynamicInt().isPositive, isFalse);
    });

    test('isZero', () {
      expect(0.toDynamicInt().isZero, isTrue);
      expect(1.toDynamicInt().isZero, isFalse);
      expect((-1).toDynamicInt().isZero, isFalse);
      expect(123.toDynamicInt().isZero, isFalse);
      expect((-123).toDynamicInt().isZero, isFalse);

      expect(0.toBigInt().toDynamicInt().isZero, isTrue);
      expect(1.toBigInt().toDynamicInt().isZero, isFalse);
      expect((-1).toBigInt().toDynamicInt().isZero, isFalse);
    });

    test('isOne', () {
      expect(1.toDynamicInt().isOne, isTrue);
      expect(0.toDynamicInt().isOne, isFalse);
      expect((-1).toDynamicInt().isOne, isFalse);
      expect(123.toDynamicInt().isOne, isFalse);
      expect((-123).toDynamicInt().isOne, isFalse);

      expect(1.toBigInt().toDynamicInt().isOne, isTrue);
      expect(0.toBigInt().toDynamicInt().isOne, isFalse);
      expect((-1).toBigInt().toDynamicInt().isOne, isFalse);
    });

    test('sum', () {
      expect(
          (123.toDynamicInt() + 123.toDynamicInt()).toString(), equals('246'));

      expect(
          (123.toDynamicInt() + 123.toDecimal()).toString(), equals('246.0'));

      expect(
          (123.toDynamicInt() + 123.toDynamicInt().asDynamicIntBig).toString(),
          equals('246'));

      expect((123.toDynamicInt().sumInt(123)).toString(), equals('246'));

      expect((123.toDynamicInt().sumInt(0)).toString(), equals('123'));

      expect((0.toDynamicInt().sumInt(456)).toString(), equals('456'));

      expect((123.toDynamicInt().sumDynamicInt(123.toDynamicInt())).toString(),
          equals('246'));

      expect(
          (123.toDynamicInt().asDynamicIntBig.sumDynamicInt(123.toDynamicInt()))
              .toString(),
          equals('246'));

      expect(
          (123.toDynamicInt().sumAsDynamicIntBig(123.toDynamicInt()))
              .toString(),
          equals('246'));

      expect(
          (123.toDynamicInt().sumAsDynamicIntBig(123.toDynamicInt())).isBigInt,
          isTrue);

      expect(
          (123
                  .toDynamicInt()
                  .asDynamicIntBig
                  .sumAsDynamicIntBig(123.toDynamicInt()))
              .toString(),
          equals('246'));

      expect(
          (123
                  .toDynamicInt()
                  .asDynamicIntBig
                  .sumAsDynamicIntBig(123.toDynamicInt()))
              .isBigInt,
          isTrue);

      expect(
          (DynamicInt.parse('123456789012345678901234567000') + 0.toDecimal())
              .toString(),
          equals('123456789012345678901234567000.0'));

      expect(
          (DynamicInt.parse('123456789012345678901234567000') + 123.toDecimal())
              .toString(),
          equals('123456789012345678901234567123.0'));

      expect(
          (DynamicInt.parse('12345678901234567000') + 123.toDynamicInt())
              .toString(),
          equals('12345678901234567123'));

      expect((DynamicInt.parse('12345678901234567000').sumInt(124)).toString(),
          equals('12345678901234567124'));

      expect((DynamicInt.parse('123').sumBigInt(BigInt.from(125))).toString(),
          equals('248'));

      expect(
          (DynamicInt.parse('12345678901234567000').sumBigInt(BigInt.from(125)))
              .toString(),
          equals('12345678901234567125'));

      expect((DynamicInt.parse('12345678901234567000').sumInt(123)).toString(),
          equals('12345678901234567123'));

      expect((DynamicInt.parse('45678901234567000').sum(123.2)).toString(),
          equals('45678901234567123.2'));

      expect((DynamicInt.parse('45678901234567000').sum(123.21)).toString(),
          equals('45678901234567123.21'));

      expect((DynamicInt.parse('45678901234567000').sumInt(123)).toString(),
          equals('45678901234567123'));

      expect((DynamicInt.parse('45678901234567000').sumInt(0)).toString(),
          equals('45678901234567000'));

      expect(
          (DynamicInt.parse('12345678901234567000').sumBigInt(123.toBigInt()))
              .toString(),
          equals('12345678901234567123'));

      expect((DynamicInt.parse('12345678901234567000').sum(123.2)).toString(),
          equals('12345678901234567123.2'));

      expect((DynamicInt.parse('12345678901234567000').sum(123)).toString(),
          equals('12345678901234567123'));

      expect(
          (DynamicInt.parse('12345678901234567000').sumBigInt(123.toBigInt()))
              .toString(),
          equals('12345678901234567123'));

      expect((DynamicInt.parse('12345678901234567000').sumInt(123)).toString(),
          equals('12345678901234567123'));

      expect((DynamicInt.parse('12345678901234567000').sumInt(0)).toString(),
          equals('12345678901234567000'));

      expect(
          (DynamicInt.parse('12345678901234567000').asDynamicIntBig.sumInt(0))
              .toString(),
          equals('12345678901234567000'));

      expect(
          (DynamicInt.parse('12345678901234567000').asDynamicIntBig.sumInt(123))
              .toString(),
          equals('12345678901234567123'));

      expect(
          (DynamicInt.fromInt(DynamicInt.maxSafeInteger)
                  .sumInt(DynamicInt.maxSafeInteger))
              .toString(),
          equals(
              (DynamicInt.maxSafeInteger.toBigInt() * BigInt.two).toString()));

      expect(
          (DynamicInt.fromInt(DynamicInt.maxSafeInteger).sumInt(0)).toString(),
          equals(DynamicInt.maxSafeInteger.toString()));

      expect(
          (DynamicInt.parse('1234567890123456789012345678901234567000')
                  .asDynamicIntBig
                  .sumInt(0))
              .toString(),
          equals('1234567890123456789012345678901234567000'));

      expect(
          (DynamicInt.parse('1234567890123456789012345678901234567000')
                  .asDynamicIntBig
                  .sumInt(123))
              .toString(),
          equals('1234567890123456789012345678901234567123'));
    });

    test('subtract', () {
      expect((123.toDynamicInt() - 123.toDynamicInt()).toString(), equals('0'));

      expect(
          (123.toDynamicInt() - -123.toDynamicInt()).toString(), equals('246'));
      expect((123.toDynamicInt() - 1000.toDynamicInt()).toString(),
          equals('-877'));

      expect(
          (123.toDynamicInt() - 123.toDynamicInt().asDynamicIntBig).toString(),
          equals('0'));
      expect(
          (123.toDynamicInt() - -123.toDynamicInt().asDynamicIntBig).toString(),
          equals('246'));
      expect(
          (123.toDynamicInt() - 1000.toDynamicInt().asDynamicIntBig).toString(),
          equals('-877'));

      expect((123.toDynamicInt() - -123.toDynamicInt().toDecimal()).toString(),
          equals('246.0'));

      expect(
          (123.toDynamicInt().asDynamicIntBig -
                  123.toDynamicInt().asDynamicIntBig)
              .toString(),
          equals('0'));
      expect(
          (123.toDynamicInt().asDynamicIntBig -
                  -123.toDynamicInt().asDynamicIntBig)
              .toString(),
          equals('246'));

      expect((123.toDynamicInt().asDynamicIntBig - -123.toDecimal()).toString(),
          equals('246.0'));

      expect((123.toDynamicInt() - 123.toDecimal()).toString(), equals('0.0'));
      expect(
          (123.toDynamicInt() - -123.toDecimal()).toString(), equals('246.0'));
      expect(
          (123.toDynamicInt() - 1000.toDecimal()).toString(), equals('-877.0'));

      expect((123.toDynamicInt().subtractInt(123)).toString(), equals('0'));
      expect((123.toDynamicInt().subtractInt(-123)).toString(), equals('246'));

      expect((123.toDynamicInt().subtractBigInt(123.toBigInt())).toString(),
          equals('0'));
      expect((123.toDynamicInt().subtractBigInt(-123.toBigInt())).toString(),
          equals('246'));

      expect(
          (123.toDynamicInt().subtractDynamicInt(-123.toDynamicInt()))
              .toString(),
          equals('246'));

      expect(
          (123
                  .toDynamicInt()
                  .asDynamicIntBig
                  .subtractDynamicInt(-123.toDynamicInt()))
              .toString(),
          equals('246'));

      expect(
          (123.toDynamicInt().subtractAsDynamicIntBig(-123.toDynamicInt()))
              .toString(),
          equals('246'));

      expect(
          (123
                  .toDynamicInt()
                  .asDynamicIntBig
                  .subtractAsDynamicIntBig(-123.toDynamicInt()))
              .toString(),
          equals('246'));

      expect(
          (DynamicInt.parse('12345678901234567000') - 155.toDynamicInt())
              .toString(),
          equals('12345678901234566845'));

      expect(
          (DynamicInt.parse('12345678901234567000').subtractInt(156))
              .toString(),
          equals('12345678901234566844'));

      expect(
          (DynamicInt.parse('12345678901234567000')
                  .subtractBigInt(BigInt.from(157)))
              .toString(),
          equals('12345678901234566843'));

      expect(
          (DynamicInt.parse('12345678901234567000').subtract(157)).toString(),
          equals('12345678901234566843'));

      expect(
          (DynamicInt.parse('12345678901234567000').subtract(157.0)).toString(),
          anyOf(equals('12345678901234566843.0'),
              equals('12345678901234566843')));

      expect(
          (DynamicInt.parse('12345678901234567000').subtract(157.40))
              .toString(),
          equals('12345678901234566842.6'));

      expect(
          (DynamicInt.parse('45678901234567000').subtract(157.40)).toString(),
          equals('45678901234566842.6'));

      expect(
          (DynamicInt.fromInt(DynamicInt.maxSafeInteger).subtractInt(0))
              .toString(),
          equals(DynamicInt.maxSafeInteger.toString()));

      expect(
          (DynamicInt.fromInt(DynamicInt.maxSafeInteger)
                  .subtractInt(DynamicInt.maxSafeInteger))
              .toString(),
          equals('0'));
    });

    test('multiply', () {
      expect(
          (123.toDynamicInt() * 10.toDynamicInt()).toString(), equals('1230'));

      expect(
          (123.toDynamicInt().asDynamicIntBig * 10.toDynamicInt()).toString(),
          equals('1230'));

      expect(
          (123.toDynamicInt() * 10.1.toDecimal()).toString(), equals('1242.3'));

      expect((123.toDynamicInt().asDynamicIntBig * 10.1.toDecimal()).toString(),
          equals('1242.3'));

      expect(
          (DynamicInt.parse('12345678901234567') * 1000.toDynamicInt())
              .toString(),
          equals('12345678901234567000'));

      expect(
          (DynamicInt.parse('12345678901234567').multiplyInt(100)).toString(),
          equals('1234567890123456700'));

      expect(
          (DynamicInt.parse('12345678901234567')
                  .multiplyBigInt(BigInt.from(1000000)))
              .toString(),
          equals('12345678901234567000000'));

      expect(
          (DynamicInt.parse('12345678901234567')
                  .asDynamicIntBig
                  .multiplyBigInt(BigInt.from(1000000)))
              .toString(),
          equals('12345678901234567000000'));

      expect(
          (DynamicInt.parse('12345678901234567').multiplyDouble(100.0))
              .toString(),
          equals('1234567890123456700.0'));

      expect(
          (DynamicInt.parse('12345678901234567').multiply(100.0)).toString(),
          anyOf(
              equals('1234567890123456700.0'), equals('1234567890123456700')));

      expect((DynamicInt.parse('12345678901234567').multiply(100.1)).toString(),
          equals('1235802458013580156.7'));

      expect((DynamicInt.parse('1234567').multiply(100.1)).toString(),
          equals('123580156.7'));

      expect((DynamicInt.parse('567891234567').multiply(100.1)).toString(),
          equals('56845912580156.7'));

      expect((DynamicInt.parse('4567891234567').multiply(100.1)).toString(),
          equals('457245912580156.7'));

      expect((DynamicInt.parse('34567891234567').multiply(100.1)).toString(),
          equals('3460245912580156.7'));

      expect((DynamicInt.parse('1234567891234567').multiply(100.1)).toString(),
          equals('123580245912580156.7'));

      expect((DynamicInt.parse('1234567891234567').multiply(100)).toString(),
          equals('123456789123456700'));

      expect(
          (DynamicInt.parse('123').multiplyInt(2)).toString(), equals('246'));

      expect(
          (DynamicInt.parse('123').asDynamicIntBig.multiplyInt(2)).toString(),
          equals('246'));

      expect((DynamicInt.parse('123').multiplyBigInt(2.toBigInt())).toString(),
          equals('246'));

      expect(
          (DynamicInt.parse('123').multiplyDynamicInt(2.toDynamicInt()))
              .toString(),
          equals('246'));

      expect(
          (DynamicInt.parse('123')
                  .multiplyDynamicInt(2.toDynamicInt().asDynamicIntBig))
              .toString(),
          equals('246'));

      expect(
          (DynamicInt.parse('123')
                  .multiplyAsDynamicIntBig(2.toDynamicInt().asDynamicIntBig))
              .toString(),
          equals('246'));

      expect(
          DynamicInt.parse('123')
              .multiplyAsDynamicIntBig(2.toDynamicInt())
              .isBigInt,
          isTrue);

      expect(
          DynamicInt.parse('123')
              .asDynamicIntBig
              .multiplyAsDynamicIntBig(2.toDynamicInt())
              .isBigInt,
          isTrue);
    });

    test('divide', () {
      expect(
          (1000.toDynamicInt() ~/ 2.toDynamicInt()).toString(), equals('500'));

      expect(
          (1000.toDynamicInt() ~/ 2.toDynamicInt().asDynamicIntBig).toString(),
          equals('500'));

      expect((1000.toDynamicInt() ~/ 2.toDecimal()).toString(), equals('500'));

      expect(
          (DynamicInt.parse('100000000000000000000000') ~/ 2.toDynamicInt())
              .toString(),
          equals('50000000000000000000000'));

      expect(
          (1001.toDynamicInt() / 2.toDynamicInt()).toString(), equals('500.5'));

      expect(
          (1001.toDynamicInt() / 2.toDynamicInt().asDynamicIntBig).toString(),
          equals('500.5'));

      expect((1001.toDynamicInt() / 2.toDecimal()).toString(), equals('500.5'));

      expect((1001.toDynamicInt().asDynamicIntBig / 2.toDecimal()).toString(),
          equals('500.5'));

      expect(
          (DynamicInt.parse('1234567890123456789').toDynamicInt() /
                  DynamicInt.parse('12345678901234567890'))
              .toString(),
          equals('0.1'));

      expect(
          (1234567890.toDynamicInt() / DynamicInt.parse('12345678900000000000'))
              .toString(),
          equals('0.0000000001'));

      expect((1000.toDynamicInt().divideInt(2)).toString(), equals('500'));

      expect((1000.toDynamicInt().divideInt(10)).toString(), equals('100'));

      expect((1000.toDynamicInt().divideBigInt(10.toBigInt())).toString(),
          equals('100'));

      expect(
          (1000.toDynamicInt().divideDynamicInt(10.toDynamicInt())).toString(),
          equals('100'));

      expect(
          (1000
                  .toDynamicInt()
                  .asDynamicIntBig
                  .divideDynamicInt(10.toDynamicInt()))
              .toString(),
          equals('100'));

      expect(
          (1000
                  .toDynamicInt()
                  .divideDynamicInt(10.toDynamicInt().asDynamicIntBig))
              .toString(),
          equals('100'));

      expect(
          (1000.toDynamicInt().divideAsDynamicIntBig(10.toDynamicInt()))
              .toString(),
          equals('100'));

      expect(
          (1000.toDynamicInt().divideDouble(10.0)).toString(), equals('100.0'));

      expect(
          (1000.toDynamicInt().asDynamicIntBig.divideDouble(10.0)).toString(),
          equals('100.0'));

      expect(
          (1000.toDynamicInt().divideDouble(20.0)).toString(), equals('50.0'));

      expect((1000.toDynamicInt().divide(10)).toString(), equals('100'));

      expect((1000.toDynamicInt().divide(10.0)).toString(),
          anyOf(equals('100.0'), equals('100')));

      expect((1000.toDynamicInt().divideInt(10)).toString(),
          anyOf(equals('100.0'), equals('100')));
      expect((1000.toDynamicInt().divideBigInt(10.toBigInt())).toString(),
          anyOf(equals('100.0'), equals('100')));

      expect((1000.toDynamicInt().asDynamicIntBig.divideInt(10)).toString(),
          anyOf(equals('100.0'), equals('100')));
      expect(
          (1000.toDynamicInt().asDynamicIntBig.divideBigInt(10.toBigInt()))
              .toString(),
          anyOf(equals('100.0'), equals('100')));

      expect((1000.toDynamicInt().divideIntAsDouble(10)).toString(),
          anyOf(equals('100.0'), equals('100')));

      expect(
          (1000.toDynamicInt().asDynamicIntBig.divideIntAsDouble(10))
              .toString(),
          anyOf(equals('100.0'), equals('100')));

      expect((1000.toDynamicInt().divideDoubleAsDouble(10.0)).toString(),
          anyOf(equals('100.0'), equals('100')));

      expect(
          (1000.toDynamicInt().asDynamicIntBig.divideDoubleAsDouble(10.0))
              .toString(),
          anyOf(equals('100.0'), equals('100')));

      expect((1000.toDynamicInt().divideNumAsDouble(10.0)).toString(),
          anyOf(equals('100.0'), equals('100')));

      expect(
          (1000.toDynamicInt().asDynamicIntBig.divideNumAsDouble(10.0))
              .toString(),
          anyOf(equals('100.0'), equals('100')));

      expect((1000.toDynamicInt().divideNumAsDouble(10)).toString(),
          anyOf(equals('100.0'), equals('100')));

      expect(
          (1000.toDynamicInt().asDynamicIntBig.divideNumAsDouble(10))
              .toString(),
          anyOf(equals('100.0'), equals('100')));

      expect(
          (1000.toDynamicInt().divideBigIntAsDouble(10.toBigInt())).toString(),
          anyOf(equals('100.0'), equals('100')));

      expect(
          (1000
                  .toDynamicInt()
                  .asDynamicIntBig
                  .divideBigIntAsDouble(10.toBigInt()))
              .toString(),
          anyOf(equals('100.0'), equals('100')));

      expect((1000.toDynamicInt().divideIntAsDecimal(10)).toString(),
          anyOf(equals('100.0'), equals('100')));

      expect((1000.toDynamicInt().divideDoubleAsDecimal(3.0)).toString(),
          equals('333.3333333333333333'));

      expect((1000.toDynamicInt().divideNumAsDecimal(3)).toString(),
          equals('333.3333333333333333'));

      expect((1000.toDynamicInt().divideDoubleAsDecimal(3.0)).toString(),
          equals('333.3333333333333333'));

      expect(
          (1000.toDynamicInt().divideBigIntAsDecimal(3.toBigInt())).toString(),
          equals('333.3333333333333333'));

      expect((1000.toDynamicInt().divideNumAsDecimal(10)).toString(),
          equals('100.0'));

      expect((1000.toDynamicInt().divideNumAsDecimal(10.0)).toString(),
          equals('100.0'));

      expect(
          (1000.toDynamicInt().divideDynamicIntAsDecimal(10.toDynamicInt()))
              .toString(),
          equals('100.0'));

      expect(
          (1000
                  .toDynamicInt()
                  .divideDynamicIntAsDecimal(10.toDynamicInt().asDynamicIntBig))
              .toString(),
          equals('100.0'));

      expect(
          (1000.toDynamicInt().divideAsDynamicIntBig(10.toDynamicInt()))
              .toString(),
          equals('100'));

      expect(
          (1000
                  .toDynamicInt()
                  .asDynamicIntBig
                  .divideAsDynamicIntBig(10.toDynamicInt()))
              .toString(),
          equals('100'));
    });

    test('modulo', () {
      expect(10.toDynamicInt().moduloInt(10).toString(), equals('0'));
      expect(11.toDynamicInt().moduloInt(10).toString(), equals('1'));
      expect(13.toDynamicInt().moduloInt(10).toString(), equals('3'));

      expect(10.toDynamicInt().moduloBigInt(10.toBigInt()).toString(),
          equals('0'));
      expect(11.toDynamicInt().moduloBigInt(10.toBigInt()).toString(),
          equals('1'));
      expect(13.toDynamicInt().moduloBigInt(10.toBigInt()).toString(),
          equals('3'));

      expect(
          10
              .toDynamicInt()
              .asDynamicIntBig
              .moduloBigInt(10.toBigInt())
              .toString(),
          equals('0'));
      expect(
          11
              .toDynamicInt()
              .asDynamicIntBig
              .moduloBigInt(10.toBigInt())
              .toString(),
          equals('1'));
      expect(
          13
              .toDynamicInt()
              .asDynamicIntBig
              .moduloBigInt(10.toBigInt())
              .toString(),
          equals('3'));

      expect(10.toDynamicInt().moduloDynamicInt(10.toDynamicInt()).toString(),
          equals('0'));
      expect(11.toDynamicInt().moduloDynamicInt(10.toDynamicInt()).toString(),
          equals('1'));
      expect(13.toDynamicInt().moduloDynamicInt(10.toDynamicInt()).toString(),
          equals('3'));

      expect(
          13
              .toDynamicInt()
              .moduloDynamicInt(10.toDynamicInt().asDynamicIntBig)
              .toString(),
          equals('3'));

      expect((13.toDynamicInt().asDynamicIntBig % 10.toDynamicInt()).toString(),
          equals('3'));

      expect((13.toDynamicInt() % 10.toDecimal()).toString(), equals('3.0'));

      expect((13.toDynamicInt() % 10.toDynamicInt().asDynamicIntBig).toString(),
          equals('3'));

      expect((13.toDynamicInt().asDynamicIntBig % 10.toDecimal()).toString(),
          equals('3.0'));
    });

    test('sin', () {
      expect(DynamicInt.fromInt(1).sin,
          equals(Decimal.fromDouble(0.8414709848078965)));
      expect(DynamicInt.fromInt(-1).sin,
          equals(Decimal.fromDouble(-0.8414709848078965)));

      expect(DynamicInt.fromInt(10).sin,
          equals(Decimal.fromDouble(-0.5440211108893699)));
      expect(DynamicInt.fromInt(-10).sin,
          equals(Decimal.fromDouble(0.5440211108893699)));
    });

    test('cos', () {
      expect(DynamicInt.fromInt(1).cos,
          equals(Decimal.fromDouble(0.5403023058681398)));
      expect(DynamicInt.fromInt(-1).cos,
          equals(Decimal.fromDouble(0.5403023058681398)));

      expect(DynamicInt.fromInt(10).cos,
          equals(Decimal.fromDouble(-0.8390715290764524)));
      expect(DynamicInt.fromInt(-10).cos,
          equals(Decimal.fromDouble(-0.8390715290764524)));
    });

    test('square', () {
      expect(1.toDynamicInt().square.toString(), equals('1'));
      expect(10.toDynamicInt().square.toString(), equals('100'));
      expect(20.toDynamicInt().square.toString(), equals('400'));
    });

    test('power', () {
      expect(0.toDynamicInt().power(2.toDynamicInt()).toString(), equals('0'));
      expect(0.toDynamicInt().power(0.toDynamicInt()).toString(), equals('1'));
      expect(2.toDynamicInt().power(0.toDynamicInt()).toString(), equals('1'));
      expect(10.toDynamicInt().power(0.toDynamicInt()).toString(), equals('1'));

      expect(() => 2.toDynamicInt().powerAsDynamicInt((-1).toDynamicInt()),
          throwsA(isA<UnsupportedError>()));

      expect(2.toDynamicInt().powerAsDecimal((-1).toDynamicInt()).toString(),
          equals('0.5'));

      expect(() => 2.toDynamicInt().powerAsDynamicInt((-2).toDynamicInt()),
          throwsA(isA<UnsupportedError>()));

      expect(() => 2.toDynamicInt().powerAsDynamicInt((-3).toDynamicInt()),
          throwsA(isA<UnsupportedError>()));

      expect(2.toDynamicInt().power(2.toDynamicInt()).toString(), equals('4'));
      expect(4.toDynamicInt().power(2.toDynamicInt()).toString(), equals('16'));
      expect(5.toDynamicInt().power(2.toDynamicInt()).toString(), equals('25'));
      expect(8.toDynamicInt().power(2.toDynamicInt()).toString(), equals('64'));

      expect(
          (-2).toDynamicInt().power(2.toDynamicInt()).toString(), equals('4'));
      expect(
          (-4).toDynamicInt().power(2.toDynamicInt()).toString(), equals('16'));
      expect(
          (-5).toDynamicInt().power(2.toDynamicInt()).toString(), equals('25'));
      expect(
          (-8).toDynamicInt().power(2.toDynamicInt()).toString(), equals('64'));

      expect(2.toDynamicInt().power(3.toDynamicInt()).toString(), equals('8'));
      expect(4.toDynamicInt().power(3.toDynamicInt()).toString(), equals('64'));
      expect(
          5.toDynamicInt().power(3.toDynamicInt()).toString(), equals('125'));
      expect(
          8.toDynamicInt().power(3.toDynamicInt()).toString(), equals('512'));

      expect(
          (-2).toDynamicInt().power(3.toDynamicInt()).toString(), equals('-8'));
      expect((-4).toDynamicInt().power(3.toDynamicInt()).toString(),
          equals('-64'));
      expect((-5).toDynamicInt().power(3.toDynamicInt()).toString(),
          equals('-125'));
      expect((-8).toDynamicInt().power(3.toDynamicInt()).toString(),
          equals('-512'));

      expect(123.toDynamicInt().power(12.toDynamicInt()).toString(),
          equals('11991163848716906297072721'));

      expect((-123).toDynamicInt().power(12.toDynamicInt()).toString(),
          equals('11991163848716906297072721'));

      expect(123.toDynamicInt().power(13.toDynamicInt()).toString(),
          equals('1474913153392179474539944683'));

      expect((-123).toDynamicInt().power(13.toDynamicInt()).toString(),
          equals('-1474913153392179474539944683'));

      expect(123.toDynamicInt().power(20.toDynamicInt()).toString(),
          equals('628206215175202159781085149496179361969201'));

      expect(
          123.toDynamicInt().power(30.toDynamicInt()).toString(),
          equals(
              '497912859868342793044999075260564303046944727069807798026337449'));

      expect(
          (-123).toDynamicInt().power(30.toDynamicInt()).toString(),
          equals(
              '497912859868342793044999075260564303046944727069807798026337449'));

      expect(
          (123).toDynamicInt().power(31.toDynamicInt()).toString(),
          equals(
              '61243281763806163544534886257049409274774201429586359157239506227'));

      expect(
          (-123).toDynamicInt().power(31.toDynamicInt()).toString(),
          equals(
              '-61243281763806163544534886257049409274774201429586359157239506227'));

      expect(
          123.toDynamicInt().power(41.toDynamicInt()).toString(),
          equals(
              '48541095000524544750127162673405880068636916264012200797813591925035550682238127143323'));

      expect(
          (-123).toDynamicInt().power(41.toDynamicInt()).toString(),
          equals(
              '-48541095000524544750127162673405880068636916264012200797813591925035550682238127143323'));
    });

    test('squareRoot', () {
      expect(4.toDynamicInt().squareRoot.toString(), equals('2.0'));
      expect(100.toDynamicInt().squareRoot.toString(), equals('10.0'));
      expect(100.toDynamicInt().asDynamicIntBig.squareRoot.toString(),
          equals('10.0'));

      expect(
          DynamicInt.parse('1000000000000')
              .asDynamicIntBig
              .squareRoot
              .toString(),
          equals('1000000.0'));

      expect(
          DynamicInt.parse('1000000000000000000000000')
              .asDynamicIntBig
              .squareRoot
              .toString(),
          equals('1000000000000.0'));
    });

    test('extension', () {
      expect([1, 2, 3].asDynamicInt,
          equals([1.toDynamicInt(), 2.toDynamicInt(), 3.toDynamicInt()]));

      expect([1, 2.2, 3].asDynamicInt,
          equals([1.toDynamicInt(), 2.toDynamicInt(), 3.toDynamicInt()]));

      expect([1.1, 2.2, 3.3].asDynamicInt,
          equals([1.toDynamicInt(), 2.toDynamicInt(), 3.toDynamicInt()]));

      expect([1.toBigInt(), 2.toBigInt(), 3.toBigInt()].asDynamicInt,
          equals([1.toDynamicInt(), 2.toDynamicInt(), 3.toDynamicInt()]));

      expect([1.toBigInt(), 2.toBigInt(), 3.toBigInt()].asDynamicInt.asInt,
          equals([1, 2, 3]));

      expect([1.toBigInt(), 2.toBigInt(), 3.toBigInt()].asDynamicInt.asDouble,
          equals([1.0, 2.0, 3.0]));

      expect([1.toBigInt(), 2.toBigInt(), 3.toBigInt()].asDynamicInt.asNum,
          equals([1, 2, 3]));

      expect([1.toBigInt(), 2.toBigInt(), 3.toBigInt()].asDynamicInt.sum,
          equals(6.toDynamicInt()));

      expect(
          <DynamicInt>[1.toDynamicInt(), 2.toDynamicInt(), 3.toDynamicInt()]
              .sum,
          equals(6.toDynamicInt()));

      expect(
          <DynamicNumber>[1.toDynamicInt(), 2.toDecimal(), 3.toDynamicInt()]
              .sum,
          equals(6.toDynamicInt()));

      expect(
          <DynamicInt>[1.toDynamicInt(), 2.toDynamicInt(), 3.toDynamicInt()]
              .sumSquares,
          equals((1 + 4 + 9).toDynamicInt()));

      expect(
          <DynamicNumber>[1.toDynamicInt(), 2.toDecimal(), 3.toDynamicInt()]
              .sumSquares,
          equals((1 + 4 + 9).toDynamicInt()));

      expect(
          <DynamicInt>[1.toDynamicInt(), 2.toDynamicInt(), 3.toDynamicInt()]
              .mean,
          equals(2.toDynamicInt()));

      expect(
          <DynamicNumber>[1.toDynamicInt(), 2.toDecimal(), 3.toDynamicInt()]
              .mean,
          equals(2.toDynamicInt()));

      expect(
          <DynamicInt>[1.toDynamicInt(), 2.toDynamicInt(), 3.toDynamicInt()]
              .standardDeviation,
          equals(Decimal.parse(
              '0.8164965809277259919075989785156611400798550887964415634737670678')));

      expect(
          <DynamicNumber>[1.toDynamicInt(), 2.toDecimal(), 3.toDynamicInt()]
              .standardDeviation,
          equals(Decimal.parse(
              '0.8164965809277259919075989785156611400798550887964415634737670678')));

      expect(
          <DynamicInt>[1.toDynamicInt(), 2.toDynamicInt(), 3.toDynamicInt()]
              .squaresMean,
          equals(Decimal.parse('4.6666666666666666')));

      expect(
          <DynamicNumber>[1.toDynamicInt(), 2.toDecimal(), 3.toDynamicInt()]
              .squaresMean,
          equals(Decimal.parse('4.6666666666666666')));

      expect(
          <DynamicInt>[1.toDynamicInt(), 2.toDynamicInt(), 3.toDynamicInt()]
              .squares
              .toIntList(),
          equals([1, 4, 9]));

      expect(
          <DynamicNumber>[1.toDynamicInt(), 2.toDecimal(), 3.toDynamicInt()]
              .squares
              .toIntList(),
          equals([1, 4, 9]));

      expect(
          <DynamicInt>[1.toDynamicInt(), 2.toDynamicInt(), 3.toDynamicInt()]
              .squaresRoots,
          equals([
            Decimal.one,
            Decimal.parse('1.414213562373095'),
            Decimal.parse('1.732050807568877')
          ].asDecimal));

      expect(
          <DynamicNumber>[1.toDynamicInt(), 2.toDecimal(), 3.toDynamicInt()]
              .squaresRoots,
          equals([
            Decimal.one,
            Decimal.parse('1.414213562373095'),
            Decimal.parse('1.732050807568877')
          ].asDecimal));

      expect(
          <DynamicInt>[1.toDynamicInt(), -2.toDynamicInt(), 3.toDynamicInt()]
              .abs,
          equals([1, 2, 3].asDynamicInt));

      expect(
          <DynamicNumber>[1.toDynamicInt(), -2.toDecimal(), 3.toDynamicInt()]
              .abs
              .toDoubleList(),
          equals([1.0, 2.0, 3.0]));
    });
  });
}
