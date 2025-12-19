import 'dart:math' as math;

import 'package:statistics/statistics.dart';

/// A [DynamicNumber] is a number implementation that can guarantee precision
/// using a dynamic internal representation for fast operations and memory optimization.
///
/// See [DynamicInt] and [Decimal].
abstract class DynamicNumber<T extends DynamicNumber<T>>
    implements Comparable<DynamicNumber> {
  /// The maximum safe integer of the current Dart platform.
  static final int maxSafeInteger = _computeMaxSafeInteger();

  /// [maxSafeInteger] as [BigInt].
  static final BigInt maxSafeIntegerAsBigInt = BigInt.from(maxSafeInteger);

  /// The maximum digits of an int to be a safe integer.
  static final int maxSafeIntegerDigits = maxSafeInteger.toString().length - 1;

  // coverage:ignore-star
  static int _computeMaxSafeInteger() {
    var n = _validateSafeInt('9223372036854775807') ??
        _validateSafeInt('9007199254740991') ??
        _validateSafeInt('2147483647');
    if (n == null) throw StateError("Can't identify the maximum safe integer!");
    return n;
  }

  // coverage:ignore-end

  /// The minimum safe integer of the current Dart platform.
  static final int minSafeInteger = _computeMinSafeInteger();

  /// [minSafeInteger] as [BigInt].
  static final BigInt minSafeIntegerAsBigInt = BigInt.from(minSafeInteger);

  /// The minimum digits of an int to be a safe integer.
  static final int minSafeIntegerDigits = minSafeInteger.toString().length - 2;

  /// The integer bits of the current Dart platform.
  static final int safeIntegerBits =
      math.min(maxSafeInteger.bitLength, minSafeInteger.bitLength);

  /// The safe integer bits for shift operations.
  static final int safeIntegerShiftBits =
      safeIntegerBits < 60 ? 32 : safeIntegerBits;

  // coverage:ignore-star
  static int _computeMinSafeInteger() {
    var n = _validateSafeInt('-9223372036854775807') ??
        _validateSafeInt('-9007199254740991') ??
        _validateSafeInt('-2147483647');
    if (n == null) throw StateError("Can't identify the maximum safe integer!");
    return n;
  }

  // coverage:ignore-end

  static int? _validateSafeInt(String n) {
    try {
      var bigInt = BigInt.parse(n);
      var i = bigInt.toInt();
      if (i.toString() == n) return i;
    } catch (_) {}
    return null;
  }

  /// Returns `true` if [int] [n] is a safe integer.
  static bool isIntSafeInteger(int n) =>
      n <= maxSafeInteger && n >= minSafeInteger;

  /// Returns `true` if [BigInt] [n] is a safe integer.
  static bool isBigIntSafeInteger(BigInt n) =>
      n <= maxSafeIntegerAsBigInt && n >= minSafeIntegerAsBigInt;

  static DynamicInt fromInt(int n) => DynamicInt.fromInt(n);

  static DynamicInt fromBigInt(BigInt n) => DynamicInt.fromBigInt(n);

  static Decimal fromDouble(double n) => Decimal.fromDouble(n);

  static DynamicNumber<dynamic> fromNum(num n) {
    if (n is int) {
      return DynamicInt.fromInt(n);
    } else {
      return Decimal.fromDouble(n.toDouble());
    }
  }

  static DynamicNumber<dynamic>? from(Object? n) {
    if (n == null) return null;

    if (n is int) return DynamicInt.fromInt(n);
    if (n is double) return Decimal.fromDouble(n);

    if (n is DynamicNumber) return n;

    return tryParse(n.toString());
  }

  /// Parses [s] to a [DynamicInt] or to a [Decimal] if contains  `.` as decimal separator.
  static DynamicNumber<dynamic> parse(String s,
      {String decimalDelimiter = '.'}) {
    _checkDecimalDelimiter(decimalDelimiter);

    if (s.contains(decimalDelimiter) || s.contains('e')) {
      return Decimal.parse(s);
    }

    return DynamicInt.parse(s);
  }

  static void _checkDecimalDelimiter(String decimalDelimiter) {
    if (decimalDelimiter.length != 1) {
      throw ArgumentError("Invalid decimalDelimiter: `$decimalDelimiter`");
    }
  }

  /// Tries to [parse] [s].
  static DynamicNumber<dynamic>? tryParse(String s,
      {String decimalDelimiter = '.'}) {
    if (s.isEmpty) return null;

    _checkDecimalDelimiter(decimalDelimiter);

    if (s.contains(decimalDelimiter) || s.contains('e')) {
      return Decimal.tryParse(s, decimalDelimiter: decimalDelimiter);
    }

    return DynamicInt.tryParse(s);
  }

  /// Returns `true` if this is a whole number.
  bool get isWholeNumber;

  /// Returns the sign of this number. See [int.sign].
  int get sign;

  /// Returns `true` if this number is negative.
  bool get isNegative;

  /// Returns `true` if this number is positive.
  ///
  /// - Note: zero is neither positive nor negative.
  bool get isPositive;

  /// Returns `true` if this number is zero.
  bool get isZero;

  /// Returns `true` if this number is one.
  bool get isOne;

  /// Returns `true` if and only if this number is odd.
  /// - Note: that only whole numbers can be even or odd.
  bool get isOdd;

  /// Returns `true` if and only if this number is even.
  /// - Note: that only whole numbers can be even or odd.
  bool get isEven;

  /// Returns this number as [int].
  ///
  /// - Will throw an [UnsupportedError] if is not a safe integer.
  /// - See [isSafeInteger].
  int toInt();

  /// Returns this number as [BigInt].
  BigInt toBigInt();

  /// Returns this number as [double].
  double toDouble();

  /// Returns this number as [num].
  num toNum();

  /// Returns this number as [DynamicInt].
  DynamicInt toDynamicInt();

  /// Returns this number as [Decimal].
  Decimal toDecimal();

  /// Returns `true` if the internal representation is a [BigInt].
  bool get isBigInt;

  /// Returns `true` if this instance is a [DynamicInt]
  bool get isDynamicInt;

  /// Returns `true` if this instance is a [Decimal]
  bool get isDecimal;

  /// Returns `true` if this number is safe to be represented as [int] for the current Dart platform.
  ///
  /// See [minSafeInteger] and [maxSafeInteger].
  bool get isSafeInteger;

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  /// Returns `true` if [n] is equals to this number.
  bool equalsInt(int n);

  /// Returns `true` if [n] is equals to this number.
  bool equalsBigInt(BigInt n);

  /// Returns `true` if [other] is equals to this number.
  bool equalsDynamicInt(DynamicInt other);

  @override
  int compareTo(DynamicNumber<dynamic> other);

  bool operator <(DynamicNumber<dynamic> other);

  bool operator <=(DynamicNumber<dynamic> other);

  bool operator >(DynamicNumber<dynamic> other);

  bool operator >=(DynamicNumber<dynamic> other);

  T abs();

  T sumBigInt(BigInt n2);

  T sumInt(int n2);

  Decimal sumDouble(double n2);

  DynamicNumber<dynamic> sum(num n2);

  T sumDynamicInt(DynamicInt other);

  DynamicNumber<dynamic> operator +(DynamicNumber<dynamic> other);

  T subtractBigInt(BigInt n2);

  T subtractInt(int n2);

  Decimal subtractDouble(double n2);

  DynamicNumber<dynamic> subtract(num n2);

  T subtractDynamicInt(DynamicInt other);

  DynamicNumber<dynamic> operator -(DynamicNumber<dynamic> other);

  N min<N extends DynamicNumber<N>>(DynamicNumber other);

  N max<N extends DynamicNumber<N>>(DynamicNumber other);

  N cast<N extends DynamicNumber<N>>();

  T multiplyBigInt(BigInt n2);

  T multiplyInt(int n2);

  Decimal multiplyDouble(double n2);

  DynamicNumber<dynamic> multiply(num n2);

  DynamicNumber<dynamic> multiplyDynamicInt(DynamicInt other);

  DynamicNumber<dynamic> multiplyDecimal(Decimal other);

  DynamicNumber<dynamic> operator *(DynamicNumber<dynamic> other);

  T divideBigInt(BigInt n2);

  T divideInt(int n2);

  Decimal divideDouble(double n2);

  DynamicNumber<dynamic> divide(num n2);

  T divideDynamicInt(DynamicInt other);

  DynamicInt operator ~/(DynamicNumber<dynamic> other);

  double divideIntAsDouble(int n2);

  double divideDoubleAsDouble(double n2);

  double divideBigIntAsDouble(BigInt n2);

  double divideNumAsDouble(num n2);

  double divideDynamicIntAsDouble(DynamicInt n2);

  Decimal divideIntAsDecimal(int n2);

  Decimal divideDoubleAsDecimal(double n2);

  Decimal divideNumAsDecimal(num n2);

  Decimal divideBigIntAsDecimal(BigInt n2);

  Decimal divideDynamicIntAsDecimal(DynamicInt other);

  DynamicInt divideDynamicIntAsDynamicInt(DynamicInt other);

  Decimal operator /(DynamicNumber<dynamic> other);

  /// Return the negative value of this integer.
  T operator -();

  /// The bit-wise negate operator.
  DynamicInt operator ~();

  /// Euclidean modulo operator.
  DynamicNumber<dynamic> operator %(DynamicNumber<dynamic> other);

  /// Euclidean modulo for [int] [n2].
  T moduloInt(int n2);

  /// Euclidean modulo for [BigInt] [n2].
  T moduloBigInt(BigInt n2);

  /// Euclidean modulo for [DynamicInt] [n2].
  T moduloDynamicInt(DynamicInt n2);

  /// The sine of this number.
  Decimal get sin;

  /// The cosine of this number.
  Decimal get cos;

  /// The square of this number.
  T get square;

  /// The square root of this number.
  Decimal get squareRoot;

  /// This number to the power of [exponent].
  ///
  /// It redirects to [powerAsDynamicInt] or [powerAsDecimal] depending of the [exponent] type and value.
  DynamicNumber<dynamic> power(DynamicNumber<dynamic> exponent);

  /// This number to the power of [exponent].
  ///
  /// See [power]
  DynamicNumber<dynamic> powerInt(int exponent);

  /// This number to the power of [exponent].
  ///
  /// See [power]
  DynamicNumber<dynamic> powerDouble(double exponent);

  /// This number to the power of [exponent].
  ///
  /// See [power]
  DynamicNumber<dynamic> powerNum(num exponent);

  /// This number to the power of [exponent].
  ///
  /// See [power]
  DynamicNumber<dynamic> powerBigInt(BigInt exponent);

  /// This number to the power of [DynamicNumber] [exponent] as [DynamicInt].
  DynamicInt powerAsDynamicInt(DynamicNumber<dynamic> exponent);

  /// This number to the power of [DynamicNumber] [exponent] as [Decimal].
  ///
  /// If [exponent] is a [Decimal] (without zero decimal part, [Decimal.isDecimalPartZero]),
  /// the precision will depend on `dart:math` `pow` function.
  Decimal powerAsDecimal(DynamicNumber<dynamic> exponent);

  /// Shift the bits of this integer to the right by [shiftAmount].
  DynamicInt operator >>(int shiftAmount);

  /// Shift the bits of this integer to the left by [shiftAmount].
  DynamicInt operator <<(int shiftAmount);

  /// This number as an integer in hexadecimal format.
  String toHex();

  /// Formats this number to a [String] in a standard format, like [int] or [double].
  String toStringStandard();

  /// Formats this number to a [String].
  ///
  /// - If [thousands] is `true` it will use thousands delimiters for the [wholePart].
  /// - [thousandsDelimiter] is the thousands delimiter.
  String format({bool thousands = true, String thousandsDelimiter = ','});

  /// Alias to [format].
  @override
  String toString({bool thousands = false, String thousandsDelimiter = ','});
}

/// An efficient integer that can dynamically change its internal representation
/// from [int] to [BigInt].
///
/// For each operation the best representation ([int] or [BigInt]) is chosen automatically.
abstract class DynamicInt implements DynamicNumber<DynamicInt> {
  static int dynamicIntDigits(DynamicInt n) {
    if (!n.isSafeInteger) {
      return n.toStringStandard().length;
    }

    var digits = _intDigits(n.toInt());
    digits ??= n.toStringStandard().length;

    return digits;
  }

  static int intDigits(int n) {
    return _intDigits(n) ?? n.toString().length;
  }

  static int? _intDigits(int n) {
    n = n.abs();

    if (n < 100000) {
      if (n < 100) {
        return n < 10 ? 1 : 2;
      } else {
        if (n < 1000) {
          return 3;
        } else {
          return n < 10000 ? 4 : 5;
        }
      }
    } else {
      if (n < 10000000) {
        return n < 1000000 ? 6 : 7;
      } else {
        if (n < 100000000) {
          return 8;
        } else {
          if (n < 1000000000) {
            return 9;
          } else {
            return null;
          }
        }
      }
    }
  }

  /// Alias to [DynamicNumber.maxSafeInteger].
  static final int maxSafeInteger = DynamicNumber.maxSafeInteger;

  /// Alias to [DynamicNumber.minSafeInteger].
  static final int minSafeInteger = DynamicNumber.minSafeInteger;

  /// Alias to [DynamicNumber.maxSafeIntegerDigits].
  static final int maxSafeIntegerDigits = DynamicNumber.maxSafeIntegerDigits;

  /// Alias to [DynamicNumber.minSafeIntegerDigits].
  static final int minSafeIntegerDigits = DynamicNumber.minSafeIntegerDigits;

  /// Alias to [DynamicNumber.safeIntegerBits].
  static final int safeIntegerBits = DynamicNumber.safeIntegerBits;

  /// The safe integer bits for shift operations.
  static final int safeIntegerShiftBits = DynamicNumber.safeIntegerShiftBits;

  static final DynamicInt zero = DynamicInt.fromInt(0);
  static final DynamicInt one = DynamicInt.fromInt(1);
  static final DynamicInt two = DynamicInt.fromInt(2);
  static final DynamicInt ten = DynamicInt.fromInt(10);

  static final DynamicInt negativeOne = DynamicInt.fromInt(-1);

  DynamicInt._();

  /// Constructs from [int] [n].
  factory DynamicInt.fromInt(int n) => _DynamicIntNative(n);

  /// Constructs from [num] [n].
  factory DynamicInt.fromNum(num n) => _DynamicIntNative(n.toInt());

  /// Constructs from [BigInt] [n].
  factory DynamicInt.fromBigInt(BigInt n) => _DynamicIntBig(n);

  /// Constructs from [n]. Accepted types: [int], [double], [num], [BigInt], [String], [DynamicInt].
  static DynamicInt? from(Object? n) {
    if (n == null) {
      return null;
    } else if (n is DynamicInt) {
      return n;
    } else if (n is Decimal) {
      return n.toDynamicInt();
    } else if (n is int) {
      return _DynamicIntNative(n);
    } else if (n is double) {
      return _DynamicIntNative(n.toInt());
    } else if (n is BigInt) {
      return _DynamicIntBig(n);
    }

    return DynamicNumber.tryParse(n.toString())?.toDynamicInt();
  }

  /// Parses [String] [s] to a [DynamicInt] integer.
  ///
  /// - It will select the best internal representation for the parsed [n] [String].
  factory DynamicInt.parse(String s) {
    if (s.length < maxSafeIntegerDigits) {
      return DynamicInt.fromInt(int.parse(s));
    } else {
      return DynamicInt.fromBigInt(BigInt.parse(s));
    }
  }

  /// Tries to [parse] [String] [s] to a [DynamicInt] integer.
  static DynamicInt? tryParse(String s) {
    if (s.isEmpty) return null;

    if (s.length < maxSafeIntegerDigits) {
      var i = int.tryParse(s);
      return i == null ? null : DynamicInt.fromInt(i);
    } else {
      var i = BigInt.tryParse(s);
      return i == null ? null : DynamicInt.fromBigInt(i);
    }
  }

  @override
  bool get isWholeNumber => true;

  @override
  int get sign;

  @override
  bool get isNegative;

  @override
  bool get isPositive => sign == 1;

  /// Returns true if and only if this integer is odd.
  @override
  bool get isOdd;

  /// Returns true if and only if this integer is even.
  @override
  bool get isEven => !isOdd;

  @override
  bool get isZero;

  @override
  bool get isOne;

  @override
  int toInt();

  @override
  BigInt toBigInt();

  @override
  double toDouble();

  @override
  DynamicInt toDynamicInt() => this;

  @override
  Decimal toDecimal();

  @override
  bool get isDynamicInt => true;

  @override
  bool get isDecimal => false;

  @override
  bool get isBigInt;

  @override
  bool get isSafeInteger;

  int get bitLength;

  int get digits;

  /// Returns a [DynamicInt] with a [BigInt] internal representation.
  DynamicInt get asDynamicIntBig;

  /// Returns a [DynamicInt] with a [int] internal representation.
  DynamicInt get asDynamicIntNative;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! DynamicNumber) return false;

    if (other.isDecimal) {
      return other.equalsDynamicInt(this);
    } else if (isBigInt || other.isBigInt) {
      return toBigInt() == other.toBigInt();
    } else {
      return toInt() == other.toInt();
    }
  }

  @override
  int get hashCode {
    if (isSafeInteger) {
      return toInt().hashCode;
    } else {
      return toBigInt().hashCode;
    }
  }

  @override
  bool equalsInt(int n);

  @override
  bool equalsBigInt(BigInt n);

  @override
  bool equalsDynamicInt(DynamicInt other) {
    if (isBigInt || other.isBigInt) {
      return toBigInt() == other.toBigInt();
    } else {
      return toInt() == other.toInt();
    }
  }

  @override
  int compareTo(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      var cmp = compareTo(other.toDynamicInt());
      if (cmp == 0) {
        return other.toDecimal().isDecimalPartZero ? 0 : 1;
      } else {
        return cmp;
      }
    } else if (isBigInt || other.isBigInt) {
      return toBigInt().compareTo(other.toBigInt());
    } else {
      return toInt().compareTo(other.toInt());
    }
  }

  @override
  bool operator <(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return toDecimal() < other.toDecimal();
    }

    if (isBigInt || other.isBigInt) {
      return toBigInt() < other.toBigInt();
    } else {
      return toInt() < other.toInt();
    }
  }

  @override
  bool operator <=(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return toDecimal() <= other.toDecimal();
    }

    if (isBigInt || other.isBigInt) {
      return toBigInt() <= other.toBigInt();
    } else {
      return toInt() <= other.toInt();
    }
  }

  @override
  bool operator >(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return toDecimal() > other.toDecimal();
    }

    if (isBigInt || other.isBigInt) {
      return toBigInt() > other.toBigInt();
    } else {
      return toInt() > other.toInt();
    }
  }

  @override
  bool operator >=(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return toDecimal() >= other.toDecimal();
    }

    if (isBigInt || other.isBigInt) {
      return toBigInt() >= other.toBigInt();
    } else {
      return toInt() >= other.toInt();
    }
  }

  @override
  N min<N extends DynamicNumber<N>>(DynamicNumber other) {
    return (this <= other ? this : other).cast<N>();
  }

  @override
  N max<N extends DynamicNumber<N>>(DynamicNumber other) {
    return (this >= other ? this : other).cast<N>();
  }

  @override
  N cast<N extends DynamicNumber<N>>() {
    var self = this;
    if (self is N) {
      return self as N;
    } else if (N == DynamicInt) {
      return toDynamicInt() as N;
    } else if (N == Decimal) {
      return toDecimal() as N;
    } else {
      throw TypeError();
    }
  }

  @override
  DynamicInt abs() => isNegative ? -this : this;

  DynamicInt sumAsDynamicIntBig(DynamicInt other);

  @override
  DynamicInt sumBigInt(BigInt n2);

  @override
  DynamicInt sumInt(int n2);

  @override
  Decimal sumDouble(double n2) => toDecimal().sumDouble(n2);

  @override
  DynamicNumber<dynamic> sum(num n2) {
    if (n2 is int) {
      return sumInt(n2);
    } else {
      return sumDouble(n2.toDouble());
    }
  }

  DynamicInt subtractAsDynamicIntBig(DynamicInt other);

  @override
  DynamicInt subtractBigInt(BigInt n2);

  @override
  DynamicInt subtractInt(int n2) => sumInt(-n2);

  @override
  Decimal subtractDouble(double n2) => toDecimal().subtractDouble(n2);

  @override
  DynamicNumber<dynamic> subtract(num n2) {
    if (n2 is int) {
      return subtractInt(n2);
    } else {
      return subtractDouble(n2.toDouble());
    }
  }

  DynamicInt multiplyAsDynamicIntBig(DynamicInt other);

  @override
  DynamicInt multiplyBigInt(BigInt n2);

  @override
  DynamicInt multiplyInt(int n2);

  @override
  Decimal multiplyDouble(double n2) => toDecimal().multiplyDouble(n2);

  @override
  DynamicNumber<dynamic> multiply(num n2) {
    if (n2 is int) {
      return multiplyInt(n2);
    } else {
      return multiplyDouble(n2.toDouble());
    }
  }

  @override
  DynamicInt multiplyDynamicInt(DynamicInt other);

  @override
  DynamicNumber<dynamic> multiplyDecimal(Decimal other) {
    if (other.isDecimalPartZero) {
      return multiplyDynamicInt(other.toDynamicInt());
    } else {
      return toDecimal().multiplyDecimal(other);
    }
  }

  @override
  DynamicInt divideDynamicInt(DynamicInt other) =>
      divideDynamicIntAsDynamicInt(other);

  DynamicInt divideAsDynamicIntBig(DynamicInt other);

  @override
  DynamicInt divideBigInt(BigInt n2);

  @override
  DynamicInt divideInt(int n2);

  @override
  DynamicNumber<dynamic> divide(num n2) {
    if (n2 is int) {
      return divideInt(n2);
    } else {
      return divideDouble(n2.toDouble());
    }
  }

  @override
  double divideDynamicIntAsDouble(DynamicInt n2) {
    if (isBigInt || n2.isBigInt) {
      return toBigInt() / n2.toBigInt();
    } else {
      return toInt() / n2.toInt();
    }
  }

  DynamicInt divideAsDynamicInt(DynamicInt n2) => (this ~/ n2);

  @override
  Decimal divideIntAsDecimal(int n2) => this / DynamicInt.fromInt(n2);

  @override
  Decimal divideDoubleAsDecimal(double n2) => this / Decimal.fromDouble(n2);

  @override
  Decimal divideNumAsDecimal(num n2) {
    if (n2 is int) {
      return divideIntAsDecimal(n2);
    } else {
      return divideDoubleAsDecimal(n2.toDouble());
    }
  }

  @override
  Decimal divideBigIntAsDecimal(BigInt n2) => this / DynamicInt.fromBigInt(n2);

  @override
  Decimal divideDynamicIntAsDecimal(DynamicInt other) => this / other;

  @override
  DynamicInt operator -();

  @override
  DynamicInt moduloInt(int n2);

  @override
  DynamicInt moduloBigInt(BigInt n2);

  @override
  DynamicInt moduloDynamicInt(DynamicInt other);

  @override
  Decimal get sin => Decimal.fromDouble(math.sin(toInt()));

  @override
  Decimal get cos => Decimal.fromDouble(math.cos(toInt()));

  @override
  DynamicInt get square => (this * this).toDynamicInt();

  int get lowestSetBit {
    if (isSafeInteger) {
      var n = toInt();
      var bits = n.bitLength;

      for (var i = 0; i < bits; ++i) {
        var b = n & 0x1;
        if (b != 0) {
          return i;
        }
        n = n >> 1;
      }
      return bits;
    } else {
      var n = toBigInt();
      var bits = n.bitLength;

      for (var i = 0; i < bits; ++i) {
        var b = n & BigInt.one;
        if (b != BigInt.one) {
          return i;
        }
        n = n >> 1;
      }
      return bits;
    }
  }

  @override
  DynamicNumber<dynamic> powerInt(int exponent) =>
      power(DynamicInt.fromInt(exponent));

  @override
  DynamicNumber<dynamic> powerDouble(double exponent) =>
      power(Decimal.fromDouble(exponent));

  @override
  DynamicNumber<dynamic> powerNum(num exponent) =>
      power(Decimal.fromNum(exponent));

  @override
  DynamicNumber<dynamic> powerBigInt(BigInt exponent) =>
      power(DynamicInt.fromBigInt(exponent));

  static final BigInt _bigIntNegativeOne = BigInt.from(-1);

  @override
  DynamicNumber<dynamic> power(DynamicNumber<dynamic> exponent) {
    if (exponent.isDecimal) {
      return toDecimal().power(exponent.toDecimal());
    } else {
      return _powerDynamicIntImpl(exponent.toDynamicInt());
    }
  }

  @override
  Decimal powerAsDecimal(DynamicNumber<dynamic> exponent) {
    if (exponent.isDecimal) {
      return toDecimal().powerAsDecimal(exponent);
    } else {
      return _powerDynamicIntImpl(exponent.toDynamicInt()).toDecimal();
    }
  }

  @override
  DynamicInt powerAsDynamicInt(DynamicNumber<dynamic> exponent) {
    if (exponent.isNegative) {
      throw UnsupportedError(
          'Negative exponent! Use `powerAsDecimal` for negative exponent support.');
    }

    if (exponent.isDecimal) {
      return toDecimal().power(exponent.toDecimal()).toDynamicInt();
    } else {
      return _powerDynamicIntImpl(exponent.toDynamicInt()).toDynamicInt();
    }
  }

  DynamicNumber<dynamic> _powerDynamicIntImpl(DynamicInt exponent) {
    if (exponent.isNegative) {
      return Decimal.one / power(-exponent);
    } else if (isZero) {
      return (exponent.isZero ? DynamicInt.one : this);
    }

    var partToSquare = abs();

    // Factor out powers of two from the base, as the exponentiation of
    // these can be done by left shifts only.
    // The remaining part can then be exponentiated faster.  The
    // powers of two will be multiplied back at the end.
    var powersOfTwo = partToSquare.lowestSetBit;

    int remainingBits;

    // Factor the powers of two out quickly by shifting right, if needed.
    if (powersOfTwo > 0) {
      partToSquare = partToSquare >> powersOfTwo;
      remainingBits = partToSquare.bitLength;
      if (remainingBits == 1) {
        var shift = (BigInt.from(powersOfTwo) * exponent.toBigInt()).toInt();
        // Nothing left but +/- 1?
        return isNegative && exponent.isOdd
            ? DynamicInt.fromBigInt(_bigIntNegativeOne << shift)
            : DynamicInt.fromBigInt(BigInt.one << shift);
      }
    } else {
      remainingBits = partToSquare.bitLength;
      if (remainingBits == 1) {
        // Nothing left but +/- 1?
        return isNegative && exponent.isOdd
            ? DynamicInt.negativeOne
            : DynamicInt.one;
      }
    }

    // Large number algorithm.  This is basically identical to
    // the algorithm above, but calls multiply() and square()
    // which may use more efficient algorithms for large numbers.
    var answer = DynamicInt.one;

    var workingExponent = exponent;

    // Perform exponentiation using repeated squaring trick
    while (!workingExponent.isZero) {
      if (workingExponent.isOdd) {
        answer = answer.multiplyDynamicInt(partToSquare);
      }

      if (!(workingExponent >>= 1).isZero) {
        partToSquare = partToSquare.multiplyDynamicInt(partToSquare);
      }
    }

    // Multiply back the (exponentiated) powers of two (quickly,
    // by shifting left)
    if (powersOfTwo > 0) {
      var shift = (exponent.multiplyInt(powersOfTwo)).toInt();
      answer = answer << shift;
    }

    return isNegative && exponent.isOdd ? -answer : answer;
  }

  /// Formats this decimal to a [String].
  ///
  /// - If [compact] is `true` it will format as [compactedPrecision] instance.
  /// - If [thousands] is `true` it will use thousands delimiters for the [wholePart].
  /// - If [decimal] is `true` it will add the [decimalPartAsString] to the [String] result.
  /// - [decimalDelimiter] is the delimiter for the decimal part.
  /// - [thousandsDelimiter] is the thousands delimiter.
  @override
  String format({bool thousands = true, String thousandsDelimiter = ','}) =>
      _formatImpl(toStringStandard(), thousands, thousandsDelimiter);

  String _formatImpl(String nStr, bool thousands, String thousandsDelimiter) {
    if (thousands) {
      var signLength = isNegative ? 1 : 0;

      var n = nStr;
      var nThousands = '';

      while ((n.length - signLength) > 3) {
        var tail = n.substring(n.length - 3);
        n = n.substring(0, n.length - 3);
        nThousands = thousandsDelimiter + tail + nThousands;
      }

      nStr = '$n$nThousands';
    }

    return nStr;
  }

  @override
  String toString({bool thousands = false, String thousandsDelimiter = ','}) =>
      format(thousands: thousands, thousandsDelimiter: thousandsDelimiter);
}

class _DynamicIntNative extends DynamicInt {
  final int _n;

  _DynamicIntNative(this._n) : super._();

  @override
  bool get isBigInt => false;

  @override
  bool get isOdd => _n.isOdd;

  @override
  bool get isEven => _n.isEven;

  @override
  int toInt() => _n;

  @override
  double toDouble() => _n.toDouble();

  @override
  num toNum() => _n;

  BigInt? _bigInt;

  @override
  BigInt toBigInt() => _bigInt ??= BigInt.from(_n);

  @override
  Decimal toDecimal() => Decimal.fromInt(_n);

  @override
  int get bitLength => _n.bitLength;

  @override
  int get digits => DynamicInt.intDigits(_n);

  @override
  bool get isSafeInteger => true;

  @override
  DynamicInt get asDynamicIntBig => _DynamicIntBig(toBigInt());

  @override
  DynamicInt get asDynamicIntNative => this;

  @override
  int get sign => _n.sign;

  @override
  bool get isNegative => _n.isNegative;

  @override
  bool get isZero => _n == 0;

  @override
  bool get isOne => _n == 1;

  @override
  bool equalsInt(int n) => _n == n;

  @override
  bool equalsBigInt(BigInt n) =>
      n.isValidInt ? _n == n.toInt() : _n.toString() == n.toString();

  @override
  DynamicInt operator -() => _DynamicIntNative(-_n);

  @override
  DynamicInt operator ~() => _DynamicIntNative(~_n);

  @override
  DynamicInt operator >>(int shiftAmount) {
    if ((_n.bitLength + shiftAmount) > DynamicInt.safeIntegerShiftBits) {
      return _DynamicIntBig(_n.toBigInt() >> shiftAmount);
    } else {
      return _DynamicIntNative(_n >> shiftAmount);
    }
  }

  @override
  DynamicInt operator <<(int shiftAmount) {
    if ((_n.bitLength + shiftAmount) > DynamicInt.safeIntegerShiftBits) {
      return _DynamicIntBig(_n.toBigInt() << shiftAmount);
    } else {
      return _DynamicIntNative(_n << shiftAmount);
    }
  }

  @override
  DynamicInt moduloInt(int n2) => _DynamicIntNative(_n % n2);

  @override
  DynamicInt moduloBigInt(BigInt n2) => _DynamicIntBig(toBigInt() % n2);

  @override
  DynamicInt moduloDynamicInt(DynamicInt other) {
    if (other.isBigInt) {
      return moduloBigInt(other.toBigInt());
    } else {
      return moduloInt(other.toInt());
    }
  }

  @override
  DynamicNumber<dynamic> operator %(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return toDecimal() % other.toDecimal();
    } else if (other.isBigInt) {
      return moduloBigInt(other.toBigInt());
    } else {
      return moduloInt(other.toInt());
    }
  }

  @override
  DynamicInt sumAsDynamicIntBig(DynamicInt other) =>
      _DynamicIntBig(toBigInt() + other.toBigInt());

  @override
  DynamicInt sumBigInt(BigInt n2) => _DynamicIntBig(toBigInt() + n2);

  @override
  DynamicInt sumInt(int n2) {
    if (n2 == 0) return this;

    var n1 = _n;

    if (n1 == 0) {
      return DynamicInt.fromInt(n2);
    } else if (n1.bitLength >= DynamicInt.safeIntegerBits ||
        n2.bitLength >= DynamicInt.safeIntegerBits) {
      return _DynamicIntBig(toBigInt() + BigInt.from(n2));
    }

    return _DynamicIntNative(n1 + n2);
  }

  @override
  DynamicInt sumDynamicInt(DynamicInt other) {
    if (other.isBigInt) {
      return sumAsDynamicIntBig(other.toDynamicInt());
    } else {
      return sumInt(other.toInt());
    }
  }

  @override
  DynamicNumber<dynamic> operator +(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return toDecimal() + other;
    } else if (other.isBigInt) {
      return sumAsDynamicIntBig(other.toDynamicInt());
    } else {
      return sumInt(other.toInt());
    }
  }

  @override
  DynamicInt subtractAsDynamicIntBig(DynamicInt other) =>
      _DynamicIntBig(toBigInt() - other.toBigInt());

  @override
  DynamicInt subtractBigInt(BigInt n2) => _DynamicIntBig(toBigInt() - n2);

  @override
  DynamicInt subtractDynamicInt(DynamicInt other) {
    if (other.isBigInt) {
      return subtractAsDynamicIntBig(other.toDynamicInt());
    } else {
      return subtractInt(other.toInt());
    }
  }

  @override
  DynamicNumber<dynamic> operator -(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return toDecimal() - other;
    } else if (other.isBigInt) {
      return subtractAsDynamicIntBig(other.toDynamicInt());
    } else {
      return subtractInt(other.toInt());
    }
  }

  @override
  DynamicInt multiplyAsDynamicIntBig(DynamicInt other) {
    if (_n == 0 || other.isZero) return DynamicInt.zero;
    return _DynamicIntBig(toBigInt() * other.toBigInt());
  }

  @override
  DynamicInt multiplyBigInt(BigInt n2) {
    if (_n == 0 || n2 == BigInt.zero) return DynamicInt.zero;
    return _DynamicIntBig(toBigInt() * n2);
  }

  @override
  DynamicInt multiplyInt(int n2) {
    var n1 = _n;

    var bits = n1.bitLength + n2.bitLength;
    if (bits >= DynamicInt.safeIntegerBits) {
      return _DynamicIntBig(toBigInt() * BigInt.from(n2));
    }

    return _DynamicIntNative(n1 * n2);
  }

  @override
  DynamicInt multiplyDynamicInt(DynamicInt other) {
    if (other.isBigInt) {
      return multiplyAsDynamicIntBig(other.toDynamicInt());
    } else {
      return multiplyInt(other.toInt());
    }
  }

  @override
  DynamicNumber<dynamic> operator *(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return toDecimal() * other;
    } else if (other.isBigInt) {
      return multiplyAsDynamicIntBig(other.toDynamicInt());
    } else {
      return multiplyInt(other.toInt());
    }
  }

  @override
  DynamicInt divideAsDynamicIntBig(DynamicInt other) =>
      _DynamicIntBig(toBigInt() ~/ other.toBigInt());

  @override
  DynamicInt divideBigInt(BigInt n2) => _DynamicIntBig(toBigInt() ~/ n2);

  @override
  DynamicInt divideInt(int n2) => _DynamicIntNative(_n ~/ n2);

  @override
  Decimal divideDouble(double n2) => toDecimal() / Decimal.fromDouble(n2);

  @override
  DynamicInt divideDynamicIntAsDynamicInt(DynamicInt other) {
    if (other.isBigInt) {
      return divideAsDynamicIntBig(other.toDynamicInt());
    } else {
      return divideInt(other.toInt());
    }
  }

  @override
  DynamicInt operator ~/(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return toDecimal() ~/ other;
    } else if (other.isBigInt) {
      return divideAsDynamicIntBig(other.toDynamicInt());
    } else {
      return divideInt(other.toInt());
    }
  }

  @override
  double divideIntAsDouble(int n2) => _n / n2;

  @override
  double divideDoubleAsDouble(double n2) => _n / n2;

  @override
  double divideNumAsDouble(num n2) => _n / n2;

  @override
  double divideBigIntAsDouble(BigInt n2) => toBigInt() / n2;

  @override
  Decimal operator /(DynamicNumber<dynamic> other) => toDecimal() / other;

  @override
  Decimal get squareRoot => toDecimal().squareRoot;

  @override
  String toHex() {
    if (_n.bitLength <= 32) {
      return _n.toHex32();
    } else {
      return _n.toHex64();
    }
  }

  @override
  String toStringStandard() => _n.toString();
}

class _DynamicIntBig extends DynamicInt {
  final BigInt _n;

  _DynamicIntBig(this._n) : super._();

  @override
  bool get isBigInt => true;

  @override
  BigInt toBigInt() => _n;

  @override
  bool get isOdd => _n.isOdd;

  @override
  bool get isEven => _n.isEven;

  int? _int;

  @override
  int toInt() => _int ??= _toIntImpl();

  int _toIntImpl() {
    if (!isSafeInteger) {
      throw UnsupportedError(
          "Can't convert to `int`! Internal `BigInt` is not a safe integer for the current platform: "
          'n: $_n ; safeIntegerRange: ${DynamicInt.minSafeInteger} .. ${DynamicInt.maxSafeInteger}');
    }
    return _n.toInt();
  }

  @override
  double toDouble() => _n.toDouble();

  @override
  num toNum() => _n.toInt();

  @override
  Decimal toDecimal() => Decimal.fromBigInt(_n);

  @override
  int get bitLength => _n.bitLength;

  @override
  int get digits => DynamicInt.dynamicIntDigits(this);

  @override
  bool get isSafeInteger => _n.isValidInt;

  @override
  DynamicInt get asDynamicIntBig => this;

  @override
  DynamicInt get asDynamicIntNative => _DynamicIntNative(toInt());

  @override
  int get sign => _n.sign;

  @override
  bool get isNegative => _n.isNegative;

  @override
  bool get isZero => _n == BigInt.zero;

  @override
  bool get isOne => _n == BigInt.one;

  @override
  bool equalsInt(int n) =>
      _n.isValidInt ? _n.toInt() == n : _n.toString() == n.toString();

  @override
  bool equalsBigInt(BigInt n) => _n == n;

  @override
  DynamicInt operator -() => _DynamicIntBig(-_n);

  @override
  DynamicInt operator ~() => _DynamicIntBig(~_n);

  @override
  DynamicInt operator >>(int shiftAmount) => _DynamicIntBig(_n >> shiftAmount);

  @override
  DynamicInt operator <<(int shiftAmount) => _DynamicIntBig(_n << shiftAmount);

  @override
  DynamicInt moduloInt(int n2) => _DynamicIntBig(_n % BigInt.from(n2));

  @override
  DynamicInt moduloBigInt(BigInt n2) => _DynamicIntBig(_n % n2);

  @override
  DynamicInt moduloDynamicInt(DynamicInt other) =>
      _DynamicIntBig(_n % other.toBigInt());

  @override
  DynamicNumber<dynamic> operator %(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return toDecimal() % other;
    }
    return _DynamicIntBig(_n % other.toBigInt());
  }

  @override
  DynamicInt sumAsDynamicIntBig(DynamicInt other) =>
      _DynamicIntBig(_n + other.toBigInt());

  @override
  DynamicInt sumBigInt(BigInt n2) => _DynamicIntBig(_n + n2);

  @override
  DynamicInt sumInt(int n2) => _DynamicIntBig(_n + BigInt.from(n2));

  @override
  DynamicInt sumDynamicInt(DynamicInt other) =>
      _DynamicIntBig(_n + other.toBigInt());

  @override
  DynamicNumber<dynamic> operator +(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return toDecimal() + other;
    }
    return _DynamicIntBig(_n + other.toBigInt());
  }

  @override
  DynamicInt subtractAsDynamicIntBig(DynamicInt other) =>
      _DynamicIntBig(_n - other.toBigInt());

  @override
  DynamicInt subtractBigInt(BigInt n2) => _DynamicIntBig(_n - n2);

  @override
  DynamicInt subtractDynamicInt(DynamicInt other) =>
      _DynamicIntBig(_n - other.toBigInt());

  @override
  DynamicNumber<dynamic> operator -(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return toDecimal() - other;
    }
    return _DynamicIntBig(_n - other.toBigInt());
  }

  @override
  DynamicInt multiplyAsDynamicIntBig(DynamicInt other) =>
      _DynamicIntBig(_n * other.toBigInt());

  @override
  DynamicInt multiplyBigInt(BigInt n2) => _DynamicIntBig(_n * n2);

  @override
  DynamicInt multiplyInt(int n2) => _DynamicIntBig(_n * BigInt.from(n2));

  @override
  DynamicInt multiplyDynamicInt(DynamicInt other) =>
      _DynamicIntBig(_n * other.toBigInt());

  @override
  DynamicNumber<dynamic> operator *(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return toDecimal() * other;
    }
    return _DynamicIntBig(_n * other.toBigInt());
  }

  @override
  DynamicInt divideAsDynamicIntBig(DynamicInt other) =>
      _DynamicIntBig(_n ~/ other.toBigInt());

  @override
  DynamicInt divideBigInt(BigInt n2) => _DynamicIntBig(_n ~/ n2);

  @override
  DynamicInt divideInt(int n2) => divideBigInt(BigInt.from(n2));

  @override
  Decimal divideDouble(double n2) => toDecimal() / Decimal.fromDouble(n2);

  @override
  DynamicInt divideDynamicIntAsDynamicInt(DynamicInt other) =>
      _DynamicIntBig(_n ~/ other.toBigInt());

  @override
  DynamicInt operator ~/(DynamicNumber<dynamic> other) =>
      _DynamicIntBig(_n ~/ other.toBigInt());

  @override
  double divideIntAsDouble(int n2) => _n / BigInt.from(n2);

  @override
  double divideDoubleAsDouble(double n2) =>
      (toDecimal() / Decimal.fromDouble(n2)).toDouble();

  @override
  double divideNumAsDouble(num n2) => _n / BigInt.from(n2);

  @override
  double divideBigIntAsDouble(BigInt n2) => _n / n2;

  @override
  Decimal operator /(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return toDecimal() / other;
    } else {
      var d = _n / other.toBigInt();
      return Decimal.fromDouble(d);
    }
  }

  @override
  Decimal get squareRoot => toDecimal().squareRoot;

  @override
  String toHex() {
    if (_n.bitLength <= 32) {
      return _n.toHex32();
    } else if (_n.bitLength <= 64) {
      return _n.toHex64();
    } else {
      return _n.toHex();
    }
  }

  @override
  String toStringStandard() => _n.toString();
}

extension DynamicIntOnNumExtension on num {
  DynamicInt toDynamicInt() => DynamicInt.fromInt(toInt());

  DynamicNumber<dynamic> toDynamicNumber() {
    if (this is int) {
      return DynamicInt.fromInt(toInt());
    } else {
      return Decimal.fromNum(this);
    }
  }
}

extension DynamicIntOnIntExtension on int {
  DynamicInt toDynamicInt() => DynamicInt.fromInt(this);
}

extension DynamicIntOnBigIntExtension on BigInt {
  DynamicInt toDynamicInt() => DynamicInt.fromBigInt(this);
}

extension DynamicIntOnIterableNumExtension on Iterable<num> {
  Iterable<DynamicInt> get asDynamicInt =>
      map((e) => DynamicInt.fromInt(e.toInt()));
}

extension DynamicIntOnIterableIntExtension on Iterable<int> {
  Iterable<DynamicInt> get asDynamicInt => map((e) => DynamicInt.fromInt(e));
}

extension DynamicIntOnIterableBigIntExtension on Iterable<BigInt> {
  Iterable<DynamicInt> get asDynamicInt => map((e) => DynamicInt.fromBigInt(e));
}

extension DynamicIntOnIterableDynamicNumberExtension
    on Iterable<DynamicNumber<dynamic>> {
  Iterable<DynamicInt> get asDynamicInt => map((e) => e.toDynamicInt());

  Iterable<Decimal> get asDecimal => map((e) => e.toDecimal());

  Iterable<double> get asDouble => map((e) => e.toDouble());

  Iterable<int> get asInt => map((e) => e.toInt());

  Iterable<num> get asNum => map((e) => e.toNum());

  /// Returns the sum of this numeric collection.
  DynamicNumber<dynamic> get sum {
    var itr = iterator;
    if (!itr.moveNext()) {
      return DynamicInt.zero;
    }

    DynamicNumber<dynamic> total = itr.current;
    while (itr.moveNext()) {
      total = total + itr.current;
    }
    return total;
  }

  /// Returns the sum of squares of this numeric collection.
  DynamicNumber<dynamic> get sumSquares {
    var itr = iterator;

    if (!itr.moveNext()) {
      return Decimal.zero;
    }

    var first = itr.current;
    var total = first * first;

    while (itr.moveNext()) {
      var n = itr.current;
      total += n * n;
    }

    return total;
  }

  /// Returns the mean/average of this numeric collection.
  Decimal get mean => sum.divideIntAsDecimal(length);

  /// Returns the standard deviation of this numeric collection.
  Decimal get standardDeviation {
    var itr = iterator;

    if (!itr.moveNext()) {
      return Decimal.zero;
    }

    var average = mean;

    var first = itr.current - average;
    var total = first * first;

    while (itr.moveNext()) {
      var n = itr.current - average;
      total += n * n;
    }

    var deviation = total.divideIntAsDecimal(length).squareRoot;

    return deviation;
  }

  /// Returns the mean/average of squares of this numeric collection.
  Decimal get squaresMean => sumSquares.divideIntAsDecimal(length);

  /// Returns the squares of this numeric collection.
  List<DynamicNumber<dynamic>> get squares =>
      map((n) => n.square as DynamicNumber<dynamic>).toList();

  /// Returns the square roots of this numeric collection.
  List<Decimal> get squaresRoots => map((n) => n.squareRoot).toList();

  /// Returns the absolute values of this numeric collection.
  List<DynamicNumber<dynamic>> get abs =>
      map((n) => n.abs() as DynamicNumber<dynamic>).toList();
}

extension DynamicIntOnIterableDynamicIntExtension on Iterable<DynamicInt> {
  StatisticsDynamicNumber<DynamicInt> get statistics =>
      StatisticsDynamicNumber<DynamicInt>.compute(this);

  /// Returns a [Statistics] of this numeric collection (with populated field [StatisticsDynamicNumber.data]).
  StatisticsDynamicNumber<DynamicInt> get statisticsWithData =>
      StatisticsDynamicNumber<DynamicInt>.compute(this, keepData: true);

  Iterable<Decimal> get asDecimal => map((e) => e.toDecimal());

  /// Returns the sum of this numeric collection.
  DynamicInt get sum {
    var itr = iterator;

    if (!itr.moveNext()) {
      return DynamicInt.zero;
    }

    var total = itr.current;

    while (itr.moveNext()) {
      total = total.sumDynamicInt(itr.current);
    }

    return total;
  }

  /// Returns the sum of squares of this numeric collection.
  DynamicInt get sumSquares {
    var itr = iterator;

    if (!itr.moveNext()) {
      return DynamicInt.zero;
    }

    var first = itr.current;
    var total = first.multiplyDynamicInt(first);

    while (itr.moveNext()) {
      var n = itr.current;
      total = total.sumDynamicInt(n.multiplyDynamicInt(n));
    }

    return total;
  }

  /// Returns the mean/average of this numeric collection.
  Decimal get mean => sum.divideIntAsDecimal(length);

  /// Returns the standard deviation of this numeric collection.
  Decimal get standardDeviation {
    var itr = iterator;

    if (!itr.moveNext()) {
      return Decimal.zero;
    }

    var average = mean;

    var first = itr.current - average;
    var total = first * first;

    while (itr.moveNext()) {
      var n = itr.current - average;
      total += n * n;
    }

    var deviation = total.divideInt(length).squareRoot;

    return deviation;
  }

  /// Returns the mean/average of squares of this numeric collection.
  Decimal get squaresMean => sumSquares.divideIntAsDecimal(length);

  /// Returns the squares of this numeric collection.
  List<DynamicInt> get squares => map((n) => n.square).toList();

  /// Returns the squares roots of this numeric collection.
  List<Decimal> get squaresRoots => map((n) => n.squareRoot).toList();

  /// Returns the absolute values of this numeric collection.
  List<DynamicInt> get abs => map((n) => n.abs()).toList();
}

extension DynamicIntOnListNumExtension on List<num> {
  List<DynamicInt> toDynamicIntList({bool growable = true}) =>
      map((e) => DynamicInt.fromInt(e.toInt())).toList(growable: growable);
}

extension DynamicIntOnListIntExtension on List<int> {
  List<DynamicInt> toDynamicIntList({bool growable = true}) =>
      map((e) => DynamicInt.fromInt(e)).toList(growable: growable);
}

extension DynamicIntOnListBigIntExtension on List<BigInt> {
  List<DynamicInt> toDynamicIntList({bool growable = true}) =>
      map((e) => DynamicInt.fromBigInt(e)).toList(growable: growable);
}

extension DynamicIntOnListDynamicNumberExtension
    on List<DynamicNumber<dynamic>> {
  List<DynamicInt> toDynamicIntList({bool growable = true}) =>
      map((e) => e.toDynamicInt()).toList(growable: growable);

  List<Decimal> toDecimalList({bool growable = true}) =>
      map((e) => e.toDecimal()).toList(growable: growable);

  List<double> toDoubleList({bool growable = true}) =>
      map((e) => e.toDouble()).toList(growable: growable);

  List<int> toIntList({bool growable = true}) =>
      map((e) => e.toInt()).toList(growable: growable);

  List<num> toNumList({bool growable = true}) =>
      map((e) => e.toNum()).toList(growable: growable);
}

extension DynamicIntOnListDynamicIntExtension on List<DynamicInt> {
  List<Decimal> toDecimalList({bool growable = true}) =>
      map((e) => e.toDecimal()).toList(growable: growable);
}
