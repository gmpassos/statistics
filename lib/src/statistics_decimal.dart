import 'dart:math' as math;

import 'statistics_base.dart';
import 'statistics_dynamic_int.dart';

/// [Decimal] is a fast implementation of decimal numbers,
/// using an internal [DynamicInt] to represent them with a fixed [precision].
///
/// In theory a [Decimal] can represent any decimal number, where the whole part
/// can be represented as [int] or [BigInt] and the [precision] is from `0` to `15`.
///
/// - All the operations will try to preserve results precision and avoid overflows,
///   by dynamically changing the [precision] of the internal representation.
///
/// - This implementation does not use fractions for its operations,
///   and depends on the maximum bits that a [DynamicInt] can represent.
///   See [maxSafeInteger].
///
/// - Note that [double] (floating-points) are not precise in the representation
///   of decimal numbers. For ex.: ` 0.2 + 0.1 = 0.30000000000000004 `
///
class Decimal implements DynamicNumber<Decimal> {
  static final Decimal zero = Decimal._(DynamicInt.zero, 0, DynamicInt.one);
  static final Decimal one = Decimal._(DynamicInt.one, 0, DynamicInt.one);
  static final Decimal two = Decimal._(DynamicInt.two, 0, DynamicInt.one);
  static final Decimal ten = Decimal._(DynamicInt.ten, 0, DynamicInt.one);

  static final int _maxInternalDigits =
      DynamicInt.maxSafeInteger.toString().length - 1;

  /// The internal representation of the decimal as an integer.
  final DynamicInt _n;

  /// The precision of the internal representation.
  final int precision;

  /// The scale of the internal representation.
  final DynamicInt _scale;

  Decimal._(this._n, this.precision, this._scale) {
    assert(precision >= 0);
    assert(_scale >= DynamicInt.one);
  }

  Decimal._computeScale(this._n, this.precision)
      : _scale = _computePrecisionScale(precision) {
    assert(precision >= 0);
    assert(_scale >= DynamicInt.one);
  }

  static final DynamicInt _dynamicInt100 = DynamicInt.fromInt(100);
  static final DynamicInt _dynamicInt1000 = DynamicInt.fromInt(1000);
  static final DynamicInt _dynamicInt10000 = DynamicInt.fromInt(10000);
  static final DynamicInt _dynamicInt100000 = DynamicInt.fromInt(100000);
  static final DynamicInt _dynamicInt1000000 = DynamicInt.fromInt(1000000);

  static DynamicInt _computePrecisionScale(int precision) {
    switch (precision) {
      case 0:
        return DynamicInt.one;
      case 1:
        return DynamicInt.ten;
      case 2:
        return _dynamicInt100;
      case 3:
        return _dynamicInt1000;
      case 4:
        return _dynamicInt10000;
      case 5:
        return _dynamicInt100000;
      case 6:
        return _dynamicInt1000000;
      default:
        {
          if (precision < 0) {
            throw ArgumentError('Invalid precision: $precision');
          }

          var m = DynamicInt.ten;
          for (var i = 2; i <= precision; ++i) {
            m = (m * DynamicInt.ten).toDynamicInt();
          }
          return m;
        }
    }
  }

  /// Creates a [Decimal] from a [DynamicInt].
  factory Decimal.fromDynamicInt(DynamicInt n, {int precision = 0}) {
    if (precision == 0) {
      if (n.isZero) return Decimal.zero;
      if (n.isOne) return Decimal.one;
      if (n == DynamicInt.two) return Decimal.two;
      if (n == DynamicInt.ten) return Decimal.ten;

      return Decimal._(n, 0, DynamicInt.one);
    }

    var scale = _computePrecisionScale(precision);
    n = n.multiplyDynamicInt(scale);

    return Decimal._(n, precision, scale);
  }

  /// Creates a [Decimal] from an [int].
  factory Decimal.fromInt(int n, {int precision = 0}) {
    if (precision == 0) {
      switch (n) {
        case 0:
          return Decimal.zero;
        case 1:
          return Decimal.one;
        case 2:
          return Decimal.two;
        case 10:
          return Decimal.ten;
        default:
          break;
      }

      return Decimal._(n.toDynamicInt(), 0, DynamicInt.one);
    }

    var multiplier = _computePrecisionScale(precision);
    var nDI = multiplier.multiplyInt(n);

    return Decimal._(nDI, precision, multiplier);
  }

  /// Creates a [Decimal] from a [double].
  factory Decimal.fromDouble(double d, {int? precision}) {
    if (precision == null || precision == 0) {
      if (d == 0.0) {
        return Decimal.zero;
      } else if (d == 1.0) {
        return Decimal.one;
      } else if (d == 2.0) {
        return Decimal.two;
      } else if (d == 10.0) {
        return Decimal.ten;
      }
    }

    precision ??= _computeDoublePrecision(d, 12);

    var scale = _computePrecisionScale(precision);

    final dI = d.toInt();
    var dIBitsLength = dI.bitLength + 1;
    final bits = dIBitsLength + scale.bitLength;

    if (bits < DynamicInt.safeIntegerBits) {
      var n = (d * scale.toInt()).toInt();
      return Decimal._(n.toDynamicInt(), precision, scale);
    } else {
      var dPrecision = _computeDoublePrecision(d, 17);
      var dScale = _computePrecisionScale(dPrecision);
      var dScaleI = dScale.toInt();

      if (dPrecision < precision) {
        final bits = dIBitsLength + dScale.bitLength;
        if (bits < DynamicInt.safeIntegerBits) {
          var n = (d * dScaleI).toInt();
          var decimal = Decimal._(n.toDynamicInt(), dPrecision, dScale);
          return decimal.withPrecision(precision);
        }
      }

      var dec = d - d.truncateToDouble();
      var n = (BigInt.from(d) * dScale.toBigInt()) + BigInt.from(dec * dScaleI);

      var decimal = Decimal._(n.toDynamicInt(), dPrecision, dScale);
      decimal = decimal.withPrecision(precision);

      return decimal;
    }
  }

  static int _computeDoublePrecision(double d, int maxPrecision) {
    int precision;

    var s = d.toString();
    if (s.contains('e')) {
      precision = maxPrecision;
    } else {
      var idx = s.indexOf('.');
      if (idx >= 0) {
        var lng = s.length - (idx + 1);
        if (lng == 1) {
          var dec = s.substring(idx + 1);
          if (dec == '0') {
            return 0;
          }
        }
        precision = math.min(lng, maxPrecision);
      } else {
        precision = 0;
      }
    }

    return precision;
  }

  /// Creates a [Decimal] from a [num].
  factory Decimal.fromNum(num n, {int? precision}) {
    if (n is int) {
      return Decimal.fromInt(n, precision: precision ?? 0);
    } else {
      return Decimal.fromDouble(n.toDouble(), precision: precision);
    }
  }

  /// Creates a [Decimal] from a [BigInt].
  factory Decimal.fromBigInt(BigInt n, {int precision = 0}) =>
      Decimal.fromDynamicInt(n.toDynamicInt(), precision: precision);

  factory Decimal.fromParts(Object whole, Object decimal, {int? precision}) {
    if (decimal is num) {
      if (decimal < 0) {
        decimal = decimal.abs();
      }

      String d;
      if (decimal is int) {
        d = decimal.toString();
      } else {
        if (decimal > 1) {
          throw ArgumentError('Decimal > 1: $decimal');
        }

        d = decimal.toString();
        if (d.contains('e')) {
          d = decimal.toStringAsFixed(20);
        }

        if (d.startsWith('0.')) {
          d = d.substring(2);
        } else {
          throw ArgumentError('Invalid decimal: $decimal');
        }
      }

      return Decimal.parseParts(whole.toString(), d, precision: precision);
    } else {
      return Decimal.parseParts(whole.toString(), decimal.toString(),
          precision: precision);
    }
  }

  /// Parses a [Decimal] from [s].
  ///
  /// - [decimalDelimiter] is the decimal delimiter to use in the parser.
  factory Decimal.parse(String s,
      {int? precision, String decimalDelimiter = '.'}) {
    s = s.trim();
    if (s.isEmpty) {
      throw FormatException('Invalid `Decimal` format: $s');
    }

    decimalDelimiter = decimalDelimiter.trim();
    if (decimalDelimiter.length != 1) {
      throw ArgumentError("Invalid decimalDelimiter: `$decimalDelimiter`");
    }

    var idx = s.lastIndexOf(decimalDelimiter);
    if (idx < 0) {
      return Decimal.parseParts(s, '', precision: precision ?? 0);
    }

    var n = s.substring(0, idx).trim();
    var d = s.substring(idx + 1).trim();

    return Decimal.parseParts(n, d, precision: precision);
  }

  /// Tries to [parse] [String] [s] to a [Decimal].
  static Decimal? tryParse(String s,
      {int? precision, String decimalDelimiter = '.'}) {
    if (s.isEmpty) return null;

    try {
      return Decimal.parse(s,
          precision: precision, decimalDelimiter: decimalDelimiter);
    } on FormatException {
      return null;
    }
  }

  factory Decimal.parseParts(String whole, String decimal, {int? precision}) {
    whole = whole.trim();
    if (whole.isEmpty) {
      whole = '0';
    }

    decimal = decimal.trim();
    if (decimal.isEmpty) {
      decimal = '0';
    }

    if (decimal == '0' || decimal == '00' || decimal == '000') {
      var n = DynamicInt.tryParse(whole);

      if (n == null) {
        throw FormatException('Invalid `Decimal` format: $whole');
      }

      if (precision == null || precision == 0) {
        if (n.isZero) return Decimal.zero;
        if (n.isOne) return Decimal.one;
        if (n == DynamicInt.two) return Decimal.two;
        if (n == DynamicInt.ten) return Decimal.ten;
      }

      var o = Decimal._(n, 0, DynamicInt.one);
      if (precision != null) {
        o = o.withPrecision(precision);
      }
      return o;
    }

    var dPrecision = decimal.length;
    var dScale = _computePrecisionScale(dPrecision);

    var nFull = whole + decimal;
    var i = DynamicInt.tryParse(nFull);

    if (i == null) {
      throw FormatException('Invalid `Decimal` format: $whole . $decimal');
    }

    var o = Decimal._(i, dPrecision, dScale);

    if (precision != null) {
      o = o.withPrecision(precision);
    }

    return o;
  }

  static Decimal? from(Object? o, {int? precision}) {
    if (o == null) return null;
    if (o is Decimal) return o;

    if (o is int) return Decimal.fromInt(o, precision: precision ?? 0);
    if (o is double) return Decimal.fromDouble(o, precision: precision);

    if (o is BigInt) return Decimal.fromBigInt(o, precision: precision ?? 0);

    if (o is DynamicInt) {
      return Decimal.fromDynamicInt(o, precision: precision ?? 0);
    }

    if (o is List) {
      var n = o[0];
      var d = o.length > 1 ? o[1] : '0';
      return Decimal.fromParts(n, d, precision: precision);
    }

    if (o is Map) {
      var n = o['whole'] ?? o['integer'] ?? o['n'] ?? o['i'];
      var d = o['decimal'] ?? o['fraction'] ?? o['cents'] ?? o['d'] ?? o['f'];
      return Decimal.fromParts(n, d, precision: precision);
    }

    return Decimal.tryParse(o.toString(), precision: precision);
  }

  @override
  bool get isWholeNumber {
    if (precision == 0) return true;
    var c = compactedPrecision;
    var isWhole = c.precision == 0;
    return isWhole;
  }

  /// Returns `this` instance with a new [precision]. Returns the same instance
  /// if [precision] is the same of the current precision.
  Decimal withPrecision(int precision) {
    if (precision == this.precision) return this;

    if (precision < 0) throw ArgumentError('Invalid precision: $precision');

    var scale = _computePrecisionScale(precision);

    if (precision > this.precision) {
      var diff = scale ~/ _scale;
      var n = _n.multiplyDynamicInt(diff);
      return Decimal._computeScale(n, precision);
    } else {
      var diff = _scale ~/ scale;
      var n = _n.divideAsDynamicInt(diff);
      return Decimal._computeScale(n, precision);
    }
  }

  int? _precisionNeeded;

  /// Returns the needed [precision] to represent this decimal.
  int get precisionNeeded => _precisionNeeded ??= _precisionNeededImpl();

  int _precisionNeededImpl() {
    switch (precision) {
      case 0:
        return 0;
      case 1:
        {
          if (_n.moduloInt(10).isZero) return 0;
          return 1;
        }
      case 2:
        {
          if (_n.moduloInt(100).isZero) return 0;
          if (_n.moduloInt(10).isZero) return 1;
          return 2;
        }
      case 3:
        {
          if (_n.moduloInt(1000).isZero) return 0;
          if (_n.moduloInt(100).isZero) return 1;
          if (_n.moduloInt(10).isZero) return 2;
          return 3;
        }
      case 4:
        {
          if (_n.moduloInt(10000).isZero) return 0;
          if (_n.moduloInt(1000).isZero) return 1;
          if (_n.moduloInt(100).isZero) return 2;
          if (_n.moduloInt(10).isZero) return 3;
          return 4;
        }
      case 5:
        {
          if (_n.moduloInt(100000).isZero) return 0;
          if (_n.moduloInt(10000).isZero) return 1;
          if (_n.moduloInt(1000).isZero) return 2;
          if (_n.moduloInt(100).isZero) return 3;
          if (_n.moduloInt(10).isZero) return 4;
          return 5;
        }
      case 6:
        {
          if (_n.moduloInt(1000000).isZero) return 0;
          if (_n.moduloInt(100000).isZero) return 1;
          if (_n.moduloInt(10000).isZero) return 2;
          if (_n.moduloInt(1000).isZero) return 3;
          if (_n.moduloInt(100).isZero) return 4;
          if (_n.moduloInt(10).isZero) return 5;
          return 6;
        }
      default:
        {
          var p = _scale;
          for (var i = 0; i < precision; ++i) {
            if (_n.moduloDynamicInt(p).isZero) return i;
            p = p ~/ DynamicInt.ten;
          }
          return precision;
        }
    }
  }

  Decimal? _compactedPrecision;

  /// Compacts this [Decimal] to the minimal precision needed to represent this decimal.
  ///
  /// See [precisionNeeded] and [withPrecision].
  Decimal get compactedPrecision =>
      _compactedPrecision ??= withPrecision(precisionNeeded);

  /// Ensures that [precision] is not gresater than [maximumPrecision].
  /// Returns [withPrecision]`(maximumPrecision)` if needed.
  Decimal withMaximumPrecision(int maximumPrecision) {
    if (precision > maximumPrecision) {
      return withPrecision(maximumPrecision);
    } else {
      return this;
    }
  }

  /// Ensures that [precision] is not less than [minimumPrecision].
  /// Returns [withPrecision]`(minimumPrecision)` if needed.
  Decimal withMinimumPrecision(int minimumPrecision) {
    if (precision < minimumPrecision) {
      return withPrecision(minimumPrecision);
    } else {
      return this;
    }
  }

  /// Clips the [precision] in range [minimumPrecision] .. [maximumPrecision] (inclusive).
  /// Returns [withPrecision] if needed.
  Decimal clipPrecision(int minimumPrecision, int maximumPrecision) {
    if (precision < minimumPrecision) {
      return withPrecision(minimumPrecision);
    } else if (precision > maximumPrecision) {
      return withPrecision(maximumPrecision);
    } else {
      return this;
    }
  }

  /// Returns this instance using the higher precision between `this` and [other].
  ///
  /// See [withPrecision].
  Decimal withHigherPrecision(Decimal other) {
    return precision < other.precision ? withPrecision(other.precision) : this;
  }

  /// Returns this instance using the lower precision between `this` and [other].
  ///
  /// See [withPrecision].
  Decimal withLowerPrecision(Decimal other) {
    return precision <= other.precision ? this : withPrecision(other.precision);
  }

  /// Returns the higher precision between `this` and [other].
  int higherPrecision(Decimal other) {
    var precision = this.precision;
    return precision < other.precision ? other.precision : precision;
  }

  /// Returns the lower precision between `this` and [other].
  int lowerPrecision(Decimal other) {
    var precision = this.precision;
    return precision > other.precision ? other.precision : precision;
  }

  DynamicInt? _wholePart;

  /// The whole part of this decimal.
  ///
  /// - Note that if the whole part is `0` it won't have a negative signal
  ///   if this instance [isNegative].
  DynamicInt get wholePart => _wholePart ??= _n.divideAsDynamicInt(_scale);

  /// [wholePart] as [int].
  int get wholePartAsInt => wholePart.toInt();

  /// [wholePart] as [BigInt].
  BigInt get wholePartAsBigInt => wholePart.toBigInt();

  /// The whole part of this decimal as [double].
  ///
  /// See [wholePart].
  double get wholePartAsDouble {
    var n = wholePart.toDouble();
    if (isNegative && !n.isNegative) {
      n = -n;
    }
    return n;
  }

  /// The whole part of this decimal as [String].
  ///
  /// See [wholePart].
  String get wholePartAsString {
    var n = wholePart;
    if (isNegative && !n.isNegative) {
      return '-$n';
    } else {
      return n.toString();
    }
  }

  int? _wholePartDigits;

  /// Returns the number of digits ot represent this decimal whole part.
  int get wholePartDigits =>
      _wholePartDigits ??= DynamicInt.dynamicIntDigits(wholePart);

  DynamicInt _wholePartMultiplied(DynamicInt multiplier) {
    var m = wholePart.multiplyDynamicInt(multiplier);
    if (isNegative && !m.isNegative) {
      m = -m;
    }
    return m;
  }

  /// Returns the decimal part of this number as [double].
  ///
  /// See [decimalPartAsString].
  double get decimalPartAsDouble {
    if (precision == 0) return 0.0;
    var multiplier = _scale;

    var n = _wholePartMultiplied(multiplier);
    var d = _n.subtractDynamicInt(n).abs();
    var dec = d.divideDynamicIntAsDouble(multiplier);

    if (isNegative && !dec.isNegative) {
      dec = -dec;
    }

    return dec;
  }

  /// Returns the decimal part of this number as [String].
  ///
  /// See [decimalPartAsDouble].
  String get decimalPartAsString {
    if (precision == 0) return '';

    var n = _wholePartMultiplied(_scale);
    var d = (_n - n).abs();
    var s = d.toString();

    if (s.length < precision) {
      var needed = precision - s.length;

      var str = StringBuffer('0');
      for (var i = 1; i < needed; ++i) {
        str.write('0');
      }
      str.write(s);

      s = str.toString();
    }

    return s;
  }

  /// Returns `true` if the decimal part is zero (an integer number).
  bool get isDecimalPartZero {
    if (precision == 0) return true;

    var n = _wholePartMultiplied(_scale);
    var d = (_n - n).abs();
    return d.isZero;
  }

  @override
  int get sign => _n.sign;

  @override
  bool get isPositive => sign == 1;

  @override
  bool get isNegative => sign == -1;

  @override
  bool get isZero => _n.isZero;

  @override
  bool get isOne => _n.equalsDynamicInt(_scale);

  /// Returns `true` if and only if this [Decimal] [isWholeNumber] and is odd.
  /// - Note: that only whole numbers can be even or odd.
  @override
  bool get isOdd => isWholeNumber && _n.isOdd;

  /// Returns `true` if and only if this [Decimal] [isWholeNumber] and is even.
  /// - Note: that only whole numbers can be even or odd.
  @override
  bool get isEven => isWholeNumber && _n.isEven;

  @override
  bool get isBigInt => false;

  @override
  bool get isDynamicInt => false;

  @override
  bool get isDecimal => true;

  @override
  bool get isSafeInteger => false;

  @override
  double toDouble() => _n.divideDynamicIntAsDouble(_scale);

  /// Returns this decimal as [int].
  @override
  int toInt() => wholePart.toInt();

  /// Returns this decimal as [num].
  @override
  num toNum() {
    if (precision == 0) return toInt();
    return toDouble();
  }

  /// Returns this decimal as [BigInt].
  @override
  BigInt toBigInt() {
    var n = wholePart.toBigInt();
    if (isNegative && !n.isNegative) {
      n = -n;
    }
    return n;
  }

  @override
  DynamicInt toDynamicInt() {
    return precision == 0 ? _n : DynamicInt.fromBigInt(toBigInt());
  }

  @override
  Decimal toDecimal() => this;

  @override
  String toHex() => toDynamicInt().toHex();

  /// Formats this decimal to a [String].
  ///
  /// - If [compact] is `true` it will format as [compactedPrecision] instance.
  /// - If [thousands] is `true` it will use thousands delimiters for the [wholePart].
  /// - If [decimal] is `true` it will add the [decimalPartAsString] to the [String] result.
  /// - [decimalDelimiter] is the delimiter for the decimal part.
  /// - [thousandsDelimiter] is the thousands delimiter.
  @override
  String format(
      {bool compact = false,
      String decimalDelimiter = '.',
      bool thousands = true,
      String thousandsDelimiter = ',',
      bool decimal = true}) {
    var self = this;
    if (compact) {
      self = self.compactedPrecision;
    }
    return self._formatImpl(
        thousands, thousandsDelimiter, decimalDelimiter, decimal);
  }

  String _formatImpl(bool thousands, String thousandsDelimiter,
      String decimalDelimiter, bool decimal) {
    var wholeStr = wholePartAsString;

    if (thousandsDelimiter == decimalDelimiter) {
      if (decimalDelimiter == ',') {
        thousandsDelimiter = '.';
      } else if (thousandsDelimiter == '.') {
        decimalDelimiter = ',';
      }
    }

    if (thousands) {
      if (thousandsDelimiter == decimalDelimiter) {
        throw StateError(
            "`thousandsDelimiter` can't be equals to `decimalDelimiter`: `$thousandsDelimiter` == `$decimalDelimiter`");
      }

      var signLength = isNegative ? 1 : 0;

      var n = wholeStr;
      var nThousands = '';

      while ((n.length - signLength) > 3) {
        var tail = n.substring(n.length - 3);
        n = n.substring(0, n.length - 3);
        nThousands = thousandsDelimiter + tail + nThousands;
      }

      wholeStr = '$n$nThousands';
    }

    if (decimal) {
      if (precision > 0) {
        return '$wholeStr$decimalDelimiter$decimalPartAsString';
      } else {
        return '$wholeStr${decimalDelimiter}0';
      }
    } else {
      return wholeStr;
    }
  }

  @override
  String toStringStandard() {
    if (precision == 0) {
      return '${_n.toStringStandard()}.0';
    } else {
      return format(thousands: false, decimal: true);
    }
  }

  /// This decimal formatted to a [String]. Delegates to [format].
  @override
  String toString(
          {bool compact = false,
          bool decimal = true,
          String decimalDelimiter = '.',
          bool thousands = false,
          String thousandsDelimiter = ','}) =>
      format(
          compact: compact,
          decimal: decimal,
          decimalDelimiter: decimalDelimiter,
          thousands: thousands,
          thousandsDelimiter: thousandsDelimiter);

  @override
  int get hashCode => _n.hashCode ^ precision;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! Decimal) return false;

    if (wholePart != other.wholePart) return false;

    var p = higherPrecision(other);
    return withPrecision(p)._n == other.withPrecision(p)._n;
  }

  @override
  bool operator <(DynamicNumber<dynamic> other) {
    var n2 = other.toDecimal();
    var p = higherPrecision(n2);
    return withPrecision(p)._n < n2.withPrecision(p)._n;
  }

  @override
  bool operator <=(DynamicNumber<dynamic> other) {
    var n2 = other.toDecimal();
    var p = higherPrecision(n2);
    return withPrecision(p)._n <= n2.withPrecision(p)._n;
  }

  @override
  bool operator >(DynamicNumber<dynamic> other) {
    var n2 = other.toDecimal();
    var p = higherPrecision(n2);
    return withPrecision(p)._n > n2.withPrecision(p)._n;
  }

  @override
  bool operator >=(DynamicNumber<dynamic> other) {
    var n2 = other.toDecimal();
    var p = higherPrecision(n2);
    return withPrecision(p)._n >= n2.withPrecision(p)._n;
  }

  @override
  Decimal sumInt(int amount) {
    if (amount == 0) return this;
    var n = _n.sumDynamicInt(_scale.multiplyInt(amount));
    return Decimal._(n, precision, _scale);
  }

  @override
  Decimal sumBigInt(BigInt amount) {
    if (amount == BigInt.zero) return this;
    var n = _n.sumDynamicInt(_scale.multiplyBigInt(amount));
    return Decimal._(n, precision, _scale);
  }

  @override
  Decimal sumDouble(double amount) {
    if (amount == 0.0) return this;
    return _sumSubOperation(Decimal.fromDouble(amount), true);
  }

  @override
  Decimal sum(num n2) {
    if (n2 is int) {
      return sumInt(n2);
    } else {
      return sumDouble(n2.toDouble());
    }
  }

  @override
  Decimal sumDynamicInt(DynamicInt other) =>
      _sumSubOperation(other.toDecimal(), true);

  @override
  Decimal operator +(DynamicNumber<dynamic> other) =>
      _sumSubOperation(other.toDecimal(), true);

  @override
  Decimal subtractInt(int amount) {
    if (amount == 0) return this;
    var n = _n.subtractDynamicInt(_scale.multiplyInt(amount));
    return Decimal._(n, precision, _scale);
  }

  @override
  Decimal subtractBigInt(BigInt amount) {
    if (amount == BigInt.zero) return this;
    var n = _n.subtractDynamicInt(_scale.multiplyBigInt(amount));
    return Decimal._(n, precision, _scale);
  }

  @override
  Decimal subtractDouble(double n2) {
    if (n2 == 0.0) return this;
    return _sumSubOperation(Decimal.fromNum(n2), false);
  }

  @override
  Decimal subtract(num n2) {
    if (n2 is int) {
      return subtractInt(n2);
    } else {
      return subtractDouble(n2.toDouble());
    }
  }

  @override
  Decimal subtractDynamicInt(DynamicInt other) =>
      _sumSubOperation(other.toDecimal(), false);

  @override
  Decimal operator -(DynamicNumber<dynamic> other) =>
      _sumSubOperation(other.toDecimal(), false);

  Decimal _sumSubOperation(Decimal other, bool doSum) {
    if (isZero) {
      return doSum ? other : -other;
    } else if (other.isZero) {
      return this;
    }

    var pHigher = higherPrecision(other);

    var self = compactedPrecision;
    other = other.compactedPrecision;

    var p = self.higherPrecision(other);

    var p1 = self.withPrecision(p);
    var p2 = other.withPrecision(p);

    var value = (doSum ? p1._n + p2._n : p1._n - p2._n).toDynamicInt();

    var result = Decimal._(value, p1.precision, p1._scale);

    if (pHigher > result.precision &&
        (result.wholePartDigits + pHigher) <= _maxInternalDigits) {
      result = result.withPrecision(pHigher);
    }

    return result;
  }

  @override
  Decimal operator *(DynamicNumber<dynamic> other) =>
      _multiplyOperation(other.toDecimal());

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
  Decimal multiply(num n2) {
    if (n2 is int) {
      return _multiplyOperationByInt(n2);
    }

    return _multiplyOperation(Decimal.fromNum(n2));
  }

  @override
  Decimal multiplyInt(int n2) => _multiplyOperationByInt(n2);

  @override
  Decimal multiplyBigInt(BigInt n2) =>
      _multiplyOperationByDynamicInt(DynamicInt.fromBigInt(n2));

  @override
  Decimal multiplyDouble(double n2) {
    if (n2 == 0.0) return Decimal.zero;
    if (n2 == 1.0) return this;
    return _multiplyOperation(Decimal.fromDouble(n2));
  }

  @override
  DynamicNumber<dynamic> multiplyDynamicInt(DynamicInt other) =>
      _multiplyOperation(other.toDecimal());

  @override
  DynamicNumber<dynamic> multiplyDecimal(Decimal other) =>
      _multiplyOperation(other);

  static const int _maxMultiplicationPrecisionExpansion = 12;

  Decimal _multiplyOperation(Decimal other) {
    if (isZero || other.isOne) {
      return this;
    } else if (other.isZero || isOne) {
      return other;
    }

    if (other.precision == 0) {
      return _multiplyOperationByDynamicInt(other._n);
    }

    return _multiplyOperationByDecimal(other);
  }

  Decimal _multiplyOperationByDecimal(Decimal other) {
    var self = compactedPrecision;
    other = other.compactedPrecision;

    var multi = (self._n * other._n).toDynamicInt();
    var multiPrecision = self.precision + other.precision;
    var multiPrecisionScale = self._scale.multiplyDynamicInt(other._scale);

    var product = Decimal._(multi, multiPrecision, multiPrecisionScale);

    if (multiPrecision > _maxMultiplicationPrecisionExpansion) {
      var pMax = self.higherPrecision(other);
      if (pMax < _maxMultiplicationPrecisionExpansion) {
        product = product.withPrecision(_maxMultiplicationPrecisionExpansion);
      }
    }

    return product;
  }

  Decimal _multiplyOperationByDynamicInt(DynamicInt n) {
    if (n.isSafeInteger && n.moduloInt(10).isZero) {
      var m = _multiplyOperationByBase10(n.toInt());
      if (m != null) return m;
    }

    return _multiplyOperationByDecimal(Decimal.fromDynamicInt(n));
  }

  Decimal _multiplyOperationByInt(int n) {
    if (n % 10 == 0) {
      var m = _multiplyOperationByBase10(n);
      if (m != null) return m;
    }

    return _multiplyOperationByDecimal(Decimal.fromInt(n));
  }

  Decimal? _multiplyOperationByBase10(int n) {
    switch (n) {
      case 10:
        return _multiplyOperationByPrecisionShift(1);
      case 100:
        return _multiplyOperationByPrecisionShift(2);
      case 1000:
        return _multiplyOperationByPrecisionShift(3);
      case 10000:
        return _multiplyOperationByPrecisionShift(4);
      case 100000:
        return _multiplyOperationByPrecisionShift(5);
      case 1000000:
        return _multiplyOperationByPrecisionShift(6);
      case 10000000:
        return _multiplyOperationByPrecisionShift(7);
      case 100000000:
        return _multiplyOperationByPrecisionShift(8);
      case 1000000000:
        return _multiplyOperationByPrecisionShift(9);
      case 10000000000:
        return _multiplyOperationByPrecisionShift(10);
      case 100000000000:
        return _multiplyOperationByPrecisionShift(11);
      case 1000000000000:
        return _multiplyOperationByPrecisionShift(12);
      default:
        return null;
    }
  }

  Decimal _multiplyOperationByPrecisionShift(int pShift) {
    var p = precision - pShift;

    if (p >= 0) {
      return Decimal._computeScale(_n, p);
    } else {
      var scale = _computePrecisionScale(p.abs());
      return Decimal._computeScale(_n.multiplyDynamicInt(scale), 0);
    }
  }

  void _throwDivisionByZero() {
    throw UnsupportedError('Division by zero: $this / 0');
  }

  @override
  Decimal operator /(DynamicNumber<dynamic> other) =>
      _divideOperation(other.toDecimal());

  @override
  DynamicInt operator ~/(DynamicNumber<dynamic> other) {
    if (other.isDecimal) {
      return _divideOperation(other.toDecimal()).toDynamicInt();
    } else {
      return _divideOperationByDynamicInt(other.toDynamicInt()).toDynamicInt();
    }
  }

  @override
  Decimal divideIntAsDecimal(int n2) => divideInt(n2);

  @override
  Decimal divideDoubleAsDecimal(double n2) => divideDouble(n2);

  @override
  Decimal divideNumAsDecimal(num n2) => divide(n2);

  @override
  Decimal divideBigIntAsDecimal(BigInt n2) => divideBigInt(n2);

  @override
  Decimal divideDouble(double n2) => _divideOperationByDouble(n2);

  @override
  Decimal divide(num n2) {
    if (n2 is int) {
      return divideInt(n2);
    } else {
      return _divideOperationByDouble(n2.toDouble());
    }
  }

  Decimal _divideOperationByDouble(double n2) {
    if (n2 == 0.0) {
      _throwDivisionByZero();
    } else if (n2 == 1.0 || isZero) {
      return this;
    }

    return _divideOperationByDecimalImpl(Decimal.fromDouble(n2));
  }

  @override
  Decimal divideDynamicInt(DynamicInt other) =>
      _divideOperationByDynamicInt(other);

  @override
  DynamicInt divideDynamicIntAsDynamicInt(DynamicInt other) =>
      _divideOperationByDynamicInt(other).toDynamicInt();

  Decimal _divideOperation(Decimal other) {
    if (other.isZero) {
      _throwDivisionByZero();
    } else if (isZero || other.isOne) {
      return this;
    }

    other = other.compactedPrecision;

    var result = other.precision == 0
        ? _divideOperationByDynamicIntImpl(other._n)
        : _divideOperationByDecimalImpl(other);

    return result.compactedPrecision;
  }

  Decimal _divideOperationByDecimalImpl(Decimal other) {
    var d = _divideOperationByDynamicIntImpl(other._n);
    var precision2 = d.precision - other.precision;
    assert(precision2 >= 0);
    var d2 = Decimal._computeScale(d._n, precision2);
    return d2;
  }

  Decimal _divideOperationByDynamicInt(DynamicInt other) {
    if (other.isZero) {
      _throwDivisionByZero();
    } else if (isZero || other.isOne) {
      return this;
    }

    var result = _divideOperationByDynamicIntImpl(other);
    return result.compactedPrecision;
  }

  Decimal _divideOperationByDynamicIntImpl(final DynamicInt n) {
    if (n.isSafeInteger && n.moduloInt(10).isZero) {
      var d = _divideOperationByBase10(n.toInt());
      if (d != null) return d;
    }

    return _divideOperationByDynamicIntImpl2(n);
  }

  Decimal _divideOperationByDynamicIntImpl2(DynamicInt n) {
    var nScaled = _n.multiplyDynamicInt(_scale);

    var d = nScaled ~/ n;
    var dPrecision = precision + precision;
    var dScale = _scale.multiplyDynamicInt(_scale);

    var r = nScaled.subtractDynamicInt(d.multiplyDynamicInt(n));

    if (!r.isZero) {
      var r2Precision = r.digits + precision;
      var r2Scale = _computePrecisionScale(r2Precision);
      var r2 = r.multiplyDynamicInt(r2Scale);
      var r2Div = r2 ~/ n;

      if (r2.isNegative) {
        while (r2Precision < 15 && r2Div.multiplyDynamicInt(n) > r2) {
          r2 = r2.multiplyDynamicInt(r2Scale);
          r2Div = r2 ~/ n;
          r2Precision *= 2;
          r2Scale = r2Scale.multiplyDynamicInt(r2Scale);
        }
      } else {
        while (r2Precision < 15 && r2Div.multiplyDynamicInt(n) < r2) {
          r2 = r2.multiplyDynamicInt(r2Scale);
          r2Div = r2 ~/ n;
          r2Precision *= 2;
          r2Scale = r2Scale.multiplyDynamicInt(r2Scale);
        }
      }

      d = d.multiplyDynamicInt(r2Scale).sumDynamicInt(r2Div);
      dPrecision = dPrecision + r2Precision;
      dScale = dScale.multiplyDynamicInt(r2Scale);
    }

    var decimal = Decimal._(d, dPrecision, dScale);

    return decimal;
  }

  Decimal _divideOperationByIntImpl(final int n) {
    if (n % 10 == 0) {
      var d = _divideOperationByBase10(n);
      if (d != null) return d;
    }

    var result = _divideOperationByDynamicIntImpl2(DynamicInt.fromInt(n));
    return result.compactedPrecision;
  }

  Decimal? _divideOperationByBase10(int n) {
    switch (n) {
      case 10:
        return _divideOperationByPrecisionShift(1);
      case 100:
        return _divideOperationByPrecisionShift(2);
      case 1000:
        return _divideOperationByPrecisionShift(3);
      case 10000:
        return _divideOperationByPrecisionShift(4);
      case 100000:
        return _divideOperationByPrecisionShift(5);
      case 1000000:
        return _divideOperationByPrecisionShift(6);
      case 10000000:
        return _divideOperationByPrecisionShift(7);
      case 100000000:
        return _divideOperationByPrecisionShift(8);
      case 1000000000:
        return _divideOperationByPrecisionShift(9);
      case 10000000000:
        return _divideOperationByPrecisionShift(10);
      case 100000000000:
        return _divideOperationByPrecisionShift(11);
      case 1000000000000:
        return _divideOperationByPrecisionShift(12);
      default:
        return null;
    }
  }

  Decimal? _divideOperationByPrecisionShift(int pShift) {
    if (precision <= (_maxInternalDigits - pShift)) {
      return Decimal._computeScale(_n, precision + pShift);
    }
    return null;
  }

  @override
  Decimal divideBigInt(BigInt n2) {
    return _divideOperationByDynamicInt(DynamicInt.fromBigInt(n2));
  }

  @override
  double divideBigIntAsDouble(BigInt n2) => divideBigInt(n2).toDouble();

  @override
  Decimal divideInt(int n2) {
    if (n2 == 0) {
      _throwDivisionByZero();
    } else if (n2 == 1 || isZero) {
      return this;
    }

    return _divideOperationByIntImpl(n2);
  }

  @override
  double divideIntAsDouble(int n2) => divideInt(n2).toDouble();

  @override
  double divideDoubleAsDouble(double n2) => divideDouble(n2).toDouble();

  @override
  double divideNumAsDouble(num n2) {
    if (n2 is int) {
      return divideIntAsDouble(n2);
    } else {
      return divideDoubleAsDouble(n2.toDouble());
    }
  }

  @override
  double divideDynamicIntAsDouble(DynamicInt n2) => (this / n2).toDouble();

  @override
  Decimal divideDynamicIntAsDecimal(DynamicInt other) => this / other;

  @override
  int compareTo(DynamicNumber<dynamic> other) {
    if (other is Decimal) {
      var p = higherPrecision(other);
      return withPrecision(p)._n.compareTo(other.withPrecision(p)._n);
    } else if (other is DynamicInt) {
      var cmp = toDynamicInt().compareTo(other);
      if (cmp == 0) {
        return isDecimalPartZero ? 0 : 1;
      } else {
        return cmp;
      }
    } else {
      return -other.compareTo(this);
    }
  }

  @override
  Decimal moduloInt(int n2) {
    var n1 = compactedPrecision;

    if (n1.precision == 0) {
      if (n1.isSafeInteger) {
        return Decimal.fromInt(toInt() % n2);
      } else {
        return Decimal.fromBigInt(toBigInt() % BigInt.from(n2));
      }
    } else {
      return n1._moduloDecimal(Decimal.fromInt(n2));
    }
  }

  @override
  Decimal moduloBigInt(BigInt n2) {
    var n1 = compactedPrecision;

    if (n1.precision == 0) {
      return Decimal.fromBigInt(toBigInt() % n2);
    } else {
      return n1._moduloDecimal(Decimal.fromBigInt(n2));
    }
  }

  @override
  Decimal moduloDynamicInt(DynamicInt other) {
    if (other.isSafeInteger) {
      return moduloInt(other.toInt());
    } else {
      return moduloBigInt(other.toBigInt());
    }
  }

  @override
  Decimal operator %(DynamicNumber<dynamic> other) {
    if (other is DynamicInt) {
      return moduloDynamicInt(other);
    }

    return _moduloDecimal(other.toDecimal());
  }

  Decimal _moduloDecimal(Decimal other) {
    var n1 = compactedPrecision;
    var n2 = other.toDecimal().compactedPrecision;

    if (n1.precision == 0 && n2.precision == 0) {
      var moduloI = n1._n % n2._n;
      return moduloI.toDecimal();
    } else {
      var rounds = (n1 / n2).toDynamicInt();
      var modulo = n1 - (n2 * rounds);
      return modulo;
    }
  }

  @override
  Decimal operator -() => Decimal._(-_n, precision, _scale);

  @override
  DynamicInt operator <<(int shiftAmount) => toDynamicInt() << shiftAmount;

  @override
  DynamicInt operator >>(int shiftAmount) => toDynamicInt() >> shiftAmount;

  @override
  Decimal abs() => isNegative ? -this : this;

  @override
  bool equalsBigInt(BigInt n) {
    if (precision == 0) {
      return _n.equalsBigInt(n);
    } else {
      if (isDecimalPartZero) {
        var n1 = compactedPrecision;
        assert(n1.precision == 0);
        return n1.toBigInt() == n;
      } else {
        return false;
      }
    }
  }

  @override
  bool equalsInt(int n) {
    if (precision == 0) {
      return _n.equalsInt(n);
    } else {
      if (isDecimalPartZero) {
        var n1Dec = compactedPrecision;
        assert(n1Dec.precision == 0);
        var n1 = n1Dec.toDynamicInt();
        return n1.isSafeInteger
            ? n1.toInt() == n
            : n1.toBigInt() == BigInt.from(n);
      } else {
        return false;
      }
    }
  }

  @override
  bool equalsDynamicInt(DynamicInt other) {
    var n1 = compactedPrecision;
    return n1.precision == 0 && n1._n.equalsDynamicInt(other);
  }

  @override
  DynamicInt operator ~() => ~toDynamicInt();

  @override
  Decimal get sin => Decimal.fromDouble(math.sin(toDouble()));

  @override
  Decimal get cos => Decimal.fromDouble(math.cos(toDouble()));

  @override
  Decimal get square => this * this;

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

  @override
  Decimal power(DynamicNumber<dynamic> exponent) {
    if (exponent.isDecimal || exponent.isNegative) {
      return _powerDecimal(exponent.toDecimal()).toDecimal();
    } else {
      if (isDecimalPartZero) {
        return toDynamicInt().powerAsDynamicInt(exponent).toDecimal();
      } else {
        return _powerDynamicInt(exponent.toDynamicInt()).toDecimal();
      }
    }
  }

  @override
  Decimal powerAsDecimal(DynamicNumber<dynamic> exponent) {
    return exponent.isDecimal || exponent.isNegative
        ? _powerDecimal(exponent.toDecimal()).toDecimal()
        : _powerDynamicInt(exponent.toDynamicInt());
  }

  @override
  DynamicInt powerAsDynamicInt(DynamicNumber<dynamic> exponent) {
    if (exponent.isNegative) {
      throw UnsupportedError(
          'Negative exponent! Use `powerAsDecimal` for negative exponent support.');
    }

    if (exponent.isDecimal) {
      return _powerDecimal(exponent.toDecimal()).toDynamicInt();
    } else {
      return _powerDynamicInt(exponent.toDynamicInt()).toDynamicInt();
    }
  }

  DynamicNumber<dynamic> _powerDecimal(Decimal exponent) {
    if (exponent.isNegative) {
      return Decimal.one / _powerDecimal(-exponent);
    } else if (isZero) {
      return (exponent.isZero ? Decimal.one : this);
    }

    var e1 = exponent.compactedPrecision;

    return e1.isDecimalPartZero
        ? _powerDynamicInt(e1.toDynamicInt())
        : _powerDecimalImpl(exponent);
  }

  static final BigInt _bigIntTen = BigInt.from(10);

  Decimal _powerDecimalImpl(Decimal exponent) {
    var n1 = compactedPrecision.abs();

    var eWhole = exponent.wholePart;
    var eDecimal = exponent.decimalPartAsDouble;

    var partWhole = n1._powerDynamicInt(eWhole);

    var nSafe = n1;
    var nSafeScale = BigInt.one;

    while (nSafe.precision > 0 && !nSafe.toDynamicInt().isSafeInteger) {
      nSafe = nSafe.withPrecision(nSafe.precision - 1);
      nSafeScale *= _bigIntTen;
    }

    while (!nSafe.toDynamicInt().isSafeInteger) {
      nSafe = nSafe.divideBigInt(_bigIntTen);
      nSafeScale *= _bigIntTen;
    }

    if (!nSafe.toDynamicInt().isSafeInteger) {
      throw StateError('Number not safe to convert to double: $n1');
    }

    var partDecimal = math.pow(nSafe.toDouble(), eDecimal).toDouble();
    if (nSafeScale > BigInt.one) {
      partDecimal = partDecimal / math.pow(BigInt.one / nSafeScale, eDecimal);
    }

    var result = partWhole.multiplyDouble(partDecimal);
    return isNegative ? -result : result;
  }

  Decimal _powerDynamicInt(DynamicInt exponent) {
    var n1 = compactedPrecision;

    var powPrecision = exponent.multiplyInt(n1.precision);
    while (!powPrecision.isSafeInteger && n1.precision > 0) {
      n1 = n1.withPrecision(n1.precision - 1);
      powPrecision = exponent.multiplyInt(n1.precision);
    }

    var pow = n1._n.powerAsDynamicInt(exponent);
    return Decimal._computeScale(pow, powPrecision.toInt());
  }

  @override
  Decimal get squareRoot {
    var n1 = compactedPrecision;
    var precision2 = math.max(precision * 4, 15);
    n1 = n1.withPrecision(precision2);
    return n1._squareRoot();
  }

  Decimal _squareRoot() {
    var n = _n.multiplyDynamicInt(_scale);

    int c;

    // Significantly speed-up algorithm by proper select of initial approximation
    // As square root has 2 times less digits as original value
    // we can start with 2^(length of N1 / 2)
    var n0 =
        DynamicInt.two.powerAsDynamicInt((n.bitLength ~/ 2).toDynamicInt());

    // Value of approximate value on previous step
    var np = n;

    do {
      // next approximation step: n0 = (n0 + in/n0) / 2
      n0 = (n0 + (n ~/ n0)) ~/ DynamicInt.two;

      // compare current approximation with previous step
      c = np.compareTo(n0);

      // save value as previous approximation
      np = n0;

      // finish when previous step is equal to current
    } while (c != 0);

    var decimal = Decimal._computeScale(n0.toDynamicInt(), precision);
    decimal = decimal.compactedPrecision;

    return decimal;
  }
}

extension DecimalOnNumExtension on num {
  Decimal toDecimal() {
    var n = this;
    if (n is int) {
      return Decimal.fromInt(n);
    } else {
      return Decimal.fromDouble(n.toDouble());
    }
  }
}

extension DecimalOnDoubleExtension on double {
  Decimal toDecimal() => Decimal.fromDouble(this);
}

extension DecimalOnIntExtension on int {
  Decimal toDecimal() => Decimal.fromInt(this);
}

extension DecimalOnBigIntExtension on BigInt {
  Decimal toDecimal() => Decimal.fromBigInt(this);
}

extension DecimalOnIterableNumExtension on Iterable<num> {
  Iterable<Decimal> get asDecimal => map((e) => e.toDecimal());
}

extension DecimalOnIterableDoubleExtension on Iterable<double> {
  Iterable<Decimal> get asDecimal => map((e) => Decimal.fromDouble(e));
}

extension DecimalOnIterableIntExtension on Iterable<int> {
  Iterable<Decimal> get asDecimal => map((e) => Decimal.fromInt(e));
}

extension DecimalOnIterableBigIntExtension on Iterable<BigInt> {
  Iterable<Decimal> get asDecimal => map((e) => Decimal.fromBigInt(e));
}

extension DecimalOnIterableDecimalExtension on Iterable<Decimal> {
  StatisticsDynamicNumber<Decimal> get statistics =>
      StatisticsDynamicNumber<Decimal>.compute(this);

  /// Returns a [Statistics] of this numeric collection (with populated field [StatisticsDynamicNumber.data]).
  StatisticsDynamicNumber<Decimal> get statisticsWithData =>
      StatisticsDynamicNumber<Decimal>.compute(this, keepData: true);

  Iterable<DynamicInt> get asDynamicInt => map((e) => e.toDynamicInt());

  /// Returns the sum of this numeric collection.
  Decimal get sum {
    var itr = iterator;

    if (!itr.moveNext()) {
      return Decimal.zero;
    }

    var total = itr.current;

    while (itr.moveNext()) {
      total += itr.current;
    }

    return total;
  }

  /// Returns the sum of squares of this numeric collection.
  Decimal get sumSquares {
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
  List<Decimal> get squares => map((n) => n.square).toList();

  /// Returns the square roots of this numeric collection.
  List<Decimal> get squaresRoots => map((n) => n.squareRoot).toList();

  /// Returns the absolute values of this numeric collection.
  List<Decimal> get abs => map((n) => n.abs()).toList();
}

extension DecimalOnListNumExtension on List<num> {
  List<Decimal> toDecimalList({bool growable = true}) =>
      map((e) => e.toDecimal()).toList(growable: growable);
}

extension DecimalOnListDoubleExtension on List<double> {
  List<Decimal> toDecimalList({bool growable = true}) =>
      map((e) => Decimal.fromDouble(e)).toList(growable: growable);
}

extension DecimalOnListIntExtension on List<int> {
  List<Decimal> toDecimalList({bool growable = true}) =>
      map((e) => Decimal.fromInt(e)).toList(growable: growable);
}

extension DecimalOnListBigIntExtension on List<BigInt> {
  List<Decimal> toDecimalList({bool growable = true}) =>
      map((e) => Decimal.fromBigInt(e)).toList(growable: growable);
}

extension DecimalOnListDecimalExtension on List<Decimal> {
  List<DynamicInt> toDynamicIntList({bool growable = true}) =>
      map((e) => e.toDynamicInt()).toList(growable: growable);
}
