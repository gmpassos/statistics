/*
Part of this code was inspired by the Java project:
- https://github.com/Cansn0w/BayesianNetwork
- MIT License
- Authors:
  - Di Lu
  - Chenrui Liu
*/

import 'package:collection/collection.dart';

/// A Bayesian Network implementation.
class BayesianNetwork extends Iterable<String> {
  final String name;
  final Map<String, Variable> _nodes = <String, Variable>{};

  BayesianNetwork(this.name);

  int get nodesLength => _nodes.length;

  /// Returns an [Analyser].
  ///
  /// - Default implementation: [VariableElimination].
  Analyser get analyser => VariableElimination(this);

  /// Adds a [Variable] node, with [values] and [parents] and [probabilities].
  Variable addNode(String name, List<String> values, List<String> parents,
      List<String> probabilities) {
    var node = Variable(name,
        network: this,
        values: values,
        parents: parents,
        probabilities: probabilities);
    _nodes[node.name] = node;

    try {
      for (var p in probabilities) {
        node._addProbability(p);
      }

      for (var v in node.parents) {
        v._addChild(node);
      }

      return node;
    } catch (e) {
      _nodes.remove(name);
      rethrow;
    }
  }

  bool hasNode(String name) => _nodes.containsKey(name);

  Variable getNode(String name) {
    var node = _nodes[name];
    if (node == null) {
      throw StateError("No such variable <" + name + ">.");
    }
    return node;
  }

  Condition parseCondition(String line) {
    line = line.replaceAll(RegExp(r'\s+'), '');
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
    line = line.replaceAll(RegExp(r'\s+'), '');
    var e = line.split("=");
    var name = e[0];
    var node = _nodes[name];
    if (node == null) {
      throw StateError('No such variable <' + e[0] + ">.");
    }

    return node.parseEvent(line);
  }

  double? query(String name, String condition) {
    return getNode(name).getProbability(condition);
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
    return 'BayesianNetwork[$name]{ ${_nodes.values.toList()} }';
  }
}

class ValidationError implements Exception {
  final String message;

  ValidationError(this.message);

  @override
  String toString() {
    return 'ValidationError{message: $message}';
  }
}

class Value implements Comparable<Value> {
  final String name;
  final Variable variable;

  Value(this.name, this.variable);

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
    return other.name.compareTo(name);
  }

  @override
  String toString() => name;
}

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

class Variable {
  final String name;
  final List<Variable> _parents = <Variable>[];
  final List<Variable> _children = <Variable>[];
  final Map<String, Value> _domain = <String, Value>{};

  Map<Condition, double>? _probabilities;

  BayesianNetwork? network;

  Variable(String name,
      {this.network,
      List<String>? values,
      List<String>? parents,
      List<String>? probabilities})
      : name = name.trim().toUpperCase() {
    if (values != null) {
      for (var v in values) {
        addValue(v);
      }
    }

    if (parents != null) {
      for (var p in parents) {
        addParentByName(p);
      }
    }
  }

  List<Variable> get parents => UnmodifiableListView<Variable>(_parents);

  Map<String, Value> get domain => UnmodifiableMapView<String, Value>(_domain);

  Map<Condition, double> get probabilities =>
      UnmodifiableMapView<Condition, double>(
          _probabilities ?? <Condition, double>{});

  void _addChild(Variable node) => _children.add(node);

  Event parseEvent(String line) {
    line = line.replaceAll(RegExp(r'\s+'), '');
    var e = line.split("=");
    if (e.length != 2) {
      throw ValidationError("Expected \"variable=value\", received " + line);
    }

    var name = e[0];
    var node = network?.getNode(name);

    if (node == null) {
      throw ValidationError("No such variable <" + e[0] + ">.");
    }

    return Event.byOutcomeName(node, e[1]);
  }

  Condition parseCondition(String line) {
    line = line.replaceAll(RegExp(r'\s+'), '');
    var cond = line.split(",");
    if (cond.length != _parents.length + 1) {
      throw ValidationError(
          "Number of events (${cond.length}) mismatches required number (${_parents.length + 1}).");
    }

    var conditionList = <Event>[];
    for (var event in cond) {
      conditionList.add(parseEvent(event));
    }

    return Condition(conditionList);
  }

  double? getProbability(String cond) => _probabilities?[parseCondition(cond)];

  void addParentByName(String name) {
    try {
      addParent(network!.getNode(name));
    } catch (e) {
      throw ValidationError(
          'The specified parent node "$name" does not exist (yet).');
    }
  }

  void addParent(Variable parent) => _parents.add(parent);

  void addValue(String name) {
    if (_domain.containsKey(name)) {
      throw ValidationError('Value with name "$name" already exists.');
    }

    _domain[name] = Value(name, this);
  }

  void _addProbability(String line) {
    var probabilities = _probabilities;

    if (probabilities == null) {
      probabilities = _probabilities = <Condition, double>{};

      var varList = _parents.toList();
      varList.add(this);

      for (var c in allConditions(varList)) {
        probabilities[c] = 0.0;
      }
    }

    line = line.replaceAll(RegExp(r'\s+'), '');

    // where desc (description) is like ["a=true,weather=sunny", "0.8"]
    var desc = line.split(":");
    if (desc.length != 2) {
      throw ValidationError("Only one ':' in an description allowed.");
    }

    var probability = double.parse(desc[1]);

    var condition = parseCondition(desc[0]);

    if (probabilities.containsKey(condition)) {
      probabilities[condition] = probability;
    } else {
      throw ValidationError("Provided condition mismatch.");
    }
  }

  Value? getValue(String name) => _domain[name];

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Variable &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          network == other.network;

  @override
  int get hashCode => name.hashCode ^ (network?.nodesLength ?? 0);

  @override
  String toString() =>
      "$name: [" + _parents.map((v) => v.name).join(', ') + ']';
}

class Condition extends Iterable<Event> {
  final List<Event> _events;

  Condition(List<Event> l) : _events = List.from(l)..sort();

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
  String toString() => _events.toString();
}

class Factor {
  final List<Variable> _variables;
  Map<Condition, double> _probabilities;

  Factor(Variable v, Condition evidence)
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
        eliminate(e.node);
      }
    }
  }

  Factor._(this._variables, this._probabilities);

  double get(Condition cond) => _probabilities[cond]!;

  void eliminate(Variable node) {
    if (!_variables.remove(node)) {
      throw StateError(
          "This factor does not contain the variable <${node.name}> to eliminate.");
    }

    var newP = <Condition, double>{};
    for (var cond in Variable.allConditions(_variables)) {
      newP[cond] = 0.0;
    }

    for (var cond in newP.keys) {
      for (var oldC in _probabilities.keys) {
        if (oldC.containsCondition(cond)) {
          newP[cond] = newP[cond]! + _probabilities[oldC]!;
        }
      }
    }

    _probabilities = newP;
  }

  Factor join(Factor other) {
    var newVars = _variables.toList();
    newVars.addAll(other._variables);
    newVars = newVars.toSet().toList();

    var allConditions = Variable.allConditions(newVars);

    // compute the joined probability table;
    var newP = <Condition, double>{};
    for (var cond in allConditions) {
      var prob = 1.0;

      for (var c in other._probabilities.keys) {
        if (cond.containsCondition(c)) {
          prob *= other.get(c);
        }
      }

      for (var c in _probabilities.keys) {
        if (cond.containsCondition(c)) {
          prob *= get(c);
        }
      }

      newP[cond] = prob;
    }

    return Factor._(newVars, newP);
  }

  void normalise() {
    var sumP = 0.0;
    for (var d in _probabilities.values) {
      sumP += d;
    }

    var newP = <Condition, double>{};
    for (var e in _probabilities.entries) {
      newP[e.key] = e.value / sumP;
    }

    _probabilities = newP;
  }

  @override
  String toString() {
    return _probabilities.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}

/// [Analyser] answer. See [Analyser.ask].
class Answer {
  final String query;

  final double probability;

  Answer(this.query, this.probability);

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
    return '$query -> $probability';
  }
}

abstract class Analyser {
  Answer showAnswer(String query,
      {String active = 'T', String inactive = 'F'}) {
    var result = ask(query, active: active, inactive: inactive);

    if (query != result.query) {
      print('$query -> $result');
    } else {
      print('$result');
    }

    return result;
  }

  Answer ask(String query, {String active = 'T', String inactive = 'F'}) {
    if (query.trim().startsWith('P(')) {
      query = parseQuery(query, active: active, inactive: inactive);
    }

    var q = query.split('|');

    var probability = askObserved(q[0], q[1]);
    return Answer(query, probability);
  }

  double askObserved(String variable, String observed);

  String parseQuery(String query,
      {String active = 'T', String inactive = 'F'}) {
    var q = query.split('(')[1].split(')')[0].split('|');

    var ret = _convert(q[0], active: active, inactive: inactive) + " | ";

    if (q.length > 1) {
      var evidences = q[1].split(",");
      for (int i = 0; i < evidences.length; i++) {
        ret +=
            _convert(evidences[i], active: active, inactive: inactive) + ", ";
      }
      if (evidences.isNotEmpty) {
        ret = ret.substring(0, ret.length - 2);
      }
    }

    return ret;
  }

  static String _convert(String s,
      {String active = 'T', String inactive = 'F'}) {
    s = s.toUpperCase().trim();
    if (s.startsWith("-")) {
      return s.substring(1) + "=$inactive";
    } else {
      return s + "=$active";
    }
  }
}

class VariableElimination extends Analyser {
  final BayesianNetwork network;

  VariableElimination(this.network);

  @override
  double askObserved(String variable, String observed) {
    // Get target event and evidence objects.
    var target = network.parseEvent(variable);
    var evidence = network.parseCondition(observed);

    // To eliminate in reverse topological ordering.
    // Assume the insertion order of the network is topologically sorted,
    // which is the case in our implementation.
    var order = network._nodes.values.toList().reversed.toList();

    // For each variable, make it into a factor.
    var factors = <Factor>[];
    for (Variable v in order) {
      factors.add(Factor(v, evidence));

      // if the variable is a hidden variable, then perform sum out
      if (target.node != v && !evidence.mention(v)) {
        Factor temp = factors[0];
        for (int i = 1; i < factors.length; i++) {
          temp = temp.join(factors[i]);
        }
        temp.eliminate(v);
        factors.clear();
        factors.add(temp);
      }
    }

    // Point wise product of all remaining factors.
    var result = factors[0];
    for (int i = 1; i < factors.length; i++) {
      result = result.join(factors[i]);
    }

    // Normalize the result factor
    result.normalise();

    // Return the result matching the query in string format.
    var probability = result.get(Condition([target]));
    return probability;
  }
}
