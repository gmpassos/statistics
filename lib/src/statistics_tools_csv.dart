import 'statistics_extension.dart';
import 'statistics_extension_num.dart';
import 'statistics_base.dart';

extension DataEntryExtension<E extends DataEntry> on List<E> {
  /// Generates a `CSV` document.
  String generateCSV({String separator = ',', List<String>? fieldsNames}) {
    if (isEmpty) return '';

    var csv = StringBuffer();

    fieldsNames ??= first.getDataFields();

    {
      var head = fieldsNames.map(_normalizeLine).join(separator);
      csv.write(head);
      csv.write('\n');
    }

    for (var e in this) {
      var values = e.getDataValues();
      var line = values.map((e) => _normalizeLine('$e')).join(separator);
      csv.write(line);
      csv.write('\n');
    }

    return csv.toString();
  }

  /// Creates a `CSV` file name.
  String csvFileName(String prefix, String name) => _csvFileName(prefix, name);
}

final _REGEXP_NEW_LINE = RegExp(r'[\r\n]');

String _normalizeLine(String e) => e.replaceAll(_REGEXP_NEW_LINE, ' ');

extension SeriesMapExtension<N extends num> on Map<String, List<N>?> {
  N _toN(num n) => (N == int ? n.toInt() : n.toDouble()) as N;

  /// Generates a `CSV` document.
  String generateCSV(
      {String separator = ',', N? nullValue, int firstEntryIndex = 1}) {
    if (isEmpty) return '';

    var csv = StringBuffer();

    var keys = this.keys;

    {
      var head = keys.map(_normalizeLine).join(separator);
      csv.write('#$separator');
      csv.write(head);
      csv.write('\n');
    }

    nullValue ??= _toN(0);

    var totalLines = values.map((e) => e?.length ?? 0).toList().statistics.max;

    for (var i = 0; i < totalLines; ++i) {
      var line = StringBuffer();
      line.write('${i + firstEntryIndex}');

      for (var k in keys) {
        var e = this[k]?.getValueIfExists(i) ?? nullValue;
        line.write(separator);
        line.write(e);
      }

      csv.write(line);
      csv.write('\n');
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
