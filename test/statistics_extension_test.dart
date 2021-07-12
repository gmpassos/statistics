import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('extension', () {
    setUp(() {});

    test('ListExtension<String>', () {
      var l = <String>['10', '20', '30'];

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
