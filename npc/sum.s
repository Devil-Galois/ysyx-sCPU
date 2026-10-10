li r0, 2
li r3, 8
add r0, r0, r3

li r1, 1
li r2, 0
li r3, 1

loop:
add r2, r2, r1
bner0 r1, increment

halt:
bner0 r3, halt

increment:
add r1, r1, r3
bner0 r3, loop
