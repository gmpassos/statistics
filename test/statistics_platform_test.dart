@Tags(['num', 'platform'])
import 'dart:typed_data';

import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

const testSafeNumbers = {
  1: '00000000 00000001',
  -1: 'FFFFFFFF FFFFFFFF',
  2: '00000000 00000002',
  -2: 'FFFFFFFF FFFFFFFE',
  123: '00000000 0000007B',
  -123: 'FFFFFFFF FFFFFF85',
  70123: '00000000 000111EB',
  268435455: '00000000 0FFFFFFF',
  -268435455: 'FFFFFFFF F0000001',
  267324344: '00000000 0FEF0BB8',
  -267324344: 'FFFFFFFF F010F448',
  4294967296: '00000001 00000000',
  -4294967296: 'FFFFFFFF 00000000',
  4294967295: '00000000 FFFFFFFF',
  -4294967295: 'FFFFFFFF 00000001',
  4294967294: '00000000 FFFFFFFE',
  -4294967294: 'FFFFFFFF 00000002',
  4294967293: '00000000 FFFFFFFD',
  -4294967293: 'FFFFFFFF 00000003',
  4264967294: '00000000 FE363C7E',
  -4264967294: 'FFFFFFFF 01C9C382',
  4294665294: '00000000 FFFB644E',
  -4294665294: 'FFFFFFFF 00049BB2',
  68719476735: '0000000F FFFFFFFF',
  -68719476735: 'FFFFFFF0 00000001',
  1099511627775: '000000FF FFFFFFFF',
  -1099511627775: 'FFFFFF00 00000001',
  17592186044415: '00000FFF FFFFFFFF',
  -17592186044415: 'FFFFF000 00000001',
  281474976710655: '0000FFFF FFFFFFFF',
  -281474976710655: 'FFFF0000 00000001',
  4503599627370495: '000FFFFF FFFFFFFF',
  -4503599627370495: 'FFF00000 00000001',
  9007199254740991: '001FFFFF FFFFFFFF',
  -9007199254740991: 'FFE00000 00000001',
};

final p = StatisticsPlatform();

void _testNumber(int n, String result) {
  print('---> $n > ${(n >> 32).toHex32()} + ${n.toHex32()}');

  var r64 = result.replaceAll(RegExp(r'\s'), '').decodeHex();
  expect(r64.length, equals(8));

  var bs1 = Uint8List(8);
  var bs2 = Uint8List(8);

  p.writeUint64(bs1, n);
  p.writeInt64(bs2, n);

  expect(bs1, equals(r64));
  expect(bs2, equals(r64));

  print('   > $n > ${n.toHex64()}');

  int nRead1 = p.readUint64(bs1);
  int nRead2 = p.readInt64(bs2);

  expect(nRead1, equals(n),
      reason: 'n: $n > ${n.toHex64()} != $nRead1 > ${nRead1.toHex64()}');
  expect(nRead2, equals(n));

  expect(p.isSafeInteger(n), isTrue,
      reason: 'Not safe number($n) for platform: $p');

  p.checkSafeInteger(n);
}

void main() {
  group('StatisticsPlatform', () {
    setUp(() {});

    test('53 bits Limits', () {
      expect(p.isSafeInteger(9007199254740991), isTrue);
      expect(p.isSafeInteger(-9007199254740991), isTrue);

      p.checkSafeInteger(9007199254740991);
      p.checkSafeInteger(-9007199254740991);

      expect(p.isSafeIntegerByBigInt(9007199254740991.toBigInt()), isTrue);
      expect(p.isSafeIntegerByBigInt(-9007199254740991.toBigInt()), isTrue);

      p.checkSafeIntegerByBigInt(9007199254740991.toBigInt());
      p.checkSafeIntegerByBigInt(-9007199254740991.toBigInt());

      expect(9007199254740991.isSafeInteger, isTrue);
      9007199254740991.checkSafeInteger();

      expect(9007199254740991.toBigInt().isSafeInteger, isTrue);
      9007199254740991.toBigInt().checkSafeInteger();
    });

    test('64 bits Limits', () {
      var max64 = BigInt.parse('9223372036854775807');
      var min64 = BigInt.parse('-9223372036854775808');

      var outUpper64 = max64 + 1024.toBigInt();
      var outLower64 = min64 - 1024.toBigInt();

      if (p.supportsFullInt64) {
        expect(p.isSafeIntegerByBigInt(max64), isTrue);
        expect(p.isSafeIntegerByBigInt(min64), isTrue);

        p.checkSafeIntegerByBigInt(max64);
        p.checkSafeIntegerByBigInt(min64);
      } else {
        expect(p.isSafeIntegerByBigInt(max64), isFalse);
        expect(p.isSafeIntegerByBigInt(min64), isFalse);

        expect(() => p.checkSafeIntegerByBigInt(max64), throwsStateError);
        expect(() => p.checkSafeIntegerByBigInt(min64), throwsStateError);
      }

      expect(p.isSafeIntegerByBigInt(outUpper64), isFalse);
      expect(p.isSafeIntegerByBigInt(outLower64), isFalse);

      expect(() => p.checkSafeIntegerByBigInt(outUpper64), throwsStateError);
      expect(() => p.checkSafeIntegerByBigInt(outLower64), throwsStateError);
    });

    test(
      'testSafeNumbers',
      () {
        print('** Testing testSafeNumbers: ${testSafeNumbers.length}');

        for (var e in testSafeNumbers.entries) {
          _testNumber(e.key, e.value);
        }
      },
      //skip: true,
    );

    test(
      'test sequence',
      () {
        print('** Testing numbers sequence...');

        var total = 0;
        for (var n = 0xAA; n < 0xFFFFFFFFFF; n += (255 * 255 * 3)) {
          var bs1 = Uint8List(8);
          var bs2 = Uint8List(8);

          p.writeUint64(bs1, n);
          p.writeInt64(bs2, n);

          var nRead1 = p.readUint64(bs1);
          var nRead2 = p.readUint64(bs1);

          expect(nRead1, equals(n));
          expect(nRead2, equals(n));
          total++;
        }

        print('-- Tested $total numbers.');
      },
      //skip: true,
    );
  });
}
