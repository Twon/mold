#!/bin/bash
export LANG=
set -e
testname=$(basename -s .sh "$0")
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t="$(pwd)/out/test/elf/$testname"
mkdir -p "$t"

cat <<'EOF' | clang -fPIC -c -o "$t"/a.o -xc -
void fn2();
void fn1() { fn2(); }
void fn3() {}
EOF

clang -shared -fuse-ld="$mold" -o "$t"/b.so "$t"/a.o

readelf --dyn-syms "$t"/b.so > "$t"/log

grep -q '0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND fn2' "$t"/log
grep -Pq 'FUNC    GLOBAL DEFAULT   \d+ fn1' "$t"/log

cat <<EOF | clang -fPIC -c -o "$t"/c.o -xc -
#include <stdio.h>

int fn1();

void fn2() {
  printf("hello\n");
}

int main() {
  fn1();
  return 0;
}
EOF

clang -fuse-ld="$mold" -o "$t"/exe "$t"/c.o "$t"/b.so
"$t"/exe | grep -q hello
! readelf --symbols "$t"/exe | grep -q fn3 || false

echo OK
