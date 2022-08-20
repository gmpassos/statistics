import 'package:collection/collection.dart';
import 'package:statistics/statistics.dart';

/// Utils for prime numbers.
class PrimeUtils {
  static final List<int> _knownPrimes = <int>[
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
    97
  ];

  /// A list of known primes.
  /// Used to compute if a number is prime or not.
  static UnmodifiableListView<int> get knownPrimes =>
      UnmodifiableListView<int>(_knownPrimes);

  static int get knownPrimesLength => _knownPrimes.length;

  static Iterator<int> get knownPrimesIterator => _knownPrimes.iterator;

  /// Returns the last known prime in the [knownPrimes] list.
  static int get lastKnownPrime {
    assert(_knownPrimes.isNotEmpty, '`_knownPrimes` must never be empty.');
    return _knownPrimes.last;
  }

  /// Expands the [knownPrimes] list to length [knownPrimesLength].
  static void expandKnownPrimes(int knownPrimesLength) {
    if (_knownPrimes.length >= knownPrimesLength) return;

    while (_knownPrimes.length < knownPrimesLength) {
      var n = knownPrimes.last + 2;

      do {
        if (n.isPrime) {
          _knownPrimes.add(n);
          break;
        } else {
          n += 2;
        }
      } while (n > 1);
    }
  }

  /// Contracts the [knownPrimes] list length to [knownPrimesLength].
  static void contractKnownPrimes(int knownPrimesLength) {
    if (knownPrimesLength < 5) {
      knownPrimesLength = 5;
    }

    if (_knownPrimes.length <= knownPrimesLength) return;

    _knownPrimes.removeRange(knownPrimesLength, _knownPrimes.length);
  }

  /// Returns `true` if [n] is in the [knownPrimes] list.
  static bool? isKnownPrime(int n) {
    assert(_knownPrimes.isNotEmpty, '`_knownPrimes` must never be empty.');

    if (n > _knownPrimes.last) {
      return null;
    }

    var idx = _knownPrimes.binarySearch(n, (a, b) => a.compareTo(b));
    return idx >= 0;
  }

  /// Generates a [List] of prime numbers of [length] and below [primeLimit] (if provided).
  static List<int> generatePrimes(int length, {int? primeLimit}) {
    if (length <= 0) return <int>[];

    if (length == 1) return <int>[2];
    if (length == 2) return <int>[2, 3];

    if (primeLimit == null || primeLimit <= 0) {
      primeLimit = Statistics.maxSafeInt;
    }

    if (primeLimit <= 3) {
      primeLimit = 3;
    }

    var primes = <int>[2, 3];

    for (var n = 5; n < primeLimit && primes.length < length; n += 2) {
      if (n.isPrime) {
        primes.add(n);
      }
    }

    return primes;
  }
}

/// Prime numbers extension on [int].
extension PrimeIntExtension on int {
  /// Returns `true` if this [int] is a prime number.
  bool get isPrime {
    var n = this;

    if (n <= 0) return false;
    if (n == 1) return false;
    if (n == 2) return true;

    var knownPrime = PrimeUtils.isKnownPrime(n);

    if (knownPrime != null) {
      return knownPrime;
    }

    var b = n.squareRoot;

    var itr = PrimeUtils.knownPrimesIterator;
    itr.moveNext(); // it's never empty.

    var p = itr.current;
    if (n % p == 0) return false;

    while (itr.moveNext()) {
      p = itr.current;
      if (p > b) break;

      if (n % p == 0) return false;
    }

    for (p += 2; p <= b; p += 2) {
      if (n % p == 0) return false;
    }

    return true;
  }

  /// Returns [val] when this number [isPrime] otherwise returns [def].
  T? whenPrime<T>(T val, [T? def]) {
    if (isPrime) {
      return val;
    } else {
      return def;
    }
  }
}

/// Prime numbers extension on [DynamicNumber].
extension PrimeDynamicNumberExtension on DynamicNumber<dynamic> {
  /// Returns `true` if this [DynamicNumber] is a prime number.
  bool get isPrime {
    var self = this;
    if (self is DynamicInt) {
      return self.isPrime;
    } else if (self is Decimal) {
      return self.isPrime;
    } else {
      throw StateError("Unknown type: $runtimeType");
    }
  }

  /// Returns [val] when this number [isPrime] otherwise returns [def].
  T? whenPrime<T>(T val, [T? def]) {
    if (isPrime) {
      return val;
    } else {
      return def;
    }
  }
}

extension PrimeDecimalExtension on Decimal {
  /// Returns `true` if this [Decimal] [isWholeNumber] and is a prime number.
  bool get isPrime {
    if (isWholeNumber) {
      return toDynamicInt().isPrime;
    } else {
      return false;
    }
  }
}

/// Prime numbers extension on [DynamicInt].
extension PrimeDynamicIntExtension on DynamicInt {
  /// Returns `true` if this [DynamicInt] is a prime number.
  bool get isPrime {
    var n = this;

    if (n.isZero) return false;
    if (n.isNegative) return false;
    if (n.isOne) return false;
    if (n == DynamicInt.two) return true;

    if (n.isSafeInteger) {
      return n.toInt().isPrime;
    }

    var b = n.squareRoot.toDynamicInt();

    // Faster:
    if (b.isSafeInteger) {
      var bI = b.toInt();

      var itr = PrimeUtils.knownPrimesIterator;
      itr.moveNext(); // it's never empty.

      var p = itr.current;
      if (n.moduloInt(p).isZero) return false;

      while (itr.moveNext()) {
        p = itr.current;
        if (p > bI) break;

        if (n.moduloInt(p).isZero) return false;
      }

      for (p = p + 2; p <= bI; p += 2) {
        if (n.moduloInt(p).isZero) return false;
      }
    }
    // For a very big `n`.
    // Only using `DynamicInt` (slower):
    else {
      var itr = PrimeUtils.knownPrimesIterator;
      itr.moveNext(); // it's never empty.

      var p = itr.current.toDynamicInt();
      if (n.moduloDynamicInt(p).isZero) return false;

      while (itr.moveNext()) {
        p = itr.current.toDynamicInt();
        if (p > b) break;

        if (n.moduloDynamicInt(p).isZero) return false;
      }

      for (p = p.sumInt(2); p <= b; p = p.sumInt(2)) {
        if (n.moduloDynamicInt(p).isZero) return false;
      }
    }

    return true;
  }
}
