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
