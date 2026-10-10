# One BTNR press performs one addition: 1 + 2 + ... + 10.
# r0: bner0 reference / final LED value
# r1: next addend (1..10)
# r2: running sum
# r3: BTNR sample / temporary value
# I/O: in r3, 1 = button bitmap (BTNR alone reads 1);
#      out r2, 1 = decimal display;
#      out r0, 0 = low eight LEDs.

li r0, 1
li r1, 1
li r2, 0

wait_press:
in r3, 1
bner0 r3, wait_press       # r0=1: keep waiting while BTNR=0
add r2, r2, r1
out r2, 1                  # show the new sum

# On the normal path r3=1, so the branch below falls through.
# On the return path r3=2, so it jumps back to wait_press.
bridge_press:
li r0, 1
bner0 r3, wait_press

li r0, 0
wait_release:
in r3, 1
bner0 r3, wait_release     # r0=0: keep waiting while BTNR=1

# On the normal path r3=0, so the branch below falls through.
# On the return path r3=2, so it jumps to bridge_press.
bridge_return:
bner0 r3, bridge_press

li r0, 8
li r3, 2
add r0, r0, r3            # r0=10, the final addend
bner0 r1, continue        # r1 != 10: prepare the next addition
bner0 r3, done            # r1 == 10: jump to completion

continue:
li r0, 1
add r1, r1, r0            # next addend
bner0 r3, bridge_return   # r3=2, r0=1: jump back in two short hops

done:
li r0, 192
li r3, 48
add r0, r0, r3            # 240
li r3, 12
add r0, r0, r3            # 252
li r3, 3
add r0, r0, r3            # 255
out r0, 0                 # light all low eight LEDs

halt:
bner0 r3, halt            # r0=255, r3=3: stay here
