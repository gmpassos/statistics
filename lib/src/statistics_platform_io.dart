import 'dart:typed_data';

import 'statistics_platform.dart';
import 'statistics_extension_num.dart';

class StatisticsPlatformIO extends StatisticsPlatform {
  StatisticsPlatformIO() : super.base();

  static final int _maxSafeInt = 9223372036854775807;

  static final int _minSafeInt = -9223372036854775808;

  @override
  int get maxSafeInt => _maxSafeInt;

  @override
  int get minSafeInt => _minSafeInt;

  @override
  int get safeIntBits => 64;

  @override
  bool get supportsFullInt64 => true;

  @override
  bool isSafeInteger(int n) => true;

  @override
  void writeUint64(Uint8List out, int n, [int offset = 0]) {
    out.asByteData().setUint64(offset, n, Endian.big);
  }

  @override
  void writeInt64(Uint8List out, int n, [int offset = 0]) {
    out.asByteData().setInt64(offset, n, Endian.big);
  }

  @override
  int readUint64(Uint8List out, [int offset = 0]) {
    return out.asByteData().getUint64(offset, Endian.big);
  }

  @override
  int readInt64(Uint8List out, [int offset = 0]) {
    return out.asByteData().getInt64(offset, Endian.big);
  }
}

StatisticsPlatform createPlatformInstance() => StatisticsPlatformIO();
