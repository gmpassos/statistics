import 'package:intl/intl.dart';

import 'statistics_extension.dart';

/// A Chronometer useful for benchmarks.
class Chronometer implements Comparable<Chronometer> {
  /// The name/title of this chronometer.
  String name;

  Chronometer([this.name = 'Chronometer']);

  Chronometer._(this.name, this.operations, this.failedOperations,
      this._startTime, this._stopTime);

  DateTime? _startTime;

  /// The start [DateTime] of this chronometer.
  DateTime? get startTime => _startTime;

  /// Starts the chronometer.
  Chronometer start() {
    _startTime = DateTime.now();
    return this;
  }

  bool get isStarted => _startTime != null;

  DateTime? _stopTime;

  /// The stop [DateTime] of this chronometer.
  DateTime? get stopTime => _stopTime;

  /// Stops the chronometer.
  Chronometer stop({int? operations, int? failedOperations}) {
    _stopTime = DateTime.now();

    if (operations != null) {
      this.operations = operations;
    }

    if (failedOperations != null) {
      this.failedOperations = failedOperations;
    }

    return this;
  }

  bool get isFinished => _stopTime != null && isStarted;

  /// Elapsed time in milliseconds ([stopTime] - [startTime]).
  int get elapsedTimeMs {
    var startTime = _startTime;
    if (startTime == null) {
      return 0;
    }

    var stopTime = _stopTime;

    return stopTime == null
        ? (DateTime.now().millisecondsSinceEpoch -
            startTime.millisecondsSinceEpoch)
        : (stopTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch);
  }

  /// Elapsed time in seconds ([stopTime] - [startTime]).
  double get elapsedTimeSec => elapsedTimeMs / 1000;

  /// Elapsed time ([stopTime] - [startTime]).
  Duration get elapsedTime => Duration(milliseconds: elapsedTimeMs);

  /// Operations performed while this chronometer was running.
  /// Used to compute [hertz].
  int operations = 0;

  /// Failed operations performed while this chronometer was running.
  int failedOperations = 0;

  /// Returns the [operations] hertz:
  /// The average operations per second of
  /// the period ([elapsedTimeSec]) of this chronometer.
  double get hertz => computeHertz(operations);

  String get hertzAsString => '${_formatNumber(hertz)} Hz';

  String get operationsAsString => _formatNumber(operations);

  String get failedOperationsAsString => _formatNumber(failedOperations);

  static final NumberFormat _numberFormatDecimal =
      NumberFormat.decimalPattern('en_US');

  String _formatNumber(num n) {
    var s = n.isFinite && n > 10000
        ? _numberFormatDecimal.format(n.toInt())
        : _numberFormatDecimal.format(n);
    return s;
  }

  /// Computes hertz for n [operations].
  double computeHertz(int operations) {
    return operations / elapsedTimeSec;
  }

  /// Resets this chronometer for a future [start] and [stop].
  void reset() {
    _startTime = null;
    _stopTime = null;
    operations = 0;
  }

  /// Returns a [String] with information of this chronometer:
  /// Example:
  /// ```
  ///   Backpropagation{elapsedTime: 2955 ms, hertz: 2030456.8527918782 Hz, ops: 6000000, startTime: 2021-04-30 22:16:54.437147, stopTime: 2021-04-30 22:16:57.392758}
  /// ```
  @override
  String toString() {
    return '$name{ elapsedTime: $elapsedTimeMs ms'
        ', hertz: $hertzAsString'
        ', ops: $operationsAsString${failedOperations != 0 ? ' (fails: $failedOperationsAsString)' : ''}'
        ', startTime: $_startTime .. +${elapsedTime.toStringUnit()} }';
  }

  Chronometer operator +(Chronometer other) {
    DateTime? end;
    if (_stopTime != null && other._stopTime != null) {
      end = _stopTime!.add(other.elapsedTime);
    } else if (_stopTime != null) {
      end = _stopTime;
    } else if (other._stopTime != null) {
      end = other._stopTime;
    }

    return Chronometer._(name, operations + other.operations,
        failedOperations + other.failedOperations, _startTime, end);
  }

  @override
  int compareTo(Chronometer other) => hertz.compareTo(other.hertz);
}
