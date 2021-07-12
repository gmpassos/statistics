import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'statistics_extension_simd.dart';

/// [Equality] for [Int32x4].
class Int32x4Equality implements Equality<Int32x4> {
  @override
  bool equals(Int32x4 e1, Int32x4 e2) => e1.equalsValues(e2);

  @override
  int hash(Int32x4 e) =>
      e.x.hashCode ^ e.y.hashCode ^ e.z.hashCode ^ e.w.hashCode;

  @override
  bool isValidKey(Object? o) {
    return o is Int32x4;
  }
}

/// [Equality] for [Float32x4].
class Float32x4Equality implements Equality<Float32x4> {
  @override
  bool equals(Float32x4 e1, Float32x4 e2) => e1.equalsValues(e2);

  @override
  int hash(Float32x4 e) =>
      e.x.hashCode ^ e.y.hashCode ^ e.z.hashCode ^ e.w.hashCode;

  @override
  bool isValidKey(Object? o) {
    return o is Float32x4;
  }
}
