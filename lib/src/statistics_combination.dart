import 'package:collection/collection.dart';

/// A combination cache. See [generateCombinations].
class CombinationCache<T, E> {
  final bool allowRepetition;
  final bool allowSharedCombinations;
  final Iterable<E> Function(T e)? mapper;
  final bool Function(List<E> combination)? validator;

  CombinationCache(
      {required this.allowRepetition,
      this.mapper,
      this.validator,
      this.allowSharedCombinations = false});

  final Map<_CombinationCacheKey<T>, List<List<E>>> _cache =
      <_CombinationCacheKey<T>, List<List<E>>>{};

  /// Returns the total number of combinations in the cache.
  int get totalCachedCombinations => _cache.length;

  /// Clears the combinations cache.
  void clear() => _cache.clear();

  /// Returns a cached combination or generates it.
  List<List<E>> getCombinations(
          Set<T> alphabet, int minimumSize, int maximumSize) =>
      _getCombinationsImpl(alphabet, minimumSize, maximumSize)
          .map((e) => e.toList())
          .toList();

  /// Same of [getCombinations], but the returned [List] won't be isolated from the
  /// cache (is the actual instance inside the cache).
  ///
  /// - [allowSharedCombinations] needs to be true, or a [StateError] will be thrown.
  ///
  /// - Note: any modification in the returned list can corrupt the combination
  ///   integrity for a future return of this cached combination cache.
  List<List<E>> getCombinationsShared(
      Set<T> alphabet, int minimumSize, int maximumSize) {
    if (!allowSharedCombinations) {
      throw StateError('Shared combinations not allowed: $this');
    }

    return _getCombinationsImpl(alphabet, minimumSize, maximumSize);
  }

  List<List<E>> _getCombinationsImpl(
      Set<T> alphabet, int minimumSize, int maximumSize) {
    return _cache.putIfAbsent(
        _CombinationCacheKey<T>(alphabet, minimumSize, maximumSize),
        () => _generateCombinationsImpl(alphabet, minimumSize, maximumSize));
  }

  int _computedCombinations = 0;

  /// Returns the number of computed combinations.
  ///
  /// - [clear] won't reset this value.
  int get computedCombinations => _computedCombinations;

  List<List<E>> _generateCombinationsImpl(
      Set<T> alphabet, int minimumSize, int maximumSize) {
    ++_computedCombinations;
    return generateCombinations(alphabet, minimumSize, maximumSize,
        allowRepetition: allowRepetition,
        checkAlphabet: false,
        mapper: mapper,
        validator: validator);
  }

  @override
  String toString() {
    return 'CombinationCache<$T,$E>{ allowRepetition: $allowRepetition, allowSharedCombinations: $allowSharedCombinations, cache: $totalCachedCombinations, computedCombinations: $_computedCombinations }';
  }
}

class _CombinationCacheKey<T> {
  final Set<T> _alphabet;

  final int _minimumSize;
  final int _maximumSize;

  late final int _alphabetHash = _setEquality.hash(_alphabet);

  _CombinationCacheKey(this._alphabet, this._minimumSize, this._maximumSize);

  static final _setEquality = SetEquality();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CombinationCacheKey &&
          runtimeType == other.runtimeType &&
          _minimumSize == other._minimumSize &&
          _maximumSize == other._maximumSize &&
          _setEquality.equals(_alphabet, other._alphabet);

  @override
  int get hashCode =>
      _alphabetHash ^ _minimumSize.hashCode ^ _maximumSize.hashCode;
}

/// Generate combinations using the [alphabet] elements.
///
/// - [alphabet] of possible elements per combination.
/// - The [minimumSize] of the generated combinations.
/// - The [maximumSize] of the generated combinations.
/// - If [allowRepetition] is `true` will allow the repetition of elements for each combination.
/// - If [checkAlphabet] is `true` it will check if the [alphabet] has duplicated elements.
/// - An optional [mapper] can be used to expand or map each [alphabet] element.
/// - An optional combination [validator].
/// - Note that an alphabet can't have duplicated elements.
List<List<E>> generateCombinations<T, E>(
    Iterable<T> alphabet, int minimumSize, int maximumSize,
    {bool allowRepetition = true,
    bool checkAlphabet = true,
    Iterable<E> Function(T e)? mapper,
    bool Function(List<E> combination)? validator}) {
  if (minimumSize < 1) minimumSize = 1;

  var combinations = <List<E>>[];
  if (alphabet.isEmpty || maximumSize <= 0) return combinations;

  if (alphabet is! List && alphabet is! Set) {
    alphabet = alphabet.toList();
  }

  if (checkAlphabet && alphabet is! Set<T>) {
    var set = alphabet.toSet();
    if (set.length != alphabet.length) {
      throw ArgumentError('Invalid alphabet: found duplicated element!');
    }
  }

  mapper ??= (e) => <E>[e as E];
  validator ??= (c) => true;

  if (allowRepetition) {
    for (var size = minimumSize; size <= maximumSize; ++size) {
      _fillWithRepetition<T, E>(
          alphabet, <E>[], size, combinations, mapper, validator);
    }
  } else {
    if (maximumSize > alphabet.length) {
      maximumSize = alphabet.length;
    }

    for (var size = minimumSize; size <= maximumSize; ++size) {
      _fillNoRepetition<T, E>(
          alphabet, <E>[], 0, size, combinations, mapper, validator);
    }
  }

  return combinations;
}

void _fillNoRepetition<T, E>(
    Iterable<T> alphabet,
    List<E> dst,
    int offset,
    int limit,
    List<List<E>> output,
    Iterable<E> Function(T e) mapper,
    bool Function(List<E> combination) validator) {
  var length = alphabet.length;

  for (var i = offset; i < length; ++i) {
    var e = alphabet.elementAt(i);

    var values = mapper(e);

    for (var v in values) {
      var dst2 = <E>[...dst, v];
      if (dst2.length < limit) {
        _fillNoRepetition(
            alphabet, dst2, i + 1, limit, output, mapper, validator);
      } else if (validator(dst2)) {
        output.add(dst2);
      }
    }
  }
}

void _fillWithRepetition<T, E>(
    Iterable<T> alphabet,
    List<E> dst,
    int limit,
    List<List<E>> output,
    Iterable<E> Function(T e) mapper,
    bool Function(List<E> combination) validator) {
  var length = alphabet.length;

  for (var i = 0; i < length; ++i) {
    var e = alphabet.elementAt(i);

    var values = mapper(e);

    for (var v in values) {
      var dst2 = <E>[...dst, v];
      if (dst2.length < limit) {
        _fillWithRepetition(alphabet, dst2, limit, output, mapper, validator);
      } else if (validator(dst2)) {
        output.add(dst2);
      }
    }
  }
}
