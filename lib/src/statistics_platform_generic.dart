import 'dart:typed_data';

import 'statistics_platform.dart';
import 'statistics_extension_num.dart';

class StatisticsPlatformGeneric extends StatisticsPlatform {
  StatisticsPlatformGeneric() : super.base();

  static final int _maxSafeInt = 9007199254740991;

  static final int _minSafeInt = -9007199254740991;

  @override
  int get maxSafeInt => _maxSafeInt;

  @override
  int get minSafeInt => _minSafeInt;

  @override
  int get safeIntBits => 53;

  @override
  bool get supportsFullInt64 => false;

  @override
  bool isSafeInteger(int n) {
    return n <= _maxSafeInt && n >= _minSafeInt;
  }

  @override
  void writeInt64(Uint8List out, int n, [int offset = 0]) =>
      writeUint64(out, n, offset);

  @override
  void writeUint64(Uint8List out, int n, [int offset = 0]) {
    if (n.isNegative) {
      if (n >= -0x80000000) {
        var data = out.asByteData();
        data.setUint32(offset, 0xFFFFFFFF);
        data.setUint32(offset + 4, n);
      } else {
        _writeUint64Impl(out, n, offset);
      }
    } else {
      if (n <= 0xFFFFFFFF) {
        var data = out.asByteData();
        data.setUint32(offset, 0);
        data.setUint32(offset + 4, n);
      } else {
        _writeUint64Impl(out, n, offset);
      }
    }
  }

  void _writeUint64Impl(Uint8List out, int n, [int offset = 0]) {
    checkSafeInteger(n);

    // Right shift operator (>>) will cast to 32 bits in JS:
    int n1;
    if (n.isNegative) {
      // Negative numbers division should round in the other direction:
      var d = (n / 0x100000000);
      var dN = d.toInt();
      var dF = d - dN;
      if (dF != 0) {
        --dN;
      }

      n1 = (dN & 0xFFFFFFFF);
    } else {
      n1 = ((n ~/ 0x100000000) & 0xFFFFFFFF);
    }

    var n2 = n & 0xFFFFFFFF;

    var buffer = out.asByteData();
    buffer.setUint32(offset, n1, Endian.big);
    buffer.setUint32(offset + 4, n2, Endian.big);
  }

  @override
  int readInt64(Uint8List out, [int offset = 0]) {
    var buffer = out.asByteData();

    var offsetN2 = offset + 4;

    var n1 = buffer.getUint32(offset);

    if (n1 == 0) {
      return buffer.getUint32(offsetN2);
    } else if (n1 == 0xFFFFFFFF) {
      var n2 = buffer.getInt32(offsetN2);
      var n = (-0x800000000 - 1) + ((0x800000001) + n2);

      // print('!!!!!!!!!>>>>>>>>> ${-0x800000000-1} + ${ 0x800000001 + n2 } >> ${ (-0x800000000-1).toHex64() } + ${ ( 0x800000001 + n2 ).toHex32() }');

      if (!n.isNegative) {
        var u = -0xFFFFFFFF - 1;
        n = u + n2;
        // print('!!A> $u > ${ u.toHex64() }');
        // print('!!B> $n > ${ n.toHex64() } > $n2');
      }

      // print('!!!!!!!!!>>>>>>>>> n: $n ');
      return n;
    } else if (n1 >= 0x80000000) {
      n1 = buffer.getInt32(offset);
      var n2 = buffer.getUint32(offsetN2);
      var n = (n1 * 0x100000000) + n2;
      //print('!!!!!!!!!>>>>>>>>> n: $n ${n.toHex64()} > n1: $n1 ${n1.toHex32()} > n2: $n2 ${n2.toHex32()} ');
      return n;
    } else {
      var n2 = buffer.getUint32(offsetN2);
      var n = (n1 * 0x100000000) + n2;
      return n;
    }
  }

  @override
  int readUint64(Uint8List out, [int offset = 0]) => readInt64(out, offset);
}

StatisticsPlatform createPlatformInstance() => StatisticsPlatformGeneric();
