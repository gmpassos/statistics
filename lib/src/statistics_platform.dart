import 'dart:typed_data';

import 'statistics_platform_generic.dart'
    if (dart.library.io) 'statistics_platform_io.dart';

//import 'statistics_platform_generic.dart';
//import 'statistics_platform_io.dart';

abstract class StatisticsPlatform {
  static final StatisticsPlatform instance = createPlatformInstance();

  factory StatisticsPlatform() => instance;

  late final BigInt _maxSafeBigInt;

  late final BigInt _minSafeBigInt;

  StatisticsPlatform.base() {
    _maxSafeBigInt = BigInt.from(maxSafeInt);
    _minSafeBigInt = BigInt.from(minSafeInt);
  }

  int get maxSafeInt;

  int get minSafeInt;

  int get safeIntBits;

  bool get supportsFullInt64;

  bool isSafeInteger(int n);

  void checkSafeInteger(int n) {
    if (!isSafeInteger(n)) {
      throw StateError(_sageErrorMessage(n));
    }
  }

  bool isSafeIntegerByBigInt(BigInt n) {
    return n <= _maxSafeBigInt && n >= _minSafeBigInt;
  }

  void checkSafeIntegerByBigInt(BigInt n) {
    if (!isSafeIntegerByBigInt(n)) {
      throw StateError(_sageErrorMessage(n));
    }
  }

  String _sageErrorMessage(Object n) {
    var type = n is BigInt ? 'BigInt' : 'int';
    return '$type out of safe `int` range (platform with $safeIntBits bits precision): minSafe:$minSafeInt < n:$n < maxSafe:$maxSafeInt';
  }

  void writeUint64(Uint8List out, int n, [int offset = 0]);

  void writeInt64(Uint8List out, int n, [int offset = 0]);

  int readUint64(Uint8List out, [int offset = 0]);

  int readInt64(Uint8List out, [int offset = 0]);
}
