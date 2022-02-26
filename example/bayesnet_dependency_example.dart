import 'package:statistics/statistics.dart';

void main() {
  // ** Note that this example is NOT USING REAL probabilities for Cancer!

  var bayesNet = BayesianNetwork('cancer');

  // C (cancer) = T (true) ; F (false)
  bayesNet.addVariable("C", [
    'F',
    'T',
  ], [], [
    "C = F: 0.99",
    "C = T: 0.01",
  ]);

  // X (exam) = P (positive) ; N (negative)
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

  // D (Doctor diagnosis) = P (positive) ; N (negative)
  bayesNet.addVariable("D", [
    '+P',
    '-N',
  ], [
    "C"
  ], [
    "D = N, C = F: 0.99",
    "D = P, C = F: 0.01",
    "D = N, C = T: 0.75",
    "D = P, C = T: 0.25",
  ]);

  // Add dependency between D (Doctor diagnosis) and X (Exam),
  // where the probability of a correct diagnosis is improved:
  bayesNet.addDependency([
    'D',
    'X'
  ], [
    "D = N, X = N, C = F: 0.364",
    "D = P, X = N, C = F: 0.546",
    "D = N, X = P, C = F: 0.036",
    "D = P, X = P, C = F: 0.054",
    "D = N, X = N, C = T: 0.025",
    "D = N, X = P, C = T: 0.075",
    "D = P, X = N, C = T: 0.225",
    "D = P, X = P, C = T: 0.675",
  ]);

  // Show the network nodes and probabilities:
  print(bayesNet);

  var analyser = bayesNet.analyser;

  // Ask the probability to have cancer with a positive exame (X = P):
  var answer1 = analyser.ask('P(c|x)');
  print(
      answer1); // P(c|x) -> C = T | X = P -> 0.09174311926605506 (0.009000000000000001) >> 917.43%

  // Ask the probability to have cancer with a negative exame (X = N):
  var answer2 = analyser.ask('P(c|-x)');
  print(
      answer2); // P(c|-x) -> C = T | X = N -> 0.0011087703736556158 (0.001) >> 11.09%

  // Ask the probability to have cancer with a positive diagnosis from the Doctor (D = P):
  var answer3 = analyser.ask('P(c|d)');
  print(
      answer3); // P(c|d) -> C = T | D = P -> 0.20161290322580644 (0.0025) >> 2016.13%

  // Ask the probability to have cancer with a negative diagnosis from the Doctor (D = N):
  var answer4 = analyser.ask('P(c|-d)');
  print(
      answer4); // P(c|-d) -> C = T | D = N -> 0.007594167679222358 (0.0075) >> 75.94%

  // Ask the probability to have cancer with a positive diagnosis from the Doctor and a positive exame (D = P, X = P):
  var answer5 = analyser.ask('P(c|d,x)');
  print(
      answer5); // P(c|d,x) -> C = T | D = P, X = P -> 0.11210762331838567 (0.006750000000000001) >> 1121.08%

  // Ask the probability to have cancer with a negative diagnosis from the Doctor and a negative exame (D = N, X = N):
  var answer6 = analyser.ask('P(c|-d,-x)');
  print(
      answer6); // P(c|-d,-x) -> C = T | D = N, X = N -> 0.0006932697373894235 (0.00025) >> 6.93%

  print('-- Generating all possible questions:');

  var questions = analyser.generateQuestions('C',
      addPriorQuestions: true, combinationsLevel: 2);
  var answers = analyser.quiz(questions);

  answers.sortByQuery();

  for (var answer in answers) {
    print(answer);
  }
}

// ---------------------------------------------
// OUTPUT:
// ---------------------------------------------
// BayesianNetwork[cancer]{ variables: 3 }<
// C: []
//   C = F: 0.99
//   C = T: 0.01
// X: [C]
//   X = N, C = F: 0.91
//   X = P, C = F: 0.09
//   X = N, C = T: 0.1
//   X = P, C = T: 0.9
// D: [C]
//   D = N, C = F: 0.99
//   D = P, C = F: 0.01
//   D = N, C = T: 0.75
//   D = P, C = T: 0.25
// D <-> X:
//   D = N, C = F, X = N: 0.364
//   D = N, C = F, X = P: 0.036
//   D = P, C = F, X = N: 0.546
//   D = P, C = F, X = P: 0.054
//   D = N, C = T, X = N: 0.025
//   D = N, C = T, X = P: 0.075
//   D = P, C = T, X = N: 0.225
//   D = P, C = T, X = P: 0.675
// >
// P(c|x) -> C = T | X = P -> 0.09174311926605506 (0.009000000000000001) >> 917.43%
// P(c|-x) -> C = T | X = N -> 0.0011087703736556158 (0.001) >> 11.09%
// P(c|d) -> C = T | D = P -> 0.20161290322580644 (0.0025) >> 2016.13%
// P(c|-d) -> C = T | D = N -> 0.007594167679222358 (0.0075) >> 75.94%
// P(c|d,x) -> C = T | D = P, X = P -> 0.11210762331838567 (0.006750000000000001) >> 1121.08%
// P(c|-d,-x) -> C = T | D = N, X = N -> 0.0006932697373894235 (0.00025) >> 6.93%
// -- Generating all possible questions:
// P(-C) -> C = F |  -> 0.99 >> 100.00%
// P(C) -> C = T |  -> 0.01 >> 100.00%
// P(C|-D) -> C = T | D = N -> 0.007594167679222358 (0.0075) >> 75.94%
// P(C|-X,-D) -> C = T | D = N, X = N -> 0.0006932697373894235 (0.00025) >> 6.93%
// P(C|X,-D) -> C = T | D = N, X = P -> 0.020610057708161583 (0.00075) >> 206.10%
// P(C|D) -> C = T | D = P -> 0.20161290322580644 (0.0025) >> 2016.13%
// P(C|-X,D) -> C = T | D = P, X = N -> 0.00414524954402255 (0.0022500000000000003) >> 41.45%
// P(C|X,D) -> C = T | D = P, X = P -> 0.11210762331838567 (0.006750000000000001) >> 1121.08%
// P(C|-X) -> C = T | X = N -> 0.0011087703736556158 (0.001) >> 11.09%
// P(C|X) -> C = T | X = P -> 0.09174311926605506 (0.009000000000000001) >> 917.43%
//
