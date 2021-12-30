#!/bin/bash
export LANG=
set -e
testname=$(basename -s .sh "$0")
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t="$(pwd)/out/test/elf/$testname"
mkdir -p "$t"

cat <<EOF | clang -c -o "$t"/a.o -x assembler -
.globl main, init, fini
main:
  ret
init:
  ret
fini:
  ret
EOF

clang -fuse-ld="$mold" -o "$t"/exe "$t"/a.o
readelf -a "$t"/exe > "$t"/log

grep -Pqz '(?s)\(INIT\)\s+0x([0-9a-f]+)\b.*\1\s+0 \w+\s+GLOBAL \w+\s+\d+ _init\b' "$t"/log

grep -Pqz '(?s)\(FINI\)\s+0x([0-9a-f]+)\b.*\1\s+0 \w+\s+GLOBAL \w+\s+\d+ _fini\b' "$t"/log

clang -fuse-ld="$mold" -o "$t"/exe "$t"/a.o -Wl,-init,init -Wl,-fini,fini
readelf -a "$t"/exe > "$t"/log

grep -Pqz '(?s)\(INIT\)\s+0x([0-9a-f]+)\b.*\1\s+0 NOTYPE  GLOBAL DEFAULT\s+\d+ init\b' "$t"/log

grep -Pqz '(?s)\(FINI\)\s+0x([0-9a-f]+)\b.*\1\s+0 NOTYPE  GLOBAL DEFAULT\s+\d+ fini\b' "$t"/log

echo OK
