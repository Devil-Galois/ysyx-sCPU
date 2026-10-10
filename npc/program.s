li r0, 12
li r1, 3
li r2, 0

loop:
add r2, r2, r1
bner0 r2, loop

halt:
bner0 r1, halt
