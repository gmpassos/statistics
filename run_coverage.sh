#!/bin/bash

rm -rf ./coverage/test
rm -rf ./coverage/report
rm ./coverage/lcov.info

dart run test --coverage=./coverage

dart pub global run coverage:format_coverage --packages=.packages --report-on=lib --lcov -o ./coverage/lcov.info -i ./coverage

genhtml -o ./coverage/report ./coverage/lcov.info
open ./coverage/report/index.html
