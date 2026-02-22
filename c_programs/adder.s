# Initialize stack pointer
ADDI r7, r0, 256

# Prologue
ADDI r7, r7, -4
SW   r6, 0(r7)
ADDI r6, r7, 0
ADDI r7, r7, -20

# r5 = 20
ADDI r5, r0, 20

# locals
ADDI r1, r0, 2
SW   r1, -12(r6)

ADDI r1, r0, 1
SW   r1, -16(r6)

ADDI r4, r0, 0
SW   r4, -8(r6)

J L2

L3:
LW   r2, -12(r6)
LW   r3, -16(r6)
ADD  r3, r2, r3
SW   r3, -20(r6)

LW   r2, -12(r6)
ADDI r2, r2, 1
SW   r2, -12(r6)

LW   r3, -16(r6)
ADDI r3, r3, 1
SW   r3, -16(r6)

LW   r4, -8(r6)
ADDI r4, r4, 1
SW   r4, -8(r6)

L2:
LW   r4, -8(r6)
SLT  r1, r4, r5
BNE  r1, r0, L3

end:
J end