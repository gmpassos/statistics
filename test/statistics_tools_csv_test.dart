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
        'a': [10.0, 20.512345, null],
        'b': [100.0, 200.0, 300.0]
      };

      var csv1 = categories.generateCSV();

      expect(
          csv1,
          equals('#,a,b\n'
              '1,10,100\n'
              '2,20.5123,200\n'
              '3,0,300\n'));

      var csv2 = categories.generateCSV(valueNormalizer: (v) => (v ?? 0) * 2);

      expect(
          csv2.replaceAll('.0,', ',').replaceAll('.0\n', '\n'),
          equals('#,a,b\n'
              '1,20,200\n'
              '2,41.02469,400\n'
              '3,0,600\n'));

      expect(categories.csvFileName('test', 'list'),
          matches(RegExp(r'^test--list--\d+\.csv$')));

      expect(categories.csvFileName('test', 'foo'),
          matches(RegExp(r'^test--foo--\d+.csv$')));
    });

    test('<List<int>>', () {
      var list = <List<int>>[
        [10, 20, 30],
        [30, 40, 50]
      ];

      var list2 = list.map((e) => e.statistics);

      var csv1 = list2.generateCSV(decimalPrecision: -1);

      expect(
          csv1,
          equals('mean,standardDeviation,length,min,max,sum,squaresSum\n'
              '20,8.16496580927726,3,10,30,60,1400\n'
              '40,8.16496580927726,3,30,50,120,5000\n'));

      var csv2 = list2.generateCSV(decimalPrecision: 2);

      expect(
          csv2,
          equals('mean,standardDeviation,length,min,max,sum,squaresSum\n'
              '20,8.16,3,10,30,60,1400\n'
              '40,8.16,3,30,50,120,5000\n'));

      var csv3 = list2.generateCSV(decimalPrecision: 0);

      expect(
          csv3,
          equals('mean,standardDeviation,length,min,max,sum,squaresSum\n'
              '20,8,3,10,30,60,1400\n'
              '40,8,3,30,50,120,5000\n'));

      var csv4 =
          list2.generateCSV(decimalPrecision: 2, commaAsDecimalSeparator: true);

      expect(
          csv4,
          equals('mean,standardDeviation,length,min,max,sum,squaresSum\n'
              '20,"8,16",3,10,30,60,1400\n'
              '40,"8,16",3,30,50,120,5000\n'));

      var csv5 =
          list2.generateCSV(valueNormalizer: (v) => v is num ? v * 2 : v!);

      expect(
          csv5.replaceAll('.0,', ',').replaceAll('.0\n', '\n'),
          equals('mean,standardDeviation,length,min,max,sum,squaresSum\n'
              '40,16.32993161855452,6,20,60,120,2800\n'
              '80,16.32993161855452,6,60,100,240,10000\n'));

      expect(list2.csvFileName('test', 'list'),
          matches(RegExp(r'^test--list--\d+\.csv$')));

      expect(list2.csvFileName('test', 'foo'),
          matches(RegExp(r'^test--foo--\d+.csv$')));
    });

    test('[<String, int>]', () {
      var l = [
        {'a': 1, 'b': 2},
        {'a': 10, 'b': 20},
        {'a': 100, 'b': 200}
      ];

      var csv1 = l.generateCSV();

      expect(
          csv1,
          equals('a,b\n'
              '1,2\n'
              '10,20\n'
              '100,200\n'));

      var csv2 = l.generateCSV(valueNormalizer: (v) => int.parse('$v') * 2);

      expect(
          csv2,
          equals('a,b\n'
              '2,4\n'
              '20,40\n'
              '200,400\n'));

      var csv3 = l.generateCSV(fieldsNames: ['b', 'a']);

      expect(
          csv3,
          equals('b,a\n'
              '2,1\n'
              '20,10\n'
              '200,100\n'));

      var csv4 = l.generateCSV(
          fieldsNames: ['b', 'a'], valueNormalizer: (v) => int.parse('$v') * 2);

      expect(
          csv4,
          equals('b,a\n'
              '4,2\n'
              '40,20\n'
              '400,200\n'));

      expect(l.csvFileName('test', 'foo'),
          matches(RegExp(r'^test--foo--\d+.csv$')));
    });

    // `RFC 4180`: a value containing the separator or a `"` must be quoted,
    // and a `"` inside a quoted value must be escaped as `""`. Without the
    // escape, `both, "x"` was written as `"both, "x""`, which any parser reads
    // back as 2 corrupted fields.
    test('normalizeCSVValue quoting/escaping', () {
      expect(normalizeCSVValue('plain'), equals('plain'));

      expect(normalizeCSVValue('has,separator'), equals('"has,separator"'));

      expect(normalizeCSVValue('has"quote'), equals('"has""quote"'));

      expect(normalizeCSVValue('both, "x"'), equals('"both, ""x"""'));

      expect(normalizeCSVValue('"quoted"'), equals('"""quoted"""'));

      // A custom separator:
      expect(normalizeCSVValue('a;b', separator: ';'), equals('"a;b"'));
      expect(normalizeCSVValue('a,b', separator: ';'), equals('a,b'));
    });

    test('generateCSV values round trip through an RFC 4180 parser', () {
      var rows = <Map<String, dynamic>>[
        {'name': 'Smith, John', 'age': 30},
        {'name': 'say "hi"', 'age': 40},
        {'name': 'both, "x"', 'age': 50},
        {'name': 'plain', 'age': 60},
      ];

      var csv = rows.generateCSV();
      var lines = csv.trim().split('\n');

      expect(lines.length, equals(rows.length + 1));
      expect(_parseCSVLine(lines[0]), equals(['name', 'age']));

      for (var i = 0; i < rows.length; ++i) {
        var fields = _parseCSVLine(lines[i + 1]);
        expect(fields.length, equals(2), reason: lines[i + 1]);
        expect(fields[0], equals(rows[i]['name']), reason: lines[i + 1]);
        expect(fields[1], equals('${rows[i]['age']}'), reason: lines[i + 1]);
      }
    });

    // A column name containing the separator was written unquoted, so the
    // header declared more columns than the rows carried.
    test('generateCSV quotes column names', () {
      var rows = <Map<String, dynamic>>[
        {'a,b': 1, 'c': 2},
      ];

      var csv = rows.generateCSV();
      var lines = csv.trim().split('\n');

      var head = _parseCSVLine(lines[0]);
      var row = _parseCSVLine(lines[1]);

      expect(head, equals(['a,b', 'c']));
      expect(row.length, equals(head.length),
          reason: 'header and rows must have the same number of columns');

      // Explicit `fieldsNames` too:
      var csv2 = rows.generateCSV(fieldsNames: ['a,b', 'c']);
      expect(_parseCSVLine(csv2.trim().split('\n')[0]), equals(['a,b', 'c']));
    });

    test('generateCSV quotes column names of a series map', () {
      var series = <String, List<int>?>{
        'x,y': [1, 2],
        'z': [3, 4],
      };

      var csv = series.generateCSV();
      var head = _parseCSVLine(csv.trim().split('\n')[0]);

      // The series head starts with the index column (`#`):
      expect(head, equals(['#', 'x,y', 'z']));
    });
  });
}

/// A minimal `RFC 4180` parser: quoted fields, with `""` as an escaped quote.
List<String> _parseCSVLine(String line, [String separator = ',']) {
  var fields = <String>[];
  var buffer = StringBuffer();
  var inQuotes = false;
  var i = 0;

  while (i < line.length) {
    var c = line[i];

    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i += 2;
          continue;
        }
        inQuotes = false;
        i++;
        continue;
      }
      buffer.write(c);
      i++;
    } else if (c == '"' && buffer.isEmpty) {
      inQuotes = true;
      i++;
    } else if (c == separator) {
      fields.add(buffer.toString());
      buffer.clear();
      i++;
    } else {
      buffer.write(c);
      i++;
    }
  }

  fields.add(buffer.toString());
  return fields;
}
