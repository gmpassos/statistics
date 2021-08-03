import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('extension', () {
    setUp(() {});

    test('ListExtension<String>', () {
      var l = <String>['10', '20', '30'];

      expect(l.toMap((e) => e, (e) => int.parse(e)),
          equals({'10': 10, '20': 20, '30': 30}));

      {
        var out = <String>[];
        l.printElements(printer: (s) => out.add('$s'), prefix: '>');
        expect(out, equals(['>10', '>20', '>30']));

        out.clear();
        l.printElements(printer: (s) => out.add('$s'));
        expect(out, equals(['10', '20', '30']));
      }

      expect(l.getReversed(0), equals('30'));
      expect(l.getReversed(1), equals('20'));
      expect(l.getReversed(2), equals('10'));

      expect(l.getValueIfExists(2), equals('30'));
      expect(l.getValueIfExists(3), isNull);

      expect(l.setAllWith((i, n) => '#$i:$n'), equals(3));
      expect(l, equals(['#0:10', '#1:20', '#2:30']));

      expect(l.allEquals('101'), isFalse);

      expect(l.setAllWithValue('101'), equals(3));
      expect(l, equals(['101', '101', '101']));

      expect(l.allEquals('101'), isTrue);

      expect(l.setAllWithList(['0', 'a', 'b', 'c', 'd'], 1), equals(3));
      expect(l, equals(['a', 'b', 'c']));

      expect(l.removeFromBegin(2), 2);
      expect(l, equals(['c']));
    });

    test('ListExtension<int>', () {
      var l = <int>[10, 20, 30];

      expect(l.getReversed(0), equals(30));
      expect(l.getReversed(1), equals(20));
      expect(l.getReversed(2), equals(10));

      expect(l.getValueIfExists(2), equals(30));
      expect(l.getValueIfExists(3), isNull);

      expect(l.setAllWith((i, n) => n + i), equals(3));
      expect(l, equals([10, 21, 32]));

      expect(l.allEquals(101), isFalse);

      expect(l.setAllWithValue(101), equals(3));
      expect(l, equals([101, 101, 101]));

      expect(l.allEquals(101), isTrue);

      expect(l.setAllWithList([0, 100, 200, 300], 1), equals(3));
      expect(l, equals([100, 200, 300]));

      expect(l.toStringElements(), equals(['100', '200', '300']));

      expect(l.removeFromEnd(2), equals(2));
      expect(l, equals([100]));

      expect(l.computeHashcode() > 0, isTrue);
      expect(l.computeHashcode(), equals([100].computeHashcode()));
      expect(l.computeHashcode() == [101].computeHashcode(), isFalse);
    });

    test('ListExtension<int>.ensureMaximumSize', () {
      var l1 = <int>[10, 20, 30];

      expect(l1.ensureMaximumSize(4), 0);
      expect(l1, equals([10, 20, 30]));

      expect(l1.ensureMaximumSize(3), 0);
      expect(l1, equals([10, 20, 30]));

      expect(l1.ensureMaximumSize(2), 1);
      expect(l1, equals([20, 30]));

      var l2 = <int>[10, 20, 30];
      expect(l2.ensureMaximumSize(1), 2);
      expect(l2, equals([30]));

      var l3 = <int>[10, 20, 30];
      expect(l3.ensureMaximumSize(1, removeFromEnd: true), 2);
      expect(l3, equals([10]));

      var l4 = <int>[10, 20, 30];
      expect(l4.ensureMaximumSize(2, removeExtras: 1), 2);
      expect(l4, equals([30]));
    });

    test('IterableExtension<T>', () {
      var itr = {'a': 1, 'b': 2, 'c': 3}.values;
      expect(itr.lastIndex, equals(2));

      expect(
          itr.groupBy((n) => n % 2 == 0 ? 'even' : 'odd'),
          equals({
            'odd': [1, 3],
            'even': [2]
          }));
    });

    test('MapExtension<String,int>', () {
      var m = <String, int>{
        'a': 1,
        'b': 2,
        'c': 3,
        'd': 4,
        'e': 5,
        'f': 6,
        'g': 7
      };

      expect(m.removeKeysAndReturnValues(['b', 'c']), equals({'b': 2, 'c': 3}));
      expect(m, equals({'a': 1, 'd': 4, 'e': 5, 'f': 6, 'g': 7}));

      m.removeKeys(['a', 'c']);
      expect(m, equals({'d': 4, 'e': 5, 'f': 6, 'g': 7}));

      m.keepKeys(['d', 'f', 'g']);
      expect(m, equals({'d': 4, 'f': 6, 'g': 7}));

      expect(m.keepKeysAndReturnValus(['d', 'g']), equals({'f': 6}));
      expect(m, equals({'d': 4, 'g': 7}));

      m.renameKeys({'d': 'D', 'g': 'G'});
      expect(m, equals({'D': 4, 'G': 7}));

      expect(m.filterKey('D', (n) => n * 10), isTrue);
      expect(m.filterKey('x', (n) => n * 10), isFalse);
      expect(m, equals({'D': 40, 'G': 7}));

      expect(m.getValuesInKeysOrder(['G', 'D']), equals([7, 40]));
      expect(m.getValuesInKeysOrder(['D', 'G']), equals([40, 7]));

      {
        var out = <String>[];
        m.printElements(
            printer: (s) => out.add('$s'), prefix: '>', keyDelimiter: '=');
        expect(out, equals(['>D=40', '>G=7']));

        out.clear();
        m.printElements(printer: (s) => out.add('$s'), keyDelimiter: '=');
        expect(out, equals(['D=40', 'G=7']));
      }

      expect(m.mergeKeysValues({'D': 10, 'G': 1}, (k, v1, v2) => v1 + v2),
          equals({'D': 50, 'G': 8}));

      expect(
          m.mergeKeysValuesNullable(
              {'D': 10, 'X': 100}, (k, v1, v2) => (v1 ?? 0) + (v2 ?? 0)),
          equals({'D': 50, 'G': 7, 'X': 100}));

      expect(
          m.mergeKeysValuesToList({'D': 10, 'G': 1}),
          equals({
            'D': [40, 10],
            'G': [7, 1]
          }));

      expect(
          m.mergeKeysValuesToListNullable({'D': 10, 'X': 100}),
          equals({
            'D': [40, 10],
            'G': [7, null],
            'X': [null, 100]
          }));

      expect(
          m.mergeKeysValuesToListNoNulls({'D': 10, 'X': 100}),
          equals({
            'D': [40, 10],
            'G': [7],
            'X': [100]
          }));
    });

    test('MapExtension<int,int>', () {
      var m = {1: 10, 2: 20, 3: 30};

      expect(m.getStringKeyValue('1'), equals(10));
      expect(m.getStringKeyValue('10'), isNull);

      expect(m.getValuesInStringKeysOrder(['1', '3']), equals([10, 30]));
    });

    test('SetExtension<String>', () {
      var l = <String>{'10', '20', '30'};

      expect(l, equals({'10', '20', '30'}));
      expect(l.allEquals('101'), isFalse);

      var l2 = <String>{'101'};
      expect(l2, equals({'101'}));
      expect(l2.allEquals('101'), isTrue);
    });

    test('SetExtension<int>', () {
      var l = <int>{10, 20, 30};

      expect(l, equals({10, 20, 30}));
      expect(l.toStringElements(), equals({'10', '20', '30'}));
      expect(l.allEquals(101), isFalse);

      var l2 = <int>{101};
      expect(l2, equals({101}));
      expect(l2.allEquals(101), isTrue);

      expect(l2.computeHashcode() > 0, isTrue);
      expect(l2.computeHashcode(), equals({101}.computeHashcode()));
      expect(l2.computeHashcode() == {102}.computeHashcode(), isFalse);
    });

    test('IterableExtension<int>', () {
      var l = <int>[11, 12, 13, 14, 15];

      var groups = l.groupBy((n) => n % 2 == 0 ? 'even' : 'odd');

      expect(groups.keys.toList(), equals(['odd', 'even']));

      expect(groups['odd'], equals([11, 13, 15]));
      expect(groups['even'], equals([12, 14]));
    });

    test('IterableMapExtension<String,int>', () {
      var itr = [
        {'a': 1, 'b': 2},
        {'c': 3, 'd': 4},
        {'e': 5, 'f': 6},
        {'a': 10, 'x': 100}
      ];

      expect(
          itr.groupBy((e) => e.keys.contains('a') ? 'with_a' : 'no_a'),
          equals({
            'with_a': [
              {'a': 1, 'b': 2},
              {'a': 10, 'x': 100}
            ],
            'no_a': [
              {'c': 3, 'd': 4},
              {'e': 5, 'f': 6}
            ]
          }));

      expect(
          itr.groupByKey('a', defaultKeyValue: 0),
          equals({
            1: [
              {'a': 1, 'b': 2}
            ],
            0: [
              {'c': 3, 'd': 4},
              {'e': 5, 'f': 6}
            ],
            10: [
              {'a': 10, 'x': 100}
            ]
          }));

      expect(itr.toKeyValues('a', defaultKeyValue: 0), equals([1, 0, 0, 10]));

      expect(itr.toKeyValuesNullable('a'), equals([1, null, null, 10]));

      itr.renameKeys({'a': 'A'});
      expect(
          itr,
          equals([
            {'b': 2, 'A': 1},
            {'c': 3, 'd': 4},
            {'e': 5, 'f': 6},
            {'x': 100, 'A': 10}
          ]));

      itr.removeKeys(['A']);
      expect(
          itr,
          equals([
            {'b': 2},
            {'c': 3, 'd': 4},
            {'e': 5, 'f': 6},
            {'x': 100}
          ]));

      itr.keepKeys(['b', 'c', 'e', 'x']);
      expect(
          itr,
          equals([
            {'b': 2},
            {'c': 3},
            {'e': 5},
            {'x': 100}
          ]));

      itr.filterKey('b', (n) => n * 100);
      expect(
          itr,
          equals([
            {'b': 200},
            {'c': 3},
            {'e': 5},
            {'x': 100}
          ]));

      expect(
          itr.mergeKeysValues([
            {'b': 1000}
          ], (key, v1, v2) => v1 + v2, onAbsentKey: (k, o) => 0),
          equals([
            {'b': 1200},
            {'c': 3},
            {'e': 5},
            {'x': 100}
          ]));

      expect(
          itr.mergeKeysValuesToList([
            {'b': 1000}
          ], onAbsentKey: (k, o) => 0),
          equals([
            {
              'b': [200, 1000]
            },
            {
              'c': [3, 0]
            },
            {
              'e': [5, 0]
            },
            {
              'x': [100, 0]
            }
          ]));
    });

    test('IterableIterableExtension<T>', () {
      var l = [
        [1, 10],
        [2, 20],
        [3, 30]
      ];

      expect(
          l.toKeysMap(keys: ['a', 'b']),
          equals([
            {'a': 1, 'b': 10},
            {'a': 2, 'b': 20},
            {'a': 3, 'b': 30}
          ]));

      expect(
          l.toKeysMap(keys: ['A', 'B']),
          equals([
            {'A': 1, 'B': 10},
            {'A': 2, 'B': 20},
            {'A': 3, 'B': 30}
          ]));

      l.insert(0, [1000, 2000]);

      expect(
          l.toKeysMap(useHeaderLine: true),
          equals([
            {1000: 1, 2000: 10},
            {1000: 2, 2000: 20},
            {1000: 3, 2000: 30}
          ]));

      var l2 = [
        ['x', 'y'],
        ...l
      ];

      expect(
          l2.toKeysMap(useHeaderLine: true),
          equals([
            {'x': 1000, 'y': 2000},
            {'x': 1, 'y': 10},
            {'x': 2, 'y': 20},
            {'x': 3, 'y': 30}
          ]));
    });

    test('StringExtension', () {
      var s = 'a,b\n1,2\n10,20\n100,"20 0",300\n';

      var lines = s.splitLines();
      expect(lines, equals(['a,b', '1,2', '10,20', '100,"20 0",300']));

      expect(lines[0].splitColumns(), equals(['a', 'b']));
      expect(lines[1].splitColumns(), equals(['1', '2']));
      expect(lines[3].splitColumns(), equals(['100', '20 0', '300']));
      expect(lines[3].splitColumns(acceptsQuotedValues: false),
          equals(['100', '"20 0"', '300']));
    });

    test('IterableStringExtension', () {
      var l = ['a,b,c', '1,2,3\n4,5,6', '10,"20,0",30'];

      var lines = l.splitLines();

      expect(lines, equals(['a,b,c', '1,2,3', '4,5,6', '10,"20,0",30']));

      expect(
          lines.splitColumns(),
          equals([
            ['a', 'b', 'c'],
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['10', '20,0', '30']
          ]));

      expect(
          lines.splitColumns(acceptQuotedValues: false),
          equals([
            ['a', 'b', 'c'],
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['10', '"20', '0"', '30']
          ]));

      var l2 = ['10', '20', '30'];
      expect(l2.toIntsList(), equals([10, 20, 30]));

      expect(l2.toDoublesList(), equals([10.0, 20.0, 30.0]));

      var l3 = ['10', '20.2', '30'];
      expect(l3.toDoublesList(), equals([10.0, 20.2, 30.0]));
      expect(l3.toNumsList(), equals([10, 20.2, 30]));

      var l4 = ['a,b,c', 'x,y,z'];
      var lines4 = l4.splitLines(filter: (l) => l.toUpperCase());

      expect(lines4, equals(['A,B,C', 'X,Y,Z']));
    });

    test('MapOfNumExtension<String,int>', () {
      var map = <String, List<int>>{
        'a': [10, 20, 30],
        'b': [40, 50, 60]
      };

      var statistics = map.statistics;

      expect(statistics['a']!.mean, equals(20));
      expect(statistics['b']!.mean, equals(50));
    });

    test('Duration.toStringUnit', () {
      expect(
          Duration(minutes: 10, seconds: 5).toStringUnit(), equals('10 min'));
      expect(Duration(minutes: 10, seconds: 5).toStringUnit(minutes: false),
          equals('605 sec'));
      expect(
          Duration(minutes: 10, seconds: 5)
              .toStringUnit(minutes: false, seconds: false),
          equals('605000 ms'));
      expect(
          Duration(minutes: 10, seconds: 5).toStringUnit(
              minutes: false, seconds: false, milliseconds: false),
          equals('605000000 μs'));
      expect(
          Duration(minutes: 10, seconds: 5).toStringUnit(
              minutes: false,
              seconds: false,
              milliseconds: false,
              microseconds: false),
          equals('0:10:05.000000'));

      expect(Duration(days: 10, hours: 5).toStringUnit(), equals('10 d'));
      expect(Duration(days: 10, hours: 5).toStringUnit(days: false),
          equals('245 h'));
    });
  });
}
