/*
Author: Graciliano M. P.
*/

import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:statistics/statistics.dart';

final _regexpSpace = RegExp(r'\s+');

class ValidationError implements Exception {
  final String message;

  ValidationError(this.message);

  @override
  String toString() {
    return 'ValidationError: $message';
  }
}

/// An interface for objects that can be validated.
abstract class Validatable {
  /// Validates the instance. Returns the invalid [Object] or `null` when valid.
  Object? validate();

  /// Returns `true` if this instance is valid.
  bool get isValid => validate() == null;

  /// Checks if this instance is valid.
  void checkValid() {
    var invalid = validate();
    if (invalid != null) {
      throw ValidationError("$invalid");
    }
  }
}

abstract class Freezeable {
  void checkNotFrozen() {
    if (isFrozen) {
      throw ValidationError("$runtimeType already frozen!");
    }
  }

  bool _frozen = false;

  bool get isFrozen => _frozen;

  bool freeze() {
    if (_frozen) return false;
    _frozen = true;
    return true;
  }
}

/// An interface for a network cache. This stores some internal resolutions.
abstract class NetworkCache {
  Map<String, String> get _resolvedVariablesNamesCache;

  Map<String, String> get _resolvedValuesNamesCache;
}

/// A Bayesian Network implementation.
class BayesianNetwork extends Iterable<String>
    with Validatable, Freezeable
    implements NetworkCache {
  /// Name of the network.
  final String name;
  final Map<String, BayesVariable> _nodes = <String, BayesVariable>{};
  final Map<String, BayesDependency> _dependencies =
      <String, BayesDependency>{};

  /// The minimal probability for an unseen value.
  ///
  /// A not seen event doesn't necessary means a zero probability event.
  ///
  /// - Defaults to `0.0000001`.
  final double unseenMinimalProbability;

  BayesianNetwork(this.name, {this.unseenMinimalProbability = 0.0000001}) {
    if (unseenMinimalProbability < 0) {
      throw ArgumentError(
          "Invalid unseenMinimalProbability: $unseenMinimalProbability");
    }
  }

  /// The root [BayesVariable] nodes.
  List<BayesVariable> get rootNodes =>
      _nodes.values.where((e) => e.isRoot).toList();

  /// All the [BayesVariable] nodes of this network.
  List<BayesVariable> get nodes => _nodes.values.toList();

  /// All the [BayesVariable] nodes of this network in a sorted in a topological order.
  List<BayesVariable> get nodesInTopologicalOrder =>
      nodes.nodesInTopologicalOrder;

  final Map<_IterableKey<BayesVariable>, List<BayesVariable>>
      _nodesInChainCache = <_IterableKey<BayesVariable>, List<BayesVariable>>{};

  /// Returns the [BayesVariable] nodes in the chain composed by [selectedNodes].
  List<BayesVariable> nodesInChain(Iterable<BayesVariable> selectedNodes) {
    var selectedNodesSet = selectedNodes.toSet();
    var cacheKey = _IterableKey(selectedNodesSet);
    var cached = _nodesInChainCache[cacheKey];
    if (cached != null) {
      return cached.toList();
    }

    var nodes = _nodesInChainImpl(selectedNodesSet, selectedNodes);
    _nodesInChainCache[cacheKey] = nodes;

    return nodes.toList();
  }

  List<BayesVariable> _nodesInChainImpl(Set<BayesVariable> selectedNodesSet,
      Iterable<BayesVariable> selectedNodes) {
    var nodes = this.nodes;

    selectedNodesSet = nodes.where((n) => selectedNodesSet.contains(n)).toSet();

    selectedNodesSet =
        selectedNodesSet.expand((n) => n.rootChains.expand((l) => l)).toSet();

    while (selectedNodes.length < nodes.length) {
      var added = false;
      for (var n in nodes) {
        if (selectedNodesSet.contains(n)) continue;

        var rootChains = n.rootChains;
        var inChain =
            rootChains.any((c) => c.any((e) => selectedNodesSet.contains(e)));

        if (inChain) {
          for (var c in rootChains) {
            selectedNodesSet.addAll(c);
          }

          added = true;
        }
      }

      if (!added) break;
    }

    var allInChain = selectedNodesSet.toList().nodesInTopologicalOrder;
    return allInChain;
  }

  @override
  Object? validate() {
    var invalid = _nodes.values
        .map((e) => e.validate())
        .firstWhereOrNull((e) => e != null);

    return invalid;
  }

  /// Returns the total number of [BayesVariable] nodes of this network.
  int get nodesLength => _nodes.length;

  /// Returns all the [BayesVariable] nodes names.
  List<String> get variablesNames => _nodes.keys.toList();

  BayesAnalyser? _analyser;

  /// Returns an [BayesAnalyser].
  ///
  /// - Default implementation: [BayesAnalyserVariableElimination].
  BayesAnalyser get analyser {
    freeze();
    return _analyser ??= BayesAnalyserVariableElimination(this);
  }

  /// Adds a [BayesVariable] node, with [values] and [parents] and [probabilities].
  BayesVariable addVariable(String name, List<String> values,
      List<String> parents, List<String> probabilities,
      {double? unseenMinimalProbability}) {
    checkNotFrozen();

    var node = BayesVariable(name, this,
        values: values,
        parents: parents,
        probabilities: probabilities,
        unseenMinimalProbability:
            unseenMinimalProbability ?? this.unseenMinimalProbability);

    for (var n in node.parents) {
      n._addChild(node);
    }

    node.checkValid();

    _disposeInternalCaches();

    return node;
  }

  /// Adds a dependency between [BayesVariable]s with respective [probabilities].
  ///
  /// - Note: Dependencies should be added after all variables.
  BayesDependency addDependency(
      List<String> variablesNames, List<String> probabilities,
      {double? unseenMinimalProbability}) {
    checkNotFrozen();

    var variables =
        _nodes.values.where((e) => variablesNames.contains(e.name)).toList();

    var dependency = BayesDependency(this, variables,
        probabilities: probabilities,
        unseenMinimalProbability:
            unseenMinimalProbability ?? this.unseenMinimalProbability);

    dependency.checkValid();

    _disposeInternalCaches();

    return dependency;
  }

  @override
  final Map<String, String> _resolvedVariablesNamesCache = <String, String>{};

  @override
  final Map<String, String> _resolvedValuesNamesCache = <String, String>{};

  /// Disposes internal caches.
  void disposeCaches() {
    _resolvedVariablesNamesCache.clear();
    _resolvedValuesNamesCache.clear();

    _disposeInternalCaches();
  }

  void _disposeInternalCaches() {
    _nodesInChainCache.clear();

    for (var n in _nodes.values) {
      n._disposeCaches();
    }
  }

  /// Freezes the network turning it immutable.
  @override
  bool freeze() {
    if (!super.freeze()) return false;

    for (var n in _nodes.values) {
      n.freeze();
    }

    return true;
  }

  /// Returns `true` if contains a node with [name].
  bool hasNodeWithName(String name) => _nodes.containsKey(name);

  /// Returns a [BayesVariable] node with [name].
  BayesVariable getNodeByName(String name) {
    var node = _nodes[name];
    if (node == null) {
      throw ValidationError("No `Variable` node with name: $name");
    }
    return node;
  }

  /// Returns a [List] of [BayesVariable]s nodes with matching [names].
  List<BayesVariable> getNodesByNames(Iterable<String> names) =>
      _nodes.values.where((e) => names.contains(e.name)).toList();

  BayesCondition _parseCondition(String line) {
    line = line.replaceAll(_regexpSpace, '');
    var cond = line.split(
        ","); // where cond (conditions) is like ["a=true", "weather=sunny"]

    var conditionList = <BayesEvent>[];
    for (var event in cond) {
      if (event.isNotEmpty) {
        conditionList.add(parseEvent(event));
      }
    }
    return BayesCondition(conditionList);
  }

  BayesEvent parseEvent(String line) {
    line = line.replaceAll(_regexpSpace, '');

    var e = line.split("=");
    if (e.length != 2) {
      throw ValidationError("Expected \"variable=value\", received " + line);
    }

    var name = e[0];
    var node = _nodes[name];
    if (node == null) {
      throw StateError('No such variable <' + e[0] + ">.");
    }

    return BayesEvent.byOutcomeName(node, e[1]);
  }

  @override
  Iterator<String> get iterator => _nodes.keys.iterator;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BayesianNetwork &&
          runtimeType == other.runtimeType &&
          _listEqualityVariable.equals(_nodes.values, other._nodes.values);

  static final _listEqualityVariable = IterableEquality<BayesVariable>();

  @override
  int get hashCode => _listEqualityVariable.hash(_nodes.values);

  @override
  String toString() {
    return 'BayesianNetwork[$name]{ variables: ${_nodes.length} }<\n'
        '${_nodes.values.join('\n')}\n'
        '${_dependencies.values.join('\n')}\n'
        '>';
  }
}

/// A [BayesValue] signal.
enum BayesValueSignal {
  positive,
  negative,
  unknown,
}

/// A value in a [BayesianNetwork].
class BayesValue extends Validatable implements Comparable<BayesValue> {
  /// Name of the value.
  final String name;

  /// Variable of this value.
  final BayesVariable variable;

  /// Signal of this value.
  final BayesValueSignal signal;

  BayesValue(String name, this.variable, {BayesValueSignal? signal})
      : name = resolveName(name, networkCache: variable.network),
        signal = resolveSignal(signal: signal, name: name);

  BayesianNetwork get network => variable.network;

  static String resolveName(String name,
      {required NetworkCache? networkCache}) {
    var cache = networkCache?._resolvedValuesNamesCache;

    var cached = cache?[name];
    if (cached != null) return cached;

    var resolved = name.trim().toUpperCase();
    if (resolved.startsWith('-') || resolved.startsWith('+')) {
      resolved = resolved.substring(1);
    }

    cache?[name] = resolved;
    return resolved;
  }

  static BayesValueSignal resolveSignal(
      {BayesValueSignal? signal, String? name}) {
    if (signal != null) return signal;

    if (name == null) return BayesValueSignal.unknown;

    name = name.trimLeft();

    return name.startsWith('-')
        ? BayesValueSignal.negative
        : (name.startsWith('+')
            ? BayesValueSignal.positive
            : BayesValueSignal.unknown);
  }

  @override
  Object? validate() => variable.validate();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BayesValue &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          variable == other.variable;

  @override
  int get hashCode => name.hashCode ^ variable.hashCode;

  @override
  int compareTo(BayesValue other) {
    if (identical(this, other)) return 0;

    var cmp = variable.name.compareTo(other.variable.name);

    if (cmp == 0) {
      cmp = name.compareTo(other.name);
      if (cmp == 0) {
        cmp = signal.index.compareTo(other.signal.index);
      }
    }

    return cmp;
  }

  @override
  String toString() => name;
}

/// A network event: [Variable] [node] + [value].
class BayesEvent implements Comparable<BayesEvent> {
  final BayesVariable node;
  late final BayesValue value;

  BayesEvent(this.node, this.value) {
    if (!node.values.contains(value)) {
      throw ValidationError(
          'Variable <${node.variablesAsString}> does not contain the value "$value".');
    }
  }

  BayesEvent.byOutcomeName(this.node, String outcomeName) {
    var value = node.values.firstWhereOrNull((v) => v.name == outcomeName);

    if (value == null) {
      throw ValidationError(
          'Variable <${node.variablesAsString}> does not contain the value "$outcomeName".');
    }

    this.value = value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BayesEvent &&
          runtimeType == other.runtimeType &&
          node == other.node &&
          value == other.value;

  @override
  int get hashCode => node.hashCode ^ value.hashCode;

  @override
  int compareTo(BayesEvent other) {
    if (identical(this, other)) return 0;

    if (node == other.node) {
      return value.compareTo(other.value);
    } else {
      return node.variablesAsString.compareTo(other.node.variablesAsString);
    }
  }

  @override
  String toString() {
    return "${node.variablesAsString} = ${value.name}";
  }
}

abstract class BayesNode extends Validatable with Freezeable {
  /// The network of this element.
  final BayesianNetwork network;

  BayesNode(this.network);

  Iterable<BayesVariable> get variables;

  String get variablesAsString;

  Iterable<BayesValue> get values;

  Iterable<BayesVariable> get parents;

  bool get isRoot;

  List<BayesVariable> get rootChain;

  Set<BayesVariable> get ancestors;

  Iterable<BayesVariable>? _conditionVariables;

  Iterable<BayesVariable> get conditionVariables => _conditionVariables ??=
      UnmodifiableSetView(<BayesVariable>{...variables, ...parents});

  BayesEvent parseEvent(String line) => network.parseEvent(line);

  final Map<BayesCondition, double> _probabilities = <BayesCondition, double>{};

  /// The probability table of this node.
  Map<BayesCondition, double> get probabilities =>
      UnmodifiableMapView<BayesCondition, double>(_probabilities);

  @override
  Object? validate() {
    if (_probabilities.values.any((n) => n.isNaN || n.isInfinite || n < 0)) {
      return this;
    }
    return null;
  }

  /// Returns a probability for [condition] in the [probabilities] table.
  double? getProbability(String condition) =>
      _probabilities[_parseCondition(condition)];

  void _setProbabilities(
      double? unseenMinimalProbability, List<String>? probabilities) {
    {
      unseenMinimalProbability ??= network.unseenMinimalProbability;

      var conditions =
          BayesCondition.allConditions(conditionVariables.toList());
      for (var c in conditions) {
        _probabilities[c] = unseenMinimalProbability;
      }
    }

    if (probabilities != null) {
      for (var p in probabilities) {
        _addProbability(p);
      }
    }
  }

  void _addProbability(String line) {
    checkNotFrozen();

    line = line.replaceAll(_regexpSpace, '');

    var idx = line.indexOf(':');
    if (idx < 1) {
      throw ValidationError("Invalid entry: $line");
    }

    var condition = _parseCondition(line.substring(0, idx));

    var probability = double.parse(line.substring(idx + 1).trim());

    if (_probabilities.containsKey(condition)) {
      _probabilities[condition] = probability;
    } else {
      throw ValidationError('Provided condition mismatch: $condition\n'
          '  -- Available conditions for: $this');
    }
  }

  String toStringProbabilities(String mainVariable) {
    if (_probabilities.isEmpty) return '';

    var s = '\n  ';

    var entries = _probabilities.entries.toList();

    entries.sort((a, b) {
      var c1 = a.key;
      var c2 = b.key;
      return c1.compareTo(c2);
    });

    s += entries
        .map((e) => '${e.key.toString(mainVariable: mainVariable)}: ${e.value}')
        .join('\n  ');

    return s;
  }

  BayesCondition _parseCondition(String line);
}

class BayesDependency extends BayesNode implements Comparable<BayesDependency> {
  final Set<BayesVariable> _variables;

  @override
  late final String variablesAsString;

  BayesDependency(BayesianNetwork network, Iterable<BayesVariable> variables,
      {List<String>? probabilities, double? unseenMinimalProbability})
      : _variables = (variables.toList()..sort()).toSet(),
        super(network) {
    if (_variables.length < 2) {
      throw ValidationError(
          'A dependency should have at least 2 different variables');
    }

    variablesAsString =
        (_variables.map((e) => e.name).toList()..sort()).join('+');

    if (network._dependencies.containsKey(variablesAsString)) {
      throw ValidationError(
          'Nodes dependency already exists: $variablesAsString');
    }

    network._dependencies[variablesAsString] = this;

    _setProbabilities(double.nan, probabilities);
    _probabilities.removeWhere((key, value) => value.isNaN);
  }

  @override
  Set<BayesVariable> get variables => UnmodifiableSetView(_variables);

  @override
  Iterable<BayesValue> get values => _variables.expand((e) => e.values);

  @override
  Iterable<BayesVariable> get parents =>
      _variables.expand((e) => e.parents).toSet();

  @override
  bool get isRoot => _variables.any((e) => e.isRoot);

  @override
  List<BayesVariable> get rootChain {
    var chains = _variables.map((e) => e.rootChain).toList();
    chains.sort((a, b) => a.length.compareTo(b.length));
    return chains.first;
  }

  Set<BayesVariable>? _ancestors;

  @override
  Set<BayesVariable> get ancestors =>
      _ancestors ??= _variables.expand((e) => e.ancestors).toSet();

  @override
  BayesCondition _parseCondition(String line) {
    line = line.replaceAll(_regexpSpace, '');

    var eventsStr = line.split(",");
    if (eventsStr.length != conditionVariables.length) {
      throw ValidationError(
          "Number of events (${eventsStr.length}) mismatches required number (${conditionVariables.length}): $line");
    }

    var events = eventsStr.map(parseEvent).toList();
    return BayesCondition(events);
  }

  static final _setEquality = SetEquality<BayesVariable>();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BayesDependency &&
          runtimeType == other.runtimeType &&
          _setEquality.equals(_variables, other._variables);

  @override
  int get hashCode => _setEquality.hash(_variables);

  @override
  String toString() {
    var s = '${variables.nodesNames.join(' <-> ')}:';
    s += toStringProbabilities(variables.first.name);
    return s;
  }

  @override
  int compareTo(BayesDependency other) {
    var cmp = _variables.length.compareTo(other._variables.length);
    if (cmp == 0) {
      cmp = _variables.compareWith(other._variables);
    }
    return cmp;
  }
}

/// A variable in the [BayesianNetwork] graph.
class BayesVariable extends BayesNode implements Comparable<BayesVariable> {
  /// The name of the variable.
  final String name;

  @override
  late final List<BayesVariable> variables = UnmodifiableListView([this]);

  final List<BayesVariable> _parents = <BayesVariable>[];
  final List<BayesVariable> _children = <BayesVariable>[];
  final Map<String, BayesValue> _domain = <String, BayesValue>{};

  BayesVariable(String name, BayesianNetwork network,
      {List<String>? values,
      List<String>? parents,
      List<String>? probabilities,
      double? unseenMinimalProbability})
      : name = resolveName(name, networkCache: network),
        super(network) {
    if (network._nodes.containsKey(name)) {
      throw ValidationError('Variable node already exists: $name');
    }

    network._nodes[name] = this;

    if (values != null) {
      for (var v in values) {
        _addValue(v);
      }
    }

    if (parents != null) {
      for (var p in parents) {
        _addParentByName(p);
      }
    }

    _setProbabilities(unseenMinimalProbability, probabilities);
  }

  static String resolveName(String name,
      {required NetworkCache? networkCache}) {
    var cache = networkCache?._resolvedVariablesNamesCache;

    var cached = cache?[name];
    if (cached != null) return cached;

    var resolved = name.trim().toUpperCase();

    cache?[name] = resolved;
    return resolved;
  }

  @override
  Object? validate() {
    var valid = super.validate();
    if (valid != null) return valid;

    if (_children.isNotEmpty) {
      var invalidChild =
          _children.map((e) => e.validate()).firstWhereOrNull((e) => e != null);

      if (invalidChild != null) {
        return invalidChild;
      }
    }

    return null;
  }

  @override
  bool get isRoot => _parents.isEmpty;

  int get parentsLength => _parents.length;

  @override
  List<BayesVariable> get parents =>
      UnmodifiableListView<BayesVariable>(_parents);

  @override
  String get variablesAsString => name;

  @override
  Iterable<BayesValue> get values => _domain.values;

  bool containsNode(BayesVariable node) {
    for (var c in _children) {
      if (c == node) return true;
    }

    for (var c in _children) {
      if (c.containsNode(node)) return true;
    }

    return false;
  }

  List<BayesVariable> nodeChain(BayesVariable node) {
    if (_children.isEmpty) return <BayesVariable>[];

    for (var c in _children) {
      if (c == node) return <BayesVariable>[this, c];
    }

    var chains = _children
        .map((e) => e.nodeChain(node))
        .where((c) => c.isNotEmpty)
        .map((c) => [this, ...c])
        .toList();

    return _shortestChain(chains);
  }

  List<BayesVariable> _shortestChain(List<List<BayesVariable>> chains) {
    if (chains.isEmpty) return <BayesVariable>[];
    if (chains.length == 1) return chains.first;

    chains.sort((a, b) {
      var cmp = a.length.compareTo(b.length);
      if (cmp == 0) {
        cmp = a.compareWith(b);
      }
      return cmp;
    });

    return chains.first;
  }

  List<BayesVariable>? _rootNodes;

  /// Returns the root nodes of this node.
  List<BayesVariable> get rootNodes =>
      (_rootNodes ??= _rootNodesImpl()).toList();

  List<BayesVariable> _rootNodesImpl() =>
      network.rootNodes.where((e) => e.containsNode(this)).toList();

  List<BayesVariable>? _rootChain;

  /// Returns the smallest chain until the root.
  @override
  List<BayesVariable> get rootChain =>
      (_rootChain ??= _rootChainImpl()).toList();

  List<BayesVariable> _rootChainImpl() {
    var rootNodes = this.rootNodes;
    if (rootNodes.isEmpty) return <BayesVariable>[this];

    var chains = rootNodes.map((r) => r.nodeChain(this)).toList();
    return _shortestChain(chains);
  }

  List<List<BayesVariable>>? _rootChains;

  /// Returns all the chains until the root.
  List<List<BayesVariable>> get rootChains =>
      (_rootChains ??= _rootChainsImpl()).map((e) => e.toList()).toList();

  List<List<BayesVariable>> _rootChainsImpl() {
    var rootNodes = this.rootNodes;
    if (rootNodes.isEmpty) {
      return <List<BayesVariable>>[
        <BayesVariable>[this]
      ];
    }

    var chains = rootNodes.map((r) => r.nodeChain(this)).toList();
    return chains;
  }

  Set<BayesVariable>? _ancestors;

  /// Returns the ancestors [BayesVariable] nodes of this node.
  @override
  Set<BayesVariable> get ancestors => (_ancestors ??= _ancestorsImpl()).toSet();

  Set<BayesVariable> _ancestorsImpl() {
    if (_parents.isEmpty) return <BayesVariable>{};
    var list = _parents.expand((p) => [p, ...p.ancestors]).toSet();
    return list;
  }

  /// The domain values of this node.
  Map<String, BayesValue> get domain =>
      UnmodifiableMapView<String, BayesValue>(_domain);

  void _addChild(BayesVariable node) {
    checkNotFrozen();

    _children.add(node);
    _disposeCaches();
  }

  @override
  BayesCondition _parseCondition(String line) {
    line = line.replaceAll(_regexpSpace, '');

    var eventsStr = line.split(",");
    if (eventsStr.length != conditionVariables.length) {
      throw ValidationError(
          "Number of events (${eventsStr.length}) mismatches required number (${conditionVariables.length}): $line");
    }

    var events = eventsStr.map(parseEvent).toList();
    return BayesCondition(events);
  }

  void _addParentByName(String name) {
    checkNotFrozen();

    try {
      _addParent(network.getNodeByName(name));
    } catch (e) {
      throw ValidationError(
          'The specified parent node "$name" does not exist (yet).');
    }
  }

  void _addParent(BayesVariable parent) {
    checkNotFrozen();
    _parents.add(parent);
    _disposeCaches();
  }

  void _addValue(String name) {
    checkNotFrozen();

    if (_domain.containsKey(name)) {
      throw ValidationError('Value with name "$name" already exists.');
    }

    var value = BayesValue(name, this);
    _domain[value.name] = value;

    _disposeCaches();
  }

  /// Returns a value with [name] in this node.
  BayesValue? getValue(String name) => _domain[name];

  /// Returns the name of a value in this node with [name] or [signal].
  String? getValueName({String? name, BayesValueSignal? signal}) {
    if (name != null) {
      name = BayesValue.resolveName(name, networkCache: network);
      if (_domain.containsKey(name)) {
        return name;
      }
    }

    if (signal != null && signal != BayesValueSignal.unknown) {
      var values = _domain.values.where((e) => e.signal == signal).toList();
      if (values.isNotEmpty) {
        return values.first.name;
      }
    }

    if (_domain.length == 2) {
      var valuesNames = _domain.keys.toList();
      valuesNames.sort();

      if (valuesNames.equals(['F', 'T'])) {
        return signal == BayesValueSignal.negative ? 'F' : 'T';
      } else if (valuesNames.equals(['0', '1'])) {
        return signal == BayesValueSignal.negative ? '0' : '1';
      } else if (valuesNames.equals(['N', 'P'])) {
        return signal == BayesValueSignal.negative ? 'N' : 'P';
      } else if (valuesNames.equals(['N', 'Y'])) {
        return signal == BayesValueSignal.negative ? 'N' : 'Y';
      } else if (valuesNames.equals(['N', 'S'])) {
        return signal == BayesValueSignal.negative ? 'N' : 'S';
      } else if (valuesNames.equals(['NO', 'YES'])) {
        return signal == BayesValueSignal.negative ? 'NO' : 'YES';
      } else if (valuesNames.equals(['FALSE', 'TRUE'])) {
        return signal == BayesValueSignal.negative ? 'FALSE' : 'TRUE';
      } else if (valuesNames.equals(['NEGATIVE', 'POSITIVE'])) {
        return signal == BayesValueSignal.negative ? 'NEGATIVE' : 'POSITIVE';
      }
    }

    return null;
  }

  static final IterableEquality _iterableEquality = IterableEquality();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BayesVariable &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          (identical(network, other.network) ||
              (network.name == other.network.name &&
                  network._nodes.length == other.network._nodes.length &&
                  _iterableEquality.equals(
                      network._nodes.keys, other.network._nodes.keys)));

  @override
  int get hashCode => name.hashCode ^ network.nodesLength;

  @override
  String toString() {
    var s = '$name: [' + _parents.map((v) => v.name).join(', ') + ']';
    s += toStringProbabilities(name);
    return s;
  }

  @override
  int compareTo(BayesVariable other) {
    if (identical(this, other)) return 0;

    var cmp = _children.compareWith(other._children);
    if (cmp == 0) {
      cmp = name.compareTo(other.name);
    }
    return cmp;
  }

  void _disposeCaches() {
    _ancestors = null;
    _rootNodes = null;
    _rootChain = null;
    _rootChains = null;
  }
}

extension ListBayesNodeExtension<T extends BayesNode> on Iterable<T> {
  List<String> get nodesNames => map((e) => e.variablesAsString).toList();

  /// Returns this [Variable] [List] in a topological order.
  List<T> get nodesInTopologicalOrder {
    var nodes = toList();

    var nodesRootChains = Map<T, List<BayesVariable>>.fromEntries(
      nodes.map((e) => MapEntry<T, List<BayesVariable>>(e, e.rootChain)),
    );

    nodes.sort((a, b) {
      var root1 = a.isRoot;
      var root2 = b.isRoot;

      if (root1 && root2) {
        return a.variablesAsString.compareTo(b.variablesAsString);
      } else if (root1) {
        return -1;
      } else if (root2) {
        return 1;
      } else {
        var chain1 = nodesRootChains[a]!;
        var chain2 = nodesRootChains[b]!;

        var cmp = chain1.length.compareTo(chain2.length);
        if (cmp == 0) {
          cmp = chain1.compareWith(chain2);
        }
        return cmp;
      }
    });

    return nodes;
  }
}

/// A condition in the [BayesianNetwork] graph.
class BayesCondition extends Iterable<BayesEvent>
    implements Comparable<BayesCondition> {
  static List<BayesCondition> allConditions(List<BayesVariable> nodes) {
    var nodesLength = nodes.length;

    var combinations = nodes.combinations<BayesEvent>(nodesLength, nodesLength,
        allowRepetition: false,
        mapper: (node) => node.values.map((v) => BayesEvent(node, v)));

    var conditions =
        combinations.map((events) => BayesCondition(events)).toList();
    return conditions;
  }

  final List<BayesEvent> _events;

  BayesCondition(List<BayesEvent> l) : _events = List.from(l)..sort();

  BayesianNetwork get network => _events.first.node.network;

  List<BayesEvent> get events => UnmodifiableListView(_events);

  List<BayesValue>? _eventsValues;

  List<BayesValue> get eventsValues => _eventsValues ??=
      UnmodifiableListView(_events.map((e) => e.value).toList());

  List<BayesVariable>? _eventsVariables;

  List<BayesVariable> get eventsVariables => _eventsVariables ??=
      UnmodifiableListView(_events.map((e) => e.node).toList());

  bool containsVariable(BayesVariable node) => eventsVariables.contains(node);

  bool containsAllVariables(Iterable<BayesVariable> variables) =>
      eventsVariables.containsAll(variables);

  bool containsEvent(BayesEvent event) => _events.contains(event);

  bool containsAllEvents(Iterable<BayesEvent> events) =>
      _events.containsAll(events);

  bool containsCondition(BayesCondition condition) =>
      condition.events.all((e) => containsEvent(e));

  bool containsAllConditions(Iterable<BayesCondition> conditions) {
    if (conditions.isEmpty) return false;
    for (var c in conditions) {
      if (!containsCondition(c)) return false;
    }
    return true;
  }

  bool mentionAny(Iterable<BayesVariable> variables) {
    for (var v in variables) {
      if (mention(v)) return true;
    }
    return false;
  }

  bool mention(BayesVariable variable) {
    for (var e in _events) {
      if (e.node == variable) return true;
    }
    return false;
  }

  @override
  Iterator<BayesEvent> get iterator => _events.iterator;

  static final _listEqualityEvent = ListEquality<BayesEvent>();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BayesCondition &&
          runtimeType == other.runtimeType &&
          _listEqualityEvent.equals(_events, other._events);

  @override
  int get hashCode => _listEqualityEvent.hash(_events);

  @override
  String toString({String? mainVariable}) {
    if (mainVariable != null) {
      mainVariable =
          BayesVariable.resolveName(mainVariable, networkCache: network);
      var mainEvents = _events
          .where((e) => e.node.variablesAsString == mainVariable)
          .toList();

      var otherEvents = _events
          .where((e) => e.node.variablesAsString != mainVariable)
          .toList();

      if (mainEvents.isNotEmpty && otherEvents.isNotEmpty) {
        return mainEvents.join(', ') + ', ' + otherEvents.join(', ');
      }
    }

    return _events.join(', ');
  }

  @override
  int compareTo(BayesCondition other, {String? mainVariable}) {
    if (identical(this, other)) return 0;

    if (mainVariable != null) {
      mainVariable =
          BayesVariable.resolveName(mainVariable, networkCache: network);

      var mainEvents1 = _events
          .where((e) => e.node.variablesAsString == mainVariable)
          .toList();
      var mainEvents2 = other._events
          .where((e) => e.node.variablesAsString == mainVariable)
          .toList();

      var cmp = mainEvents1.compareWith(mainEvents2);
      if (cmp == 0) {
        var otherEvents1 = _events
            .where((e) => e.node.variablesAsString != mainVariable)
            .toList();
        var otherEvents2 = other._events
            .where((e) => e.node.variablesAsString != mainVariable)
            .toList();

        cmp = otherEvents1.compareWith(otherEvents2);
      }

      return cmp;
    }

    return _events.compareWith(other._events);
  }
}

extension ConditionProbabilitiesExtension on Map<BayesCondition, num> {
  void show({String linePrefix = '-- ', String title = ''}) {
    if (title.isNotEmpty) {
      print(title);
    }
    for (var e in entries) {
      print('$linePrefix${e.key} = ${e.value}');
    }
  }
}

/// Helper class for the [BayesAnalyserVariableElimination] analyser.
class _Factor {
  final List<BayesNode> _nodes;
  late final List<BayesVariable> _variables;

  Map<BayesCondition, double> _probabilities;

  _Factor._(this._nodes, this._probabilities) {
    _defineVariables();
  }

  void _defineVariables() {
    _variables = _nodes.expand((e) => e.variables).toSet().toList();
  }

  _Factor(BayesNode node, BayesCondition evidence, {bool verbose = false})
      : _nodes = node.parents.cast<BayesNode>().toList(),
        _probabilities = Map<BayesCondition, double>.from(node.probabilities) {
    _nodes.add(node);
    _defineVariables();

    if (verbose) {
      print('-- Computing Factor(${_variables.nodesNames})...');
      _probabilities.show(linePrefix: '  --> ');
    }

    var evidenceVariables = evidence.eventsVariables;

    for (var event in evidence) {
      var node = _getNodeWithEvent(event);

      if (node != null) {
        var selVariables =
            node.variables.where((e) => evidenceVariables.contains(e)).toList();

        var selEvents = evidence.events
            .where((e) => selVariables.contains(e.node))
            .toList();

        if (verbose) {
          print('  -- Node: ${node.variablesAsString}');
          print('  -- Select: ${selVariables.nodesNames}');
          print('  -- Events: $selEvents');
        }

        var newP = <BayesCondition, double>{};
        for (var c in _probabilities.keys) {
          if (c.containsAllEvents(selEvents)) {
            newP[c] = _probabilities[c]!;
          }
        }

        _probabilities = newP;

        if (verbose) {
          _probabilities.show(linePrefix: '  --SEL[$event]> ');
        }

        marginalize(event.node.variables.toList());

        if (verbose) {
          _probabilities.show(
              linePrefix: '  --RM[${event.node.variablesAsString}]> ');
        }
      }
    }
  }

  BayesNode? _getNodeWithEvent(BayesEvent event) {
    var eventNodeVariables = event.node.variables;

    for (var node in _nodes) {
      if (node == event.node) return node;

      if (node.variables.containsAll(eventNodeVariables)) {
        return node;
      }
    }

    return null;
  }

  double get(BayesCondition cond) {
    var p = _probabilities[cond];
    if (p == null) {
      throw StateError("Can't find probability for: $cond");
    }
    return p;
  }

  void marginalize(List<BayesVariable> eliminateVariables) {
    var rmNode = _removeNode(eliminateVariables);

    if (rmNode == null) {
      throw StateError(
          "This factor does not contain a node with variables $eliminateVariables to eliminate. "
          "Nodes: ${_nodes.nodesNames}");
    }

    eliminateVariables = rmNode.variables.toList();
    _variables.removeWhere((e) => eliminateVariables.contains(e));

    var allConditions = BayesCondition.allConditions(_variables);

    var newP = Map<BayesCondition, double>.fromEntries(
        allConditions.map((c) => MapEntry(c, 0.0)));

    for (var c in newP.keys) {
      for (var oldC in _probabilities.keys) {
        if (oldC.containsCondition(c)) {
          newP[c] = newP[c]! + _probabilities[oldC]!;
        }
      }
    }

    _probabilities = newP;
  }

  BayesNode? _removeNode(List<BayesVariable> eliminateVariables) {
    for (var i = 0; i < _nodes.length; ++i) {
      var node = _nodes[i];

      if (node.variables.containsAll(eliminateVariables)) {
        _nodes.removeAt(i);
        return node;
      }
    }

    for (var i = 0; i < _nodes.length; ++i) {
      var node = _nodes[i];

      if (node.variables.containsAny(eliminateVariables)) {
        _nodes.removeAt(i);
        return node;
      }
    }

    return null;
  }

  _Factor product(_Factor other) {
    var newVars = <BayesVariable>{..._variables, ...other._variables}.toList();

    var allConditions = BayesCondition.allConditions(newVars);

    // compute the joined probability table;
    var newP = <BayesCondition, double>{};
    for (var cond in allConditions) {
      var prob = 1.0;

      for (var c in other._probabilities.keys) {
        if (cond.containsCondition(c)) {
          var p = other.get(c);
          prob *= p;
        }
      }

      for (var c in _probabilities.keys) {
        if (cond.containsCondition(c)) {
          var p = get(c);
          prob *= p;
        }
      }

      newP[cond] = prob;
    }

    return _Factor._(newVars, newP);
  }

  _Factor normalise() {
    var sumP = 0.0;
    for (var d in _probabilities.values) {
      sumP += d;
    }

    var newP = <BayesCondition, double>{};

    if (sumP == 0.0) {
      for (var e in _probabilities.entries) {
        newP[e.key] = 0.0;
      }
    } else {
      for (var e in _probabilities.entries) {
        newP[e.key] = e.value / sumP;
      }
    }

    return _Factor._(_nodes.toList(), newP);
  }

  @override
  String toString() {
    var s = '_Factor(${_variables.nodesNames}):\n';
    s += _probabilities.entries.map((e) => '  ${e.key}: ${e.value}').join('\n');
    return s;
  }
}

/// [BayesAnalyser] answer. See [BayesAnalyser.ask].
class Answer implements Comparable<Answer> {
  /// The query for this answer.
  final String query;

  /// The [query] target value.
  final BayesValue targetValue;

  /// The selected values in the [query].
  final List<BayesValue> selectedValues;

  /// The [targetValue] probability.
  final double probability;

  /// The [targetValue] probability before normalization.
  final double probabilityUnnormalized;

  /// The original unparsed query.
  final String originalQuery;

  late final double fitness;

  Answer(this.query, this.targetValue, this.selectedValues, this.probability,
      {String? originalQuery, double? probabilityUnnormalized})
      : originalQuery = originalQuery ?? query,
        probabilityUnnormalized = probabilityUnnormalized ?? probability,
        fitness = _computeFitness(probability, probabilityUnnormalized);

  static double _computeFitness(double probability,
      [double? probabilityUnnormalized]) {
    if (probabilityUnnormalized != null) {
      var squaresSum = ((probability * probability) +
          (probabilityUnnormalized * probabilityUnnormalized));
      return squaresSum / 2;
    } else {
      return probability;
    }
  }

  double? _targetProbability;

  double? get targetProbability => _targetProbability;

  double? _performance;

  double get performance => _performance ??= _performanceImpl();

  double _performanceImpl() {
    var targetProbability = _targetProbability;
    if (targetProbability == null) {
      return probability;
    }

    var performance = probability / targetProbability;
    return performance;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Answer &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          probability == other.probability;

  @override
  int get hashCode => query.hashCode ^ probability.hashCode;

  @override
  String toString() {
    var pUnnormalized = probability != probabilityUnnormalized
        ? ' ($probabilityUnnormalized)'
        : '';

    var performanceStr =
        _targetProbability != null ? ' >> ' + performance.toPercentage() : '';

    if (originalQuery != query) {
      return '$originalQuery -> $query -> $probability$pUnnormalized$performanceStr';
    } else {
      return '$query -> $probability$pUnnormalized$performanceStr';
    }
  }

  @override
  int compareTo(Answer other) {
    if (identical(this, other)) return 0;

    var cmp = fitness.compareTo(other.fitness);
    if (cmp == 0) {
      if (cmp == 0) {
        cmp = probability.compareTo(other.probability);
        if (cmp == 0) {
          cmp = query.compareTo(other.query);
        }
      }
    }
    return cmp;
  }
}

extension ListAnswerExtension on List<Answer> {
  /// Sorts the [Answer] [List] by [Answer.probability].
  void sortByProbability() =>
      sort((a, b) => a.probability.compareTo(b.probability));

  /// Sorts the [Answer] [List] by [Answer.probabilityUnnormalized].
  void sortByProbabilityUnnormalized() => sort(
      (a, b) => a.probabilityUnnormalized.compareTo(b.probabilityUnnormalized));

  /// Sorts the [Answer] [List] by [Answer.fitness].
  void sortByFitness() => sort((a, b) => a.fitness.compareTo(b.fitness));

  /// Sorts the [Answer] [List] by [Answer.performance].
  void sortByPerformance() =>
      sort((a, b) => a.performance.compareTo(b.performance));

  /// Sorts the [Answer] [List] by [Answer.selectedValues].
  void sortBySelectedValues() {
    sort((a, b) {
      var cmp = a.selectedValues.compareWith(b.selectedValues);
      if (cmp == 0) {
        cmp = a.targetValue.compareTo(b.targetValue);
      }
      return cmp;
    });
  }

  /// Sorts the [Answer] [List] by [Answer.selectedValues] signals.
  void sortBySelectedValuesSignal() {
    sort((a, b) {
      var cmp = a.selectedValues
          .map((e) => e.signal.index)
          .compareWith(b.selectedValues.map((e) => e.signal.index));
      if (cmp == 0) {
        cmp = a.targetValue.compareTo(b.targetValue);
      }
      return cmp;
    });
  }

  /// Sorts the [Answer] [List] by [Answer.targetValue].
  void sortByTargetValue() {
    sort((a, b) {
      var cmp = a.targetValue.compareTo(b.targetValue);
      if (cmp == 0) {
        cmp = a.selectedValues.compareWith(b.selectedValues);
      }
      return cmp;
    });
  }

  /// Sorts the [Answer] [List] by [Answer.targetValue].
  void sortByQuery() => sort((a, b) => a.query.compareTo(b.query));

  /// Selects the best variables using the [size] and [sizeRatio] criteria.
  ///
  /// - Note: it assumes that this [list] is ordered by some criteria and
  ///   the best values are in the end of it.
  List<String> selectBestVariablesNames(
      {int? size, double? sizeRatio, int? minimumSize, int? maximumSize}) {
    if (isEmpty) return <String>[];

    var nodesLength = first.targetValue.variable.network.nodesLength;

    if (size == null) {
      var ratio = sizeRatio ?? 0.20;
      size = (nodesLength * ratio).toInt();
    }

    if (minimumSize != null && minimumSize >= 0) {
      if (minimumSize > nodesLength) minimumSize = nodesLength;
      if (size < minimumSize) size = minimumSize;
    }

    if (maximumSize != null && maximumSize >= 0) {
      if (maximumSize > nodesLength) maximumSize = nodesLength;
      if (size > maximumSize) size = maximumSize;
    }

    var length = this.length;

    var bestVariables = <String>[];
    var bestVariablesSet = <String>{};

    for (var i = length - 1; i >= 0 && bestVariablesSet.length < size; --i) {
      var e = this[i];

      for (var name in e.selectedValues.map((e) => e.variable.name)) {
        if (bestVariablesSet.add(name)) {
          bestVariables.add(name);
        }
      }
    }

    return bestVariables;
  }

  /// Groups [Answer]s by [Answer.selectedValues] [BayesVariable].
  Map<BayesVariable, List<Answer>> groupBySelectedVariable() =>
      this.groupBy((e) => e.selectedValues.first.variable);

  /// Groups [Answer]s by [Answer.targetValue] [BayesVariable].
  Map<BayesVariable, List<Answer>> groupByTargetVariable() =>
      this.groupBy((e) => e.targetValue.variable);

  /// Filters [Answer]s with [Answer.selectedValues] matching [signal].
  List<Answer> withSelectedValueSignal(BayesValueSignal signal) =>
      where((e) => e.selectedValues.any((e) => e.signal == signal)).toList();

  /// Filters [Answer]s with [Answer.name] matching [valueName].
  List<Answer> withSelectedValueName(String valueName) =>
      where((e) => e.selectedValues.any((e) => e.name == valueName)).toList();

  /// Returns the [BayesValue] matching [valueName] [Answer.probability] mean.
  double valueProbabilityMean(String valueName) =>
      withSelectedValueName(valueName).map((e) => e.probability).mean;

  /// Returns the [BayesValue] matching [valueName] [Answer.probabilityUnnormalized] mean.
  double valueProbabilityUnnormalizedMean(String valueName) =>
      withSelectedValueName(valueName)
          .map((e) => e.probabilityUnnormalized)
          .mean;

  /// Returns the performance by [Answer.probability] of opposite values:
  ///
  /// - Formula: `(positiveProbability + (1 - negativeProbability)) / 2`
  ///   - positiveProbability: the mean probability of positive values.
  ///   - negativeProbability: the mean probability of negative values.
  double oppositeValuesPerformance(String positiveValue, String negativeValue) {
    var positiveProb = valueProbabilityMean(positiveValue);
    var negativeProb = valueProbabilityMean(negativeValue);
    var performance = ((positiveProb) + (1 - negativeProb)) / 2;
    return performance;
  }

  /// Returns the performance by [Answer.probabilityUnnormalized] of opposite values:
  ///
  /// - Formula: `(positiveProbability + (1 - negativeProbability)) / 2`
  ///   - positiveProbability: the mean probability unnormalized of positive values.
  ///   - negativeProbability: the mean probability unnormalized of negative values.
  double oppositeValuesPerformanceUnnormalized(
      String positiveValue, String negativeValue) {
    var positiveProb = valueProbabilityUnnormalizedMean(positiveValue);
    var negativeProb = valueProbabilityUnnormalizedMean(negativeValue);
    var performance = ((positiveProb) + (1 - negativeProb)) / 2;
    return performance;
  }
}

extension ListOfListAnswerExtension on List<List<Answer>> {
  /// Sort sub lists by [ListAnswerExtension.oppositeValuesPerformance].
  void sortByOppositeValuesPerformance(
      String positiveValue, String negativeValue) {
    sort((a, b) {
      var p1 = a.oppositeValuesPerformance(positiveValue, negativeValue);
      var p2 = b.oppositeValuesPerformance(positiveValue, negativeValue);
      return p1.compareTo(p2);
    });
  }

  /// Sort sub lists by [ListAnswerExtension.oppositeValuesPerformanceUnnormalized].
  void sortByOppositeValuesPerformanceUnnormalized(
      String positiveValue, String negativeValue) {
    sort((a, b) {
      var p1 =
          a.oppositeValuesPerformanceUnnormalized(positiveValue, negativeValue);
      var p2 =
          b.oppositeValuesPerformanceUnnormalized(positiveValue, negativeValue);
      return p1.compareTo(p2);
    });
  }
}

/// Base class to analyse a [BayesianNetwork].
abstract class BayesAnalyser {
  final BayesianNetwork network;

  BayesAnalyser(this.network);

  final CombinationCache<String, String> _combinationCache =
      CombinationCache<String, String>(
          allowRepetition: false,
          allowSharedCombinations: true,
          mapper: _combinationMapper);

  static List<String> _combinationMapper(String name) => [name, '-$name'];

  /// Generates questions to infer [inferVariable].
  ///
  /// - [combinationsLevel] is the variables combination depth.
  /// - [variables] is provided defines the selected variables.
  /// - [variablesFilter] is provided defines the selected variables (selects when returns `true`).
  /// - [ignoreVariables] is a list of variables to ignore.
  /// - [ignoreVariablesFilter] filters the variables to ignore (ignores when returns `true`).
  List<String> generateQuestions(String inferVariable,
      {bool addPriorQuestions = false,
      int combinationsLevel = 1,
      Iterable<String>? variables,
      bool Function(String name)? variablesFilter,
      Iterable<String>? ignoreVariables,
      bool Function(String name)? ignoreVariablesFilter,
      bool allowEmptySelection = true}) {
    inferVariable =
        BayesVariable.resolveName(inferVariable, networkCache: network);

    var selectedVariables =
        network.variablesNames.where((v) => v != inferVariable).toList();

    if (selectedVariables.isEmpty) {
      if (allowEmptySelection) return <String>[];
      throw StateError("BayesianNetwork empty!");
    }

    if (variables != null) {
      var select = variables
          .map((v) => BayesVariable.resolveName(v, networkCache: network))
          .toSet();
      selectedVariables.retainWhere((e) => select.contains(e));

      if (selectedVariables.isEmpty) {
        if (allowEmptySelection) return <String>[];
        throw StateError("No valid variable in parameter `variables`!");
      }
    }

    if (variablesFilter != null) {
      selectedVariables.retainWhere(variablesFilter);

      if (selectedVariables.isEmpty) {
        if (allowEmptySelection) return <String>[];
        throw StateError("No variables selected by `variablesFilter`!");
      }
    }

    if (ignoreVariables != null) {
      var ignore = ignoreVariables
          .map((v) => BayesVariable.resolveName(v, networkCache: network))
          .toSet();
      selectedVariables.removeWhere((e) => ignore.contains(e));

      if (selectedVariables.isEmpty) {
        if (allowEmptySelection) return <String>[];
        throw StateError(
            "Ignored all variables! ignoreVariables: $ignoreVariables");
      }
    }

    if (ignoreVariablesFilter != null) {
      selectedVariables.removeWhere(ignoreVariablesFilter);

      if (selectedVariables.isEmpty) {
        if (allowEmptySelection) return <String>[];
        throw StateError("Ignored all variables by `ignoreVariablesFilter`!");
      }
    }

    if (combinationsLevel < 1) {
      combinationsLevel = 1;
    } else if (combinationsLevel > selectedVariables.length) {
      combinationsLevel = selectedVariables.length;
    }

    var combinations = _combinationCache.getCombinationsShared(
        selectedVariables.toSet(), 1, combinationsLevel);

    var questions =
        combinations.map((v) => 'P($inferVariable|${v.join(',')})').toList();

    if (addPriorQuestions) {
      questions.add('P($inferVariable)');
      questions.add('P(-$inferVariable)');
    }

    return questions;
  }

  /// Performas a Quiz: Asks all the [questions] and returns the answers sorted
  /// by best probability ([Answer.probability]).
  List<Answer> quiz(List<String> questions,
      {String positive = 'T', String negative = 'F'}) {
    var answers = questions.map((q) => ask(q)).toList();
    answers.sort();
    _definePerformance(answers, positive, negative);
    return answers;
  }

  Answer showAnswer(String query,
      {String positive = 'T', String negative = 'F', bool verbose = false}) {
    var result =
        ask(query, positive: positive, negative: negative, verbose: verbose);
    print(result);
    return result;
  }

  Answer ask(String query,
      {String positive = 'T', String negative = 'F', bool verbose = false}) {
    var answer = _askImpl(query, positive, negative, verbose);
    _definePerformance([answer], positive, negative);
    return answer;
  }

  void _definePerformance(
      List<Answer> answers, String positive, String negative) {
    var groups = answers.groupBy((e) => e.targetValue);

    for (var e in groups.entries) {
      var targetValue = e.key;
      var group = e.value;

      var targetAnswer = _askImpl(
          '${targetValue.variable.name} = ${targetValue.name}',
          positive,
          negative,
          false);
      var targetProbability = targetAnswer.probability;

      for (var answer in group) {
        answer._targetProbability = targetProbability;
      }
    }
  }

  Answer _askImpl(
      String query, String positive, String negative, bool verbose) {
    query = query.trimLeft();
    var originalQuery = query;

    if (query.startsWith('P(') || query.startsWith('p(')) {
      query = parseQuery(query, positive: positive, negative: negative);
    }

    var idx = query.indexOf('|');

    String targetVariable, selectedVariables;

    if (idx >= 0) {
      targetVariable = query.substring(0, idx);
      selectedVariables = query.substring(idx + 1);
    } else {
      targetVariable = query;
      selectedVariables = '';
    }

    var answer = infer(targetVariable, selectedVariables,
        originalQuery: originalQuery, verbose: verbose);
    return answer;
  }

  Answer infer(String targetVariable, String selectedVariables,
      {String? originalQuery, bool verbose = false});

  String parseQuery(String query,
      {String positive = 'T', String negative = 'F'}) {
    var q = query.split('(')[1].split(')')[0].split('|');

    var ret = _convert(q[0], positive: positive, negative: negative) + " | ";

    if (q.length > 1) {
      var evidences = q[1].split(",");
      for (int i = 0; i < evidences.length; i++) {
        ret += _convert(evidences[i], positive: positive, negative: negative) +
            ", ";
      }
      if (evidences.isNotEmpty) {
        ret = ret.substring(0, ret.length - 2);
      }
    }

    return ret;
  }

  String _convert(String s, {String positive = 'T', String negative = 'F'}) {
    s = s.trim();

    var name = BayesValue.resolveName(s, networkCache: network);
    var signal = BayesValue.resolveSignal(name: s);

    var node = network.getNodeByName(name);

    var valueName = node.getValueName(signal: signal);

    if (valueName == null) {
      if (signal == BayesValueSignal.negative) {
        valueName =
            node.getValueName(signal: BayesValueSignal.negative) ?? positive;
      } else {
        valueName =
            node.getValueName(signal: BayesValueSignal.positive) ?? negative;
      }
    }

    return "$name=$valueName";
  }

  @override
  String toString() {
    return '$runtimeType{network: ${network.name}}';
  }
}

/// A [BayesianNetwork] analyser using the "Variable Elimination" method.
class BayesAnalyserVariableElimination extends BayesAnalyser {
  BayesAnalyserVariableElimination(BayesianNetwork network) : super(network);

  @override
  Answer infer(String targetVariable, String selectedVariables,
      {String? originalQuery, bool verbose = false}) {
    // Get target event and evidence objects.
    var target = network.parseEvent(targetVariable);

    var evidence = network._parseCondition(selectedVariables);
    var evidenceVariables = evidence.events.map((e) => e.node).toList();

    // All nodes of the query:
    var selectedNodes = <BayesNode>[target.node, ...evidenceVariables];

    // All nodes in chain to answer the query:
    var nodesInChain =
        selectedNodes.expand((n) => [n, ...n.ancestors]).toSet().toList();

    var dependencies = _selectDependencies(evidenceVariables);

    if (verbose) {
      print('** INFER: $target | $evidence');
      print('-- selectedNodes: ${selectedNodes.nodesNames}');
      print('-- nodesInChain: ${nodesInChain.nodesNames}');

      if (dependencies.isNotEmpty) {
        print('-- dependencies: ${dependencies.nodesNames}');
      }
    }

    // To eliminate in reverse topological ordering.
    var order = nodesInChain.nodesInTopologicalOrder.reversed.toList();

    if (dependencies.isNotEmpty) {
      if (verbose) {
        print('-- Order (no dependencies): ${order.nodesNames}');
      }

      var newOrder = <BayesNode>[];

      for (var node in order) {
        var nodeVariables = node.variables;

        var dependency = dependencies
            .firstWhereOrNull((d) => d.variables.containsAll(nodeVariables));

        if (dependency != null) {
          var alreadyInOrder =
              newOrder.any((e) => e.variables.containsAny(nodeVariables));
          if (!alreadyInOrder) {
            newOrder.add(dependency);
          }
        } else {
          newOrder.add(node);
        }
      }

      order = newOrder;
    }

    if (verbose) {
      print('-- Order: ${order.nodesNames}');
    }

    // For each variable, make it into a factor.
    var factors = <_Factor>[];
    for (var node in order) {
      var f = _Factor(node, evidence, verbose: verbose);
      factors.add(f);

      // if the variable is a hidden variable, then perform sum out
      if (target.node != node && !evidence.mentionAny(node.variables)) {
        var joinedFactors =
            factors.reduce((value, element) => value.product(element));
        joinedFactors.marginalize(node.variables.toList());
        factors.clear();
        factors.add(joinedFactors);
      }
    }

    // Point wise product of all remaining factors.
    var result = factors.reduce((value, element) => value.product(element));

    // Normalize the result factor
    var resultNormalized = result.normalise();

    var probabilityUnnormalized = result.get(BayesCondition([target]));
    var probability = resultNormalized.get(BayesCondition([target]));

    var answer = Answer('$target | $evidence', target.value,
        evidence.events.map((e) => e.value).toList(), probability,
        originalQuery: originalQuery,
        probabilityUnnormalized: probabilityUnnormalized);

    return answer;
  }

  List<BayesDependency> _selectDependencies(List<BayesNode> evidenceVariables) {
    if (network._dependencies.isEmpty || evidenceVariables.isEmpty) {
      return <BayesDependency>[];
    }

    var dependenciesMatching = network._dependencies.values
        .where((d) =>
            d.variables.length <= evidenceVariables.length &&
            evidenceVariables.containsAll(d.variables))
        .toList();

    dependenciesMatching.sort();

    var dependencies = dependenciesMatching
        .where((e) => e.variables.length == evidenceVariables.length)
        .toList();

    dependenciesMatching.removeWhere((e) => dependencies.contains(e));

    while (dependenciesMatching.isNotEmpty) {
      var d = dependenciesMatching[0];

      var mentioned =
          dependenciesMatching.any((e) => e.variables.containsAny(d.variables));
      if (!mentioned) {
        dependenciesMatching.add(d);
      }

      dependenciesMatching.removeAt(0);
    }

    return dependencies;
  }
}

/// A [BayesianNetwork] event monitor.
class BayesEventMonitor implements NetworkCache {
  final String name;

  BayesEventMonitor(this.name);

  @override
  final Map<String, String> _resolvedVariablesNamesCache = <String, String>{};

  @override
  final Map<String, String> _resolvedValuesNamesCache = <String, String>{};

  final Map<ObservedEvent, int> _eventsCount = <ObservedEvent, int>{};

  int get eventsLength => _eventsCount.length;

  /// Notifies an event.
  void notifyEvent(Iterable eventValues, {bool dependency = false}) {
    var event =
        ObservedEvent(eventValues, networkCache: this, dependency: dependency);
    _eventsCount.update(event, (count) => count + 1, ifAbsent: () => 1);
  }

  final List<List<List<String>>> currentObservations = <List<List<String>>>[];

  /// Notifies an observation (an event not finished yet).
  ///
  /// - See [notifyObservationsConclusion].
  void notifyObservation(Iterable<Iterable<String>> observations) {
    var o = observations.map((e) => e.toList()).toList();
    currentObservations.add(o);
  }

  /// Notifies the [conclusion] of all previous observations.
  void notifyObservationsConclusion(Iterable<String> conclusion) {
    var c = conclusion.toList();

    for (var e in currentObservations) {
      e.add(c.toList());
      notifyEvent(e);
    }

    currentObservations.clear();
  }

  /// Instantiates a [BayesianNetwork], calls [populateNodes] and returns it.
  BayesianNetwork buildBayesianNetwork(
      {double unseenMinimalProbability = 0.0000001,
      bool populateDependencies = true}) {
    var network = BayesianNetwork(name,
        unseenMinimalProbability: unseenMinimalProbability);
    populateNodes(network, populateDependencies: populateDependencies);
    return network;
  }

  /// Populates [network] with all recorded events.
  void populateNodes(BayesianNetwork network,
      {bool populateDependencies = true}) {
    var variablesEvents =
        Map.fromEntries(_eventsCount.entries.where((e) => !e.key.dependency));

    var variablesProbabilities =
        _computeProbabilities(network, variablesEvents);

    for (var e in variablesProbabilities.values) {
      network.addVariable(e.name, e.values, e.parents, e.probabilities);
    }

    if (populateDependencies) {
      var dependencyEvents =
          Map.fromEntries(_eventsCount.entries.where((e) => e.key.dependency));

      var dependenciesProbabilities =
          _computeProbabilities(network, dependencyEvents);

      for (var e in dependenciesProbabilities.values) {
        var names = [e.name, ...e.parents];
        var nodes = network
            .getNodesByNames(names)
            .nodesInTopologicalOrder
            .reversed
            .toList();

        var variablesNames = <String>[];
        var parentsNames = <String>[];

        for (var node in nodes) {
          var nodeName = node.name;
          if (!parentsNames.contains(nodeName)) {
            variablesNames.add(nodeName);
            parentsNames.addAll(node.parents.map((e) => e.name));
          }
        }

        network.addDependency(variablesNames, e.probabilities);
      }
    }

    network.freeze();
  }

  LinkedHashMap<String, ObservedEventProbabilities> _computeProbabilities(
      BayesianNetwork network, Map<ObservedEvent, int> _eventsCount) {
    var groups = <String, List<ObservedEvent>>{};
    var totals = <String, int>{};

    for (var e in _eventsCount.entries) {
      var event = e.key;
      var count = e.value;
      var groupKey = event.groupKey;

      groups.update(groupKey, (group) => group..add(event),
          ifAbsent: () => <ObservedEvent>[event]);

      totals.update(groupKey, (total) => total + count, ifAbsent: () => count);
    }

    // Need a sorted `HashMap`:
    var variablesProbabilities =
        // ignore: prefer_collection_literals
        LinkedHashMap<String, ObservedEventProbabilities>();

    var eventsEntries = _eventsCount.entries.toList();
    _sortEventsByTopology(eventsEntries);

    for (var e in eventsEntries) {
      var event = e.key;
      var groupKey = event.groupKey;
      var group = groups[groupKey]!;

      var nodeName = event.values.first.variableName;
      var nodeVariablesNames = event.variablesNamesString;

      if (!variablesProbabilities.containsKey(nodeVariablesNames)) {
        var observationsValues = groups.values
            .expand((e) => e.expand((e) => e.values))
            .where((v) => v.variableName == nodeName)
            .toSet()
            .toList();

        var valuesSignals = <String, BayesValueSignal>{};

        for (var e in observationsValues) {
          valuesSignals.update(e.valueName, (signal) {
            var valueSignal = e.valueSignal;
            if (valueSignal == BayesValueSignal.unknown) {
              return signal;
            }

            if (signal == BayesValueSignal.unknown) {
              return valueSignal;
            } else {
              return signal;
            }
          }, ifAbsent: () => e.valueSignal);
        }

        var valuesNames = observationsValues.map((v) {
          var valueName = v.valueName;
          var valueSignal = valuesSignals[valueName];
          return valueSignal == BayesValueSignal.negative
              ? '-$valueName'
              : valueName;
        }).toList();

        var parents = group
            .expand((g) => g.values.map((v) => v.variableName).skip(1))
            .toSet()
            .toList();

        variablesProbabilities[nodeVariablesNames] =
            ObservedEventProbabilities(nodeName, valuesNames, parents);
      }
    }

    for (var e in eventsEntries) {
      var event = e.key;
      var count = e.value;
      var groupKey = event.groupKey;

      var total = totals[groupKey]!;
      var ratio = count / total;

      var nodeVariablesNames = event.variablesNamesString;
      var variablesProbability = variablesProbabilities[nodeVariablesNames]!;

      var p = '$event: $ratio';

      variablesProbability.probabilities.add(p);
    }

    return variablesProbabilities;
  }

  void _sortEventsByTopology(List<MapEntry<ObservedEvent, int>> entries) {
    entries.sort((a, b) {
      var values1 = a.key.values.toList();
      var values2 = b.key.values.toList();

      var l1 = values1.length;
      var l2 = values2.length;

      var cmp = l1.compareTo(l2);
      if (cmp == 0) {
        cmp = values1.compareWith(values2);
      }

      return cmp;
    });
  }

  @override
  String toString() {
    var entries = _eventsCount.entries.toList();
    _sortEventsByTopology(entries);

    return 'EventMonitor[$name]<\n  '
        '${entries.map((e) => '${e.key}: ${e.value}').join('\n  ')}\n>';
  }
}

class ObservedEventProbabilities {
  final String name;
  final List<String> values;

  final List<String> parents;

  final List<String> probabilities = <String>[];

  ObservedEventProbabilities(this.name, this.values, this.parents);
}

class ObservedEvent {
  final bool dependency;
  final Set<ObservedEventValue> _values;

  ObservedEvent(Iterable values,
      {required NetworkCache? networkCache, this.dependency = false})
      : _values = values
            .map((pair) => ObservedEventValue(pair, networkCache: networkCache))
            .toSet();

  Set<ObservedEventValue> get values => UnmodifiableSetView(_values);

  List<String> get variablesNames => values.map((v) => v.variableName).toList();

  String? _variablesNamesString;

  String get variablesNamesString =>
      _variablesNamesString ??= variablesNames.join(',');

  static final _setEquality = SetEquality<ObservedEventValue>();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObservedEvent &&
          runtimeType == other.runtimeType &&
          dependency == other.dependency &&
          _setEquality.equals(_values, other._values);

  @override
  int get hashCode => _setEquality.hash(_values) ^ dependency.hashCode;

  String? _groupKey;

  String get groupKey => _groupKey ??= _groupKeyImpl();

  String _groupKeyImpl() {
    var s = toString();
    var idx = s.indexOf('=');

    var main = s.substring(0, idx).trim();

    idx = s.indexOf(',');
    if (idx < 0) {
      return main;
    }

    var rest = s.substring(idx);

    var k = '$main$rest${dependency ? ' <->' : ''}';
    return k;
  }

  String? _str;

  @override
  String toString() => _str ??= _values.join(', ');
}

class ObservedEventValue implements Comparable<ObservedEventValue> {
  final String variableName;
  final String valueName;
  final BayesValueSignal valueSignal;

  ObservedEventValue._(String variable, String value,
      {required NetworkCache? networkCache})
      : variableName =
            BayesVariable.resolveName(variable, networkCache: networkCache),
        valueName = BayesValue.resolveName(value, networkCache: networkCache),
        valueSignal = BayesValue.resolveSignal();

  factory ObservedEventValue(Object o, {required NetworkCache? networkCache}) {
    if (o is ObservedEventValue) return o;

    if (o is MapEntry) {
      return ObservedEventValue._(
          o.key.toString(), _resolveValueToString(o.value),
          networkCache: networkCache);
    }

    if (o is Pair) {
      return ObservedEventValue._(o.a.toString(), _resolveValueToString(o.b),
          networkCache: networkCache);
    }

    if (o is Iterable<String>) {
      return ObservedEventValue._(o.elementAt(0), o.elementAt(1),
          networkCache: networkCache);
    }

    if (o is Iterable) {
      var variable = o.elementAt(0).toString();
      var value = o.elementAt(1);
      var valueStr = _resolveValueToString(value);

      return ObservedEventValue._(variable, valueStr,
          networkCache: networkCache);
    }

    if (o is String) {
      var idx = o.indexOf('=');

      String variable, value;

      if (idx >= 0) {
        variable = o.substring(0, idx);
        value = o.substring(idx + 1);
      } else {
        o = o.trimLeft();

        if (o.startsWith('-')) {
          variable = o.substring(1);
          value = 'F';
        } else {
          variable = o;
          value = 'T';
        }
      }

      return ObservedEventValue._(variable, value, networkCache: networkCache);
    }

    throw StateError("Can't parse: $o");
  }

  static String _resolveValueToString(Object value) {
    if (value is bool) {
      return value ? 'T' : 'F';
    } else {
      return value.toString();
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObservedEventValue &&
          runtimeType == other.runtimeType &&
          variableName == other.variableName &&
          valueName == other.valueName;

  @override
  int get hashCode => variableName.hashCode ^ valueName.hashCode;

  @override
  int compareTo(ObservedEventValue other) {
    if (identical(this, other)) return 0;

    var cmp = variableName.compareTo(other.variableName);
    if (cmp == 0) {
      cmp = valueName.compareTo(other.valueName);
    }
    return cmp;
  }

  String? _str;

  @override
  String toString() => _str ??= '$variableName = $valueName';
}

class _IterableKey<T> {
  final Iterable<T> _iterable;

  late final Equality<Iterable?> _equality;

  _IterableKey(this._iterable) : _equality = _resolveEquality(_iterable);

  static final _setEquality = SetEquality();
  static final _listEquality = ListEquality();
  static final _iterableEquality = IterableEquality();

  static Equality<Iterable?> _resolveEquality(Iterable _iterable) {
    if (_iterable is Set) {
      return _setEquality;
    } else if (_iterable is List) {
      return _listEquality;
    } else {
      return _iterableEquality;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _IterableKey &&
          runtimeType == other.runtimeType &&
          _equality.equals(_iterable, other._iterable);

  int? _hashCode;

  @override
  int get hashCode => _hashCode ??= _equality.hash(_iterable);
}
