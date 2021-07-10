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

Statistics package for easy and efficient data manipulation with many built-in mathematical functions and units.

## Usage

A simple usage example:

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
