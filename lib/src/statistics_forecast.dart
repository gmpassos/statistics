import 'dart:math' show Random;

import 'package:collection/collection.dart';

import 'statistics_bayesnet.dart';
import 'statistics_combination.dart';
import 'statistics_extension.dart';

typedef ForecastConclusionListener<T, V> = void Function(T source,
    List<ForecastObservation<T, V>>? observations, String event, V conclusion);

/// A Probabilistic Forecast producer base class.
abstract class EventForecaster<T, V, F> {
  final BayesEventMonitor eventMonitor;

  final int maxDependencyLevel;
  final double dependencyNotificationRatio;

  final Random _random;

  EventForecaster.withEventMonitor(this.eventMonitor,
      {this.maxDependencyLevel = 2,
      this.dependencyNotificationRatio = 0.50,
      Random? random})
      : _random = random ?? Random();

  EventForecaster(String name,
      {this.maxDependencyLevel = 2,
      this.dependencyNotificationRatio = 0.50,
      Random? random})
      : eventMonitor = BayesEventMonitor(name),
        _random = random ?? Random();

  final Map<String, List<ObservationOperation<T, V>>> _operations =
      <String, List<ObservationOperation<T, V>>>{};

  /// The [ObservationOperation] [List] for [phase].
  List<ObservationOperation<T, V>> getPhaseOperations(String phase) =>
      _operations.putIfAbsent(
          phase, () => generatePhaseOperations(phase).toList());

  /// Generates the operations for [phase].
  Iterable<ObservationOperation<T, V>> generatePhaseOperations(String phase);

  final Map<String, List<ForecastObservation<T, V>>> _phasesObservations =
      <String, List<ForecastObservation<T, V>>>{};

  /// Disposes all the non-concluded observations of all phases.
  ///
  /// See [concludeObservations].
  void disposeObservations() {
    _phasesObservations.clear();
  }

  /// Observe [source] for [phase]. Calls [getPhaseOperations] to generated
  /// the observations.
  List<ForecastObservation<T, V>> observe(source, {String phase = ''}) {
    var operations = getPhaseOperations(phase);

    var observations = operations.map((op) {
      var value = op.compute(source);
      return ForecastObservation<T, V>(phase, source, op, value);
    }).toList();

    var phaseObs = _phasesObservations.putIfAbsent(
        phase, () => <ForecastObservation<T, V>>[]);
    phaseObs.addAll(observations);

    return observations;
  }

  /// Returns all the non-concluded observations of all phases.
  List<ForecastObservation<T, V>> get allObservations =>
      _phasesObservations.values.expand((e) => e).toList();

  /// Selects the non-concluded observations that matches the criteria:
  /// - If [phases] is define selects only for observations of [phases]. (Overrides [allPhases]).
  /// - If [allPhases] is `true` selects all observations of all phases.
  /// - If [source] is defined will selects only observations for [source].
  ///
  /// See [concludeObservations].
  List<ForecastObservation<T, V>> selectedObservations(
      {Iterable<String>? phases, bool allPhases = false, T? source}) {
    Iterable<ForecastObservation<T, V>> selector;

    if (phases != null) {
      var phasesSet = phases is Set<String> ? phases : phases.toSet();
      selector = phasesSet.expand(
          (p) => _phasesObservations[p] ?? <ForecastObservation<T, V>>[]);
    } else {
      if (allPhases || source != null) {
        selector = _phasesObservations.values.expand((e) => e);
      } else {
        return <ForecastObservation<T, V>>[];
      }
    }

    if (source != null) {
      selector = selector.where((o) => o.source == source);
    }

    return selector.toList();
  }

  /// Removes [observation] of the non-concluded list.
  ///
  /// See [concludeObservations].
  void removeObservation(ForecastObservation<T, V> observation) {
    var phase = _phasesObservations[observation.phase];
    if (phase != null) {
      phase.remove(observation);
    }
  }

  /// Removes [observations] of the non-concluded list.
  ///
  /// See [concludeObservations].
  void removeObservations(List<ForecastObservation<T, V>> observations) {
    var observationsByPhase = observations.groupBy((e) => e.phase);

    for (var e in observationsByPhase.entries) {
      var phase = _phasesObservations[e.key];
      if (phase == null) continue;

      var list = e.value;
      phase.removeAll(list);
    }
  }

  final CombinationCache<String, String> _combinationCache =
      CombinationCache<String, String>(
          allowRepetition: false, allowSharedCombinations: true);

  /// Concludes observations for [source] with [value].
  ///
  /// - If [phases] is provided, concludes only for observations in [phases].
  List<ForecastObservation<T, V>> concludeObservations(
      T source, Map<String, V> conclusions,
      {List<String>? phases}) {
    var selectedObservations =
        this.selectedObservations(phases: phases, source: source);

    Map<String, ForecastObservation<T, V>> observationsByID;
    List<List<String>> dependencies;

    if (dependencyNotificationRatio > 0) {
      observationsByID =
          Map.fromEntries(selectedObservations.map((e) => MapEntry(e.id, e)));

      var ids = observationsByID.keys.toSet();
      dependencies = ids.isEmpty
          ? <List<String>>[]
          : _combinationCache.getCombinationsShared(ids, 2, maxDependencyLevel);
    } else {
      observationsByID = <String, ForecastObservation<T, V>>{};
      dependencies = <List<String>>[];
    }

    for (var e in conclusions.entries) {
      var event = e.key;
      var value = e.value;

      for (var o in selectedObservations) {
        _notifyConclusion(source, [o], event, value);
      }

      for (var combination in dependencies) {
        if (dependencyNotificationRatio >= 1 ||
            _random.nextDouble() < dependencyNotificationRatio) {
          var dependentObservations =
              combination.map((id) => observationsByID[id]).nonNulls;

          _notifyConclusion(source, dependentObservations, event, value,
              dependency: true);
        }
      }

      _notifyConclusion(source, null, event, value);
    }

    removeObservations(selectedObservations);

    return selectedObservations;
  }

  /// Performes a forecast over [source]. Calls [computeForecast] with the selected
  /// observations.
  ///
  /// - If [phase] is defined, it will make a forecast for this phase.
  /// - If [previousPhases] is defined the observations for this [source] in
  ///   the [previousPhases]es will be selected too.
  F forecast(T source, {String phase = '', Iterable<String>? previousPhases}) {
    List<ForecastObservation<T, V>> observations =
        observe(source, phase: phase);

    if (previousPhases != null && previousPhases.isNotEmpty) {
      var selPhases = {phase, ...previousPhases};

      if (selPhases.length > 1) {
        observations = selectedObservations(phases: selPhases, source: source);
      }
    }

    var f = computeForecast(phase, observations);
    return f;
  }

  F computeForecast(String phase, List<ForecastObservation<T, V>> observations);

  ForecastConclusionListener<T, V>? conclusionListener;

  void _notifyConclusion(
      T source,
      Iterable<ForecastObservation<T, V>>? observations,
      String event,
      V conclusion,
      {bool dependency = false}) {
    var eventValues = {
      if (observations != null && observations.isNotEmpty)
        ...observations.map((o) =>
            ObservedEventValue(o.id, o.value!, networkCache: eventMonitor)),
      ObservedEventValue(event, conclusion!, networkCache: eventMonitor)
    };

    if (dependency) {
      var dependentVariables = observations?.map((o) => o.id).toList();
      if (dependentVariables == null || dependentVariables.length < 2) {
        throw StateError(
            "Dependency requires at least 2 variables: $dependentVariables");
      }

      eventMonitor.notifyDependency(dependentVariables, eventValues);
    } else {
      eventMonitor.notifyEvent(eventValues);
    }

    var conclusionListener = this.conclusionListener;
    if (conclusionListener != null) {
      conclusionListener(source, observations?.toList(), event, conclusion);
    }
  }
}

typedef OperationComputer<T, V> = V Function(T source);

/// A Forecast observation operation over source [T] that produces value [V].
class ObservationOperation<T, V> {
  static final RegExp _regExpNonWord = RegExp(r'\W+');

  /// Normalizes the [id].
  ///
  /// Substitutes `\W` by `_` (trimmed).
  static String normalizeID(String id) {
    id = id.replaceAll(_regExpNonWord, '_');
    if (id.startsWith('_')) id = id.substring(1);
    if (id.endsWith('_')) id = id.substring(0, id.length - 1);
    return id;
  }

  /// Operation ID.
  final String id;

  /// Operation description.
  final String description;

  /// The [Function] that computes the operation.
  final OperationComputer<T, V>? computer;

  ObservationOperation(String id, {this.computer, this.description = ''})
      : id = normalizeID(id);

  V compute(T source) => computer!(source);

  @override
  String toString() {
    var descriptionStr =
        description.isNotEmpty ? ', description: $description' : '';
    return 'ForecastOperation{id: $id$descriptionStr}';
  }
}

/// A Forecast value [V] observation over [source] [T].
class ForecastObservation<T, V> {
  /// The forecast phase.
  final String phase;

  /// The source of the [value] observed.
  final T source;

  /// The operation performed over [source] to produce the observed [value].
  final ObservationOperation<T, V> operation;

  /// The value observed during a forecast performed over [source].
  final V value;

  ForecastObservation(this.phase, this.source, this.operation, this.value);

  /// The [operation.id].
  String get opID => operation.id;

  String? _id;

  /// ID of the observation.
  ///
  /// It's the [opID] prefixed with the [phase] (if the [phase] is not empty).
  String get id => _id ??= phase.isNotEmpty ? '$phase.$opID' : opID;

  @override
  String toString() {
    var phaseStr = phase.isNotEmpty ? '$phase.' : '';
    return '$phaseStr${operation.id}($source) -> $value';
  }
}

extension ListForecastObservationExtension<T, V>
    on List<ForecastObservation<T, V>> {
  /// Gets an observation by operation ID [opID].
  ///
  /// - If [opIdAlreadyNormalized] is `true` own't normalize [opID].
  ForecastObservation<T, V>? getByOpID(String opID,
      {bool opIdAlreadyNormalized = false}) {
    if (!opIdAlreadyNormalized) {
      opID = ObservationOperation.normalizeID(opID);
    }
    return firstWhereOrNull((e) => e.opID == opID);
  }
}
