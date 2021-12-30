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
extern char foo;
extern char bar;
void baz();

void print() {
  printf("Hello %p %p\n", &foo, &bar);
}

int main() {
  baz();
}
EOF

clang -fuse-ld="$mold" -o "$t"/exe "$t"/a.o -Wl,-defsym=foo=16 \
  -Wl,-defsym=bar=0x2000 -Wl,-defsym=baz=print

"$t"/exe | grep -q '^Hello 0x10 0x2000$'

echo OK
