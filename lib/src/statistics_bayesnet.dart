/*
Part of this code was inspired by the Java project:
- https://github.com/Cansn0w/BayesianNetwork
- MIT License
- Authors:
  - Di Lu
  - Chenrui Liu
*/

import 'package:collection/collection.dart';

import 'statistics_extension_num.dart';

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

/// An interface for a network cache. This stores some internal resolutions.
abstract class NetworkCache {
  Map<String, String> get _resolvedVariablesNamesCache;

  Map<String, String> get _resolvedValuesNamesCache;
}

/// A Bayesian Network implementation.
class BayesianNetwork extends Iterable<String>
    with Validatable
    implements NetworkCache {
  /// Name of the network.
  final String name;
  final Map<String, Variable> _nodes = <String, Variable>{};

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

  /// The root [Variable] nodes.
  List<Variable> get rootNodes => _nodes.values.where((e) => e.isRoot).toList();

  /// All the [Variable] nodes of this network.
  List<Variable> get nodes => _nodes.values.toList();

  /// All the [Variable] nodes of this network in a sorted in a topological order.
  List<Variable> get nodesInTopologicalOrder => nodes.nodesInTopologicalOrder;

  final Map<_IterableKey<Variable>, List<Variable>> _nodesInChainCache =
      <_IterableKey<Variable>, List<Variable>>{};

  /// Returns the [Variable] nodes in the chain composed by [selectedNodes].
  List<Variable> nodesInChain(Iterable<Variable> selectedNodes) {
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

  List<Variable> _nodesInChainImpl(
      Set<Variable> selectedNodesSet, Iterable<Variable> selectedNodes) {
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

  /// Returns the total number of [Variable] nodes of this network.
  int get nodesLength => _nodes.length;

  /// Returns all the [Variable] nodes names.
  List<String> get variablesNames => _nodes.keys.toList();

  Analyser? _analyser;

  /// Returns an [Analyser].
  ///
  /// - Default implementation: [VariableElimination].
  Analyser get analyser {
    freeze();
    return _analyser ??= VariableElimination(this);
  }

  /// Adds a [Variable] node, with [values] and [parents] and [probabilities].
  Variable addNode(String name, List<String> values, List<String> parents,
      List<String> probabilities,
      {double? unseenMinimalProbability}) {
    _checkNotFrozen();

    unseenMinimalProbability ??= this.unseenMinimalProbability;

    var node = Variable(name, this,
        values: values, parents: parents, probabilities: probabilities);

    for (var n in node.parents) {
      n._addChild(node);
    }

    node.checkValid();

    _disposeInternalCaches();

    return node;
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

  void _checkNotFrozen() {
    if (isFrozen) {
      throw StateError("Network already frozen!");
    }
  }

  bool _frozen = false;

  bool get isFrozen => _frozen;

  /// Freezes the network turning it immutable.
  void freeze() {
    if (_frozen) return;
    _frozen = true;

    for (var n in _nodes.values) {
      n.freeze();
    }
  }

  /// Returns `true` if contains a node with [name].
  bool hasNode(String name) => _nodes.containsKey(name);

  /// Returns a [Variable] node with [name].
  Variable getNode(String name) {
    var node = _nodes[name];
    if (node == null) {
      throw StateError("No such variable <" + name + ">.");
    }
    return node;
  }

  Condition _parseCondition(String line) {
    line = line.replaceAll(_regexpSpace, '');
    var cond = line.split(
        ","); // where cond (conditions) is like ["a=true", "weather=sunny"]

    var conditionList = <Event>[];
    for (var event in cond) {
      if (event.isNotEmpty) {
        conditionList.add(parseEvent(event));
      }
    }
    return Condition(conditionList);
  }

  Event parseEvent(String line) {
    line = line.replaceAll(_regexpSpace, '');
    var e = line.split("=");
    var name = e[0];
    var node = _nodes[name];
    if (node == null) {
      throw StateError('No such variable <' + e[0] + ">.");
    }

    return node.parseEvent(line);
  }

  @override
  Iterator<String> get iterator => _nodes.keys.iterator;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BayesianNetwork &&
          runtimeType == other.runtimeType &&
          _listEqualityVariable.equals(_nodes.values, other._nodes.values);

  static final _listEqualityVariable = IterableEquality<Variable>();

  @override
  int get hashCode => _listEqualityVariable.hash(_nodes.values);

  @override
  String toString() {
    return 'BayesianNetwork[$name]{ variables: ${_nodes.length} }<\n${_nodes.values.join('\n')}\n>';
  }
}

/// A [Value] signal.
enum ValueSignal {
  positive,
  negative,
  unknown,
}

/// A value in a [BayesianNetwork].
class Value extends Validatable implements Comparable<Value> {
  /// Name of the value.
  final String name;

  /// Variable of this value.
  final Variable variable;

  /// Signal of this value.
  final ValueSignal signal;

  Value(String name, this.variable, {ValueSignal? signal})
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

  static ValueSignal resolveSignal({ValueSignal? signal, String? name}) {
    if (signal != null) return signal;

    if (name == null) return ValueSignal.unknown;

    name = name.trimLeft();

    return name.startsWith('-')
        ? ValueSignal.negative
        : (name.startsWith('+') ? ValueSignal.positive : ValueSignal.unknown);
  }

  @override
  Object? validate() => variable.validate();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Value &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          variable == other.variable;

  @override
  int get hashCode => name.hashCode ^ variable.hashCode;

  @override
  int compareTo(Value other) {
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
class Event implements Comparable<Event> {
  final Variable node;
  late final Value value;

  Event(this.node, this.value) {
    if (!node.domain.containsValue(value)) {
      throw ValidationError(
          'Variable <${node.name}> does not contain the value "$value".');
    }
  }

  Event.byOutcomeName(this.node, String outcomeName) {
    var value = node.domain[outcomeName];

    if (value == null) {
      throw ValidationError(
          'Variable <${node.name}> does not contain the value "$outcomeName".');
    }

    this.value = value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          runtimeType == other.runtimeType &&
          node == other.node &&
          value == other.value;

  @override
  int get hashCode => node.hashCode ^ value.hashCode;

  @override
  int compareTo(Event other) {
    if (identical(this, other)) return 0;

    if (node == other.node) {
      return value.compareTo(other.value);
    } else {
      return node.name.compareTo(other.node.name);
    }
  }

  @override
  String toString() {
    return "${node.name} = ${value.name}";
  }
}

/// A variable in the [BayesianNetwork] graph.
class Variable extends Validatable implements Comparable<Variable> {
  /// The name of the variable.
  final String name;

  /// The network of this variable.
  final BayesianNetwork network;

  final List<Variable> _parents = <Variable>[];
  final List<Variable> _children = <Variable>[];
  final Map<String, Value> _domain = <String, Value>{};

  final Map<Condition, double> _probabilities = <Condition, double>{};

  Variable(String name, this.network,
      {List<String>? values,
      List<String>? parents,
      List<String>? probabilities})
      : name = resolveName(name, networkCache: network) {
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

    {
      var unseenMinimalProbability = network.unseenMinimalProbability;

      var nodes = _parents.toList();
      nodes.add(this);

      var conditions = Condition.allConditions(nodes);
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
    if (_probabilities.values.any((n) => n.isNaN || n.isInfinite)) {
      return this;
    }

    if (_children.isNotEmpty) {
      var invalidChild =
          _children.map((e) => e.validate()).firstWhereOrNull((e) => e != null);

      if (invalidChild != null) {
        return invalidChild;
      }
    }

    return null;
  }

  bool get isRoot => _parents.isEmpty;

  int get parentsLength => _parents.length;

  List<Variable> get parents => UnmodifiableListView<Variable>(_parents);

  bool containsNode(Variable node) {
    for (var c in _children) {
      if (c == node) return true;
    }

    for (var c in _children) {
      if (c.containsNode(node)) return true;
    }

    return false;
  }

  List<Variable> nodeChain(Variable node) {
    if (_children.isEmpty) return <Variable>[];

    for (var c in _children) {
      if (c == node) return <Variable>[this, c];
    }

    var chains = _children
        .map((e) => e.nodeChain(node))
        .where((c) => c.isNotEmpty)
        .map((c) => [this, ...c])
        .toList();

    return _shortestChain(chains);
  }

  List<Variable> _shortestChain(List<List<Variable>> chains) {
    if (chains.isEmpty) return <Variable>[];
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

  List<Variable>? _rootNodes;

  /// Returns the root nodes of this node.
  List<Variable> get rootNodes => (_rootNodes ??= _rootNodesImpl()).toList();

  List<Variable> _rootNodesImpl() =>
      network.rootNodes.where((e) => e.containsNode(this)).toList();

  List<Variable>? _rootChain;

  /// Returns the smallest chain until the root.
  List<Variable> get rootChain => (_rootChain ??= _rootChainImpl()).toList();

  List<Variable> _rootChainImpl() {
    var rootNodes = this.rootNodes;
    if (rootNodes.isEmpty) return <Variable>[this];

    var chains = rootNodes.map((r) => r.nodeChain(this)).toList();
    return _shortestChain(chains);
  }

  List<List<Variable>>? _rootChains;

  /// Returns all the chains until the root.
  List<List<Variable>> get rootChains =>
      (_rootChains ??= _rootChainsImpl()).map((e) => e.toList()).toList();

  List<List<Variable>> _rootChainsImpl() {
    var rootNodes = this.rootNodes;
    if (rootNodes.isEmpty) {
      return <List<Variable>>[
        <Variable>[this]
      ];
    }

    var chains = rootNodes.map((r) => r.nodeChain(this)).toList();
    return chains;
  }

  Set<Variable>? _ancestors;

  /// Returns the ancestors [Variable] nodes of this node.
  Set<Variable> get ancestors => (_ancestors ??= _ancestorsImpl()).toSet();

  Set<Variable> _ancestorsImpl() {
    if (_parents.isEmpty) return <Variable>{};
    var list = _parents.expand((p) => [p, ...p.ancestors]).toSet();
    return list;
  }

  /// The domain values of this node.
  Map<String, Value> get domain => UnmodifiableMapView<String, Value>(_domain);

  /// The probability table of this node.
  Map<Condition, double> get probabilities =>
      UnmodifiableMapView<Condition, double>(_probabilities);

  void _addChild(Variable node) {
    _checkNotFrozen();

    _children.add(node);
    _disposeCaches();
  }

  void _checkNotFrozen() {
    if (isFrozen) {
      throw StateError("Network already frozen!");
    }
  }

  bool _frozen = false;

  bool get isFrozen => _frozen;

  void freeze() {
    if (_frozen) return;
    _frozen = true;
  }

  Event parseEvent(String line) {
    line = line.replaceAll(_regexpSpace, '');
    var e = line.split("=");
    if (e.length != 2) {
      throw ValidationError("Expected \"variable=value\", received " + line);
    }

    var name = e[0];
    var node = network.getNode(name);

    return Event.byOutcomeName(node, e[1]);
  }

  Condition _parseCondition(String line) {
    line = line.replaceAll(_regexpSpace, '');

    var eventsStr = line.split(",");
    if (eventsStr.length != _parents.length + 1) {
      throw ValidationError(
          "Number of events (${eventsStr.length}) mismatches required number (${_parents.length + 1}): $line");
    }

    var events = eventsStr.map(parseEvent).toList();
    return Condition(events);
  }

  /// Returns a probability for [condition] in the [probabilities] table.
  double? getProbability(String condition) =>
      _probabilities[_parseCondition(condition)];

  void _addParentByName(String name) {
    _checkNotFrozen();

    try {
      _addParent(network.getNode(name));
    } catch (e) {
      throw ValidationError(
          'The specified parent node "$name" does not exist (yet).');
    }
  }

  void _addParent(Variable parent) {
    _checkNotFrozen();
    _parents.add(parent);
    _disposeCaches();
  }

  void _addValue(String name) {
    _checkNotFrozen();

    if (_domain.containsKey(name)) {
      throw ValidationError('Value with name "$name" already exists.');
    }

    var value = Value(name, this);
    _domain[value.name] = value;

    _disposeCaches();
  }

  void _addProbability(String line) {
    _checkNotFrozen();

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
      throw ValidationError("Provided condition mismatch.");
    }
  }

  /// Returns a value with [name] in this node.
  Value? getValue(String name) => _domain[name];

  /// Returns the name of a value in this node with [name] or [signal].
  String? getValueName({String? name, ValueSignal? signal}) {
    if (name != null) {
      name = Value.resolveName(name, networkCache: network);
      if (_domain.containsKey(name)) {
        return name;
      }
    }

    if (signal != null && signal != ValueSignal.unknown) {
      var values = _domain.values.where((e) => e.signal == signal).toList();
      if (values.isNotEmpty) {
        return values.first.name;
      }
    }

    if (_domain.length == 2) {
      var valuesNames = _domain.keys.toList();
      valuesNames.sort();

      if (valuesNames.equals(['F', 'T'])) {
        return signal == ValueSignal.negative ? 'F' : 'T';
      } else if (valuesNames.equals(['0', '1'])) {
        return signal == ValueSignal.negative ? '0' : '1';
      } else if (valuesNames.equals(['N', 'P'])) {
        return signal == ValueSignal.negative ? 'N' : 'P';
      } else if (valuesNames.equals(['N', 'Y'])) {
        return signal == ValueSignal.negative ? 'N' : 'Y';
      } else if (valuesNames.equals(['N', 'S'])) {
        return signal == ValueSignal.negative ? 'N' : 'S';
      } else if (valuesNames.equals(['NO', 'YES'])) {
        return signal == ValueSignal.negative ? 'NO' : 'YES';
      } else if (valuesNames.equals(['FALSE', 'TRUE'])) {
        return signal == ValueSignal.negative ? 'FALSE' : 'TRUE';
      } else if (valuesNames.equals(['NEGATIVE', 'POSITIVE'])) {
        return signal == ValueSignal.negative ? 'NEGATIVE' : 'POSITIVE';
      }
    }

    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Variable &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          network == other.network;

  @override
  int get hashCode => name.hashCode ^ network.nodesLength;

  @override
  String toString() {
    var s = '$name: [' + _parents.map((v) => v.name).join(', ') + ']';

    if (_probabilities.isNotEmpty) {
      s += '\n  ';

      var entries = _probabilities.entries.toList();

      entries.sort((a, b) {
        var c1 = a.key;
        var c2 = b.key;
        //return c1.compareTo(c2, mainVariable: name);
        return c1.compareTo(c2);
      });

      s += entries
          .map((e) => '${e.key.toString(mainVariable: name)}: ${e.value}')
          .join('\n  ');
    }

    return s;
  }

  @override
  int compareTo(Variable other) {
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

extension ListVariableExtension on List<Variable> {
  /// Returns this [Variable] [List] in a topological order.
  List<Variable> get nodesInTopologicalOrder {
    var nodes = this;

    var nodesRootChains = Map<Variable, List<Variable>>.fromEntries(
      nodes.map((e) => MapEntry<Variable, List<Variable>>(e, e.rootChain)),
    );

    nodes.sort((a, b) {
      var root1 = a.isRoot;
      var root2 = b.isRoot;

      if (root1 && root2) {
        return a.name.compareTo(b.name);
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
class Condition extends Iterable<Event> implements Comparable<Condition> {
  static List<Condition> allConditions(List<Variable> nodes) {
    var ret = <Condition>[];
    _fill(nodes, ret, <Event>[]);
    return ret;
  }

  static void _fill(
      List<Variable> src, List<Condition> dest, List<Event> walked) {
    if (src.length == walked.length) {
      dest.add(Condition(walked));
      return;
    }

    var current = src[walked.length];
    for (var v in current.domain.values) {
      var w = walked.toList();
      w.add(Event(current, v));
      _fill(src, dest, w);
    }
  }

  final List<Event> _events;

  Condition(List<Event> l) : _events = List.from(l)..sort();

  BayesianNetwork get network => _events.first.node.network;

  List<Event> get events => UnmodifiableListView(_events);

  bool containsEvent(Event event) => _events.contains(event);

  bool containsCondition(Condition condition) =>
      condition.events.any((e) => containsEvent(e));

  bool mention(Variable node) {
    for (var e in _events) {
      if (e.node == node) return true;
    }
    return false;
  }

  @override
  Iterator<Event> get iterator => _events.iterator;

  static final _listEqualityEvent = ListEquality<Event>();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Condition &&
          runtimeType == other.runtimeType &&
          _listEqualityEvent.equals(_events, other._events);

  @override
  int get hashCode => _listEqualityEvent.hash(_events);

  @override
  String toString({String? mainVariable}) {
    if (mainVariable != null) {
      mainVariable = Variable.resolveName(mainVariable, networkCache: network);
      var mainEvents =
          _events.where((e) => e.node.name == mainVariable).toList();
      var otherEvents =
          _events.where((e) => e.node.name != mainVariable).toList();

      if (mainEvents.isNotEmpty && otherEvents.isNotEmpty) {
        return mainEvents.join(', ') + ', ' + otherEvents.join(', ');
      }
    }

    return _events.join(', ');
  }

  @override
  int compareTo(Condition other, {String? mainVariable}) {
    if (identical(this, other)) return 0;

    if (mainVariable != null) {
      mainVariable = Variable.resolveName(mainVariable, networkCache: network);

      var mainEvents1 =
          _events.where((e) => e.node.name == mainVariable).toList();
      var mainEvents2 =
          other._events.where((e) => e.node.name == mainVariable).toList();

      var cmp = mainEvents1.compareWith(mainEvents2);
      if (cmp == 0) {
        var otherEvents1 =
            _events.where((e) => e.node.name != mainVariable).toList();
        var otherEvents2 =
            other._events.where((e) => e.node.name != mainVariable).toList();

        cmp = otherEvents1.compareWith(otherEvents2);
      }

      return cmp;
    }

    return _events.compareWith(other._events);
  }
}

/// Helper class for the [VariableElimination] analyser.
class _Factor {
  final List<Variable> _variables;
  Map<Condition, double> _probabilities;

  _Factor._(this._variables, this._probabilities);

  _Factor(Variable v, Condition evidence)
      : _variables = v.parents.toList(),
        _probabilities = Map<Condition, double>.from(v.probabilities) {
    _variables.add(v);

    for (var e in evidence) {
      if (_variables.contains(e.node)) {
        var newP = <Condition, double>{};
        for (var c in _probabilities.keys) {
          if (c.containsEvent(e)) {
            newP[c] = _probabilities[c]!;
          }
        }
        _probabilities = newP;
        marginalize(e.node);
      }
    }
  }

  double get(Condition cond) {
    var p = _probabilities[cond];
    if (p == null) {
      throw StateError("Can't find probability for: $cond");
    }
    return p;
  }

  void marginalize(Variable eliminateNode) {
    if (!_variables.remove(eliminateNode)) {
      throw StateError(
          "This factor does not contain the variable <${eliminateNode.name}> to eliminate.");
    }

    var newP = <Condition, double>{};
    var allConditions = Condition.allConditions(_variables);

    for (var cond in allConditions) {
      newP[cond] = 0.0;
    }

    for (var c in newP.keys) {
      for (var oldC in _probabilities.keys) {
        if (oldC.containsCondition(c)) {
          newP[c] = newP[c]! + _probabilities[oldC]!;
        }
      }
    }

    _probabilities = newP;
  }

  _Factor product(_Factor other) {
    var newVars = _variables.toList();
    newVars.addAll(other._variables);
    newVars = newVars.toSet().toList();

    var allConditions = Condition.allConditions(newVars);

    // compute the joined probability table;
    var newP = <Condition, double>{};
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

    var newP = <Condition, double>{};

    if (sumP == 0.0) {
      for (var e in _probabilities.entries) {
        newP[e.key] = 0.0;
      }
    } else {
      for (var e in _probabilities.entries) {
        newP[e.key] = e.value / sumP;
      }
    }

    return _Factor._(_variables.toList(), newP);
  }

  @override
  String toString() {
    return _probabilities.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}

/// [Analyser] answer. See [Analyser.ask].
class Answer implements Comparable<Answer> {
  /// The query for this answer.
  final String query;

  /// The [query] target value.
  final Value targetValue;

  /// The selected values in the [query].
  final List<Value> selectedValues;

  /// The [targetValue] probability.
  final double probability;

  /// The [targetValue] probability before normalization.
  final double probabilityUnnormalized;

  /// The original unparsed query.
  final String originalQuery;

  Answer(this.query, this.targetValue, this.selectedValues, this.probability,
      {String? originalQuery, double? probabilityUnnormalized})
      : originalQuery = originalQuery ?? query,
        probabilityUnnormalized = probabilityUnnormalized ?? probability;

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

    if (originalQuery != query) {
      return '$originalQuery -> $query -> $probability$pUnnormalized';
    } else {
      return '$query -> $probability$pUnnormalized';
    }
  }

  @override
  int compareTo(Answer other) {
    if (identical(this, other)) return 0;

    var cmp = probability.compareTo(other.probability);
    if (cmp == 0) {
      cmp = query.compareTo(other.query);
    }
    return cmp;
  }
}

/// Base class to analyse a [BayesianNetwork].
abstract class Analyser {
  final BayesianNetwork network;

  Analyser(this.network);

  /// Generates questions to infer [inferVariable].
  ///
  /// - [combinationsLevel] is the variables combination depth.
  /// - [variables] is provided defines the selected variables.
  /// - [variablesFilter] is provided defines the selected variables (selects when returns `true`).
  /// - [ignoreVariables] is a list of variables to ignore.
  /// - [ignoreVariablesFilter] filters the variables to ignore (ignores when returns `true`).
  List<String> generateQuestions(String inferVariable,
      {int combinationsLevel = 1,
      Iterable<String>? variables,
      bool Function(String name)? variablesFilter,
      Iterable<String>? ignoreVariables,
      bool Function(String name)? ignoreVariablesFilter}) {
    inferVariable = Variable.resolveName(inferVariable, networkCache: network);

    var selectedVariables =
        network.variablesNames.where((v) => v != inferVariable).toList();

    if (selectedVariables.isEmpty) {
      throw StateError("BayesianNetwork empty!");
    }

    if (variables != null) {
      var select = variables
          .map((v) => Variable.resolveName(v, networkCache: network))
          .toSet();
      selectedVariables.retainWhere((e) => select.contains(e));

      if (selectedVariables.isEmpty) {
        throw StateError("No valid variable in parameter `variables`!");
      }
    }

    if (variablesFilter != null) {
      selectedVariables.retainWhere(variablesFilter);

      if (selectedVariables.isEmpty) {
        throw StateError("No variables selected by `variablesFilter`!");
      }
    }

    if (ignoreVariables != null) {
      var ignore = ignoreVariables
          .map((v) => Variable.resolveName(v, networkCache: network))
          .toSet();
      selectedVariables.removeWhere((e) => ignore.contains(e));

      if (selectedVariables.isEmpty) {
        throw StateError(
            "Ignored all variables! ignoreVariables: $ignoreVariables");
      }
    }

    if (ignoreVariablesFilter != null) {
      selectedVariables.removeWhere(ignoreVariablesFilter);

      if (selectedVariables.isEmpty) {
        throw StateError("Ignored all variables by `ignoreVariablesFilter`!");
      }
    }

    if (combinationsLevel < 1) {
      combinationsLevel = 1;
    } else if (combinationsLevel > selectedVariables.length) {
      combinationsLevel = selectedVariables.length;
    }

    var questions = <String>[];

    if (combinationsLevel >= 1) {
      for (var v1 in selectedVariables) {
        questions.add('P($inferVariable|$v1)');
        questions.add('P($inferVariable|-$v1)');
      }
    }

    if (combinationsLevel >= 2) {
      var length = selectedVariables.length;

      for (var i = 0; i < length; ++i) {
        var v1 = selectedVariables[i];
        for (var j = i + 1; j < length; ++j) {
          var v2 = selectedVariables[j];

          questions.add('P($inferVariable|$v1,$v2)');
          questions.add('P($inferVariable|$v1,-$v2)');
          questions.add('P($inferVariable|-$v1,$v2)');
          questions.add('P($inferVariable|-$v1,-$v2)');
        }
      }
    }

    if (combinationsLevel >= 3) {
      var length = selectedVariables.length;

      for (var i = 0; i < length; ++i) {
        var v1 = selectedVariables[i];
        for (var j = i + 1; j < length; ++j) {
          var v2 = selectedVariables[j];

          for (var k = j + 1; k < length; ++k) {
            var v3 = selectedVariables[k];

            questions.add('P($inferVariable|$v1,$v2,$v3)');
            questions.add('P($inferVariable|$v1,$v2,-$v3)');

            questions.add('P($inferVariable|$v1,-$v2,$v3)');
            questions.add('P($inferVariable|$v1,-$v2,-$v3)');

            questions.add('P($inferVariable|-$v1,$v2,$v3)');
            questions.add('P($inferVariable|-$v1,$v2,-$v3)');

            questions.add('P($inferVariable|-$v1,-$v2,$v3)');
            questions.add('P($inferVariable|-$v1,-$v2,-$v3)');
          }
        }
      }
    }

    if (combinationsLevel >= 4) {
      throw UnsupportedError(
          "Can't generate combinationsLevel: $combinationsLevel");
    }

    return questions;
  }

  /// Performas a Quiz: Asks all the [questions] and returns the answers sorted
  /// by best probability ([Answer.probability]).
  List<Answer> quiz(List<String> questions,
      {String positive = 'T', String negative = 'F'}) {
    var answers = questions.map((q) => ask(q)).toList();
    answers.sort();
    return answers;
  }

  Answer showAnswer(String query,
      {String positive = 'T', String negative = 'F'}) {
    var result = ask(query, positive: positive, negative: negative);
    print(result);
    return result;
  }

  Answer ask(String query, {String positive = 'T', String negative = 'F'}) {
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

    var answer =
        infer(targetVariable, selectedVariables, originalQuery: originalQuery);
    return answer;
  }

  Answer infer(String targetVariable, String selectedVariables,
      {String? originalQuery});

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

    var name = Value.resolveName(s, networkCache: network);
    var signal = Value.resolveSignal(name: s);

    var node = network.getNode(name);

    var valueName = node.getValueName(signal: signal);

    if (valueName == null) {
      if (signal == ValueSignal.negative) {
        valueName = node.getValueName(signal: ValueSignal.negative) ?? positive;
      } else {
        valueName = node.getValueName(signal: ValueSignal.positive) ?? negative;
      }
    }

    return "$name=$valueName";
  }

  @override
  String toString() {
    return '$runtimeType{network: ${network.name}';
  }
}

/// A [BayesianNetwork] analyser using the "Variable Elimination" method.
class VariableElimination extends Analyser {
  VariableElimination(BayesianNetwork network) : super(network);

  @override
  Answer infer(String targetVariable, String selectedVariables,
      {String? originalQuery}) {
    // Get target event and evidence objects.
    var target = network.parseEvent(targetVariable);
    var evidence = network._parseCondition(selectedVariables);

    // All nodes of the query:
    var selectedNodes = [target.node, ...evidence.events.map((e) => e.node)];

    // All nodes in chain to answer the query:
    var nodesInChain =
        selectedNodes.expand((n) => [n, ...n.ancestors]).toSet().toList();

    // To eliminate in reverse topological ordering.
    var order = nodesInChain.nodesInTopologicalOrder.reversed.toList();

    // For each variable, make it into a factor.
    var factors = <_Factor>[];
    for (Variable v in order) {
      var f = _Factor(v, evidence);
      factors.add(f);

      // if the variable is a hidden variable, then perform sum out
      if (target.node != v && !evidence.mention(v)) {
        var joinedFactors =
            factors.reduce((value, element) => value.product(element));
        joinedFactors.marginalize(v);
        factors.clear();
        factors.add(joinedFactors);
      }
    }

    // Point wise product of all remaining factors.
    var result = factors.reduce((value, element) => value.product(element));

    // Normalize the result factor
    var resultNormalized = result.normalise();

    var probabilityUnnormalized = result.get(Condition([target]));
    var probability = resultNormalized.get(Condition([target]));

    var answer = Answer('$target | $evidence', target.value,
        evidence.events.map((e) => e.value).toList(), probability,
        originalQuery: originalQuery,
        probabilityUnnormalized: probabilityUnnormalized);

    return answer;
  }
}

/// A [BayesianNetwork] event monitor.
class EventMonitor implements NetworkCache {
  final String name;

  EventMonitor(this.name);

  @override
  final Map<String, String> _resolvedVariablesNamesCache = <String, String>{};

  @override
  final Map<String, String> _resolvedValuesNamesCache = <String, String>{};

  final Map<ObservedEvent, int> _eventsCount = <ObservedEvent, int>{};

  int get eventsLength => _eventsCount.length;

  /// Notifies an event.
  void notifyEvent(Iterable eventValues) {
    var event = ObservedEvent(eventValues, networkCache: this);
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
      {double unseenMinimalProbability = 0.0000001}) {
    var network = BayesianNetwork(name,
        unseenMinimalProbability: unseenMinimalProbability);
    populateNodes(network);
    return network;
  }

  /// Populates [network] with all recorded events.
  void populateNodes(BayesianNetwork network) {
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

    var variablesProbabilities = <String, ObservedEventProbabilities>{};

    for (var e in _eventsCount.entries) {
      var event = e.key;
      var groupKey = event.groupKey;
      var group = groups[groupKey]!;

      var name = event.values.first.variableName;

      if (!variablesProbabilities.containsKey(name)) {
        var observations = groups.values
            .expand((e) => e.expand((e) => e.values))
            .where((v) => v.variableName == name)
            .toSet()
            .toList();

        var valuesSignals = <String, ValueSignal>{};

        for (var e in observations) {
          valuesSignals.update(e.valueName, (signal) {
            var valueSignal = e.valueSignal;
            if (valueSignal == ValueSignal.unknown) {
              return signal;
            }

            if (signal == ValueSignal.unknown) {
              return valueSignal;
            } else {
              return signal;
            }
          }, ifAbsent: () => e.valueSignal);
        }

        var valuesNames = observations.map((v) {
          var valueName = v.valueName;
          var valueSignal = valuesSignals[valueName];
          return valueSignal == ValueSignal.negative
              ? '-$valueName'
              : valueName;
        }).toList();

        var parents = group
            .expand((g) => g.values.map((v) => v.variableName).skip(1))
            .toSet()
            .toList();

        variablesProbabilities[name] =
            ObservedEventProbabilities(name, valuesNames, parents);
      }
    }

    for (var e in _eventsCount.entries) {
      var event = e.key;
      var count = e.value;
      var groupKey = event.groupKey;

      var total = totals[groupKey]!;
      var ratio = count / total;

      var variableName = event.values.first.variableName;
      var variablesProbability = variablesProbabilities[variableName]!;

      var p = '$event: $ratio';

      variablesProbability.probabilities.add(p);
    }

    for (var e in variablesProbabilities.values) {
      network.addNode(e.name, e.values, e.parents, e.probabilities);
    }

    network.freeze();
  }

  @override
  String toString() {
    var entries = _eventsCount.entries.toList();

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
  final Set<ObservedEventValue> _values;

  ObservedEvent(Iterable values, {required NetworkCache? networkCache})
      : _values = values
            .map((pair) => ObservedEventValue(pair, networkCache: networkCache))
            .toSet();

  Set<ObservedEventValue> get values => UnmodifiableSetView(_values);

  static final _setEquality = SetEquality<ObservedEventValue>();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObservedEvent &&
          runtimeType == other.runtimeType &&
          _setEquality.equals(_values, other._values);

  @override
  int get hashCode => _setEquality.hash(_values);

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

    var k = '$main$rest';
    return k;
  }

  String? _str;

  @override
  String toString() => _str ??= _values.join(', ');
}

class ObservedEventValue implements Comparable<ObservedEventValue> {
  final String variableName;
  final String valueName;
  final ValueSignal valueSignal;

  ObservedEventValue._(String variable, String value,
      {required NetworkCache? networkCache})
      : variableName =
            Variable.resolveName(variable, networkCache: networkCache),
        valueName = Value.resolveName(value, networkCache: networkCache),
        valueSignal = Value.resolveSignal();

  factory ObservedEventValue(Object o, {required NetworkCache? networkCache}) {
    if (o is ObservedEventValue) return o;

    if (o is Iterable<String>) {
      return ObservedEventValue._(o.elementAt(0), o.elementAt(1),
          networkCache: networkCache);
    }

    if (o is String) {
      var idx = o.indexOf('=');
      var variable = o.substring(0, idx);
      var value = o.substring(idx + 1);
      return ObservedEventValue._(variable, value, networkCache: networkCache);
    }

    throw StateError("Can't parse: $o");
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
