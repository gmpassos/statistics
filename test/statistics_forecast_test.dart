import 'dart:math';

import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('Forecast', () {
    test('forecast: EvenProduct{no phases}', () {
      var eventMonitor = EventMonitor('EvenProduct');
      var evenForecaster = EvenProductForecaster();

      expect(
          evenForecaster.generateOperations('').map((o) => '$o'),
          equals([
            'ForecastOperation{id: last_bit_A}',
            'ForecastOperation{id: last_bit_B}'
          ]));

      expect(evenForecaster.generateOperations('A').map((o) => '$o'),
          equals(['ForecastOperation{id: last_bit_A}']));

      expect(evenForecaster.generateOperations('B').map((o) => '$o'),
          equals(['ForecastOperation{id: last_bit_B}']));

      var conclusionListenerVerbose = true;

      evenForecaster.conclusionListener = (s, o, v) {
        if (o != null) {
          if (conclusionListenerVerbose) print('-- $s > $o -> $v');
          eventMonitor.notifyEvent(['${o.opID} = ${o.value}', 'EVEN = $v']);
        } else {
          if (conclusionListenerVerbose) print('-- $s > $v');
          eventMonitor.notifyEvent(['EVEN = $v']);
        }
      };

      var p1 = Pair(10, 2);
      var p2 = Pair(10, 3);
      var p3 = Pair(3, 3);
      var p4 = Pair(5, 5);
      var p5 = Pair(2, 4);
      var p6 = Pair(3, 4);

      expect(evenForecaster.forecast(p1), isTrue);
      expect(evenForecaster.forecast(p2), isTrue);
      expect(evenForecaster.forecast(p3), isFalse);

      expect(evenForecaster.allObservations.length, equals(6));

      evenForecaster.concludeObservations(p1, p1.productIsEven);
      expect(evenForecaster.allObservations.length, equals(4));

      evenForecaster.concludeObservations(p2, p2.productIsEven);
      expect(evenForecaster.allObservations.length, equals(2));

      evenForecaster.concludeObservations(p3, p3.productIsEven);
      expect(evenForecaster.allObservations.length, equals(0));

      expect(evenForecaster.forecast(p4), isFalse);
      expect(evenForecaster.forecast(p5), isTrue);
      expect(evenForecaster.forecast(p6), isTrue);

      expect(evenForecaster.allObservations.length, equals(6));

      evenForecaster.concludeObservations(p4, p4.productIsEven);
      expect(evenForecaster.allObservations.length, equals(4));

      evenForecaster.concludeObservations(p5, p5.productIsEven);
      expect(evenForecaster.allObservations.length, equals(2));

      evenForecaster.concludeObservations(p6, p6.productIsEven);
      expect(evenForecaster.allObservations.length, equals(0));

      conclusionListenerVerbose = false;

      var random = Random(123);

      for (var i = 0; i < 100000; ++i) {
        var p = Pair(random.nextInt(100), random.nextInt(100));

        expect(evenForecaster.forecast(p), equals(p.productIsEven));
        evenForecaster.concludeObservations(p, p.productIsEven);
      }

      expect(evenForecaster.allObservations.length, equals(0));

      {
        var p = Pair(random.nextInt(100), random.nextInt(100));
        expect(evenForecaster.forecast(p), equals(p.productIsEven));
      }

      expect(evenForecaster.allObservations.length, equals(2));

      evenForecaster.disposeObservations();
      expect(evenForecaster.allObservations.length, equals(0));

      _testEvenProductProbabilities(eventMonitor);
    });

    test('forecast: EvenProduct{phases: [A, B]}', () {
      var eventMonitor = EventMonitor('EvenProduct');
      var evenForecaster = EvenProductForecaster();

      evenForecaster.conclusionListener = (s, o, v) {
        if (o != null) {
          eventMonitor.notifyEvent(['${o.opID} = ${o.value}', 'EVEN = $v']);
        } else {
          eventMonitor.notifyEvent(['EVEN = $v']);
        }
      };

      var p1 = Pair(10, 2);
      var p2 = Pair(10, 3);
      var p3 = Pair(3, 3);
      var p4 = Pair(5, 5);
      var p5 = Pair(2, 4);
      var p6 = Pair(3, 4);

      expect(evenForecaster.forecast(p1, phase: 'A'), isTrue);
      expect(evenForecaster.forecast(p2, phase: 'A'), isTrue);
      expect(evenForecaster.forecast(p3, phase: 'A'), isFalse);
      expect(evenForecaster.forecast(p4, phase: 'A'), isFalse);
      expect(evenForecaster.forecast(p5, phase: 'A'), isTrue);
      expect(evenForecaster.forecast(p6, phase: 'A'), isFalse);

      expect(evenForecaster.allObservations.length, equals(6));

      expect(evenForecaster.forecast(p1, phase: 'B', previousPhases: {'A'}),
          isTrue);
      expect(evenForecaster.forecast(p2, phase: 'B', previousPhases: {'A'}),
          isTrue);
      expect(evenForecaster.forecast(p3, phase: 'B', previousPhases: {'A'}),
          isFalse);
      expect(evenForecaster.forecast(p4, phase: 'B', previousPhases: {'A'}),
          isFalse);
      expect(evenForecaster.forecast(p5, phase: 'B', previousPhases: {'A'}),
          isTrue);
      expect(evenForecaster.forecast(p6, phase: 'B', previousPhases: {'A'}),
          isTrue);

      evenForecaster.concludeObservations(p1, p1.productIsEven);
      evenForecaster.concludeObservations(p2, p2.productIsEven);
      evenForecaster.concludeObservations(p3, p3.productIsEven);
      evenForecaster.concludeObservations(p4, p4.productIsEven);
      evenForecaster.concludeObservations(p5, p5.productIsEven);
      evenForecaster.concludeObservations(p6, p6.productIsEven);

      var random = Random(123);

      for (var i = 0; i < 100000; ++i) {
        var p = Pair(random.nextInt(100), random.nextInt(100));

        evenForecaster.forecast(p, phase: 'A');
        evenForecaster.forecast(p, phase: 'B', previousPhases: {'A'});
        evenForecaster.concludeObservations(p, p.productIsEven);
      }

      _testEvenProductProbabilities(eventMonitor);
    });
  });
}

void _testEvenProductProbabilities(EventMonitor eventMonitor) {
  print(eventMonitor);

  var bayesNet =
      eventMonitor.buildBayesianNetwork(unseenMinimalProbability: 0.0);
  print(bayesNet);

  var analyser = bayesNet.analyser;

  expect(analyser.showAnswer('P(EVEN)').probability, _isNear(0.75, 0.01));
  expect(analyser.showAnswer('P(-EVEN)').probability, _isNear(0.25, 0.01));

  expect(analyser.showAnswer('P(EVEN|LAST_BIT_A)').probability,
      _isNear(0.50, 0.01));
  expect(analyser.showAnswer('P(EVEN|-LAST_BIT_A)').probability, _isNear(1.0));

  expect(analyser.showAnswer('P(EVEN|LAST_BIT_B)').probability,
      _isNear(0.50, 0.01));
  expect(analyser.showAnswer('P(EVEN|-LAST_BIT_B)').probability, _isNear(1.0));
}

class EvenProductForecaster extends Forecaster<Pair<int>, bool, bool> {
  @override
  Iterable<ForecastOperation<Pair<int>, bool>> generateOperations(
      String phase) {
    var opA = ForecastOperation<Pair<int>, bool>('last_bit(A)',
        computer: _extractLastBitA);

    var opB = ForecastOperation<Pair<int>, bool>('last_bit(B)',
        computer: _extractLastBitB);

    switch (phase) {
      case '':
        return [opA, opB];
      case 'A':
        return [opA];
      case 'B':
        return [opB];
      default:
        throw StateError('Unknown phase: $phase');
    }
  }

  static bool _extractLastBitA(Pair<int> ns) => _extractBit(ns.a, 0);

  static bool _extractLastBitB(Pair<int> ns) => _extractBit(ns.b, 0);

  static bool _extractBit(num n, int bit) {
    var i = n.toInt();
    return (i >> bit) & 0x01 == 1;
  }

  @override
  bool computeForecast(
      String phase, List<ForecastObservation<Pair<int>, bool>> observations) {
    var opLastBitA = observations.getByOpID('last_bit(A)')!;
    var opLastBitB = observations.getByOpID('last_bit(B)');

    if (opLastBitB == null) {
      return !opLastBitA.value;
    } else {
      return !opLastBitA.value || !opLastBitB.value;
    }
  }
}

extension _PairExtension on Pair<int> {
  int get product => a * b;

  bool get productIsEven => product % 2 == 0;
}

Matcher _isNear(double value, [double tolerance = 0.0001]) =>
    inInclusiveRange(value - tolerance, value + tolerance);
