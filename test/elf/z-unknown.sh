#!/bin/bash
export LANG=
set -e
testname=$(basename -s .sh "$0")
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t="$(pwd)/out/test/elf/$testname"
mkdir -p "$t"

"$mold" -z no-such-opt 2>&1 | grep -q 'unknown command line option: -z no-such-opt'
"$mold" -zno-such-opt 2>&1 | grep -q 'unknown command line option: -zno-such-opt'

echo OK
