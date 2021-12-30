#!/bin/bash
export LANG=
set -e
testname=$(basename -s .sh "$0")
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t="$(pwd)/out/test/elf/$testname"
mkdir -p "$t"

[ "$(uname -m)" = x86_64 ] || { echo skipped; exit; }

cat <<'EOF' | cc -o "$t"/a.o -c -x assembler -
  .text
  .globl main
main:
  sub $8, %rsp
  lea msg(%rip), %rdi
  xor %rax, %rax
  call printf@PLT
  xor %rax, %rax
  add $8, %rsp
  ret

  .data
msg:
  .string "Hello world\n"
EOF

clang -fuse-ld="$mold" -o "$t"/exe "$t"/a.o

readelf --sections "$t"/exe | fgrep -q '.got'
readelf --sections "$t"/exe | fgrep -q '.got.plt'

"$t"/exe | grep -q 'Hello world'

echo OK
