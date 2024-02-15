import 'statistics_tools.dart';

typedef BenchMarkFunction<R> = BenchmarkFunctionResult<R> Function(int loops);

/// Performas a benchmark of a [set] of [BenchMarkFunction]s.
List<BenchmarkResult<R>> benchmarkSet<R>(
    int loops, Map<String, BenchMarkFunction<R>> set) {
  var results = set.entries.map((e) {
    var result = benchmark(e.key, loops, e.value);
    return result;
  }).toList();
  results.sort();
  return results;
}

/// Performas a benchmark of [BenchMarkFunction] [f].
BenchmarkResult<R> benchmark<R>(String name, int loops, BenchMarkFunction<R> f,
    {bool verbose = false, Function(Object? o)? printer}) {
  var chronometer = BenchmarkResult<R>(name)..start();
  var result = f(loops);
  chronometer.stop(operations: result.operations);
  chronometer._result = result.result;

  if (verbose) {
    if (printer != null) {
      printer(chronometer);
    } else {
      print(chronometer);
    }
  }

  return chronometer;
}

class BenchmarkResult<R> extends Chronometer {
  late R _result;

  BenchmarkResult(super.name);

  R get result => _result;

  Duration get duration => elapsedTime;

  @override
  String toString({bool withStartTime = true}) {
    var s = super.toString(withStartTime: withStartTime);
    return '$s -> $result';
  }
}

class BenchmarkFunctionResult<R> {
  final int operations;
  final R result;

  BenchmarkFunctionResult(this.operations, this.result);
}
