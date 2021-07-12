import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('CSV', () {
    setUp(() {});

    test('<String, List<int>>', () {
      var categories = <String, List<int>>{
        'a': [10, 20, 30],
        'b': [100, 200, 300]
      };

      var csv1 = categories.generateCSV();

      expect(
          csv1,
          equals('#,a,b\n'
              '1,10,100\n'
              '2,20,200\n'
              '3,30,300\n'));

      var csv2 = categories.generateCSV(valueNormalizer: (v) => v * 2);

      expect(
          csv2,
          equals('#,a,b\n'
              '1,20,200\n'
              '2,40,400\n'
              '3,60,600\n'));

      expect(categories.csvFileName('test', 'list'),
          matches(RegExp(r'^test--list--\d+\.csv$')));
    });

    test('<String, List<int?>>', () {
      var categories = <String, List<int?>>{
        'a': [10, 20, null],
        'b': [100, 200, 300]
      };

      var csv1 = categories.generateCSV();

      expect(
          csv1,
          equals('#,a,b\n'
              '1,10,100\n'
              '2,20,200\n'
              '3,0,300\n'));

      var csv2 = categories.generateCSV(valueNormalizer: (v) => (v ?? 0) * 2);

      expect(
          csv2,
          equals('#,a,b\n'
              '1,20,200\n'
              '2,40,400\n'
              '3,0,600\n'));

      expect(categories.csvFileName('test', 'list'),
          matches(RegExp(r'^test--list--\d+\.csv$')));
    });

    test('<String, List<double?>>', () {
      var categories = <String, List<double?>>{
        'a': [10.0, 20.0, null],
        'b': [100.0, 200.0, 300.0]
      };

      var csv1 = categories.generateCSV();

      expect(
          csv1,
          equals('#,a,b\n'
              '1,10.0,100.0\n'
              '2,20.0,200.0\n'
              '3,0.0,300.0\n'));

      var csv2 = categories.generateCSV(valueNormalizer: (v) => (v ?? 0) * 2);

      expect(
          csv2,
          equals('#,a,b\n'
              '1,20.0,200.0\n'
              '2,40.0,400.0\n'
              '3,0.0,600.0\n'));

      expect(categories.csvFileName('test', 'list'),
          matches(RegExp(r'^test--list--\d+\.csv$')));
    });

    test('<List<int>>', () {
      var list = <List<int>>[
        [10, 20, 30],
        [30, 40, 50]
      ];

      var list2 = list.map((e) => e.statistics);

      var csv1 = list2.generateCSV();

      expect(
          csv1,
          equals('mean,standardDeviation,length,min,max,sum,squaresSum\n'
              '20.0,21.602468994692867,3.0,10,30,60,1400\n'
              '40.0,40.824829046386306,3.0,30,50,120,5000\n'));

      var csv2 =
          list2.generateCSV(valueNormalizer: (v) => v is num ? v * 2 : v!);

      expect(
          csv2,
          equals('mean,standardDeviation,length,min,max,sum,squaresSum\n'
              '40.0,43.20493798938573,6.0,20,60,120,2800\n'
              '80.0,81.64965809277261,6.0,60,100,240,10000\n'));

      expect(list2.csvFileName('test', 'list'),
          matches(RegExp(r'^test--list--\d+\.csv$')));
    });
  });
}
