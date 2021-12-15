import 'dart:typed_data';

import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('Equality', () {
    setUp(() {});

    test('IntEquality', () {
      var eq = IntEquality();

      expect(eq.equals(10, 10), isTrue);
      expect(eq.equals(10, -10), isFalse);

      expect(eq.hash(10) == eq.hash(10), isTrue);
      expect(eq.hash(10) == eq.hash(11), isFalse);

      expect(eq.isValidKey(10), isTrue);
      expect(eq.isValidKey(10.1), isFalse);
    });

    test('DoubleEquality', () {
      var eq = DoubleEquality();

      expect(eq.equals(10.0, 10.0), isTrue);
      expect(eq.equals(10.0, -10.0), isFalse);
      expect(eq.equals(10.0, 10.00001), isFalse);

      expect(eq.hash(10) == eq.hash(10), isTrue);
      expect(eq.hash(10) == eq.hash(11), isFalse);

      expect(eq.isValidKey(10.0), isTrue);
      expect(eq.isValidKey('x'), isFalse);
    });

    test('NumEquality', () {
      var eq = NumEquality();

      expect(eq.equals(10, 10), isTrue);
      expect(eq.equals(10, -10), isFalse);

      expect(eq.hash(10) == eq.hash(10), isTrue);
      expect(eq.hash(10) == eq.hash(11), isFalse);

      expect(eq.isValidKey(10), isTrue);
      expect(eq.isValidKey(10.0), isTrue);

      expect(eq.isValidKey('10'), isFalse);
    });

    test('Int32x4Equality', () {
      var eq = Int32x4Equality();

      expect(
          eq.equals(Int32x4(10, 20, 30, 40), Int32x4(10, 20, 30, 40)), isTrue);
      expect(eq.equals(Int32x4(10, 20, 30, 40), Int32x4(-10, 20, 30, 40)),
          isFalse);

      expect(eq.hash(Int32x4(10, 20, 30, 40)),
          equals(eq.hash(Int32x4(10, 20, 30, 40))));
      expect(
          eq.hash(Int32x4(10, 20, 30, 40)) == eq.hash(Int32x4(-10, 20, 30, 40)),
          isFalse);

      expect(eq.isValidKey(Int32x4(10, 20, 30, 40)), isTrue);
      expect(eq.isValidKey(Float32x4(10, 20, 30, 40)), isFalse);
      expect(eq.isValidKey('10'), isFalse);
    });

    test('Float32x4Equality', () {
      var eq = Float32x4Equality();

      expect(eq.equals(Float32x4(10, 20, 30, 40), Float32x4(10, 20, 30, 40)),
          isTrue);
      expect(eq.equals(Float32x4(10, 20, 30, 40), Float32x4(-10, 20, 30, 40)),
          isFalse);

      expect(eq.hash(Float32x4(10, 20, 30, 40)),
          equals(eq.hash(Float32x4(10, 20, 30, 40))));
      expect(
          eq.hash(Float32x4(10, 20, 30, 40)) ==
              eq.hash(Float32x4(-10, 20, 30, 40)),
          isFalse);

      expect(eq.isValidKey(Float32x4(10, 20, 30, 40)), isTrue);
      expect(eq.isValidKey(Int32x4(10, 20, 30, 40)), isFalse);
      expect(eq.isValidKey('10'), isFalse);
    });
  });
}
