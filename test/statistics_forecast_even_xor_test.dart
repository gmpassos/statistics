import 'dart:math';

import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('Forecast', () {
    test('forecast: EvenXOR{no phases}', () {
      var evenForecaster = EvenXorForecaster();

      expect(
          evenForecaster.getPhaseOperations('').map((o) => '$o'),
          equals([
            'ForecastOperation{id: last_bit_A}',
            'ForecastOperation{id: last_bit_B}'
          ]));

      expect(evenForecaster.getPhaseOperations('A').map((o) => '$o'),
          equals(['ForecastOperation{id: last_bit_A}']));

      expect(evenForecaster.getPhaseOperations('B').map((o) => '$o'),
          equals(['ForecastOperation{id: last_bit_B}']));

      var p1 = Pair(10, 2);
      var p2 = Pair(10, 3);
      var p3 = Pair(3, 3);
      var p4 = Pair(5, 5);
      var p5 = Pair(2, 4);
      var p6 = Pair(3, 4);

      expect(evenForecaster.forecast(p1), isTrue);
      expect(evenForecaster.forecast(p2), isFalse);
      expect(evenForecaster.forecast(p3), isTrue);

      expect(evenForecaster.allObservations.length, equals(6));

      evenForecaster.concludeObservations(p1, {'EVEN': p1.xorIsEven});
      expect(evenForecaster.allObservations.length, equals(4));

      evenForecaster.concludeObservations(p2, {'EVEN': p2.xorIsEven});
      expect(evenForecaster.allObservations.length, equals(2));

      evenForecaster.concludeObservations(p3, {'EVEN': p3.xorIsEven});
      expect(evenForecaster.allObservations.length, equals(0));

      expect(evenForecaster.forecast(p4), isTrue);
      expect(evenForecaster.forecast(p5), isTrue);
      expect(evenForecaster.forecast(p6), isFalse);

      expect(evenForecaster.allObservations.length, equals(6));

      evenForecaster.concludeObservations(p4, {'EVEN': p4.xorIsEven});
      expect(evenForecaster.allObservations.length, equals(4));

      evenForecaster.concludeObservations(p5, {'EVEN': p5.xorIsEven});
      expect(evenForecaster.allObservations.length, equals(2));

      evenForecaster.concludeObservations(p6, {'EVEN': p6.xorIsEven});
      expect(evenForecaster.allObservations.length, equals(0));

      var random = Random(123);

      var totalForecasts = 100000;

      for (var i = 0; i < totalForecasts; ++i) {
        var p = Pair(random.nextInt(100), random.nextInt(100));

        expect(evenForecaster.forecast(p), equals(p.xorIsEven), reason: '$p');
        evenForecaster.concludeObservations(p, {'EVEN': p.xorIsEven});
      }

      expect(evenForecaster.allObservations.length, equals(0));

      {
        var p = Pair(random.nextInt(100), random.nextInt(100));
        expect(evenForecaster.forecast(p), equals(p.xorIsEven));
      }

      expect(evenForecaster.allObservations.length, equals(2));

      evenForecaster.disposeObservations();
      expect(evenForecaster.allObservations.length, equals(0));

      _testEvenProductProbabilities(evenForecaster.eventMonitor);
    });

    test('forecast: EvenXOR{phases: [A, B]}', () {
      var evenForecaster = EvenXorForecaster();

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
          isFalse);
      expect(evenForecaster.forecast(p3, phase: 'B', previousPhases: {'A'}),
          isTrue);
      expect(evenForecaster.forecast(p4, phase: 'B', previousPhases: {'A'}),
          isTrue);
      expect(evenForecaster.forecast(p5, phase: 'B', previousPhases: {'A'}),
          isTrue);
      expect(evenForecaster.forecast(p6, phase: 'B', previousPhases: {'A'}),
          isFalse);

      evenForecaster.concludeObservations(p1, {'EVEN': p1.xorIsEven});
      evenForecaster.concludeObservations(p2, {'EVEN': p2.xorIsEven});
      evenForecaster.concludeObservations(p3, {'EVEN': p3.xorIsEven});
      evenForecaster.concludeObservations(p4, {'EVEN': p4.xorIsEven});
      evenForecaster.concludeObservations(p5, {'EVEN': p5.xorIsEven});
      evenForecaster.concludeObservations(p6, {'EVEN': p6.xorIsEven});

      var random = Random(123);

      var totalForecasts = 100000;

      for (var i = 0; i < totalForecasts; ++i) {
        var p = Pair(random.nextInt(100), random.nextInt(100));

        evenForecaster.forecast(p, phase: 'A');
        evenForecaster.forecast(p, phase: 'B', previousPhases: {'A'});
        evenForecaster.concludeObservations(p, {'EVEN': p.xorIsEven});
      }

      _testEvenProductProbabilities(evenForecaster.eventMonitor);
    });
  });
}

void _testEvenProductProbabilities(BayesEventMonitor eventMonitor) {
  print(eventMonitor);

  var bayesNet = eventMonitor.buildBayesianNetwork(
      unseenMinimalProbability: 0.0, verbose: true);
  print(bayesNet);

  var analyser = bayesNet.analyser;

  expect(analyser.showAnswer('P(EVEN)').probability, _isNear(0.50, 0.01));
  expect(analyser.showAnswer('P(-EVEN)').probability, _isNear(0.50, 0.01));

  expect(analyser.showAnswer('P(EVEN|LAST_BIT_A)').probability,
      _isNear(0.50, 0.01));
  expect(analyser.showAnswer('P(EVEN|-LAST_BIT_A)').probability, _isNear(0.50));

  expect(analyser.showAnswer('P(EVEN|LAST_BIT_B)').probability,
      _isNear(0.50, 0.01));
  expect(analyser.showAnswer('P(EVEN|-LAST_BIT_B)').probability, _isNear(.50));

  expect(analyser.showAnswer('P(EVEN|-LAST_BIT_A,-LAST_BIT_B)').probability,
      _isNear(1.0));

  expect(analyser.showAnswer('P(EVEN|LAST_BIT_A,-LAST_BIT_B)').probability,
      _isNear(0.0));

  expect(analyser.showAnswer('P(EVEN|-LAST_BIT_A,LAST_BIT_B)').probability,
      _isNear(0.0));

  expect(analyser.showAnswer('P(EVEN|LAST_BIT_A,LAST_BIT_B)').probability,
      _isNear(1.0));
}

class EvenXorForecaster extends EventForecaster<Pair<int>, bool, bool> {
  EvenXorForecaster() : super('EvenXOR');

  @override
  List<ObservationOperation<Pair<int>, bool>> generatePhaseOperations(
      String phase) {
    var opA = ObservationOperation<Pair<int>, bool>('last_bit(A)',
        computer: _extractLastBitA);

    var opB = ObservationOperation<Pair<int>, bool>('last_bit(B)',
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
      var odd = opLastBitA.value;
      return !odd;
    } else {
      var even = (opLastBitA.value == opLastBitB.value);
      return even;
    }
  }
}

extension _PairExtension on Pair<int> {
  int get xor => a ^ b;

  bool get xorIsEven => xor % 2 == 0;
}

Matcher _isNear(double value, [double tolerance = 0.01]) =>
    inInclusiveRange(value - tolerance, value + tolerance);
