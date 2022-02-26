import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('BayesianNetwork', () {
    test('basic', () {
      print('--------------------------------------------------------');

      var bayesNet = BayesianNetwork('basic');

      bayesNet.addVariable("M", [
        'T',
        'F'
      ], [], [
        "M = T: 0.2",
        "M = F: 0.8",
      ]);

      bayesNet.addVariable("I", [
        'T',
        'F'
      ], [
        "M"
      ], [
        "I = T, M = T: 0.8",
        "I = T, M = F: 0.2",
        "I = F, M = T: 0.2",
        "I = F, M = F: 0.8",
      ]);

      bayesNet.addVariable("B", [
        'T',
        'F'
      ], [
        "M"
      ], [
        "B = T, M = T: 0.2",
        "B = T, M = F: 0.05",
        "B = F, M = T: 0.8",
        "B = F, M = F: 0.95",
      ]);

      bayesNet.addVariable("C", [
        'T',
        'F'
      ], [
        "I",
        "B"
      ], [
        "C = T, I = T, B = T: 0.8",
        "C = T, I = T, B = F: 0.8",
        "C = T, I = F, B = T: 0.8",
        "C = T, I = F, B = F: 0.05",
        "C = F, I = T, B = T: 0.2",
        "C = F, I = T, B = F: 0.2",
        "C = F, I = F, B = T: 0.2",
        "C = F, I = F, B = F: 0.95",
      ]);

      bayesNet.addVariable("S", [
        'T',
        'F'
      ], [
        'B'
      ], [
        "S = T, B = T: 0.8",
        "S = T, B = F: 0.6",
        "S = F, B = T: 0.2",
        "S = F, B = F: 0.4",
      ]);

      print(bayesNet);

      var analyser = bayesNet.analyser;

      var result1 = analyser.showAnswer('P(c|m,b)');
      expect(result1.probability, _isNear(0.80));

      var result2 = analyser.showAnswer('P(-c|m,b)');
      expect(result2.probability, _isNear(0.20));

      var result3 = analyser.showAnswer('P(c|m,-b)');
      expect(result3.probability, _isNear(0.65));

      var result4 = analyser.showAnswer('P(-c|m,-b)');
      expect(result4.probability, _isNear(0.35));

      var result5 = analyser.showAnswer('P(s|m,b)');
      expect(result5.probability, _isNear(0.80));

      var result6 = analyser.showAnswer('P(s|m,-b)');
      expect(result6.probability, _isNear(0.60));
    });

    test('sprinkler', () {
      print('--------------------------------------------------------');

      var bayesNet = BayesianNetwork('sprinkler');

      bayesNet.addVariable("C", [
        'F',
        'T',
      ], [], [
        "C = F: 0.5",
        "C = T: 0.5",
      ]);

      bayesNet.addVariable("S", [
        'F',
        'T',
      ], [
        "C"
      ], [
        "S = F, C = F: 0.5",
        "S = F, C = T: 0.5",
        "S = T, C = F: 0.9",
        "S = T, C = T: 0.1",
      ]);

      bayesNet.addVariable("R", [
        'F',
        'T',
      ], [
        "C"
      ], [
        "R = F, C = F: 0.8",
        "R = F, C = T: 0.2",
        "R = T, C = F: 0.2",
        "R = T, C = T: 0.8",
      ]);

      bayesNet.addVariable("W", [
        'F',
        'T',
      ], [
        "S",
        "R",
      ], [
        "W = F, S = F, R = F: 1.0",
        "W = F, S = F, R = T: 0.0",
        "W = F, S = T, R = F: 0.1",
        "W = F, S = T, R = T: 0.9",
        "W = T, S = F, R = F: 0.1",
        "W = T, S = F, R = T: 0.9",
        "W = T, S = T, R = F: 0.01",
        "W = T, S = T, R = T: 0.99",
      ]);

      print(bayesNet);

      var analyser = bayesNet.analyser;

      analyser.showAnswer('P(w|-s,-r)', verbose: true);

      var result1 = analyser.showAnswer('P(c|s,r)');
      expect(result1.probability, _isNear(0.307692));

      var result2 = analyser.showAnswer('P(c|s,-r)');
      expect(result2.probability, _isNear(0.027027));

      var result3 = analyser.showAnswer('P(c|-s,-r)');
      expect(result3.probability, _isNear(0.2000000));

      var result4 = analyser.showAnswer('P(w|-s,-r)');
      expect(result4.probability, _isNear(0.0909090));

      var result5 = analyser.showAnswer('P(w|s,r)');
      expect(result5.probability, _isNear(0.5238095));

      var result6 = analyser.showAnswer('P(c|w,r)');
      expect(result6.probability, _isNear(0.6208651));

      var result7 = analyser.showAnswer('P(c|w,s)');
      expect(result7.probability, _isNear(0.2998489));

      var result8 = analyser.showAnswer('P(c|-w)');
      expect(result8.probability, _isNear(0.2153465));
    });

    test('xor', () {
      print('--------------------------------------------------------');

      var bayesNet = BayesianNetwork('XOR');

      bayesNet.addVariable("XOR", [
        'F',
        'T',
      ], [], [
        "XOR = F: 0.5",
        "XOR = T: 0.5",
      ]);

      bayesNet.addVariable("A", [
        'F',
        'T',
      ], [
        "XOR"
      ], [
        "A = F, XOR = F: 0.50",
        "A = F, XOR = T: 0.50",
        "A = T, XOR = F: 0.50",
        "A = T, XOR = T: 0.50",
      ]);

      bayesNet.addVariable("B", [
        'F',
        'T',
      ], [
        "XOR"
      ], [
        "B = F, XOR = F: 0.50",
        "B = F, XOR = T: 0.50",
        "B = T, XOR = F: 0.50",
        "B = T, XOR = T: 0.50",
      ]);

      bayesNet.addDependency([
        'A',
        'B'
      ], [
        "A = F, B = F, XOR = F: 0.0",
        "A = F, B = T, XOR = T: 1.0",
        "A = T, B = F, XOR = T: 1.0",
        "A = T, B = T, XOR = F: 0.0",
      ]);

      print(bayesNet);

      var analyser = bayesNet.analyser;

      expect(analyser.showAnswer('P(xor|a,b)', verbose: true).probability,
          _isNear(0.0));

      expect(analyser.showAnswer('P(xor|-a,b)', verbose: true).probability,
          _isNear(1.0));

      expect(analyser.showAnswer('P(xor)').probability, _isNear(0.50));

      expect(analyser.showAnswer('P(xor|a)').probability, _isNear(0.50));
      expect(analyser.showAnswer('P(xor|-a)').probability, _isNear(0.50));

      expect(analyser.showAnswer('P(xor|b)').probability, _isNear(0.50));
      expect(analyser.showAnswer('P(xor|-b)').probability, _isNear(0.50));

      expect(analyser.showAnswer('P(xor|a,-b)').probability, _isNear(1.0));
      expect(analyser.showAnswer('P(xor|a,b)').probability, _isNear(0.0));
      expect(analyser.showAnswer('P(xor|-a,b)').probability, _isNear(1.0));
      expect(analyser.showAnswer('P(xor|a,b)').probability, _isNear(0.0));
    });

    test('cancer', () {
      print('--------------------------------------------------------');

      var bayesNet = BayesianNetwork('cancer');

      bayesNet.addVariable("C", [
        'F',
        'T',
      ], [], [
        "C = F: 0.99",
        "C = T: 0.01",
      ]);

      bayesNet.addVariable("X", [
        '+P',
        '-N',
      ], [
        "C"
      ], [
        "X = N, C = F: 0.91",
        "X = P, C = F: 0.09",
        "X = N, C = T: 0.10",
        "X = P, C = T: 0.90",
      ]);

      print(bayesNet);

      bayesNet.analyser.showAnswer('P(C|X)', verbose: true);

      _testBayesNetCancer(bayesNet);

      {
        var bayesNet2 = BayesianNetwork('cancer');

        bayesNet2.addVariable("C", [
          'F',
          'T',
        ], [], [
          "C = F: 0.99",
          "C = T: 0.01",
        ]);

        bayesNet2.addVariable("X", [
          '+P',
          '-N',
        ], [
          "C"
        ], [
          "X = N, C = F: 0.91",
          "X = P, C = F: 0.09",
          "X = N, C = T: 0.10",
          "X = P, C = T: 0.90",
        ]);

        expect(bayesNet, equals(bayesNet2));
      }
    });

    test('cancer by event', () {
      print('--------------------------------------------------------');

      var eventMonitor = _generateCancerEvents(1);

      var bayesNet = BayesianNetwork('cancer');

      eventMonitor.populateNodes(bayesNet);

      print(bayesNet);

      _testBayesNetCancer(bayesNet, hasGhostBranch: true);
    });

    test('cancer by events (x1000)', () async {
      print('--------------------------------------------------------');

      var eventMonitor = _generateCancerEvents(1000);

      var bayesNet = BayesianNetwork('cancer');

      eventMonitor.populateNodes(bayesNet);

      print(bayesNet);

      _testBayesNetCancer(bayesNet, hasGhostBranch: true);
    });

    test('invalid 1', () {
      expect(() {
        BayesianNetwork('invalid', unseenMinimalProbability: -0.1);
      }, throwsA(isA<ArgumentError>()));
    });

    test('invalid 2', () {
      var bayesNet = BayesianNetwork('invalid');

      expect(() {
        bayesNet.addVariable("C", [
          'F',
          'T',
        ], [], [
          "C = F: -0.99",
          "C = T: 0.01",
        ]);
      }, throwsA(isA<ValidationError>()));
    });

    test('invalid 3', () {
      var bayesNet = BayesianNetwork('invalid');

      bayesNet.addVariable("C", [
        'F',
        'T',
      ], [], [
        "C = F: 0.99",
        "C = T: 0.01",
      ]);

      expect(bayesNet.isFrozen, isFalse);

      bayesNet.freeze();

      expect(bayesNet.isFrozen, isTrue);

      expect(() {
        bayesNet.addVariable("X", [
          'F',
          'T',
        ], [], [
          "X = F: 0.40",
          "X = T: 0.60",
        ]);
      }, throwsA(isA<ValidationError>()));
    });
  });
}

BayesEventMonitor _generateCancerEvents(int multiplier) {
  var eventMonitor = BayesEventMonitor('cancer');

  var limit = 990 * multiplier;
  for (var i = 0; i < limit; ++i) {
    eventMonitor.notifyEvent(['C=F']);
  }

  limit = 10 * multiplier;
  for (var i = 0; i < limit; ++i) {
    eventMonitor.notifyEvent(['C=T']);
  }

  limit = 901 * multiplier;
  for (var i = 0; i < limit; ++i) {
    eventMonitor.notifyEvent(['X=N', 'C=F']);
  }

  limit = 89 * multiplier;
  for (var i = 0; i < limit; ++i) {
    eventMonitor.notifyEvent(['X=P', 'C=F']);
  }

  limit = 1 * multiplier;
  for (var i = 0; i < limit; ++i) {
    eventMonitor.notifyEvent(['X=N', 'C=T']);
  }

  limit = 9 * multiplier;
  for (var i = 0; i < limit; ++i) {
    eventMonitor.notifyEvent(['X=P', 'C=T']);
  }

  limit = 10 * multiplier;
  for (var i = 0; i < limit; ++i) {
    eventMonitor.notifyEvent(['D=T']);
    eventMonitor.notifyEvent(['D=F']);
  }

  // Nodes out of `C` chain:
  limit = 10 * multiplier;
  for (var i = 0; i < limit; ++i) {
    eventMonitor.notifyEvent(['Y=N', 'D=T']);
  }

  limit = 90 * multiplier;
  for (var i = 0; i < limit; ++i) {
    eventMonitor.notifyEvent(['Y=P', 'D=T']);
  }

  print(eventMonitor);
  return eventMonitor;
}

void _testBayesNetCancer(BayesianNetwork bayesNet,
    {double tolerance = 0.0001, bool hasGhostBranch = false}) {
  expect(bayesNet.isValid, isTrue);

  expect(bayesNet.hasNodeWithName('C'), isTrue);
  expect(bayesNet.hasNodeWithName('X'), isTrue);
  expect(bayesNet.hasNodeWithName('Z'), isFalse);

  expect(bayesNet.getNodeByName('C').parentsLength, 0);
  expect(bayesNet.getNodeByName('X').parentsLength, 1);

  expect(() {
    bayesNet.getNodeByName('Z');
  }, throwsA(isA<ValidationError>()));

  if (hasGhostBranch) {
    expect(bayesNet.nodes.map((e) => e.name), equals(['C', 'D', 'X', 'Y']));
    expect(bayesNet.nodesInTopologicalOrder.map((e) => e.name),
        equals(['C', 'D', 'X', 'Y']));

    expect(
        bayesNet.nodesInChain([bayesNet.getNodeByName('C')]).map((e) => e.name),
        equals(['C', 'X']));

    expect(
        bayesNet
            .nodesInChain(bayesNet.getNodesByNames(['C', 'D']))
            .map((e) => e.name),
        equals(['C', 'D', 'X', 'Y']));
  } else {
    expect(bayesNet.nodesInTopologicalOrder.map((e) => e.name),
        equals(['C', 'X']));

    expect(
        bayesNet.nodesInChain([bayesNet.getNodeByName('C')]).map((e) => e.name),
        equals(['C', 'X']));

    expect(
        bayesNet
            .nodesInChain(bayesNet.getNodesByNames(['C', 'D']))
            .map((e) => e.name),
        equals(['C', 'X']));
  }

  var analyser = bayesNet.analyser;

  var result1 = analyser.showAnswer('C=T | X=P');
  expect(result1.probability, _isNear(0.091836, tolerance));
  expect(analyser.ask('P(c|x)'), equals(result1));

  var result2 = analyser.showAnswer('C=T | X=N');
  expect(result2.probability, _isNear(0.0011, tolerance));
  expect(analyser.ask('P(c|-x)'), equals(result2));

  var result3 = analyser.showAnswer('C=T');
  expect(result3.probability, _isNear(0.01, tolerance));
  expect(analyser.ask('P(c)'), equals(result3));

  {
    var questions = analyser.generateQuestions('X');
    expect(questions.length, equals(hasGhostBranch ? 6 : 2));
  }

  {
    var questions =
        analyser.generateQuestions('X', ignoreVariables: ['D', 'Y']);
    expect(questions.length, equals(2));

    var answers = analyser.quiz(questions);

    for (var e in answers) {
      print(e);
    }

    expect(answers[0].selectedValues[0].name, equals('F'));
    expect(answers[1].selectedValues[0].name, equals('T'));

    expect(answers[0].probability, _isNear(0.09, 0.01));
    expect(answers[1].probability, _isNear(0.90, 0.01));

    var groupByTarget = answers.groupByTargetVariable();

    expect(groupByTarget.keys.map((e) => e.name).toList(), equals(['X']));
    expect(
        groupByTarget.values
            .map((e) => e.map((e) => e.targetValue.variable.name).toList())
            .toList(),
        equals([
          ['X', 'X']
        ]));

    var groupBySelVar = answers.groupBySelectedVariable();

    expect(groupBySelVar.keys.map((e) => e.name).toList(), equals(['C']));
    expect(
        groupBySelVar.values
            .map((e) => e.map((e) => e.targetValue.variable.name).toList())
            .toList(),
        equals([
          ['X', 'X']
        ]));

    answers.sortBySelectedValues();
    expect(answers.map((e) => e.query).toList(), [
      'X = P | C = F',
      'X = P | C = T',
    ]);

    answers.sortByTargetValue();
    expect(answers.map((e) => e.query).toList(), [
      'X = P | C = F',
      'X = P | C = T',
    ]);

    answers.sortByProbability();
    expect(answers.map((e) => e.query).toList(), [
      'X = P | C = F',
      'X = P | C = T',
    ]);

    answers.sortBySelectedValuesSignal();
    expect(answers.map((e) => e.query).toList(), [
      'X = P | C = F',
      'X = P | C = T',
    ]);

    bayesNet.disposeCaches();

    if (hasGhostBranch) {
      expect(bayesNet.nodesInTopologicalOrder.map((e) => e.name),
          equals(['C', 'D', 'X', 'Y']));
    } else {
      expect(bayesNet.nodesInTopologicalOrder.map((e) => e.name),
          equals(['C', 'X']));
    }
  }
}

Matcher _isNear(double value, [double tolerance = 0.0001]) =>
    inInclusiveRange(value - tolerance, value + tolerance);
