import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'statistics_base.dart';
import 'statistics_extension_num.dart';

/// extension for `List<T>`.
extension ListExtension<T> on List<T> {
  /// The last index of this [List].
  int get lastIndex => length - 1;

  /// Returns the elements at [reversedIndex] (index: `[lastIndex - reversedIndex]`).
  T getReversed(int reversedIndex) => this[lastIndex - reversedIndex];

  /// Returns the element at [index]. Returns `null` if out of range.
  T? getValueIfExists(int index) =>
      index >= 0 && index < length ? this[index] : null;

  /// Set all elements of this instance with [value].
  int setAllWithValue(T value) {
    var lng = length;
    for (var i = 0; i < lng; ++i) {
      this[i] = value;
    }
    return lng;
  }

  /// Set all elements of this instance with values from [f].
  int setAllWith(T Function(int index, T value) f) {
    var lng = length;
    for (var i = 0; i < lng; ++i) {
      this[i] = f(i, this[i]);
    }
    return lng;
  }

  /// Set all elements of this instance with [list], starting from [list] [offset].
  int setAllWithList(List<T> list, [int offset = 0]) {
    var lng = length;
    for (var i = 0; i < lng; ++i) {
      this[i] = list[offset + i];
    }
    return lng;
  }

  /// Returns `true` if all elements are equals to [element].
  bool allEquals(T element) {
    if (length == 0) return false;

    for (var e in this) {
      if (e != element) return false;
    }

    return true;
  }

  /// Creates a new [List]<[String]>, mapping each element to a [String].
  List<String> toStringElements() => map((e) => '$e').toList();

  /// Computes the `hashcode` of this [List], using [ListEquality] defaults.
  int computeHashcode() {
    return ListEquality<T>().hash(this);
  }

  /// Ensures that this [List.length] is not bigger than [maximumSize].
  /// - [removeFromEnd] if `true`, removes from end (default: `false`).
  /// - [removeExtras] if > 0, removes some extra elements when [List.length] > [maximumSize].
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

  /// Remove an [amount] of elements from the beginning.
  int removeFromBegin(int amount) {
    if (amount <= 0) return 0;
    var length = this.length;
    if (amount > length) amount = length;
    removeRange(0, amount);
    return amount;
  }

  /// Remove an [amount] of elements from the end.
  int removeFromEnd(int amount) {
    if (amount <= 0) return 0;
    var length = this.length;
    if (amount > length) amount = length;
    removeRange(length - amount, length);
    return amount;
  }

  /// Returns this instance as a [List]<double>.
  /// If needed creates a new instance, calling [parseDouble] for each element.
  List<double> asDoubles() => this is List<double>
      ? this as List<double>
      : map((v) => parseDouble(v)!).toList();

  /// Returns this instance as a [List]<int>.
  /// If needed creates a new instance, calling [parseInt] for each element.
  List<int> asInts() =>
      this is List<int> ? this as List<int> : map((v) => parseInt(v)!).toList();

  /// Head of this [List] with [size].
  List<T> head(int size) => sublist(0, size);

  /// Tail of this [List] with [size].
  List<T> tail(int size) => sublist(length - size);

  /// Sames as [sublist], but with reversed parameters indexes [endReversed] and [startReversed].
  List<T> sublistReversed(int endReversed, [int? startReversed]) {
    var length = this.length;

    var start = startReversed == null ? 0 : length - startReversed;
    var end = length - endReversed;

    return sublist(start, end);
  }

  /// Returns the index to insert [key] and keep the [List] sorted.
  int searchInsertSortedIndex<E, K>(final T key,
      {int start = 0, int? end, Comparator<T>? compare}) {
    var idx = binarySearchPoint(key, start: start, end: end, compare: compare);
    return idx >= 0 ? idx : (-idx) - 1;
  }

  /// A binary search that returns:
  /// - Found [key]: returns the value index.
  /// - Not found [key]: returns `-n-1` if it was not found,
  ///   where `n` is the index of the first value higher than [key].
  int binarySearchPoint(T key,
      {int start = 0, int? end, Comparator<T>? compare}) {
    var low = start;
    var high = (end ?? length) - 1;

    compare = comparator(compare: compare, sample: key);

    while (low <= high) {
      var mid = (low + high) >> 1;
      var midVal = this[mid];

      var cmp = compare(midVal, key);

      if (cmp < 0) {
        low = mid + 1;
      } else if (cmp > 0) {
        high = mid - 1;
      } else {
        return mid; // key found
      }
    }

    return -(low + 1); // key not found.
  }

  /// Resample elements by index range ([RangeSelectionByIndex]).
  /// - [selector]: the index range selector of each element resample.
  /// - [merger]: the values merger.
  /// - [skipResampledIndexes]: if `true` skips indexes already selected by [selector].
  List<R> resampleByIndex<R>(
      RangeSelectorFunction<T, RangeSelectionByIndex<T>> selector,
      List<R> Function(List<T> sel) merger,
      {bool skipResampledIndexes = true}) {
    var length = this.length;

    var list = <R>[];

    var previous = RangeSelectionByIndex<T>.empty();

    for (var i = 0; i < length; ++i) {
      if (skipResampledIndexes && previous.isInRange(i)) {
        continue;
      }

      var selection = selector(this, previous, i);

      if (selection.isValid) {
        var sel = selection.select(this);
        var l = merger(sel);
        list.addAll(l);

        previous = selection;
      }
    }

    return list;
  }

  /// Resample elements by value range ([RangeSelectionByValue]).
  /// - [selector]: the value range selector of each element resample.
  /// - [merger]: the values merger.
  /// - [skipResampledIndexes]: if `true` skips indexes already selected by [selector].
  /// - [compare]: the comparator for [T].
  List<R> resampleByValue<R>(
      RangeSelectorFunction<T, RangeSelectionByValue<T>> selector,
      List<R> Function(List<T> sel) merger,
      {bool skipResampledIndexes = true,
      Comparator<T>? compare}) {
    var length = this.length;

    var list = <R>[];

    compare ??= comparator(compare: compare);

    var previous = RangeSelectionByValue<T>.empty();

    for (var i = 0; i < length; ++i) {
      if (skipResampledIndexes && previous.isInRangeOfLastSelection(i)) {
        continue;
      }

      var selection = selector(this, previous, i);

      if (selection.isValid) {
        var sel = selection.select(this, compare: compare);
        var l = merger(sel);
        list.addAll(l);

        previous = selection;
      }
    }

    return list;
  }
}

typedef RangeSelectorFunction<T, S extends RangeSelection<T>> = S Function(
    List<T> list, S previous, int cursor);

abstract class RangeSelection<T> {
  bool get isValid;

  List<T> select(List<T> l);
}

class RangeSelectionByIndex<T> implements RangeSelection<T> {
  final int start;

  final int end;

  RangeSelectionByIndex(this.start, this.end);

  RangeSelectionByIndex.empty() : this(-1, -1);

  @override
  bool get isValid => start >= 0 && start < end;

  bool isInRange(int index) {
    return isValid && index >= start && index < end;
  }

  @override
  List<T> select(List<T> l) {
    var start = this.start;
    var end = this.end;

    if (start < 0) start = 0;
    if (end > l.length) end = l.length;

    return l.sublist(start, end);
  }
}

class RangeSelectionByValue<T> implements RangeSelection<T> {
  final T? start;
  final bool startExclusive;

  final T? end;
  final bool endExclusive;

  RangeSelectionByValue(
      this.start, this.startExclusive, this.end, this.endExclusive);

  RangeSelectionByValue.empty() : this(null, false, null, false);

  @override
  bool get isValid => start != null && end != null;

  bool isGreaterThanStart(T value, {Comparator<T>? compare}) {
    compare ??= (dynamic a, T b) => a!.compareTo(b!) as int;

    var cmp = compare(start!, value);
    return startExclusive ? cmp < 0 : cmp <= 0;
  }

  bool isLesserThanEnd(T value, {Comparator<T>? compare}) {
    compare ??= (dynamic a, T b) => a!.compareTo(b!) as int;

    var cmp = compare(end!, value);
    return endExclusive ? cmp > 0 : cmp >= 0;
  }

  bool isValueInRange(T value, {Comparator<T>? compare}) =>
      isValid &&
      isGreaterThanStart(value, compare: compare) &&
      isLesserThanEnd(value, compare: compare);

  @override
  List<T> select(List<T> l, {Comparator<T>? compare}) {
    var start = this.start!;
    var end = this.end!;

    compare ??= l.comparator(compare: compare, sample: start);

    var startIdx = l.searchInsertSortedIndex(start, compare: compare);
    var endIdx = l.searchInsertSortedIndex(end, compare: compare);

    var length = l.length;

    while (startIdx > 0) {
      var val = l[startIdx];
      var prev = l[startIdx - 1];
      if (compare(val, prev) == 0) {
        startIdx--;
      } else {
        break;
      }
    }

    if (endIdx > 0 && endIdx < length) {
      var val = l[endIdx];
      if (compare(val, end) > 0) {
        endIdx--;
      }
    }

    while (endIdx < length - 1) {
      var val = l[endIdx];
      var next = l[endIdx + 1];
      if (compare(val, next) == 0) {
        endIdx++;
      } else {
        break;
      }
    }

    if (startExclusive) {
      while (startIdx < length) {
        var val = l[startIdx];
        if (compare(val, start) == 0) {
          startIdx++;
        } else {
          break;
        }
      }
    }

    if (startIdx >= length) return <T>[];

    if (endIdx < startIdx) {
      endIdx = startIdx;
    }

    if (endExclusive) {
      while (endIdx > 0 && endIdx < length) {
        var val = l[endIdx];
        if (compare(val, end) == 0) {
          endIdx--;
        } else {
          break;
        }
      }
    }

    if (endIdx < length) {
      endIdx++;
    }

    lastSelectStart = startIdx;
    lastSelectEnd = endIdx;

    return l.sublist(startIdx, endIdx);
  }

  int? lastSelectStart;

  int? lastSelectEnd;

  bool get hasLastSelection => lastSelectStart != null && lastSelectEnd != null;

  bool isInRangeOfLastSelection(int index) =>
      hasLastSelection && index >= lastSelectStart! && index < lastSelectEnd!;
}

/// extension for `Set<T>`.
extension SetExtension<T> on Set<T> {
  bool allEquals(T element) {
    if (length != 1) return false;
    return first == element;
  }

  /// Creates a new [List]<[String]>, mapping each element to a [String].
  List<String> toStringElements() => map((e) => '$e').toList();

  int computeHashcode() {
    return SetEquality<T>().hash(this);
  }
}

/// extension for `Iterable<T>`.
extension IterableExtension<T> on Iterable<T> {
  /// The last index of this [List].
  int get lastIndex => length - 1;

  /// Tries to returns a [Comparator<T>] for this instance.
  /// Validates [compare] if provided.
  Comparator<T> comparator({Comparator<T>? compare, T? sample}) {
    if (compare == null) {
      return (dynamic a, T b) => a.compareTo(b) as int;
    } else {
      return compare;
    }
  }

  /// Groups elements by [grouper].
  Map<G, List<T>> groupBy<G>(G Function(T e) grouper) {
    var groups = <G, List<T>>{};

    for (var e in this) {
      var g = grouper(e);
      var list = groups.putIfAbsent(g, () => <T>[]);
      list.add(e);
    }

    return groups;
  }

  /// Converts this [List] to a [Map].
  /// - [keyMapper] the [Function] that maps the keys.
  /// - [valueMapper] the [Function] that maps the values.
  Map<K, V> toMap<K, V>(
          K Function(T e) keyMapper, V Function(T e) valueMapper) =>
      Map.fromEntries(map((T e) {
        var k = keyMapper(e);
        var v = valueMapper(e);
        return MapEntry(k, v);
      }));

  /// Returns a [List]<String>. If this instance is not already a [List]<String>,
  /// creates a new instance, calling [toString] for each element.
  List<String> toStringsList() {
    if (this is List<String>) {
      return this as List<String>;
    } else {
      return map((e) => e.toString()).toList();
    }
  }

  /// Print the elements.
  /// - [printer] the printer function (default: [print]).
  /// - [prefix] the optional [String] prefix for each element.
  void printElements({Function(Object? o)? printer, String? prefix}) {
    printer ??= print;

    if (prefix != null) {
      for (var e in this) {
        printer('$prefix$e');
      }
    } else {
      for (var e in this) {
        printer(e);
      }
    }
  }
}

/// extension for `Map<K, Iterable<num>>`.
extension MapOfNumExtension<K, N extends num> on Map<K, Iterable<N>> {
  /// Returns a Map of [Statistics] for each entry of `[Iterable]<N>`.
  Map<K, Statistics<N>> get statistics =>
      map((key, n) => MapEntry(key, n.statistics));
}

/// extension for [Duration].
extension DurationExtension on Duration {
  /// The number of entire years (365 days) spanned by this [Duration].
  int get inYears => inDays ~/ 365;

  /// The number of entire years (365 days) spanned by this [Duration].
  /// Returns a double, with the partial year as decimal.
  double get inYearsAsDouble => inDays / 365;

  /// Format this [Duration] instance to a [String] with the best time unit for the value.
  ///
  /// - [days] if `true` allows `d` unit.
  /// - [hours] if `true` allows `h` unit.
  /// - [minutes] if `true` allows `min` unit.
  /// - [seconds] if `true` allows `sec` unit.
  /// - [milliseconds] if `true` allows `ms` unit.
  /// - [microseconds] if `true` allows `μs` unit.
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

/// Extension for [DateTime].
extension DateTimeExtension on DateTime {
  /// Formats to [format], using [DateFormat].
  String formatTo(String format, {String? locale}) =>
      DateFormat(format, locale).format(this);

  /// Formats to `yyyy-MM-dd`.
  String formatToYMD({String dateDelimiter = '-', String? locale}) =>
      DateFormat('yyyy${dateDelimiter}MM${dateDelimiter}dd', locale)
          .format(this);

  /// Formats to `yyyy-MM-dd HH:mm`.
  String formatToYMDHm(
          {String dateDelimiter = '-',
          String hourDelimiter = ':',
          String? locale}) =>
      DateFormat(
              'yyyy${dateDelimiter}MM${dateDelimiter}dd HH${hourDelimiter}mm',
              locale)
          .format(this);

  /// Formats to `yyyy-MM-dd HH:mm:ss`.
  String formatToYMDHms(
          {String dateDelimiter = '-',
          String hourDelimiter = ':',
          String? locale}) =>
      DateFormat(
              'yyyy${dateDelimiter}MM${dateDelimiter}dd HH${hourDelimiter}mm${hourDelimiter}ss',
              locale)
          .format(this);
}

/// Extension for `Map<K, V>`.
extension MapExtension<K, V> on Map<K, V> {
  /// Removes [keys] and return a [Map] with them.
  Map<K, V> removeKeysAndReturnValues(Iterable<K> keys) {
    var rms = <K, V>{};
    for (var k in keys) {
      var v = remove(k);
      if (v != null) {
        rms[k] = v;
      }
    }
    return rms;
  }

  /// Remove [keys].
  void removeKeys(Iterable<K> keys) {
    for (var k in keys) {
      remove(k);
    }
  }

  /// Only keep [keys], removing any key not in [keys] parameter.
  void keepKeys(Iterable<K> keys) {
    var rmKeys = getUnknownKeys(keys);
    removeKeys(rmKeys);
  }

  /// Only keep [keys], removing any key not in [keys] parameter, than return a [Map] with them.
  Map<K, V> keepKeysAndReturnValus(Iterable<K> keys) {
    var rmKeys = getUnknownKeys(keys);
    return removeKeysAndReturnValues(rmKeys);
  }

  /// Returns all unknown keys, not present at [knownKeys].
  List<K> getUnknownKeys(Iterable<K> knownKeys) {
    var rmKeys = <K>[];

    for (var k in keys) {
      if (!knownKeys.contains(k)) {
        rmKeys.add(k);
      }
    }

    return rmKeys;
  }

  /// Rename the keys using the [rename] mapper.
  void renameKeys(Map<K, K> rename) {
    for (var e in rename.entries) {
      var v = remove(e.key);
      if (v != null) {
        this[e.value] = v;
      }
    }
  }

  /// Filter [key] with [filter].
  bool filterKey(K key, V Function(V val) filter) {
    var v = this[key];

    if (v != null) {
      this[key] = filter(v);
      return true;
    } else {
      return false;
    }
  }

  /// Merge this instance with [other], merging keys values to a [List]<[V]>.
  /// See [mergeKeysValues].
  ///
  /// - [onAbsentKey] called when a key in this instance is not present in [other] instance (vice versa).
  Map<K, List<V>> mergeKeysValuesToList(Map<K, V> other,
          {V Function(K key, bool other)? onAbsentKey}) =>
      mergeKeysValues(other, (k, a, b) => [a, b], onAbsentKey: onAbsentKey);

  /// Same as [mergeKeysValuesToList], but allows `null` values.
  /// See [mergeKeysValues].
  Map<K, List<V?>> mergeKeysValuesToListNullable(Map<K, V> other) =>
      mergeKeysValuesNullable(other, (k, a, b) => [a, b]);

  /// Same as [mergeKeysValuesToList], but ignore `null` values.
  /// See [mergeKeysValues].
  Map<K, List<V>> mergeKeysValuesToListNoNulls(Map<K, V> other) =>
      mergeKeysValuesNullable(other, (k, a, b) {
        if (a != null) {
          return b != null ? [a, b] : [a];
        } else {
          return b != null ? [b] : [];
        }
      });

  /// Merge this instance with [other], calling [merger] for each key (of both [Map]s).
  ///
  /// - [onAbsentKey] called when a key in this instance is not present in [other] instance (vice versa).
  Map<K, M> mergeKeysValues<M>(
      Map<K, V> other, M Function(K key, V val1, V val2) merger,
      {V Function(K key, bool other)? onAbsentKey}) {
    var merge = <K, M>{};

    var allKeys = <K>{...keys, ...other.keys};

    for (var k in allKeys) {
      var v1 = this[k] ?? onAbsentKey!(k, false);
      var v2 = other[k] ?? onAbsentKey!(k, true);

      merge[k] = merger(k, v1, v2);
    }

    return merge;
  }

  /// Same as [mergeKeysValues], but allows `null` at [merger].
  Map<K, M> mergeKeysValuesNullable<M>(
      Map<K, V> other, M Function(K key, V? val1, V? val2) merger) {
    var merge = <K, M>{};

    var allKeys = <K>{...keys, ...other.keys};

    for (var k in allKeys) {
      var v1 = this[k];
      var v2 = other[k];

      merge[k] = merger(k, v1, v2);
    }

    return merge;
  }

  /// Returns the values for [keys] (in the same order).
  List<V> getValuesInKeysOrder(Iterable<K> keys) =>
      keys.map((k) => this[k]!).toList();

  /// Returns the values for [keys] (in the same order), using [getStringKeyValue].
  List<V> getValuesInStringKeysOrder(Iterable<String> keys) =>
      keys.map((k) => getStringKeyValue(k)!).toList();

  /// Returns a value by [String] [key], treating all this instance keys as [String].
  V? getStringKeyValue(String key) {
    var v = this[key];
    if (v != null) return v;

    for (var e in entries) {
      var kStr = e.key.toString();
      if (key == kStr) {
        return e.value;
      }
    }

    return null;
  }

  /// Returns `true` if [other] have [keys] of equals value.
  bool equalsKeysValues(Iterable<K> keys, Map<K, V> other) {
    for (var k in keys) {
      var v1 = this[k];
      var v2 = other[k];
      if (v1 != v2) {
        return false;
      }
    }
    return true;
  }

  /// Prints this [Map] entries to [printer],
  /// using [keyDelimiter] (`"$key$keyDelimiter$value"`) to map each entry to [String].
  ///
  /// - [printer] the printer [Function] (default: [print]).
  /// - [prefix] the prefix of each entry.
  /// - [keyDelimiter] the key/value delimiter (default: `': '`).
  void printElements(
      {Function(Object? o)? printer,
      String prefix = '',
      String keyDelimiter = ': '}) {
    printer ??= print;

    for (var e in entries) {
      printer('$prefix${e.key}$keyDelimiter${e.value}');
    }
  }
}

/// Extension for `List<Map<K, V>>`.
extension ListMapExtension<K, V> on List<Map<K, V>> {
  /// Sorts this [List]<[Map]>> by [key].
  ///
  /// - [compare] the optional key comparator.
  void sortByKey(K key, {Comparator<V>? compare}) {
    var comparator =
        compare ?? ((dynamic a, dynamic b) => a.compareTo(b) as int);

    sort((m1, m2) {
      var v1 = m1[key];
      var v2 = m2[key];
      if (v1 == null && v2 == null) {
        return 0;
      } else if (v1 == null) {
        return 1;
      } else if (v2 == null) {
        return -1;
      } else {
        return comparator(v1, v2);
      }
    });
  }
}

/// Extension for `Iterable<Map<K, V>>`.
extension IterableMapExtension<K, V> on Iterable<Map<K, V>> {
  /// Groups elements by [groupMapper].
  Map<G, List<Map<K, V>>> groupBy<G>(G Function(Map<K, V> e) groupMapper) {
    var map = <G, List<Map<K, V>>>{};

    for (var e in this) {
      var g = groupMapper(e);
      var list = map.putIfAbsent(g, () => <Map<K, V>>[]);
      list.add(e);
    }

    return map;
  }

  /// Returns a sorted List of this [Iterable]<[Map]>, sorting by [key].
  List<Map<K, V>> sortedByKey(K key, {Comparator<V>? compare}) {
    var l = List<Map<K, V>>.from(this);
    l.sortByKey(key);
    return l;
  }

  /// Groups by [key] of each element (a [Map]).
  Map<V, List<Map<K, V>>> groupByKey<G>(K key, {V? defaultKeyValue}) {
    var map = <V, List<Map<K, V>>>{};

    for (var e in this) {
      var g = (e[key] ?? defaultKeyValue)!;
      var list = map.putIfAbsent(g, () => <Map<K, V>>[]);
      list.add(e);
    }

    return map;
  }

  /// Returns the [key] value of each element (a [Map]).
  List<V> toKeyValues(K key, {V? defaultKeyValue}) =>
      map((e) => e[key] ?? defaultKeyValue!).toList();

  /// Same as [toKeyValues], but accepts null values.
  List<V?> toKeyValuesNullable(K key) => map((e) => e[key]).toList();

  /// Removes [keys] for each element (a [Map]).
  void removeKeys(Iterable<K> keys) {
    for (var e in this) {
      e.removeKeys(keys);
    }
  }

  /// Calls [keepKeys] for each element (A [Map]).
  void keepKeys(Iterable<K> keys) {
    for (var e in this) {
      e.keepKeys(keys);
    }
  }

  /// Removes keys for each element (a [Map]) using [rename] mapper.
  void renameKeys(Map<K, K> rename) {
    for (var e in this) {
      e.renameKeys(rename);
    }
  }

  /// Filter [key] for each element (a [Map]), using [filter].
  void filterKey(K key, V Function(V val) filter) {
    for (var e in this) {
      e.filterKey(key, filter);
    }
  }

  List<Map<K, List<V>>> mergeKeysValuesToList(Iterable<Map<K, V>> other,
          {V Function(K key, bool other)? onAbsentKey}) =>
      mergeKeysValues(other, (k, a, b) => [a, b], onAbsentKey: onAbsentKey);

  List<Map<K, M>> mergeKeysValues<M>(
      Iterable<Map<K, V>> other, M Function(K key, V val1, V val2) merger,
      {V Function(K key, bool other)? onAbsentKey}) {
    var length = math.max(this.length, other.length);

    var list = <Map<K, M>>[];
    for (var i = 0; i < length; ++i) {
      if (i < this.length && i < other.length) {
        var m1 = elementAt(i);
        var m2 = other.elementAt(i);
        var merged = m1.mergeKeysValues(m2, merger, onAbsentKey: onAbsentKey);
        list.add(merged);
      } else if (i < this.length) {
        var m1 = elementAt(i);
        var m2 = <K, V>{};
        var merged = m1.mergeKeysValues(m2, merger, onAbsentKey: onAbsentKey);
        list.add(merged);
      } else if (i < other.length) {
        var m1 = <K, V>{};
        var m2 = other.elementAt(i);
        var merged = m1.mergeKeysValues(m2, merger, onAbsentKey: onAbsentKey);
        list.add(merged);
      }
    }

    return list;
  }
}

/// Extension for `Iterable<Iterable<T>>`.
extension IterableIterableExtension<T> on Iterable<Iterable<T>> {
  /// Converts this [Iterable]<[Iterable]<[T]>> (a list of values) to a [List]<[Map]<[K], [V]>>.
  ///
  /// - [keys] the keys of the values, in the same order.
  /// - [useHeaderLine] uses the [first] line as header, for the [keys] of the values.
  /// - [keepKeys] an options list of keys to keep (will remove keys not present at [keepKeys]).
  /// - [filter] a filter each resulting [Map] entry. Should return `true` for valid entries.
  List<Map<K, V>> toKeysMap<K, V>({
    List<K>? keys,
    bool useHeaderLine = false,
    Iterable<K>? keepKeys,
    bool Function(Map<K, V> map)? filter,
  }) {
    var lines = this;

    if (keys == null && useHeaderLine) {
      var header = first;
      keys = header.cast<K>().toList();
      lines = skip(1);
    }

    if (keys == null) {
      throw ArgumentError("Can't determine keys!");
    }

    var keysResolved = keys;

    if (keepKeys != null && keepKeys.isNotEmpty) {
      var keepKeysResolved = keepKeys.length > 10 && keepKeys is! Set
          ? keepKeys.toSet()
          : keepKeys;

      return lines
          .map((cols) {
            var m = <K, V>{};
            for (var i = 0; i < cols.length; ++i) {
              var v = cols.elementAt(i);
              var k = keysResolved[i];
              if (keepKeysResolved.contains(k)) {
                m[k] = v as V;
              }
            }
            return filter == null || filter(m) ? m : null;
          })
          .whereType<Map<K, V>>()
          .toList();
    } else {
      return lines
          .map((cols) {
            var m = <K, V>{};
            for (var i = 0; i < cols.length; ++i) {
              var v = cols.elementAt(i);
              var k = keysResolved[i];
              m[k] = v as V;
            }
            return filter == null || filter(m) ? m : null;
          })
          .whereType<Map<K, V>>()
          .toList();
    }
  }
}

typedef _StringFilter = String Function(String line);

RegExp _regexpLineBreak = RegExp(r'[\r\n]');

/// Extension for [String].
extension StringExtension on String {
  /// Splits this [String] lines.
  ///
  /// - [lineDelimiter] the line delimiter [Pattern]. (default: `[\r\n]`).
  /// - [trimLines] if `true` trims lines.
  /// - [removeEmptyLines] if `true` removes empty lines.
  /// - [filter] the filter to apply for each line.
  List<String> splitLines(
      {RegExp? lineDelimiter,
      bool trimLines = true,
      bool removeEmptyLines = true,
      _StringFilter? filter}) {
    var lines = split(lineDelimiter ?? _regexpLineBreak);

    return lines.filterLines(
        trimLines: trimLines,
        removeEmptyLines: removeEmptyLines,
        filter: filter);
  }

  /// Splits this [String] in columns.
  ///
  /// - [delimiter] the column delimiter [Pattern]. (default: `,`).
  /// - [acceptsQuotedValues] if `true` accepts values in quotes: `"some value"`
  List<String> splitColumns(
      {Pattern delimiter = ',', bool acceptsQuotedValues = true}) {
    if (!acceptsQuotedValues) {
      return split(delimiter);
    }
    return _splitColumnsWithQuotedValues(this, delimiter, null);
  }

  /// Returns `true` if this [String] [contains] any element of [others].
  bool containsAny(Iterable<String> others) {
    for (var s in others) {
      if (contains(s)) {
        return true;
      }
    }
    return false;
  }
}

RegExp _toRegExpDelimiter(Pattern delimiter) {
  if (delimiter is RegExp) {
    return RegExp(
        '(?:"(.*?)"(?:(${delimiter.pattern})|\$)|(?:(${delimiter.pattern})|\$))',
        multiLine: false);
  } else {
    var spaced = RegExp.escape(delimiter.toString());
    return RegExp('(?:"(.*?)"(?:($spaced)|\$)|(?:($spaced)|\$))',
        multiLine: false);
  }
}

List<String> _splitColumnsWithQuotedValues(
    String s, Pattern delimiter, RegExp? reDelimiter) {
  if (delimiter is String) {
    return _splitColumnsWithQuotedValuesString(s, delimiter);
  } else {
    return _splitColumnsWithQuotedValuesRegexp(s, delimiter, reDelimiter);
  }
}

List<String> _splitColumnsWithQuotedValuesString(String s, String delimiter) {
  var length = s.length;
  var lengthM1 = length - 1;
  var delimiterLng = delimiter.length;
  var quoteDelimiter = '"$delimiter';
  var quoteDelimiterLng = quoteDelimiter.length;
  var endsWithQuote = s.endsWith('"');

  var cols = <String>[];
  var init = 0;

  while (init <= length) {
    if (init >= length) {
      cols.add('');
      break;
    }
    var c = s[init];
    if (c == '"') {
      var quoteEnd = s.indexOf(quoteDelimiter, init + 1);

      if (quoteEnd > 0) {
        var val = s.substring(init + 1, quoteEnd);
        val = _normalizeQuotedValue(val);

        if (quoteEnd + quoteDelimiterLng == length) {
          cols.add(val);
          cols.add('');
          break;
        } else {
          cols.add(val);
          init = quoteEnd + quoteDelimiterLng;
        }
      } else if (endsWithQuote) {
        var val = s.substring(init + 1, lengthM1);
        val = _normalizeQuotedValue(val);
        cols.add(val);
        break;
      } else {
        var idx = s.indexOf(delimiter, init);
        if (idx >= 0) {
          var val = s.substring(init, idx);
          cols.add(val);
          init = idx + delimiterLng;
        } else {
          var val = s.substring(init);
          cols.add(val);
          break;
        }
      }
    } else {
      var idx = s.indexOf(delimiter, init);
      if (idx >= 0) {
        var val = s.substring(init, idx);
        cols.add(val);
        init = idx + delimiterLng;
      } else {
        var val = s.substring(init);
        cols.add(val);
        break;
      }
    }
  }

  return cols;
}

String _normalizeQuotedValue(String s) {
  var idx = s.indexOf('""', 0);
  if (idx < 0) return s;

  var str = StringBuffer();
  str.write(s.substring(0, idx));
  str.write('"');

  var init = idx + 2;
  while (true) {
    idx = s.indexOf('""', init);
    if (idx < 0) {
      str.write(s.substring(init));
      break;
    } else {
      if (idx > init) {
        str.write(s.substring(init, idx));
      }
      str.write('"');
      init = idx + 2;
    }
  }

  return str.toString();
}

List<String> _splitColumnsWithQuotedValuesRegexp(
    String s, Pattern delimiter, RegExp? reDelimiter) {
  var cols = <String>[];
  var init = 0;

  var length = s.length;

  reDelimiter ??= _toRegExpDelimiter(delimiter);

  for (var m in reDelimiter.allMatches(s)) {
    var quoted = m.group(1);

    var atEnd = m.end == length;
    var withDelimiter = m.group(2) != null || m.group(3) != null;

    if (quoted != null) {
      quoted = _normalizeQuotedValue(quoted);
      cols.add(quoted);
      if (atEnd) {
        if (withDelimiter) {
          cols.add('');
        }
        break;
      }
    } else {
      var v = s.substring(init, m.start);

      if (atEnd) {
        cols.add(v);
        if (withDelimiter) {
          cols.add('');
        }
        break;
      } else {
        cols.add(v);
      }
    }

    init = m.end;
  }

  return cols;
}

/// Extension for `Iterable<String>`.
extension IterableStringExtension on Iterable<String> {
  List<String> splitLines(
      {RegExp? lineDelimiter,
      bool trimLines = true,
      bool removeEmptyLines = true,
      _StringFilter? filter}) {
    var resolvedLineDelimiter = lineDelimiter ?? _regexpLineBreak;
    var lines = expand((e) => e.split(resolvedLineDelimiter));

    return lines.filterLines(
        trimLines: trimLines,
        removeEmptyLines: removeEmptyLines,
        filter: filter);
  }

  List<String> filterLines(
      {bool trimLines = true,
      bool removeEmptyLines = true,
      _StringFilter? filter}) {
    var lines = this;

    if (trimLines) {
      lines = lines.map((e) => e.trim());
    }

    if (removeEmptyLines) {
      lines = lines.where((e) => e.isNotEmpty);
    }

    if (filter != null) {
      lines = lines.map((e) => filter(e));
    }

    return lines.toList();
  }

  List<List<String>> splitColumns(
      {Pattern delimiter = ',', bool acceptQuotedValues = true}) {
    if (!acceptQuotedValues) {
      return map((e) => e.split(delimiter)).toList();
    }

    var reDelimiter = _toRegExpDelimiter(delimiter);
    return map((e) => _splitColumnsWithQuotedValues(e, delimiter, reDelimiter))
        .toList();
  }

  List<int> toIntsList() => map((e) => int.parse(e)).toList();

  List<double> toDoublesList() => map((e) => double.parse(e)).toList();

  List<num> toNumsList() => map((e) => num.parse(e)).toList();
}

/// Extension for `Iterable<Statistics>`.
extension IterableStatisticsExtension<N extends num>
    on Iterable<Statistics<N>> {
  /// Returns the mean of the [Statistics] elements of this collection.
  Statistics<double> get statisticsMean {
    var sum = reduce((value, element) {
      var s = value.sumWith(element).cast<N>();
      return s;
    });
    var mean = sum.divideBy(length);
    return mean;
  }
}
