import 'package:statistics/statistics.dart';

void main() {
  var ns = [10, 20.0, 25, 30];
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
  print(
      'Statistics.median: ${statistics.median} -> ${statistics.medianLow} , ${statistics.medianHigh}');
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
// ns: [10, 20.0, 25, 30]
// mean: 21.25
// sdv: 6.931585316505886
// squares: [100, 400.0, 625, 900]
// Statistics.max: 30
// Statistics.min: 10
// Statistics.mean: 21.25
// Statistics.standardDeviation: 22.5
// Statistics.sum: 85.0
// Statistics.center: 25
// Statistics.median: 22.5 -> 20.0 , 25
// Statistics.squaresSum: 2025.0
// Statistics: {~21.25 +-22.5 [10..(25)..30] #4}
// ---
// CSV:
// #,a,b
// 1,10,100
// 2,20,200
// 3,0,300
//
