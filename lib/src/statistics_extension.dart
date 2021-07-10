import 'package:collection/collection.dart';

import 'statistics_base.dart';

/// extension for `List<T>`.
extension ListExtension<T> on List<T> {
  int get lastIndex => length - 1;

  T getReversed(int reversedIndex) => this[lastIndex - reversedIndex];

  T? getValueIfExists(int index) =>
      index >= 0 && index < length ? this[index] : null;

  int setAllWithValue(T n) {
    var lng = length;
    for (var i = 0; i < lng; ++i) {
      this[i] = n;
    }
    return lng;
  }

  int setAllWith(T Function(int index, T value) f) {
    var lng = length;
    for (var i = 0; i < lng; ++i) {
      this[i] = f(i, this[i]);
    }
    return lng;
  }

  int setAllWithList(List<T> list, [int offset = 0]) {
    var lng = length;
    for (var i = 0; i < lng; ++i) {
      this[i] = list[offset + i];
    }
    return lng;
  }

  bool allEquals(T element) {
    if (length == 0) return false;

    for (var e in this) {
      if (e != element) return false;
    }

    return true;
  }

  List<String> toStringElements() => map((e) => '$e').toList();

  int computeHashcode() {
    return ListEquality<T>().hash(this);
  }

  int ensureMaximumSize(int maximumSize,
      {bool removeFromEnd = false, int removeExtras = 0}) {
    var toRemove = length - maximumSize;
    if (toRemove <= 0) return 0;

    if (removeExtras > 0) {
      toRemove += removeExtras;
    }

    if (removeFromEnd) {
      return this.removeFromEnd(toRemove);
    } else {
      return removeFromBegin(toRemove);
    }
  }

  int removeFromBegin(int amount) {
    if (amount <= 0) return 0;
    var length = this.length;
    if (amount > length) amount = length;
    removeRange(0, amount);
    return amount;
  }

  int removeFromEnd(int amount) {
    if (amount <= 0) return 0;
    var length = this.length;
    if (amount > length) amount = length;
    removeRange(length - amount, length);
    return amount;
  }

  List<double> asDoubles() => this is List<double>
      ? this as List<double>
      : map((v) => parseDouble(v)!).toList();

  List<int> asInts() =>
      this is List<int> ? this as List<int> : map((v) => parseInt(v)!).toList();
}

/// extension for `Set<T>`.
extension SetExtension<T> on Set<T> {
  bool allEquals(T element) {
    if (length == 0) return false;

    for (var e in this) {
      if (e != element) return false;
    }

    return true;
  }

  List<String> toStringElements() => map((e) => '$e').toList();

  int computeHashcode() {
    return SetEquality<T>().hash(this);
  }
}

/// extension for `Iterable<T>`.
extension IterableExtension<T> on Iterable<T> {
  Map<G, List<T>> groupBy<G>(G Function(T e) grouper) {
    var groups = <G, List<T>>{};

    for (var e in this) {
      var g = grouper(e);
      var list = groups.putIfAbsent(g, () => <T>[]);
      list.add(e);
    }

    return groups;
  }
}

/// extension for [Duration].
extension DurationExtension on Duration {
  String toStringUnit({
    bool days = true,
    bool hours = true,
    bool minutes = true,
    bool seconds = true,
    bool milliseconds = true,
    bool microseconds = true,
  }) {
    if (days && inDays > 0) {
      return '$inDays d';
    } else if (hours && inHours > 0) {
      return '$inHours h';
    } else if (minutes && inMinutes > 0) {
      return '$inMinutes min';
    } else if (seconds && inSeconds > 0) {
      return '$inSeconds sec';
    } else if (milliseconds && inMilliseconds > 0) {
      return '$inMilliseconds ms';
    } else if (microseconds && inMicroseconds > 0) {
      return '$inMicroseconds μs';
    } else {
      return toString();
    }
  }
}
