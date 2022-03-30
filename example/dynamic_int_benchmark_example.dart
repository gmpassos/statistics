import 'package:statistics/statistics.dart';

void main() {
  var set = {
    'int': testInt,
    'DynamicInt': testDynamicInt,
    'BigInt': testBigInt,
  };

  // Warm up:
  benchmarkSet(2000000, set);

  var results = benchmarkSet(2000000, set);

  print('RESULTS (${results.length}):');
  for (var r in results) {
    print('-> $r');
  }

  var fastest = results.last;

  print('\nFASTEST: $fastest');
}

const m1Value = 2;
const m2Value = 3;
const m3Value = 4;
const m4Value = 10;

BenchmarkFunctionResult<BigInt> testInt(int loops) {
  var ops = 0;

  var total = 0;
  ops++;

  var m1 = m1Value;
  ops++;
  var m2 = m2Value;
  ops++;
  var m3 = m3Value;
  ops++;
  var m4 = m4Value;
  ops++;

  for (var i = 0; i < loops; ++i) {
    var n1 = i;
    ops++;

    var n2 = n1 * m1;
    ops++;

    var n3 = n1 * m2;
    ops++;

    var n4 = n1 * m3;
    ops++;

    var n5 = (n1 * n3) + (n2 * n4);
    ops += 3;

    var n6 = n5 % m4;
    ops++;

    total += n6;
    ops++;
  }
  return BenchmarkFunctionResult(ops, total.toBigInt());
}

BenchmarkFunctionResult<BigInt> testDynamicInt(int loops) {
  var ops = 0;

  var total = DynamicInt.zero;
  ops++;

  var m1 = DynamicInt.fromInt(m1Value);
  ops++;
  var m2 = DynamicInt.fromInt(m2Value);
  ops++;
  var m3 = DynamicInt.fromInt(m3Value);
  ops++;
  var m4 = DynamicInt.fromInt(m4Value);
  ops++;

  for (var i = 0; i < loops; ++i) {
    var n1 = DynamicInt.fromInt(i);
    ops++;

    var n2 = n1 * m1;
    ops++;

    var n3 = n1 * m2;
    ops++;

    var n4 = n1 * m3;
    ops++;

    var n5 = (n1 * n3) + (n2 * n4);
    ops += 3;

    var n6 = n5 % m4;
    ops++;

    total = (total + n6).toDynamicInt();
    ops++;
  }
  return BenchmarkFunctionResult(ops, total.toBigInt());
}

BenchmarkFunctionResult<BigInt> testBigInt(int loops) {
  var ops = 0;

  var total = BigInt.zero;
  ops++;

  var m1 = BigInt.from(m1Value);
  ops++;
  var m2 = BigInt.from(m2Value);
  ops++;
  var m3 = BigInt.from(m3Value);
  ops++;
  var m4 = BigInt.from(m4Value);
  ops++;

  for (var i = 0; i < loops; ++i) {
    var n1 = BigInt.from(i);
    ops++;

    var n2 = n1 * m1;
    ops++;

    var n3 = n1 * m2;
    ops++;

    var n4 = n1 * m3;
    ops++;

    var n5 = (n1 * n3) + (n2 * n4);
    ops += 3;

    var n6 = n5 % m4;
    ops++;

    total += n6;
    ops++;
  }

  return BenchmarkFunctionResult(ops, total);
}

// ---------------------------------------------
// OUTPUT:
// ---------------------------------------------
// RESULTS (3):
// -> BigInt{ 892.00 ms · hertz: 20,179,377 Hz · ops: 18,000,005 · start: 2022-03-30 04:24:29.924215 .. 30.822949 } -> 9000000
// -> DynamicInt{ 252.00 ms · hertz: 71,428,591 Hz · ops: 18,000,005 · start: 2022-03-30 04:24:29.672963 .. 30.842626 } -> 9000000
// -> int{ 30.00 ms · hertz: 600,000,166 Hz · ops: 18,000,005 · start: 2022-03-30 04:24:29.642038 .. 30.842715 } -> 9000000
//
// FASTEST: int{ 30.00 ms · hertz: 600,000,166 Hz · ops: 18,000,005 · start: 2022-03-30 04:24:29.642038 .. 30.842783 } -> 9000000
//
