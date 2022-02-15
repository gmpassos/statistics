import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('BayesianNetwork', () {
    test('basic', () {
      print('--------------------------------------------------------');

      var bayseNet = BayesianNetwork('basic');

      bayseNet.addNode("M", [
        'T',
        'F'
      ], [], [
        "M = T: 0.2",
        "M = F: 0.8",
      ]);

      bayseNet.addNode("I", [
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

      bayseNet.addNode("B", [
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

      bayseNet.addNode("C", [
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

      bayseNet.addNode("S", [
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

      print(bayseNet);

      var analyser = bayseNet.analyser;

      var result1 = analyser.showAnswer('P(c|m,b)');
      expect(result1.probability, inInclusiveRange(0.600000, 0.600001));

      var result2 = analyser.showAnswer('P(-c|m,b)');
      expect(result2.probability, inInclusiveRange(0.399999, 0.400001));

      var result3 = analyser.showAnswer('P(c|m,-b)');
      expect(result3.probability, inInclusiveRange(0.547826, 0.547827));

      var result4 = analyser.showAnswer('P(-c|m,-b)');
      expect(result4.probability, inInclusiveRange(0.452173, 0.452174));

      var result5 = analyser.showAnswer('P(s|m,b)');
      expect(result5.probability, inInclusiveRange(0.600000, 0.600001));

      var result6 = analyser.showAnswer('P(s|m,-b)');
      expect(result6.probability, inInclusiveRange(0.534050, 0.534051));
    });

    test('sprinkler', () {
      print('--------------------------------------------------------');

      var bayseNet = BayesianNetwork('sprinkler');

      bayseNet.addNode("C", [
        'F',
        'T',
      ], [], [
        "C = F: 0.5",
        "C = T: 0.5",
      ]);

      bayseNet.addNode("S", [
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

      bayseNet.addNode("R", [
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

      bayseNet.addNode("W", [
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

      print(bayseNet);

      var analyser = bayseNet.analyser;

      var result1 = analyser.showAnswer('P(c|s,r)');
      expect(result1.probability, inInclusiveRange(0.307692, 0.307693));

      var result2 = analyser.showAnswer('P(c|s,-r)');
      expect(result2.probability, inInclusiveRange(0.027027, 0.027028));

      var result3 = analyser.showAnswer('P(c|-s,-r)');
      expect(result3.probability, inInclusiveRange(0.2000000, 0.2000001));

      var result4 = analyser.showAnswer('P(w|-s,-r)');
      expect(result4.probability, inInclusiveRange(0.4805194, 0.4805195));

      var result5 = analyser.showAnswer('P(w|s,r)');
      expect(result5.probability, inInclusiveRange(0.596153, 0.596154));

      var result6 = analyser.showAnswer('P(c|w,r)');
      expect(result6.probability, inInclusiveRange(0.556521, 0.556522));

      var result7 = analyser.showAnswer('P(c|w,s)');
      expect(result7.probability, inInclusiveRange(0.074468, 0.074469));

      var result8 = analyser.showAnswer('P(c|-w)');
      expect(result8.probability, inInclusiveRange(0.211461, 0.211462));
    });

    test('cancer', () {
      print('--------------------------------------------------------');

      var bayseNet = BayesianNetwork('cancer');

      bayseNet.addNode("C", [
        'F',
        'T',
      ], [], [
        "C = F: 0.99",
        "C = T: 0.01",
      ]);

      bayseNet.addNode("X", [
        'F',
        'T',
      ], [
        "C"
      ], [
        "X = F, C = F: 0.99",
        "X = F, C = T: 0.01",
        "X = T, C = F: 0.10",
        "X = T, C = T: 0.90",
      ]);

      print(bayseNet);

      var analyser = bayseNet.analyser;

      var result1 = analyser.showAnswer('C=T | X=T');
      expect(result1.probability, inInclusiveRange(0.083333, 0.083334));
      expect(analyser.ask('P(c|x)'), equals(result1));

      var result2 = analyser.showAnswer('C=T | X=F');
      expect(result2.probability, inInclusiveRange(0.000102, 0.000103));
      expect(analyser.ask('P(c|-x)'), equals(result2));
    });
  });
}
