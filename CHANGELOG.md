## 1.1.1

- `DynamicNumber`:
  - Added `sin` and `cos`.

- test: ^1.25.8
- coverage: ^1.8.0

## 1.1.0

- sdk: '>=3.3.0 <4.0.0'

- intl: ^0.19.0
- collection: ^1.18.0
- data_serializer: ^1.1.0

- lints: ^3.0.0
- test: ^1.25.2
- coverage: ^1.7.2

## 1.0.26

- Fix:
  - `IterableNumExtension.standardDeviation`.
  - `IterableDoubleExtension.standardDeviation`.
  - `DecimalOnIterableDecimalExtension.standardDeviation`.
  - `DynamicIntOnIterableDynamicNumberExtension.standardDeviation`.

- sdk: '>=2.14.0 <4.0.0'
- intl: ^0.18.1
- dependency_validator: ^3.2.3

## 1.0.25

- `Decimal`:
  - Added `withMaximumPrecision`, `withMinimumPrecision` and `clipPrecision`.
- collection: ^1.17.0
- test: ^1.24.0
- coverage: ^1.6.3

## 1.0.24

- intl: ^0.18.0
- lints: ^2.0.1
- test: ^1.22.1
- coverage: ^1.6.1

## 1.0.23

- `DynamicNumber`, `DynamicInt`, `Decimal`:
  - Added `isWholeNumber`, `isOdd`, `isEven`.
- Added prime numbers support:
  - `PrimeUtils`, `PrimeIntExtension`, `PrimeDynamicNumberExtension`, `PrimeDecimalExtension`, `PrimeDynamicIntExtension`.

## 1.0.22

- Added extension `NumericTypeExtension`:
  - Methods: `isNumericType`, `isNumericOrDynamicNumberType`, `isDynamicNumberType`.
- Added extension `NumericTypeExtension`:
  - Methods: `isNumericValue`, `isNumericOrDynamicNumberValue`, `isDynamicNumberValue`, `whenNull`.

## 1.0.21

- Added `StandardDeviationComputer`:
  - `StandardDeviationComputerNum`
  - `StandardDeviationComputerBigInt`
  - `StandardDeviationComputerDynamicNumber`
- Fix standard deviation online calculation.
- sdk: '>=2.14.0 <3.0.0'
- collection: ^1.16.0
- lints: ^2.0.0
- test: ^1.21.4
- dependency_validator: ^3.2.2
- coverage: ^1.2.0

## 1.0.20

- Added `Decimal.tryParse` and `DynamicInt.tryParse`.

## 1.0.19

- Added High-Precision Arithmetic: `DynamicInt` and `Decimal`.
- Added benchmark tools.
- Added browser tests to CI.
  - Fixed some tests for browser.

## 1.0.18

- New `CountTable`.
- `BayesianNetwork` and `BayesEventMonitor`:
  - Significant performance improvement for high number of variables and dependencies.
  - Allow variables nodes with multiple root paths.
- `Pair`:
  - Added `hashCode` cache.
- `generateCombinations`:
  - Added parameter `validator`.
- Improved `Chronometer`:
  - New field `totalOperation` and method `timeToComplete`.
  - Added time marks.
  - Better `toString`:
    - Changed parameter `withTime` to `withStartTime`.
- `Duration` extension:
  - `toStringUnit`:
    - New parameter `decimal`.
    - Better output for `zero` `Duration`.
  - Added `toStringDifference`
- `String` extension
  - Added `headEqualsLength`, `tailEqualsLength`, `headEquals`, `tailDifferent`.
- `ListExtension`:
  - Added `equalsElements`, `removeAll`, `retainAll`, `toDistinctList`, `shuffleCopy`, `randomSelection`.
- `SetExtension`:
  - Added `copy`, `equalsElements`.
- `IterableExtension`:
  - Added `copy`, `asList`, `asSet`, `whereIn`, `whereNotIn`, `equalsElements`, `computeHashcode`.
- `MapEntryExtension`:
  - Added `copy`, `equals`, `toPair`.
- `MapExtension`:
  - Added `copy`.

## 1.0.17

- New type `Pair`.
- New `EventForecaster` framework.
- `BayesianNetwork`:
  - New method `addDependency`.
  - Now allows probability dependency between variables.
  - Added test with `XOR`.
- `BayesEventMonitor`:
  - Now allows out-of-order events from the Bayesian Network topology.
- New `CombinationCache` and function `generateCombinations`.
- coverage: ^1.0.4

## 1.0.16

- `ListComparablesExtension` changed to `IterableComparablesExtension`.
- New `IterableUint8ListExtension`, `ListAnswerExtension` and `ListOfListAnswer`.

## 1.0.15

- `Variable` node optimization:
  - `ancestors`, `rootNodes`, `rootChain`, `rootChain`.
- `VariableElimination`: 
  - Optimize resolution of nodes needed to answer a query.

## 1.0.14

- Improved `BayesianNetwork`.
  - Optimized parsing and building of network.
  - Added `EventMonitor` to help to build a `BayesianNetwork` and probabilities.
  - Improved documentation.
- Fix some typos.

## 1.0.13

- Added `BayesianNetwork`.

## 1.0.12

- Added `parseBigInt`.
- Moved some extension methods to package `data_serializer`.
- Moved `StatisticsPlatform` to package `data_serializer` as `DataSerializerPlatform`.
- Exporting `data_serializer ^1.0.3`

## 1.0.11

- Improved performance: `toUint8List32Reversed` and `reverseBytes`.
- Added `BigInt.thousands`.

## 1.0.10

- Optimize `Statistics` to allow computation of big numbers without overflow issues.

## 1.0.9

- Added extensions:
  - `String: `encodeLatin1`, `encodeUTF8`, `truncate`.
  - `Uint8List`: `copyAsUnmodifiable`, `asUnmodifiableView`, `toStringLatin1/bytes`, `toStringUTF8/bytes`,
     `setUint8/16/32/64`, `setInt8/16/32/64`.
  - `List<int>`: `toUint8List`, `asUint8List`, `compareWith`.
  - `int`: `isSafeInteger`, `checkSafeInteger`, `int16/32/64ToBytes`, `uInt16/32/64ToBytes`.
  - `BigInt`: `isSafeInteger`, `checkSafeInteger`.
- Improved documentation.
- Fix typo: renamed extension with `UInt` to `Uint` to follow Dart style.

## 1.0.8

- Added extensions:
  - `DateTime.elapsedTime`.
  - `int`: `bits/8/16/32/64`, `toUint8List32Reversed`, `toUint8List64Reversed`.
  - `Uint8List`: `bits/8/16/32/64`.

## 1.0.7

- `Chronometer.toString`: added parameter `withTime`.
- Added `StatisticsPlatform` to ensure safe `int` serialization in any Dart platform.
- `double` extension: added `toPercentage`.
- `int` extension: added `toBigInt`, `toUint8List32`, `toUint8List64`, `toHex32`, `toHex64`, `toStringPadded`.
- Added extension for `BigInt` and `Uint8List`.
- Added numeric extension for `String`.
- Migrated code coverage to use package `coverage`.
- base_codecs: ^1.0.1
- coverage: ^1.0.3

## 1.0.6

- `Chronometer.elapsedTimeMs`: now returns the elapsed time even if not stopped.

## 1.0.5

- `Statistics`:
  - Added `medianHigh`, `medianLow` and `median`.
    - Change constructor: required `medianHigh`.
  - `center` points to `medianHigh`.
- `NumExtension`:
  - Added: `num.cast`.

## 1.0.4

- New metric tools:
  - `UnitLength` and `UnitLengthExtension`.
- Added:
  - `parseDateTime`.
  - `DateTimeExtension`:
    - `formatToYMD`, `formatToYMDHm`, `formatToYMDHms`, `formatToYMDHmZ` and `formatToYMDHmsZ`.
  - `MapExtension`:
    - `equalsKeysValues`.
  - `ListMapExtension`:
    - `sortByKey`.
  - `IterableMapExtension`:
    - `sortedByKey`.
  - `DoubleExtension`:
    - `truncateDecimals`.
- Optimize:
  - Optimize `splitColumns` with `acceptsQuotedValues`.
- Improved API Documentation.

## 1.0.3

- New extension methods:
  - `head`, `tail` and `sublistReversed`.
  - `searchInsertSortedIndex` and `binarySearchPoint`.
  - `resampleByIndex` and `resampleByValue`.
- Changed from package `pedantic` (deprecated) to `lints`.
- lints: ^1.0.1

## 1.0.2

- Improve extensions.
- generateCSV:
  - Added `commaAsDecimalSeparator` and `decimalPrecision`.

## 1.0.1

- Added:
  - `DoubleEquality`, `IntEquality` and `NumEquality`.
- Improve unit tests and coverage up to 98%.
- Improve example.
- Improve `README.md`.

## 1.0.0

- `extension` for `int`, `double` and `num` collections.
- Initial version.
