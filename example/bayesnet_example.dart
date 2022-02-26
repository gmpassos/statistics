import 'package:statistics/statistics.dart';

void main() {
  // Monitor events to then build a Bayesian Network:
  // ** Note that this example is NOT USING REAL probabilities for Cancer!
  var eventMonitor = BayesEventMonitor('cancer');

  // The prevalence of Cancer in the population:
  // - 1% (10:990):

  for (var i = 0; i < 990; ++i) {
    eventMonitor.notifyEvent(['CANCER=false']);
  }

  for (var i = 0; i < 10; ++i) {
    eventMonitor.notifyEvent(['CANCER=true']);
  }

  // The Exam performance when the person have cancer:
  // - 90% Sensitivity.
  // - 10% false negative (1:9).

  for (var i = 0; i < 9; ++i) {
    eventMonitor.notifyEvent(['EXAM=positive', 'CANCER=true']);
  }

  for (var i = 0; i < 1; ++i) {
    eventMonitor.notifyEvent(['EXAM=negative', 'CANCER=true']);
  }

  // The Exam performance when the person doesn't have cancer:
  // - 91% Specificity
  // - 9% false positive (89:901).

  for (var i = 0; i < 901; ++i) {
    eventMonitor.notifyEvent(['EXAM=negative', 'CANCER=false']);
  }
  for (var i = 0; i < 89; ++i) {
    eventMonitor.notifyEvent(['EXAM=positive', 'CANCER=false']);
  }

  var bayesNet = eventMonitor.buildBayesianNetwork();

  print('$bayesNet\n');

  var analyser = bayesNet.analyser;

  print('- Analyser: $analyser\n');

  var answerCancerWithoutExam = analyser.ask('P(cancer)');
  print('- Cancer probability without an Exam:');
  print('  $answerCancerWithoutExam');

  var answerNoCancerWithoutExam = analyser.ask('P(-cancer)');
  print('- Not having Cancer probability without an Exam:');
  print('  $answerNoCancerWithoutExam');

  var answerCancerWithPositiveExam = analyser.ask('P(cancer|exam)');
  print('- Cancer probability with a positive Exam:');
  print('  $answerCancerWithPositiveExam');

  var answerCancerWithNegativeExam = analyser.ask('P(cancer|-exam)');
  print('- Cancer probability with a negative Exam:');
  print('  $answerCancerWithNegativeExam');

  var answerNoCancerWithPositiveExam = analyser.ask('P(-cancer|exam)');
  print('- Not having Cancer probability with a positive Exam:');
  print('  $answerNoCancerWithPositiveExam');

  var answerNoCancerWithNegativeExam = analyser.ask('P(-cancer|-exam)');
  print('- Not having Cancer probability with a negative Exam:');
  print('  $answerNoCancerWithNegativeExam');

  print('\n** NOTE: This example is NOT USING REAL probabilities for Cancer!');
}

// ---------------------------------------------
// OUTPUT:
// ---------------------------------------------
// BayesianNetwork[cancer]{ variables: 2 }<
// CANCER: []
//   CANCER = FALSE: 0.99
//   CANCER = TRUE: 0.01
// EXAM: [CANCER]
//   EXAM = NEGATIVE, CANCER = FALSE: 0.9101010101010101
//   EXAM = POSITIVE, CANCER = FALSE: 0.0898989898989899
//   EXAM = NEGATIVE, CANCER = TRUE: 0.1
//   EXAM = POSITIVE, CANCER = TRUE: 0.9
//
// >
//
// - Analyser: BayesAnalyserVariableElimination{network: cancer}
//
// - Cancer probability without an Exam:
//   P(cancer) -> CANCER = TRUE |  -> 0.01 >> 100.00%
// - Not having Cancer probability without an Exam:
//   P(-cancer) -> CANCER = FALSE |  -> 0.99 >> 100.00%
// - Cancer probability with a positive Exam:
//   P(cancer|exam) -> CANCER = TRUE | EXAM = POSITIVE -> 0.09183673469387756 (0.009000000000000001) >> 918.37%
// - Cancer probability with a negative Exam:
//   P(cancer|-exam) -> CANCER = TRUE | EXAM = NEGATIVE -> 0.0011086474501108647 (0.001) >> 11.09%
// - Not having Cancer probability with a positive Exam:
//   P(-cancer|exam) -> CANCER = FALSE | EXAM = POSITIVE -> 0.9081632653061223 (0.089) >> 91.73%
// - Not having Cancer probability with a negative Exam:
//   P(-cancer|-exam) -> CANCER = FALSE | EXAM = NEGATIVE -> 0.9988913525498891 (0.901) >> 100.90%
//
// ** NOTE: This example is NOT USING REAL probabilities for Cancer!
//
