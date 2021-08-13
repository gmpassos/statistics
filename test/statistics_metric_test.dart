import 'package:statistics/src/statistics_metric.dart';
import 'package:test/test.dart';

void main() {
  group('UnitLength', () {
    setUp(() {});

    test('km', () {
      expect(UnitLength.km.name, equals('kilometre'));
      expect(UnitLength.km.unit, equals('km'));

      expect(UnitLength.nm.isMetric, isTrue);
      expect(UnitLength.nm.isSI, isTrue);
      expect(UnitLength.nm.isImperial, isFalse);

      expect(UnitLength.km.convertTo(UnitLength.km, 1), equals(1));
      expect(UnitLength.km.convertTo(UnitLength.m, 1), equals(1000));
      expect(UnitLength.km.convertTo(UnitLength.dm, 1), equals(10000));
      expect(UnitLength.km.convertTo(UnitLength.cm, 1), equals(100000));
      expect(UnitLength.km.convertTo(UnitLength.mm, 1), equals(1000000));
      expect(UnitLength.km.convertTo(UnitLength.mic, 1), equals(1e+9));
      expect(UnitLength.km.convertTo(UnitLength.nm, 1), equals(1e+12));

      expect(UnitLength.km.convertTo(UnitLength.inch, 1), equals(39370.1));
      expect(UnitLength.km.convertTo(UnitLength.mi, 1), equals(0.62137119224));
    });

    test('m', () {
      expect(UnitLength.m.name, equals('metre'));
      expect(UnitLength.m.unit, equals('m'));

      expect(UnitLength.nm.isMetric, isTrue);
      expect(UnitLength.nm.isSI, isTrue);
      expect(UnitLength.nm.isImperial, isFalse);

      expect(UnitLength.m.convertTo(UnitLength.km, 1), equals(0.001));
      expect(UnitLength.m.convertTo(UnitLength.m, 1), equals(1));
      expect(UnitLength.m.convertTo(UnitLength.dm, 1), equals(10));
      expect(UnitLength.m.convertTo(UnitLength.cm, 1), equals(100));
      expect(UnitLength.m.convertTo(UnitLength.mm, 1), equals(1000));
      expect(UnitLength.m.convertTo(UnitLength.mic, 1), equals(1000000));
      expect(UnitLength.m.convertTo(UnitLength.nm, 1), equals(1e+9));

      expect(UnitLength.m.convertTo(UnitLength.inch, 1), equals(39.3701));
      expect(
          UnitLength.m.convertTo(UnitLength.mi, 1), equals(0.00062137119224));
    });

    test('dm', () {
      expect(UnitLength.dm.name, equals('decimetre'));
      expect(UnitLength.dm.unit, equals('dm'));

      expect(UnitLength.nm.isMetric, isTrue);
      expect(UnitLength.nm.isSI, isTrue);
      expect(UnitLength.nm.isImperial, isFalse);

      expect(UnitLength.dm.convertTo(UnitLength.km, 1), equals(0.0001));
      expect(UnitLength.dm.convertTo(UnitLength.m, 1), equals(0.1));
      expect(UnitLength.dm.convertTo(UnitLength.dm, 1), equals(1));
      expect(UnitLength.dm.convertTo(UnitLength.cm, 1), equals(10));
      expect(UnitLength.dm.convertTo(UnitLength.mm, 1), equals(100));
      expect(UnitLength.dm.convertTo(UnitLength.mic, 1), equals(100000));
      expect(UnitLength.dm.convertTo(UnitLength.nm, 1), equals(1e+8));

      expect(UnitLength.dm.convertTo(UnitLength.inch, 1), equals(3.93701));
      expect(UnitLength.dm.convertTo(UnitLength.mi, 1), equals(6.21371e-5));
    });

    test('cm', () {
      expect(UnitLength.cm.name, equals('centimetre'));
      expect(UnitLength.cm.unit, equals('cm'));

      expect(UnitLength.nm.isMetric, isTrue);
      expect(UnitLength.nm.isSI, isTrue);
      expect(UnitLength.nm.isImperial, isFalse);

      expect(UnitLength.cm.convertTo(UnitLength.km, 1), equals(0.00001));
      expect(UnitLength.cm.convertTo(UnitLength.m, 1), equals(0.01));
      expect(UnitLength.cm.convertTo(UnitLength.dm, 1), equals(0.1));
      expect(UnitLength.cm.convertTo(UnitLength.cm, 1), equals(1));
      expect(UnitLength.cm.convertTo(UnitLength.mm, 1), equals(10));
      expect(UnitLength.cm.convertTo(UnitLength.mic, 1), equals(10000));
      expect(UnitLength.cm.convertTo(UnitLength.nm, 1), equals(1e+7));

      expect(UnitLength.cm.convertTo(UnitLength.inch, 1), equals(0.393701));
      expect(UnitLength.cm.convertTo(UnitLength.mi, 1), equals(6.21371e-6));
    });

    test('mm', () {
      expect(UnitLength.mm.name, equals('millimetre'));
      expect(UnitLength.mm.unit, equals('mm'));

      expect(UnitLength.nm.isMetric, isTrue);
      expect(UnitLength.nm.isSI, isTrue);
      expect(UnitLength.nm.isImperial, isFalse);

      expect(UnitLength.mm.convertTo(UnitLength.km, 1), equals(0.000001));
      expect(UnitLength.mm.convertTo(UnitLength.m, 1), equals(0.001));
      expect(UnitLength.mm.convertTo(UnitLength.dm, 1), equals(0.01));
      expect(UnitLength.mm.convertTo(UnitLength.cm, 1), equals(0.1));
      expect(UnitLength.mm.convertTo(UnitLength.mm, 1), equals(1));
      expect(UnitLength.mm.convertTo(UnitLength.mic, 1), equals(1000));
      expect(UnitLength.mm.convertTo(UnitLength.nm, 1), equals(1000000));

      expect(UnitLength.mm.convertTo(UnitLength.inch, 1), equals(0.0393701));
      expect(UnitLength.mm.convertTo(UnitLength.mi, 1), equals(6.21371e-7));
    });

    test('mic', () {
      expect(UnitLength.mic.name, equals('micrometre'));
      expect(UnitLength.mic.unit, equals('μm'));

      expect(UnitLength.nm.isMetric, isTrue);
      expect(UnitLength.nm.isSI, isTrue);
      expect(UnitLength.nm.isImperial, isFalse);

      expect(UnitLength.mic.convertTo(UnitLength.km, 1), equals(1e-9));
      expect(UnitLength.mic.convertTo(UnitLength.m, 1), equals(0.000001));
      expect(UnitLength.mic.convertTo(UnitLength.dm, 1), equals(0.00001));
      expect(UnitLength.mic.convertTo(UnitLength.cm, 1), equals(0.0001));
      expect(UnitLength.mic.convertTo(UnitLength.mm, 1), equals(0.001));
      expect(UnitLength.mic.convertTo(UnitLength.mic, 1), equals(1));
      expect(UnitLength.mic.convertTo(UnitLength.nm, 1), equals(1000));

      expect(UnitLength.mic.convertTo(UnitLength.inch, 1), equals(3.93701e-5));
      expect(UnitLength.mic.convertTo(UnitLength.mi, 1), equals(6.21371e-10));
    });

    test('nm', () {
      expect(UnitLength.nm.name, equals('nanometre'));
      expect(UnitLength.nm.unit, equals('nm'));

      expect(UnitLength.nm.isMetric, isTrue);
      expect(UnitLength.nm.isSI, isTrue);
      expect(UnitLength.nm.isImperial, isFalse);

      expect(UnitLength.nm.convertTo(UnitLength.km, 1), equals(1e-12));
      expect(UnitLength.nm.convertTo(UnitLength.m, 1), equals(1e-9));
      expect(UnitLength.nm.convertTo(UnitLength.dm, 1), equals(1e-8));
      expect(UnitLength.nm.convertTo(UnitLength.cm, 1), equals(1e-7));
      expect(UnitLength.nm.convertTo(UnitLength.mm, 1), equals(0.000001));
      expect(UnitLength.nm.convertTo(UnitLength.mic, 1), equals(0.001));
      expect(UnitLength.nm.convertTo(UnitLength.nm, 1), equals(1));

      expect(UnitLength.nm.convertTo(UnitLength.inch, 1), equals(3.93701e-8));
      expect(UnitLength.nm.convertTo(UnitLength.mi, 1), equals(6.21371e-13));
    });

    test('inch', () {
      expect(UnitLength.inch.name, equals('inch'));
      expect(UnitLength.inch.unit, equals('in'));

      expect(UnitLength.inch.isMetric, isFalse);
      expect(UnitLength.inch.isSI, isFalse);
      expect(UnitLength.inch.isImperial, isTrue);

      expect(UnitLength.inch.convertTo(UnitLength.km, 1), equals(2.54e-5));
      expect(UnitLength.inch.convertTo(UnitLength.m, 1), equals(0.0254));
      expect(UnitLength.inch.convertTo(UnitLength.dm, 1), equals(0.254));
      expect(UnitLength.inch.convertTo(UnitLength.cm, 1), equals(2.54));
      expect(UnitLength.inch.convertTo(UnitLength.mm, 1), equals(25.4));
      expect(UnitLength.inch.convertTo(UnitLength.mic, 1), equals(25400));
      expect(UnitLength.inch.convertTo(UnitLength.nm, 1), equals(2.54e+7));

      expect(UnitLength.inch.convertTo(UnitLength.mi, 1), equals(1.57828e-5));
    });

    test('mile', () {
      expect(UnitLength.mi.name, equals('mile'));
      expect(UnitLength.mi.unit, equals('mi'));

      expect(UnitLength.mi.isMetric, isFalse);
      expect(UnitLength.mi.isSI, isFalse);
      expect(UnitLength.mi.isImperial, isTrue);

      expect(UnitLength.mi.convertTo(UnitLength.km, 1), equals(1.60934));
      expect(UnitLength.mi.convertTo(UnitLength.m, 1), equals(1609.34));
      expect(UnitLength.mi.convertTo(UnitLength.dm, 1), equals(16093.4));
      expect(UnitLength.mi.convertTo(UnitLength.cm, 1), equals(160934));
      expect(UnitLength.mi.convertTo(UnitLength.mm, 1), equals(1.609e+6));
      expect(UnitLength.mi.convertTo(UnitLength.mic, 1), equals(1.609e+9));
      expect(UnitLength.mi.convertTo(UnitLength.nm, 1), equals(1.609e+12));

      expect(UnitLength.mi.convertTo(UnitLength.inch, 1), equals(63360));
    });
  });
}
