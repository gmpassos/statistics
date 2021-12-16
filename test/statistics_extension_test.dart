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

      var l2 = [10, 11, 12, 20, 21, 22, 30, 31, 32];

      expect(l2.sublistReversed(3), equals([10, 11, 12, 20, 21, 22]));
      expect(l2.sublistReversed(3, 5), equals([21, 22]));

      expect(l2.head(3), equals([10, 11, 12]));
      expect(l2.tail(3), equals([30, 31, 32]));

      {
        var resample1 = l2.resampleByIndex<double>((l, previous, cursor) {
          return RangeSelectionByIndex(cursor, cursor + 3);
        }, (sel) => [sel.mean], skipResampledIndexes: true);

        expect(resample1, equals([11.0, 21.0, 31.0]));

        var resample2 = l2.resampleByIndex<double>((l, previous, cursor) {
          if (previous.isInRange(cursor)) {
            return RangeSelectionByIndex.empty();
          } else {
            return RangeSelectionByIndex(cursor, cursor + 3);
          }
        }, (sel) => [sel.mean], skipResampledIndexes: false);

        expect(resample2, equals([11.0, 21.0, 31.0]));

        var resample3 = l2.resampleByIndex<double>((l, previous, cursor) {
          return RangeSelectionByIndex(cursor, cursor + 3);
        }, (sel) => [sel.mean], skipResampledIndexes: false);

        expect(
            resample3,
            equals([
              11.0,
              14.333333333333334,
              17.666666666666668,
              21.0,
              24.333333333333332,
              27.666666666666668,
              31.0,
              31.5,
              32.0,
            ]));
      }

      {
        var resample1 = l2.resampleByValue<double>((list, previous, cursor) {
          var val = list[cursor];
          var start = (val ~/ 10) * 10;
          var end = start + 9;
          return RangeSelectionByValue(start, false, end, false);
        }, (sel) => [sel.mean], skipResampledIndexes: true);

        expect(resample1, equals([11.0, 21.0, 31.0]));

        var resample2 = l2.resampleByValue<double>((list, previous, cursor) {
          if (previous.isInRangeOfLastSelection(cursor)) {
            return RangeSelectionByValue.empty();
          } else {
            var val = list[cursor];
            var start = (val ~/ 10) * 10;
            var end = start + 9;
            return RangeSelectionByValue(start, false, end, false);
          }
        }, (sel) => [sel.mean], skipResampledIndexes: false);

        expect(resample2, equals([11.0, 21.0, 31.0]));

        var resample3 = l2.resampleByValue<double>((list, previous, cursor) {
          var val = list[cursor];
          var start = (val ~/ 10) * 10;
          var end = start + 9;
          return RangeSelectionByValue(start, false, end, false);
        }, (sel) => [sel.mean], skipResampledIndexes: false);

        expect(resample3,
            equals([11.0, 11.0, 11.0, 21.0, 21.0, 21.0, 31.0, 31.0, 31.0]));

        var resample4 = l2.resampleByValue<double>((list, previous, cursor) {
          if (previous.isInRangeOfLastSelection(cursor)) {
            return RangeSelectionByValue.empty();
          } else {
            var val = list[cursor];
            var start = (val ~/ 10) * 10;
            var end = start + 10;
            return RangeSelectionByValue(start, false, end, true);
          }
        }, (sel) => [sel.mean]);

        expect(resample4, equals([11.0, 21.0, 31.0]));

        var resample5 = l2.resampleByValue<double>((list, previous, cursor) {
          if (previous.isInRangeOfLastSelection(cursor)) {
            return RangeSelectionByValue.empty();
          } else {
            var val = list[cursor];
            var start = (val ~/ 2) * 2;
            var end = start + 1;
            return RangeSelectionByValue(start, false, end, false);
          }
        }, (sel) => [sel.mean]);

        expect(resample5, equals([10.5, 12.0, 20.5, 22.0, 30.5, 32.0]));
      }
    });

    test('RangeSelectionByIndex', () {
      var l = [10, 11, 12, 20, 21, 22, 30, 31, 32];
      var selector = RangeSelectionByIndex(1, 3);
      expect(selector.select(l), equals([11, 12]));

      expect(selector.isInRange(0), isFalse);
      expect(selector.isInRange(1), isTrue);
      expect(selector.isInRange(2), isTrue);
      expect(selector.isInRange(0), isFalse);
    });

    test('RangeSelectionByValue<int>', () {
      var l = [0, 2, 3, 10, 10, 12, 13, 20, 22, 23, 30, 30, 32, 34];

      var selector = RangeSelectionByValue<int>(10, false, 1000, false);
      expect(selector.select(l).head(3), equals([10, 10, 12]));

      expect(selector.isInRangeOfLastSelection(2), isFalse);
      expect(selector.isInRangeOfLastSelection(3), isTrue);
      expect(selector.isInRangeOfLastSelection(4), isTrue);
      expect(selector.isInRangeOfLastSelection(5), isTrue);
      expect(selector.isInRangeOfLastSelection(13), isTrue);
      expect(selector.isInRangeOfLastSelection(14), isFalse);

      expect(
          RangeSelectionByValue<int>(9, false, 1000, false).select(l).head(3),
          equals([10, 10, 12]));

      expect(
          RangeSelectionByValue<int>(11, false, 1000, false).select(l).head(3),
          equals([12, 13, 20]));

      expect(
          RangeSelectionByValue<int>(10, true, 1000, false).select(l).head(3),
          equals([12, 13, 20]));

      expect(RangeSelectionByValue<int>(9, true, 1000, false).select(l).head(3),
          equals([10, 10, 12]));

      expect(
          RangeSelectionByValue<int>(11, true, 1000, false).select(l).head(3),
          equals([12, 13, 20]));

      //

      var selector2 = RangeSelectionByValue<int>(0, false, 30, false);
      expect(selector2.select(l).tail(3), equals([23, 30, 30]));

      expect(selector2.isValueInRange(-1), isFalse);
      expect(selector2.isValueInRange(0), isTrue);
      expect(selector2.isValueInRange(9), isTrue);
      expect(selector2.isValueInRange(29), isTrue);
      expect(selector2.isValueInRange(30), isTrue);
      expect(selector2.isValueInRange(31), isFalse);

      expect(selector2.isInRangeOfLastSelection(-1), isFalse);
      expect(selector2.isInRangeOfLastSelection(0), isTrue);
      expect(selector2.isInRangeOfLastSelection(9), isTrue);
      expect(selector2.isInRangeOfLastSelection(10), isTrue);
      expect(selector2.isInRangeOfLastSelection(11), isTrue);
      expect(selector2.isInRangeOfLastSelection(12), isFalse);

      expect(RangeSelectionByValue<int>(0, false, 31, false).select(l).tail(3),
          equals([23, 30, 30]));

      expect(RangeSelectionByValue<int>(0, false, 29, false).select(l).tail(3),
          equals([20, 22, 23]));

      expect(RangeSelectionByValue<int>(0, false, 30, true).select(l).tail(3),
          equals([20, 22, 23]));

      expect(RangeSelectionByValue<int>(0, false, 29, true).select(l).tail(3),
          equals([20, 22, 23]));

      expect(RangeSelectionByValue<int>(0, false, 31, true).select(l).tail(3),
          equals([23, 30, 30]));
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

      var comparator = itr.comparator();
      expect(comparator(10, 20), equals(-1));
      expect(comparator(20, 10), equals(1));
      expect(comparator(100, 100), equals(0));

      var itr2 = {'a': 1, 'b': 2, 'c': 3}.entries;

      var comparator2 =
          itr2.comparator(compare: (a, b) => a.value.compareTo(b.value));
      expect(comparator2(itr2.elementAt(0), itr2.elementAt(1)), equals(-1));
      expect(comparator2(itr2.elementAt(1), itr2.elementAt(0)), equals(1));
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

      expect(
          m.equalsKeysValues([
            'a',
            'b'
          ], {
            'a': 1,
            'b': 2,
            'c': 3,
            'd': 4,
          }),
          isTrue);

      expect(
          m.equalsKeysValues([
            'a',
            'b'
          ], {
            'a': 1,
            'b': 2,
            'c': 3,
            'd': 5,
          }),
          isTrue);

      expect(
          m.equalsKeysValues([
            'a',
            'd'
          ], {
            'a': 1,
            'b': 2,
            'c': 3,
            'd': 5,
          }),
          isFalse);

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

      expect(
          l.toKeysMap(keys: ['A', 'B'], filter: (v) => v['A'] as int <= 2),
          equals([
            {'A': 1, 'B': 10},
            {'A': 2, 'B': 20},
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

      expect(
          l2.toKeysMap(useHeaderLine: true, keepKeys: {'x'}),
          equals([
            {'x': 1000},
            {'x': 1},
            {'x': 2},
            {'x': 3}
          ]));

      var l3 = [
        List.generate(20, (i) => i),
        List.generate(20, (i) => i * 10),
        List.generate(20, (i) => i * 20)
      ];

      var lm3 = l3.toKeysMap(
          useHeaderLine: true, keepKeys: List.generate(15, (i) => i));

      expect(
          lm3[0],
          equals({
            0: 0,
            1: 10,
            2: 20,
            3: 30,
            4: 40,
            5: 50,
            6: 60,
            7: 70,
            8: 80,
            9: 90,
            10: 100,
            11: 110,
            12: 120,
            13: 130,
            14: 140
          }));
    });

    test('StringExtension', () {
      expect('abcdef'.truncate(10), equals('abcdef'));
      expect('abcdef'.truncate(3), equals('abc!...'));

      expect('abc'.encodeLatin1Bytes(), equals([97, 98, 99]));
      expect('€'.encodeUTF8Bytes(), equals([226, 130, 172]));

      var s = 'a,b\n1,2\n10,20\n100,"20 0",300\n';

      expect(s.containsAny(['a', 'b']), isTrue);
      expect(s.containsAny(['x', 'b']), isTrue);
      expect(s.containsAny(['x', 'y']), isFalse);
      expect(s.containsAny([]), isFalse);

      var lines = s.splitLines();
      expect(lines, equals(['a,b', '1,2', '10,20', '100,"20 0",300']));

      expect(lines[0].splitColumns(), equals(['a', 'b']));
      expect(lines[1].splitColumns(), equals(['1', '2']));
      expect(lines[3].splitColumns(), equals(['100', '20 0', '300']));
      expect(lines[3].splitColumns(acceptsQuotedValues: false),
          equals(['100', '"20 0"', '300']));
    });

    test('StringExtension.splitColumns()', () {
      expect('10,20,30'.splitColumns(), equals(['10', '20', '30']));
      expect('10,20,30,'.splitColumns(), equals(['10', '20', '30', '']));

      expect('10,20,"30"'.splitColumns(), equals(['10', '20', '30']));
      expect('10,20,"30",'.splitColumns(), equals(['10', '20', '30', '']));
      expect('10,20,"30'.splitColumns(), equals(['10', '20', '"30']));
      expect('10,20,"30,40'.splitColumns(), equals(['10', '20', '"30', '40']));
      expect('10,20,"30,'.splitColumns(), equals(['10', '20', '"30', '']));

      expect('10,"20 ""x"" .","30"'.splitColumns(),
          equals(['10', '20 "x" .', '30']));
    });

    test("StringExtension.splitColumns(delimiter: ',;')", () {
      expect('10,;20,;30'.splitColumns(delimiter: ',;'),
          equals(['10', '20', '30']));
      expect('10,;20,;30,;'.splitColumns(delimiter: ',;'),
          equals(['10', '20', '30', '']));

      expect('10,;20,;"30"'.splitColumns(delimiter: ',;'),
          equals(['10', '20', '30']));
      expect('10,;20,;"30",;'.splitColumns(delimiter: ',;'),
          equals(['10', '20', '30', '']));
      expect('10,;20,;"30'.splitColumns(delimiter: ',;'),
          equals(['10', '20', '"30']));
      expect('10,;20,;"30,;40'.splitColumns(delimiter: ',;'),
          equals(['10', '20', '"30', '40']));
      expect('10,;20,;"30,;'.splitColumns(delimiter: ',;'),
          equals(['10', '20', '"30', '']));

      expect('10,;"20 ""x"" .",;"30"'.splitColumns(delimiter: ',;'),
          equals(['10', '20 "x" .', '30']));
    });

    test("StringExtension.splitColumns(delimiter: RegExp(r'[,;]'))", () {
      var d = RegExp(r'[,;]');

      expect('10,20;30'.splitColumns(delimiter: d), equals(['10', '20', '30']));
      expect('10;20,30,'.splitColumns(delimiter: d),
          equals(['10', '20', '30', '']));

      expect(
          '10;20,"30"'.splitColumns(delimiter: d), equals(['10', '20', '30']));
      expect('10,20;"30";'.splitColumns(delimiter: d),
          equals(['10', '20', '30', '']));
      expect(
          '10;20,"30'.splitColumns(delimiter: d), equals(['10', '20', '"30']));
      expect('10,20,"30;40'.splitColumns(delimiter: d),
          equals(['10', '20', '"30', '40']));
      expect('10;20,"30,'.splitColumns(delimiter: d),
          equals(['10', '20', '"30', '']));

      expect('10,"20 ""x"" .";"30"'.splitColumns(delimiter: d),
          equals(['10', '20 "x" .', '30']));
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

    test('ListMapExtension<String,int>', () {
      var l = <Map<String, int>>[
        {'i': 2, 'a': 10},
        {'i': 1, 'a': 2},
        {'i': 0, 'a': 3},
      ];

      expect(
          l.sortedByKey('a'),
          equals([
            {'i': 1, 'a': 2},
            {'i': 0, 'a': 3},
            {'i': 2, 'a': 10},
          ]));

      expect(
          l.sortedByKey('i'),
          equals([
            {'i': 0, 'a': 3},
            {'i': 1, 'a': 2},
            {'i': 2, 'a': 10},
          ]));

      l.sortByKey('a');

      expect(
          l,
          equals([
            {'i': 1, 'a': 2},
            {'i': 0, 'a': 3},
            {'i': 2, 'a': 10},
          ]));

      l.sortByKey('i');

      expect(
          l,
          equals([
            {'i': 0, 'a': 3},
            {'i': 1, 'a': 2},
            {'i': 2, 'a': 10},
          ]));
    });

    test('Duration', () {
      expect(Duration(days: (365 * 3.5).toInt()).inYears, equals(3));
      expect(Duration(days: (365 * 3.5).toInt()).inYearsAsDouble,
          closeTo(3.5, 0.01));

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

    test('Duration.formatTo...', () async {
      expect(DateTime(2021, 08, 02).formatToYMD(), equals('2021-08-02'));
      expect(DateTime(2021, 08, 02).formatToYMD(dateDelimiter: '_'),
          equals('2021_08_02'));

      expect(DateTime(2021, 08, 02, 10, 11, 12).formatToYMD(),
          equals('2021-08-02'));

      expect(DateTime(2021, 08, 02, 10, 11, 12).formatToYMDHm(),
          equals('2021-08-02 10:11'));
      expect(DateTime(2021, 08, 02, 10, 11, 12).formatToYMDHms(),
          equals('2021-08-02 10:11:12'));

      expect(
          DateTime(2021, 08, 02, 10, 11, 12)
              .formatToYMDHms(dateDelimiter: '_', hourDelimiter: '.'),
          equals('2021_08_02 10.11.12'));

      expect(DateTime(2021, 8, 2).formatTo('yyyy/MM/dd'), equals('2021/08/02'));

      var now = DateTime.now();
      await Future.delayed(Duration(milliseconds: 100));
      expect(now.elapsedTime.inMilliseconds, greaterThanOrEqualTo(100));
    });
  });
}
