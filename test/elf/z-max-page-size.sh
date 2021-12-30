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

clang -fuse-ld="$mold" -o "$t"/exe "$t"/a.o -Wl,-z,max-page-size=65536
"$t"/exe | grep -q 'Hello world'
readelf -W --segments "$t"/exe | grep -q 'LOAD.*R   0x10000$'

clang -fuse-ld="$mold" -o "$t"/exe "$t"/a.o -Wl,-zmax-page-size=$((1024*1024))
"$t"/exe | grep -q 'Hello world'
readelf -W --segments "$t"/exe | grep -q 'LOAD.*R   0x100000$'

echo OK
