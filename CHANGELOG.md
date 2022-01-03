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
