#!/bin/bash
export LANG=
set -e
testname=$(basename -s .sh "$0")
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t="$(pwd)/out/test/elf/$testname"
mkdir -p "$t"

cat <<EOF | cc -o "$t"/a.o -c -xc -
#include <stdio.h>

int main() {
  printf("Hello world\n");
}
EOF

clang -fuse-ld="$mold" -o "$t"/exe "$t"/a.o -static
"$t"/exe | grep -q 'Hello world'

echo OK
