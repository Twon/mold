#!/bin/bash
export LANG=
set -e
testname=$(basename -s .sh "$0")
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/ld64.mold"
t="$(pwd)/out/test/macho/$testname"
mkdir -p "$t"

cat <<EOF | cc -o "$t"/a.o -c -xc -
#include <stdio.h>

static int foo[100];

int main() {
  foo[1] = 5;
  printf("%d %d %p\n", foo[0], foo[1], foo);
}
EOF

clang -fuse-ld="$mold" -o "$t"/exe "$t"/a.o
"$t"/exe | grep -q '^0 5 '

echo OK
