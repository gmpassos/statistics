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
  var ns = [10, 20.0, 25, 30];
  var statistics = ns.statistics;

  print('Statistics.max: ${ statistics.max }');
  print('Statistics.min: ${ statistics.min }');
  print('Statistics.mean: ${ statistics.mean }');
  print('Statistics.standardDeviation: ${ statistics.standardDeviation }');
  print('Statistics.sum: ${ statistics.sum }');
  print('Statistics.center: ${ statistics.center }');
  print('Statistics.median: ${statistics.median} -> ${statistics.medianLow} , ${statistics.medianHigh}');
  print('Statistics.squaresSum: ${ statistics.squaresSum }');

  print('Statistics: $statistics');
}
```

OUTPUT:

```text
Statistics.max: 30
Statistics.min: 10
Statistics.mean: 21.25
Statistics.standardDeviation: 22.5
Statistics.sum: 85.0
Statistics.center: 25
Statistics.median: 22.5 -> 20.0 , 25
Statistics.squaresSum: 2025.0
Statistics: {~21.25 +-22.5 [10..(25)..30] #4}
```

### Bayesian Network

Bayesian Network, also known as Bayes Network, is a very important tool in understanding the dependency
among events and assigning probabilities to them.

Here's an example of how to build a `BayesianNetwork`.

```dart
import 'package:statistics/statistics.dart';

void main(){
  var bayesNet = BayesianNetwork('cancer');

  // C (cancer) = T (true) ; F (false)
  bayesNet.addNode("C", [
    'F',
    'T',
  ], [], [
    "C = F: 0.99",
    "C = T: 0.01",
  ]);

  // X (exam) = P (positive) ; N (negative)
  bayesNet.addNode("X", [
    '+P',
    '-N',
  ], [
    "C"
  ], [
    "X = N, C = F: 0.91",
    "X = P, C = F: 0.09",
    "X = N, C = T: 0.10",
    "X = P, C = T: 0.90",
  ]);

  // Show the network nodes and probabilities:
  print(bayesNet);

  var analyser = bayesNet.analyser;

  // Ask the probability to have cancer with a positive exame (X = T): 
  var answer1 = analyser.ask('P(c|x)');
  print(answer1); // P(c|x) -> C = TRUE | X = P -> 0.09183673469387756

  // Ask the probability to have cancer with a negative exame (X = F):
  var answer2 = analyser.ask('P(c|-x)');
  print(answer2); // P(c|-x) -> C = T | X = N -> 0.0011086474501108647
}
```

#### Event Monitoring

To help to generate the probabilities you can use the `EventMonitor` class and
then build the `BayesianNetwork`:

```dart
import 'package:statistics/statistics.dart';

void main() {
  // Monitor events to then build a Bayesian Network:
  // ** Note that this example is NOT USING REAL probabilities for Cancer!
  var eventMonitor = EventMonitor('cancer');

  // The prevalence of Cancer in the population:
  // - 1% (10:990):

  for (var i = 0; i < 990; ++i) {
    eventMonitor.notifyEvent(['CANCER=false']);
  }

  for (var i = 0; i < 10; ++i) {
    eventMonitor.notifyEvent(['CANCER=true']);
  }

  // The Exam performance when the person have cancer:
  // - 90% Sensitivity.
  // - 10% false negative (1:9).

  for (var i = 0; i < 9; ++i) {
    eventMonitor.notifyEvent(['EXAM=positive', 'CANCER=true']);
  }

  for (var i = 0; i < 1; ++i) {
    eventMonitor.notifyEvent(['EXAM=negative', 'CANCER=true']);
  }

  // The Exam performance when the person doesn't have cancer:
  // - 91% Specificity
  // - 9% false positive (89:901).

  for (var i = 0; i < 901; ++i) {
    eventMonitor.notifyEvent(['EXAM=negative', 'CANCER=false']);
  }
  for (var i = 0; i < 89; ++i) {
    eventMonitor.notifyEvent(['EXAM=positive', 'CANCER=false']);
  }

  var bayesNet = eventMonitor.buildBayesianNetwork();

  var analyser = bayesNet.analyser;

  var answer1 = analyser.ask('P(cancer)');
  print('- Cancer probability without an Exam:');
  print('  $answer1'); // P(cancer) -> CANCER = TRUE |  -> 0.01

  var answer2 = analyser.ask('P(cancer|exam)');
  print('- Cancer probability with a positive Exam:');
  print('  $answer2'); // P(cancer|exam) -> CANCER = TRUE | EXAM = POSITIVE -> 0.09183673469387756
}
```

See a full [example for Bayes Net at GitHub][bayes_example]:

[bayes_example]: https://github.com/gmpassos/statistics/blob/master/example/bayesnet_example.dart

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

## data_serializer

The `statistics` package exports the package [data_serializer][data_serializer] to help the handling of primitives, data, bytes and files.

- ***Some extension in `data_serializer` were originally in the `statistics` package.***

[data_serializer]: https://pub.dev/packages/data_serializer

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
