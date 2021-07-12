import 'statistics_base.dart';
import 'statistics_extension.dart';
import 'statistics_extension_num.dart';

extension DataEntryExtension<E extends DataEntry> on Iterable<E> {
  /// Generates a `CSV` document.
  String generateCSV(
      {String separator = ',',
      List<String>? fieldsNames,
      Object Function(Object? e)? valueNormalizer}) {
    if (isEmpty) return '';

    var csv = StringBuffer();

    fieldsNames ??= first.getDataFields();

    {
      var head = fieldsNames.map(_normalizeLine).join(separator);
      csv.write(head);
      csv.write('\n');
    }

    if (valueNormalizer != null) {
      for (var e in this) {
        var values = e.getDataValues();
        var line = values
            .map((e) => _normalizeLine(valueNormalizer(e).toString()))
            .join(separator);
        csv.write(line);
        csv.write('\n');
      }
    } else {
      for (var e in this) {
        var values = e.getDataValues();
        var line = values.map((e) => _normalizeLine('$e')).join(separator);
        csv.write(line);
        csv.write('\n');
      }
    }

    return csv.toString();
  }

  /// Creates a `CSV` file name.
  String csvFileName(String prefix, String name) => _csvFileName(prefix, name);
}

final _REGEXP_NEW_LINE = RegExp(r'[\r\n]');

String _normalizeLine(String e) => e.replaceAll(_REGEXP_NEW_LINE, ' ');

extension SeriesMapExtension<E> on Map<String, List<E>?> {
  static Type _toType<T>() => T;

  static final Type _intNullable = _toType<int?>();
  static final Type _doubleNullable = _toType<double?>();
  static final Type _numNullable = _toType<num?>();
  static final Type _stringNullable = _toType<String?>();

  E _toDefault() {
    if (E == int || E == _intNullable) {
      return 0 as E;
    } else if (E == double || E == _doubleNullable) {
      return 0.0 as E;
    } else if (E == num || E == _numNullable) {
      return 0 as E;
    } else if (E == String || E == _stringNullable) {
      return '' as E;
    } else {
      throw StateError('No default value for type: $E');
    }
  }

  /// Generates a `CSV` document.
  String generateCSV(
      {String separator = ',',
      E? nullValue,
      int firstEntryIndex = 1,
      Object Function(E e)? valueNormalizer}) {
    if (isEmpty) return '';

    var csv = StringBuffer();

    var keys = this.keys;

    {
      var head = keys.map(_normalizeLine).join(separator);
      csv.write('#$separator');
      csv.write(head);
      csv.write('\n');
    }

    var totalLines = values.map((e) => e?.length ?? 0).toList().statistics.max;

    if (valueNormalizer != null) {
      for (var i = 0; i < totalLines; ++i) {
        var line = StringBuffer();
        line.write('${i + firstEntryIndex}');

        for (var k in keys) {
          var e = this[k]?.getValueIfExists(i);
          e ??= nullValue;
          e ??= (nullValue = _toDefault())!;

          var v = valueNormalizer(e);

          line.write(separator);
          line.write(v);
        }

        csv.write(line);
        csv.write('\n');
      }
    } else {
      for (var i = 0; i < totalLines; ++i) {
        var line = StringBuffer();
        line.write('${i + firstEntryIndex}');

        for (var k in keys) {
          var e = this[k]?.getValueIfExists(i);
          e ??= nullValue;
          e ??= (nullValue = _toDefault())!;

          line.write(separator);
          line.write(e);
        }

        csv.write(line);
        csv.write('\n');
      }
    }

    return csv.toString();
  }

  /// Creates a `CSV` file name.
  String csvFileName(String prefix, String name) => _csvFileName(prefix, name);
}

String _csvFileName(String prefix, String name) {
  var now = DateTime.now().millisecondsSinceEpoch;
  var csvFileName = '$prefix--$name--$now.csv';
  return csvFileName;
}
