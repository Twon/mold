#!/bin/bash
export LANG=
set -e
testname=$(basename -s .sh "$0")
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t="$(pwd)/out/test/elf/$testname"
mkdir -p "$t"

cat <<EOF | cc -o "$t"/a.o -c -x assembler -
  .text
  .globl _start
_start:
  nop
EOF

"$mold" -o "$t"/b.so "$t"/a.o -auxiliary foo -f bar -shared

readelf --dynamic "$t"/b.so > "$t"/log
fgrep -q 'Auxiliary library: [foo]' "$t"/log
fgrep -q 'Auxiliary library: [bar]' "$t"/log

echo OK
