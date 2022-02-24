import 'package:collection/collection.dart';

typedef ForecastConclusionListener<T, V> = void Function(
    T source, ForecastObservation<T, V>? observation, V conclusion);

/// A Forecast producer base class.
abstract class Forecaster<T, V, F> {
  /// Generates the operations for [phase].
  Iterable<ForecastOperation<T, V>> generateOperations(String phase);

  final Map<String, List<ForecastObservation<T, V>>> _phasesObservations =
      <String, List<ForecastObservation<T, V>>>{};

  /// Disposes all the non-concluded observations of all phases.
  ///
  /// See [concludeObservations].
  void disposeObservations() {
    _phasesObservations.clear();
  }

  /// Observe [source] for [phase]. Calls [generateOperations] to generated
  /// the observations.
  List<ForecastObservation<T, V>> observe(source, {String phase = ''}) {
    var operations = generateOperations(phase);

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
    for (var o in observations) {
      removeObservation(o);
    }
  }

  /// Concludes observations for [source] with [value].
  ///
  /// - If [phases] is provided, concludes only for observations in [phases].
  List<ForecastObservation<T, V>> concludeObservations(T source, V value,
      {List<String>? phases}) {
    var selectedObservation =
        selectedObservations(phases: phases, source: source);

    for (var o in selectedObservation) {
      notifyConclusion(source, o, value);
    }

    notifyConclusion(source, null, value);

    removeObservations(selectedObservation);

    return selectedObservation;
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

  void notifyConclusion(
      T source, ForecastObservation<T, V>? observation, V conclusion) {
    var conclusionListener = this.conclusionListener;
    if (conclusionListener != null) {
      conclusionListener(source, observation, conclusion);
    }
  }
}

typedef OperationComputer<T, V> = V Function(T source);

/// A Forecast operation over source [T] that produces value [V].
class ForecastOperation<T, V> {
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

  final String id;

  final String description;

  final OperationComputer<T, V>? computer;

  ForecastOperation(String id, {this.computer, this.description = ''})
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
  final ForecastOperation<T, V> operation;

  /// The value observed during a forecast performed over [source].
  final V value;

  ForecastObservation(this.phase, this.source, this.operation, this.value);

  /// The [operation.id].
  String get opID => operation.id;

  @override
  String toString() {
    var phaseStr = phase.isNotEmpty ? '[$phase] ' : '';
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
      opID = ForecastOperation.normalizeID(opID);
    }
    return firstWhereOrNull((e) => e.opID == opID);
  }
}
