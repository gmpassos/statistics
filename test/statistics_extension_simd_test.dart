import 'dart:typed_data';

import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('extension SIMD', () {
    setUp(() {});

    test('Int32x4', () {
      expect(Int32x4(10, 20, 30, 40).maxInLane, equals(40));
      expect(Int32x4(10, 20, 30, 40).minInLane, equals(10));

      expect(Int32x4(50, 20, 30, 40).maxInLane, equals(50));
      expect(Int32x4(50, 20, 30, 40).minInLane, equals(20));

      expect(Int32x4(50, 20, 30, 40).sumLane, equals(140));
      expect(Int32x4(50, 20, 30, 40).sumSquaresLane, equals(5400));

      expect(Int32x4(50, 20, 30, 40).sumLanePartial(4), equals(140));
      expect(Int32x4(50, 20, 30, 40).sumLanePartial(3), equals(100));
      expect(Int32x4(50, 20, 30, 40).sumLanePartial(2), equals(70));
      expect(Int32x4(50, 20, 30, 40).sumLanePartial(1), equals(50));

      expect(Int32x4(50, 20, 30, 40).sumSquaresLanePartial(4), equals(5400));
      expect(Int32x4(50, 20, 30, 40).sumSquaresLanePartial(3), equals(3800));
      expect(Int32x4(50, 20, 30, 40).sumSquaresLanePartial(2), equals(2900));
      expect(Int32x4(50, 20, 30, 40).sumSquaresLanePartial(1), equals(2500));

      expect(() => Int32x4(50, 20, 30, 40).sumLanePartial(5), throwsStateError);
      expect(() => Int32x4(50, 20, 30, 40).sumSquaresLanePartial(5),
          throwsStateError);

      expect(Int32x4(50, 20, 30, 40).equalsValues(Int32x4(50, 20, 30, 40)),
          isTrue);

      expect(
          Int32x4(50, 20, 30, 40)
              .equalsValues(Int32x4(50, 20, 30, 41), tolerance: 1),
          isTrue);

      expect(
          Int32x4(50, 20, 30, 40)
              .equalsValues(Int32x4(50, 20, 30, 41), tolerance: 0.1),
          isFalse);

      expect(
          (Int32x4(50, 20, 30, 40) - Int32x4(10, 30, 5, 40))
              .equalsValues(Int32x4(40, -10, 25, 0)),
          isTrue);
      expect(
          (Int32x4(50, 20, 30, 40) * Int32x4(1, 2, 3, 4))
              .equalsValues(Int32x4(50, 40, 90, 160)),
          isTrue);
      expect(
          (Int32x4(50, 20, 30, 40) ~/ Int32x4(1, 2, 3, 4))
              .equalsValues(Int32x4(50, 10, 10, 10)),
          isTrue);

      expect(Int32x4(50, 20, 30, 40).toInts(), equals([50, 20, 30, 40]));

      expect(
          Int32x4(50, 20, 30, 40)
              .toFloat32x4()
              .equalsValues(Float32x4(50, 20, 30, 40)),
          isTrue);

      expect(
          Int32x4(50, 20, 30, 40).toFloat32x4().equalsValues(
              Float32x4(50.01, 20.01, 30.01, 40.01),
              tolerance: 0.1),
          isTrue);

      expect(
          Int32x4(50, 20, 30, 40).toFloat32x4().equalsValues(
              Float32x4(50.01, 20.01, 30.01, 40.01),
              tolerance: 0.001),
          isFalse);

      expect(
          Int32x4(50, 20, 30, 40)
              .filterValues((n) => n * 2)
              .equalsValues(Int32x4(100, 40, 60, 80)),
          isTrue);

      expect(
          Int32x4(50, 20, 30, 40)
              .filterToDoubleValues((n) => n * 2)
              .equalsValues(Float32x4(100, 40, 60, 80)),
          isTrue);

      expect(
          Int32x4(50, 20, 30, 40)
              .filter((e) => Int32x4(e.x * 3, e.y * 3, e.z * 3, e.w * 3))
              .equalsValues(Int32x4(150, 60, 90, 120)),
          isTrue);

      expect(Int32x4(50, 20, 30, 40).map((e) => '${e.x};${e.y};${e.z};${e.w}'),
          equals('50;20;30;40'));
    });

    test('Float32x4', () {
      expect(Float32x4(10, 20, 30, 40).maxInLane, equals(40));
      expect(Float32x4(10, 20, 30, 40).minInLane, equals(10));

      expect(Float32x4(50, 20, 30, 40).maxInLane, equals(50));
      expect(Float32x4(50, 20, 30, 40).minInLane, equals(20));

      expect(Float32x4(50, 20, 30, 40).sumLane, equals(140));
      expect(Float32x4(50, 20, 30, 40).sumSquaresLane, equals(5400));

      expect(Float32x4(50, 20, 30, 40).sumLanePartial(4), equals(140));
      expect(Float32x4(50, 20, 30, 40).sumLanePartial(3), equals(100));
      expect(Float32x4(50, 20, 30, 40).sumLanePartial(2), equals(70));
      expect(Float32x4(50, 20, 30, 40).sumLanePartial(1), equals(50));

      expect(Float32x4(50, 20, 30, 40).sumSquaresLanePartial(4), equals(5400));
      expect(Float32x4(50, 20, 30, 40).sumSquaresLanePartial(3), equals(3800));
      expect(Float32x4(50, 20, 30, 40).sumSquaresLanePartial(2), equals(2900));
      expect(Float32x4(50, 20, 30, 40).sumSquaresLanePartial(1), equals(2500));

      expect(
          () => Float32x4(50, 20, 30, 40).sumLanePartial(5), throwsStateError);
      expect(() => Float32x4(50, 20, 30, 40).sumSquaresLanePartial(5),
          throwsStateError);

      expect(Float32x4(50, 20, 30, 40).equalsValues(Float32x4(50, 20, 30, 40)),
          isTrue);

      expect(
          Float32x4(50, 20, 30, 40)
              .equalsValues(Float32x4(50, 20, 30, 40.01), tolerance: 0.1),
          isTrue);

      expect(
          Float32x4(50, 20, 30, 40)
              .equalsValues(Float32x4(50, 20, 30, 40.01), tolerance: 0.001),
          isFalse);

      expect(
          (Float32x4(50, 20, 30, 40) - Float32x4(10, 30, 5, 40))
              .equalsValues(Float32x4(40, -10, 25, 0)),
          isTrue);
      expect(
          (Float32x4(50, 20, 30, 40) * Float32x4(1, 2, 3, 4))
              .equalsValues(Float32x4(50, 40, 90, 160)),
          isTrue);
      expect(
          (Float32x4(50, 20, 30, 40) ~/ Float32x4(1, 2, 3, 4))
              .equalsValues(Int32x4(50, 10, 10, 10)),
          isTrue);

      expect(Float32x4(50, 20, 30, 40).toDoubles(),
          equals([50.0, 20.0, 30.0, 40.0]));

      expect(
          Float32x4(50, 20, 30, 40)
              .toInt32x4()
              .equalsValues(Int32x4(50, 20, 30, 40)),
          isTrue);

      expect(
          Float32x4(50, 20, 30, 40)
              .toInt32x4()
              .equalsValues(Int32x4(50, 20, 30, 41), tolerance: 1),
          isTrue);

      expect(
          Float32x4(50, 20, 30, 40)
              .toInt32x4()
              .equalsValues(Int32x4(50, 20, 30, 41), tolerance: 0.1),
          isFalse);

      expect(
          Float32x4(50.01, 20, 30.2, 41.01)
              .toIntAsFloat32x4()
              .equalsValues(Float32x4(50, 20, 30, 41)),
          isTrue);

      expect(
          Float32x4(50, 20, 30, 40)
              .filterValues((n) => n * 2)
              .equalsValues(Float32x4(100, 40, 60, 80)),
          isTrue);

      expect(
          Float32x4(50, 20, 30, 40)
              .filterToIntValues((n) => (n * 2).toInt())
              .equalsValues(Int32x4(100, 40, 60, 80)),
          isTrue);

      expect(
          Float32x4(50, 20, 30, 40)
              .filter((e) => Float32x4(e.x * 3, e.y * 3, e.z * 3, e.w * 3))
              .equalsValues(Float32x4(150, 60, 90, 120)),
          isTrue);

      expect(
          Float32x4(50, 20, 30, 40)
              .map((e) => Float32x4(e.x * 3, e.y * 3, e.z * 3, e.w * 3))
              .equalsValues(Float32x4(150, 60, 90, 120)),
          isTrue);

      expect(
          Float32x4(50.1, 20.1, 30.1, 40.1).map((e) =>
              '${e.x.toStringAsFixed(1)};${e.y.toStringAsFixed(1)};${e.z.toStringAsFixed(1)};${e.w.toStringAsFixed(1)}'),
          equals('50.1;20.1;30.1;40.1'));
    });
  });
}
