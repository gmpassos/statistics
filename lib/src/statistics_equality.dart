import 'package:collection/collection.dart';

/// [Equality] for 'double'.
class DoubleEquality implements Equality<double> {
  @override
  bool equals(double e1, double e2) => e1 == e2;

  @override
  int hash(double e) => e.hashCode;

  @override
  bool isValidKey(Object? o) {
    return o is double;
  }
}

/// [Equality] for 'int'.
class IntEquality implements Equality<int> {
  @override
  bool equals(int e1, int e2) => e1 == e2;

  @override
  int hash(int e) => e.hashCode;

  @override
  bool isValidKey(Object? o) {
    return o is int;
  }
}

/// [Equality] for 'num'.
class NumEquality implements Equality<num> {
  @override
  bool equals(num e1, num e2) => e1 == e2;

  @override
  int hash(num e) => e.hashCode;

  @override
  bool isValidKey(Object? o) {
    return o is num;
  }
}
