import 'package:statistics/statistics.dart';

void main() {
  var ns = [10, 20.0, 30];
  print('ns: $ns');

  // Numeric extension:

  var mean = ns.mean;
  print('mean: $mean');

  var sdv = ns.standardDeviation;
  print('sdv: $sdv');

  var squares = ns.square;
  print('squares: $squares');

  // Statistics:

  var statistics = ns.statistics;

  print('Statistics.max: ${statistics.max}');
  print('Statistics.min: ${statistics.min}');
  print('Statistics.mean: ${statistics.mean}');
  print('Statistics.standardDeviation: ${statistics.standardDeviation}');
  print('Statistics.sum: ${statistics.sum}');
  print('Statistics.center: ${statistics.center}');
  print('Statistics.squaresSum: ${statistics.squaresSum}');

  print('Statistics: $statistics');

  // CSV:

  var categories = <String, List<double?>>{
    'a': [10.0, 20.0, null],
    'b': [100.0, 200.0, 300.0]
  };

  var csv = categories.generateCSV();
  print('---');
  print('CSV:');
  print(csv);
}

// ---------------------------------------------
// OUTPUT:
// ---------------------------------------------
// ns: [10, 20.0, 30]
// mean: 20.0
// sdv: 8.16496580927726
// squares: [100, 400.0, 900]
// Statistics.max: 30
// Statistics.min: 10
// Statistics.mean: 20.0
// Statistics.standardDeviation: 21.602468994692867
// Statistics.sum: 60.0
// Statistics.center: 20.0
// Statistics.squaresSum: 1400.0
// Statistics: {~20 +-21.6024 [10..(20)..30] #3.0}
// ---
// CSV:
// #,a,b
// 1,10.0,100.0
// 2,20.0,200.0
// 3,0.0,300.0
//
