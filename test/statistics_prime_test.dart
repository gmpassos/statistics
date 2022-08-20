import 'package:collection/collection.dart';
import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

const primes = <int>[
  2,
  3,
  5,
  7,
  11,
  13,
  17,
  19,
  23,
  29,
  31,
  37,
  41,
  43,
  47,
  53,
  59,
  61,
  67,
  71,
  73,
  79,
  83,
  89,
  97,
  101,
  103,
  107,
  109,
  113,
  127,
  131,
  137,
  139,
  149,
  151,
  157,
  163,
  167,
  173,
  179,
  181,
  191,
  193,
  197,
  199,
  211,
  223,
  227,
  229,
  233,
  239,
  241,
  251,
  257,
  263,
  269,
  271,
  277,
  281,
  283,
  293,
  307,
  311,
  313,
  317,
  331,
  337,
  347,
  349,
  353,
  359,
  367,
  373,
  379,
  383,
  389,
  397,
  401,
  409,
  419,
  421,
  431,
  433,
  439,
  443,
  449,
  457,
  461,
  463,
  467,
  479,
  487,
  491,
  499,
  503,
  509,
  521,
  523,
  541,
  547,
  557,
  563,
  569,
  571,
  577,
  587,
  593,
  599,
  601,
  607,
  613,
  617,
  619,
  631,
  641,
  643,
  647,
  653,
  659,
  661,
  673,
  677,
  683,
  691,
  701,
  709,
  719,
  727,
  733,
  739,
  743,
  751,
  757,
  761,
  769,
  773,
  787,
  797,
  809,
  811,
  821,
  823,
  827,
  829,
  839,
  853,
  857,
  859,
  863,
  877,
  881,
  883,
  887,
  907,
  911,
  919,
  929,
  937,
  941,
  947,
  953,
  967,
  971,
  977,
  983,
  991,
  997,
  1009,
  1013,
  1019,
  1021,
  1031,
  1033,
  1039,
  1049,
  1051,
  1061,
  1063,
  1069,
  1087,
  1091,
  1093,
  1097,
  1103,
  1109,
  1117,
  1123,
  1129,
  1151,
  1153,
  1163,
  1171,
  1181,
  1187,
  1193,
  1201,
  1213,
  1217,
  1223,
];

void main() {
  group('Prime', () {
    setUp(() {});

    test('PrimeUtils.generatePrimes', () {
      expect(PrimeUtils.generatePrimes(-1), isEmpty);
      expect(PrimeUtils.generatePrimes(0), isEmpty);
      expect(PrimeUtils.generatePrimes(1), equals([2]));
      expect(PrimeUtils.generatePrimes(2), equals([2, 3]));
      expect(PrimeUtils.generatePrimes(3), equals([2, 3, 5]));
      expect(PrimeUtils.generatePrimes(4), equals([2, 3, 5, 7]));
      expect(PrimeUtils.generatePrimes(5), equals([2, 3, 5, 7, 11]));

      expect(PrimeUtils.generatePrimes(primes.length), equals(primes));
    });

    test('int', () {
      expect((-3).isPrime, isFalse);
      expect((-2).isPrime, isFalse);
      expect((-1).isPrime, isFalse);
      expect(0.isPrime, isFalse);
      expect(1.isPrime, isFalse);
      expect(2.isPrime, isTrue);
      expect(3.isPrime, isTrue);
      expect(4.isPrime, isFalse);
      expect(5.isPrime, isTrue);

      int nComparator(int a, int b) => a.compareTo(b);

      for (var n = 0; n < primes.last; ++n) {
        if (primes.binarySearch(n, nComparator) >= 0) {
          expect(n.isPrime, isTrue, reason: "$n is prime!");
        } else {
          expect(n.isPrime, isFalse, reason: "$n is NOT prime!");
        }
      }

      expect(Statistics.maxSafeInt.isPrime, isFalse,
          reason: "${Statistics.maxSafeInt} is NOT prime!");

      var mersennePrime2 =
          2.toDynamicInt().powerInt(31).toDynamicInt().subtractInt(1).toInt();
      print('mersennePrime2: $mersennePrime2');

      expect(mersennePrime2.isPrime, isTrue,
          reason: "`$mersennePrime2`is a Mersenne prime!");
      expect((mersennePrime2 - 2).isPrime, isFalse,
          reason: "`$mersennePrime2 - 2`is a NOT prime!");
    });

    test('DynamicInt', () {
      expect((-3).toDynamicInt().isPrime, isFalse);
      expect((-2).toDynamicInt().isPrime, isFalse);
      expect((-1).toDynamicInt().isPrime, isFalse);
      expect(0.toDynamicInt().isPrime, isFalse);
      expect(1.toDynamicInt().isPrime, isFalse);
      expect(2.toDynamicInt().isPrime, isTrue);
      expect(3.toDynamicInt().isPrime, isTrue);
      expect(4.toDynamicInt().isPrime, isFalse);
      expect(5.toDynamicInt().isPrime, isTrue);

      var primesDN = primes.toDynamicIntList();

      int nComparator(DynamicInt a, DynamicInt b) => a.compareTo(b);

      for (var n = DynamicInt.zero; n < primesDN.last; n = n.sumInt(1)) {
        if (primesDN.binarySearch(n, nComparator) >= 0) {
          expect(n.isPrime, isTrue, reason: "$n is prime!");
        } else {
          expect(n.isPrime, isFalse, reason: "$n is NOT prime!");
        }
      }

      var maxSafeDN = Statistics.maxSafeInt.toDynamicInt();
      print('maxSafeDN: $maxSafeDN');

      expect(maxSafeDN.isPrime, isFalse,
          reason: "${Statistics.maxSafeInt} is NOT prime!");

      var bigDN = maxSafeDN.multiplyInt(100000000000000);

      print('bigDN: $bigDN');

      expect(bigDN.isPrime, isFalse,
          reason: "${Statistics.maxSafeInt} is NOT prime!");

      expect(bigDN.sumInt(1).isPrime, isFalse,
          reason: "${Statistics.maxSafeInt} is NOT prime!");

      var mersennePrime1 =
          2.toDynamicInt().powerInt(17).toDynamicInt().subtractInt(1);
      print('mersennePrime1: $mersennePrime1');

      expect(mersennePrime1.isPrime, isTrue,
          reason: "`$mersennePrime1`is a Mersenne prime!");
      expect(mersennePrime1.subtractInt(2).isPrime, isFalse,
          reason: "`$mersennePrime1 - 2`is NOT prime!");

      var mersennePrime2 =
          2.toDynamicInt().powerInt(31).toDynamicInt().subtractInt(1);
      print('mersennePrime2: $mersennePrime2');

      expect(mersennePrime2.isPrime, isTrue,
          reason: "`$mersennePrime2`is a Mersenne prime!");
      expect(mersennePrime2.subtractInt(2).isPrime, isFalse,
          reason: "`$mersennePrime2 - 2`is a NOT prime!");

      print('PrimeUtils.knownPrimesLength: ${PrimeUtils.knownPrimesLength}');
      PrimeUtils.expandKnownPrimes(10000);
      print('PrimeUtils.knownPrimesLength: ${PrimeUtils.knownPrimesLength}');

      expect(PrimeUtils.knownPrimesLength, greaterThanOrEqualTo(10000));

      var mersennePrim3 =
          2.toDynamicInt().powerInt(61).toDynamicInt().subtractInt(1);
      print('mersennePrim3: $mersennePrim3');

      expect(mersennePrim3.isPrime, isTrue,
          reason: "`$mersennePrim3`is a Mersenne prime!");

      expect(mersennePrim3.subtractInt(1).isPrime, isFalse,
          reason: "`$mersennePrim3 - 1`is NOT prime!");

      expect(mersennePrim3.subtractInt(2).isPrime, isFalse,
          reason: "`$mersennePrim3 - 2`is NOT prime!");
    });
  });
}
