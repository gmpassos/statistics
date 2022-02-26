import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

void main() {
  group('Combinations', () {
    test('CombinationCache', () {
      var cache = CombinationCache<int, int>(allowRepetition: false);

      var alphabet = {0, 1};

      expect(cache.totalCachedCombinations, equals(0));
      expect(cache.computedCombinations, equals(0));

      expect(
          cache.getCombinations(alphabet, 1, 1),
          equals([
            [0],
            [1]
          ]));

      expect(cache.totalCachedCombinations, equals(1));
      expect(cache.computedCombinations, equals(1));

      expect(
          cache.getCombinations(alphabet, 1, 1),
          equals([
            [0],
            [1]
          ]));

      expect(cache.totalCachedCombinations, equals(1));
      expect(cache.computedCombinations, equals(1));

      expect(() => cache.getCombinationsShared(alphabet, 1, 1),
          throwsA(isA<StateError>()));

      expect(
          cache.getCombinations(alphabet, 1, 2),
          equals([
            [0],
            [1],
            [0, 1]
          ]));

      expect(cache.totalCachedCombinations, equals(2));
      expect(cache.computedCombinations, equals(2));

      expect(
          cache.getCombinations(alphabet, 1, 1),
          equals([
            [0],
            [1]
          ]));

      expect(cache.totalCachedCombinations, equals(2));
      expect(cache.computedCombinations, equals(2));

      expect(
          cache.getCombinations(alphabet, 1, 2),
          equals([
            [0],
            [1],
            [0, 1]
          ]));

      expect(cache.totalCachedCombinations, equals(2));
      expect(cache.computedCombinations, equals(2));

      cache.clear();

      expect(cache.totalCachedCombinations, equals(0));
      expect(cache.computedCombinations, equals(2));

      expect(
          cache.getCombinations(alphabet, 1, 2),
          equals([
            [0],
            [1],
            [0, 1]
          ]));

      expect(cache.totalCachedCombinations, equals(1));
      expect(cache.computedCombinations, equals(3));
    });

    test('CombinationCache: shared', () {
      var cache = CombinationCache<int, int>(
          allowRepetition: false, allowSharedCombinations: true);

      var alphabet = {0, 1};

      expect(cache.totalCachedCombinations, equals(0));
      expect(cache.computedCombinations, equals(0));

      expect(
          cache.getCombinationsShared(alphabet, 1, 1),
          equals([
            [0],
            [1]
          ]));

      expect(cache.totalCachedCombinations, equals(1));
      expect(cache.computedCombinations, equals(1));

      expect(
          cache.getCombinationsShared(alphabet, 1, 1),
          equals([
            [0],
            [1]
          ]));

      expect(cache.totalCachedCombinations, equals(1));
      expect(cache.computedCombinations, equals(1));

      cache.getCombinationsShared(alphabet, 1, 1)[1][0] = 10;

      expect(
          cache.getCombinationsShared(alphabet, 1, 1),
          equals([
            [0],
            [10]
          ]));

      expect(cache.totalCachedCombinations, equals(1));
      expect(cache.computedCombinations, equals(1));
    });

    test('error: invalid alphabet', () {
      expect(() => generateCombinations([10, 10], 2, 2, allowRepetition: false),
          throwsA(isA<ArgumentError>()));
    });

    test('[0,1]', () {
      var alphabet = [0, 1];

      expect(generateCombinations(alphabet, 0, 0), equals([]));

      expect(
          generateCombinations(alphabet, 1, 1, allowRepetition: false),
          equals([
            [0],
            [1]
          ]));

      expect(
          generateCombinations(alphabet, 1, 1, allowRepetition: true),
          equals([
            [0],
            [1]
          ]));

      expect(
          generateCombinations(alphabet, 2, 2, allowRepetition: false),
          equals([
            [0, 1]
          ]));

      expect(
          generateCombinations(alphabet, 2, 2, allowRepetition: true),
          equals([
            [0, 0],
            [0, 1],
            [1, 0],
            [1, 1]
          ]));

      expect(
          generateCombinations(alphabet, 2, 3, allowRepetition: false),
          equals([
            [0, 1]
          ]));

      expect(generateCombinations(alphabet, 3, 3, allowRepetition: false),
          equals([]));

      expect(
          generateCombinations(alphabet, 3, 3, allowRepetition: true),
          equals([
            [0, 0, 0],
            [0, 0, 1],
            [0, 1, 0],
            [0, 1, 1],
            [1, 0, 0],
            [1, 0, 1],
            [1, 1, 0],
            [1, 1, 1]
          ]));

      expect(alphabet.combinations(3, 3, allowRepetition: true),
          equals(generateCombinations(alphabet, 3, 3, allowRepetition: true)));
    });

    test('[a,b,c]', () {
      var alphabet = ['a', 'b', 'c'];

      expect(generateCombinations(alphabet, 0, 0), equals([]));

      expect(
          generateCombinations(alphabet, 1, 1, allowRepetition: false),
          equals([
            ['a'],
            ['b'],
            ['c']
          ]));

      expect(
          generateCombinations(alphabet, 1, 1, allowRepetition: true),
          equals([
            ['a'],
            ['b'],
            ['c']
          ]));

      expect(
          generateCombinations(alphabet.map((e) => e.toUpperCase()), 2, 2,
              allowRepetition: false),
          equals([
            ['A', 'B'],
            ['A', 'C'],
            ['B', 'C']
          ]));

      expect(
          generateCombinations(alphabet, 2, 2, allowRepetition: false),
          equals([
            ['a', 'b'],
            ['a', 'c'],
            ['b', 'c']
          ]));

      expect(
          generateCombinations(alphabet, 2, 2, allowRepetition: true),
          equals([
            ['a', 'a'],
            ['a', 'b'],
            ['a', 'c'],
            ['b', 'a'],
            ['b', 'b'],
            ['b', 'c'],
            ['c', 'a'],
            ['c', 'b'],
            ['c', 'c']
          ]));

      expect(
          generateCombinations(alphabet, 3, 3, allowRepetition: false),
          equals([
            ['a', 'b', 'c']
          ]));

      expect(
          generateCombinations(alphabet, 3, 3, allowRepetition: true),
          equals([
            ['a', 'a', 'a'],
            ['a', 'a', 'b'],
            ['a', 'a', 'c'],
            ['a', 'b', 'a'],
            ['a', 'b', 'b'],
            ['a', 'b', 'c'],
            ['a', 'c', 'a'],
            ['a', 'c', 'b'],
            ['a', 'c', 'c'],
            ['b', 'a', 'a'],
            ['b', 'a', 'b'],
            ['b', 'a', 'c'],
            ['b', 'b', 'a'],
            ['b', 'b', 'b'],
            ['b', 'b', 'c'],
            ['b', 'c', 'a'],
            ['b', 'c', 'b'],
            ['b', 'c', 'c'],
            ['c', 'a', 'a'],
            ['c', 'a', 'b'],
            ['c', 'a', 'c'],
            ['c', 'b', 'a'],
            ['c', 'b', 'b'],
            ['c', 'b', 'c'],
            ['c', 'c', 'a'],
            ['c', 'c', 'b'],
            ['c', 'c', 'c'],
          ]));

      expect(alphabet.combinations(3, 3, allowRepetition: true),
          equals(generateCombinations(alphabet, 3, 3, allowRepetition: true)));
    });

    test('with mapper', () {
      var alphabet = [MapEntry('A', Pair(0, 1)), MapEntry('B', Pair('T', 'F'))];
      List<String> mapper(MapEntry<String, Pair> e) =>
          <String>['${e.key}:${e.value.a}', '${e.key}:${e.value.b}'];

      expect(generateCombinations(alphabet, 0, 0, mapper: mapper), equals([]));

      expect(
          generateCombinations<MapEntry<String, Pair>, String>(alphabet, 1, 1,
              allowRepetition: false, mapper: mapper),
          equals([
            ['A:0'],
            ['A:1'],
            ['B:T'],
            ['B:F']
          ]));

      expect(
          generateCombinations(alphabet, 1, 1,
              allowRepetition: true, mapper: mapper),
          equals([
            ['A:0'],
            ['A:1'],
            ['B:T'],
            ['B:F']
          ]));

      expect(
          generateCombinations(alphabet, 2, 2,
              allowRepetition: false, mapper: mapper),
          equals([
            ['A:0', 'B:T'],
            ['A:0', 'B:F'],
            ['A:1', 'B:T'],
            ['A:1', 'B:F']
          ]));

      expect(
          generateCombinations(alphabet, 2, 2,
              allowRepetition: true, mapper: mapper),
          equals([
            ['A:0', 'A:0'],
            ['A:0', 'A:1'],
            ['A:0', 'B:T'],
            ['A:0', 'B:F'],
            ['A:1', 'A:0'],
            ['A:1', 'A:1'],
            ['A:1', 'B:T'],
            ['A:1', 'B:F'],
            ['B:T', 'A:0'],
            ['B:T', 'A:1'],
            ['B:T', 'B:T'],
            ['B:T', 'B:F'],
            ['B:F', 'A:0'],
            ['B:F', 'A:1'],
            ['B:F', 'B:T'],
            ['B:F', 'B:F']
          ]));

      expect(alphabet.combinations(3, 3, allowRepetition: true),
          equals(generateCombinations(alphabet, 3, 3, allowRepetition: true)));
    });
  });
}
