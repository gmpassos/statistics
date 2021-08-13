# statistics

[![pub package](https://img.shields.io/pub/v/statistics.svg?logo=dart&logoColor=00b9fc)](https://pub.dev/packages/statistics)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![Codecov](https://img.shields.io/codecov/c/github/gmpassos/statistics)](https://app.codecov.io/gh/gmpassos/statistics)
[![CI](https://img.shields.io/github/workflow/status/gmpassos/statistics/Dart%20CI/master?logo=github-actions&logoColor=white)](https://github.com/gmpassos/statistics/actions)
[![GitHub Tag](https://img.shields.io/github/v/tag/gmpassos/statistics?logo=git&logoColor=white)](https://github.com/gmpassos/statistics/releases)
[![New Commits](https://img.shields.io/github/commits-since/gmpassos/statistics/latest?logo=git&logoColor=white)](https://github.com/gmpassos/statistics/network)
[![Last Commits](https://img.shields.io/github/last-commit/gmpassos/statistics?logo=git&logoColor=white)](https://github.com/gmpassos/statistics/commits/master)
[![Pull Requests](https://img.shields.io/github/issues-pr/gmpassos/statistics?logo=github&logoColor=white)](https://github.com/gmpassos/statistics/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/gmpassos/statistics?logo=github&logoColor=white)](https://github.com/gmpassos/statistics)
[![License](https://img.shields.io/github/license/gmpassos/statistics?logo=open-source-initiative&logoColor=green)](https://github.com/gmpassos/statistics/blob/master/LICENSE)

Statistics package for easy and efficient data manipulation with many built-in mathematical functions and tools.

## API Documentation

See the [API Documentation][api_doc] for a full list of functions, classes and extension.

[api_doc]: https://pub.dev/documentation/statistics/latest/

## Usage

### Numeric extension:

```dart
import 'package:statistics/statistics.dart';

void main() {
  var ns = [10, 20.0, 30];
  print('ns: $ns');

  var mean = ns.mean;
  print('mean: $mean');

  var sdv = ns.standardDeviation;
  print('sdv: $sdv');

  var squares = ns.square;
  print('squares: $squares');
}
```

OUTPUT:

```text
ns: [10, 20.0, 30]
mean: 20.0
sdv: 8.16496580927726
squares: [100.0, 400.0, 900.0]
```

### Statistics

The class [Statistics][statistics_class], that have many pre-computed statistics, can be generated from a numeric collection:

[statistics_class]: https://pub.dev/documentation/statistics/latest/statistics/Statistics-class.html

```dart
import 'package:statistics/statistics.dart';

void main() {
  var ns = [10, 20.0, 30];
  var statistics = ns.statistics;

  print('Statistics.max: ${ statistics.max }');
  print('Statistics.min: ${ statistics.min }');
  print('Statistics.mean: ${ statistics.mean }');
  print('Statistics.standardDeviation: ${ statistics.standardDeviation }');
  print('Statistics.sum: ${ statistics.sum }');
  print('Statistics.center: ${ statistics.center }');
  print('Statistics.squaresSum: ${ statistics.squaresSum }');

  print('Statistics: $statistics');
}
```

OUTPUT:

```text
Statistics.max: 30
Statistics.min: 10
Statistics.mean: 20.0
Statistics.standardDeviation: 21.602468994692867
Statistics.sum: 60.0
Statistics.center: 20.0
Statistics.squaresSum: 1400.0
Statistics: {~20 +-21.6024 [10..(20)..30] #3.0}
```

### CSV

To generate a [CSV][csv_wikipedia] document, just use the extension [generateCSV][generate_csv] in your data collection.
You can pass the parameter `separator` to change the value separator (default: `,`).

[generate_csv]:https://pub.dev/documentation/statistics/latest/statistics/IterableMapExtensionCSV/generateCSV.html
[csv_wikipedia]: https://en.wikipedia.org/wiki/Comma-separated_values

```dart
import 'package:statistics/statistics.dart';

void main() {
  var categories = <String, List<double?>>{
    'a': [10.0, 20.0, null],
    'b': [100.0, 200.0, 300.0]
  };

  var csv = categories.generateCSV();
  print(csv);
}
```

OUTPUT:

```text
#,a,b
1,10.0,100.0
2,20.0,200.0
3,0.0,300.0
```

## Tools



Parsers:
- [parseDouble](https://pub.dev/documentation/statistics/latest/statistics/parseDouble.html)
- [parseInt](https://pub.dev/documentation/statistics/latest/statistics/parseInt.html)
- [parseNum](https://pub.dev/documentation/statistics/latest/statistics/parseNum.html)
- [parseDateTime](https://pub.dev/documentation/statistics/latest/statistics/parseDateTime.html)
- *All parses accepts a `dynamic` value as input and have a default value parameter `def`.*

Formatters:
- [formatDecimal](https://pub.dev/documentation/statistics/latest/statistics/formatDecimal.html)
- [DateTimeExtension.formatToYMD](https://pub.dev/documentation/statistics/latest/statistics/DateTimeExtension/formatToYMD.html)
- [DateTimeExtension.formatToYMDHm](https://pub.dev/documentation/statistics/latest/statistics/DateTimeExtension/formatToYMDHm.html)
- [DateTimeExtension.formatToYMDHms](https://pub.dev/documentation/statistics/latest/statistics/DateTimeExtension/formatToYMDHms.html)
- [DateTimeExtension.formatToYMDHmZ](https://pub.dev/documentation/statistics/latest/statistics/DateTimeExtension/formatToYMDHmZ.html)
- [DateTimeExtension.formatToYMDHmsZ](https://pub.dev/documentation/statistics/latest/statistics/DateTimeExtension/formatToYMDHmsZ.html)

Extension:
- [StringExtension.splitLines](https://pub.dev/documentation/statistics/latest/statistics/StringExtension/splitLines.html)
- [StringExtension.splitColumns](https://pub.dev/documentation/statistics/latest/statistics/StringExtension/splitColumns.html)
- [StringExtension.containsAny](https://pub.dev/documentation/statistics/latest/statistics/StringExtension/containsAny.html)
- [IterableIterableExtension.toKeysMap](https://pub.dev/documentation/statistics/latest/statistics/IterableIterableExtension/toKeysMap.html)
- [IterableStringExtension.filterLines](https://pub.dev/documentation/statistics/latest/statistics/IterableStringExtension/filterLines.html)
- [IterableStringExtension.toIntsList](https://pub.dev/documentation/statistics/latest/statistics/IterableStringExtension/toIntsList.html)
- [IterableStringExtension.toDoublesList](https://pub.dev/documentation/statistics/latest/statistics/IterableStringExtension/toDoublesList.html)
- [IterableStringExtension.toNumsList](https://pub.dev/documentation/statistics/latest/statistics/IterableStringExtension/toNumsList.html)


See the [API Documentation][api_doc] for a full list of functions, extension and classes.

## Test Coverage

[![Codecov](https://img.shields.io/codecov/c/github/gmpassos/statistics)](https://app.codecov.io/gh/gmpassos/statistics)

This package aims to always have a high test coverage percentage, over 95%.
With that the package can be a reliable tool to support your important projects. 

## Source

The official source code is [hosted @ GitHub][github_async_field]:

- https://github.com/gmpassos/statistics

[github_async_field]: https://github.com/gmpassos/statistics

# Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

# Contribution

Any help from the open-source community is always welcome and needed:

- Found an issue?
    - Please fill a bug report with details.
- Wish a feature?
    - Open a feature request with use cases.
- Are you using and liking the project?
    - Promote the project: create an article, do a post or make a donation.
- Are you a developer?
    - Fix a bug and send a pull request.
    - Implement a new feature.
    - Improve the Unit Tests.
- Have you already helped in any way?
    - **Many thanks from me, the contributors and everybody that uses this project!**

*If you donate 1 hour of your time, you can contribute a lot,
because others will do the same, just be part and start with your 1 hour.*

[tracker]: https://github.com/gmpassos/statistics/issues

# Author

Graciliano M. Passos: [gmpassos@GitHub][github].

[github]: https://github.com/gmpassos

## License

[Apache License - Version 2.0][apache_license]

[apache_license]: https://www.apache.org/licenses/LICENSE-2.0.txt

## See Also

Take a look at [SciDart][scidart], an experimental cross-platform scientific library for Dart by [Angelo Polotto](https://github.com/polotto).

[scidart]: https://pub.dev/packages/scidart
