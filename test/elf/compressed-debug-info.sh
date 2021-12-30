#!/bin/bash
export LANG=
set -e
testname=$(basename -s .sh "$0")
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t="$(pwd)/out/test/elf/$testname"
mkdir -p "$t"

which dwarfdump >& /dev/null || { echo skipped; exit; }

cat <<EOF | g++ -c -o "$t"/a.o -g -gz=zlib-gnu -xc++ -
int main() {
  return 0;
}
EOF

cat <<EOF | g++ -c -o "$t"/b.o -g -gz=zlib -xc++ -
int foo() {
  return 0;
}
EOF

clang -fuse-ld="$mold" -o "$t"/exe "$t"/a.o "$t"/b.o
dwarfdump "$t"/exe > /dev/null
readelf --sections "$t"/exe | fgrep -q .debug_info

echo ' OK'
