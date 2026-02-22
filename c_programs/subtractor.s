# -------------------------
# Initialize stack pointer
# -------------------------

ADDI r7, r0, 256      # sp = 256

# -------------------------
# Prologue
# -------------------------

ADDI r7, r7, -4
SW   r6, 0(r7)
ADDI r6, r7, 0
ADDI r7, r7, -20

# Load constants
ADDI r2, r0, 20       # a = 20
SW   r2, -12(r6)

ADDI r3, r0, 5        # b = 5
SW   r3, -16(r6)

ADDI r4, r0, 0        # counter = 0
SW   r4, -8(r6)

ADDI r5, r0, 20       # limit = 20

J L2

# -------------------------
# Loop Body
# -------------------------

L3:
LW   r2, -12(r6)      # a
LW   r3, -16(r6)      # b
SUB  r1, r2, r3       # result = a - b
SW   r1, -20(r6)

LW   r2, -12(r6)
ADDI r2, r2, -1
SW   r2, -12(r6)      # a--

LW   r3, -16(r6)
ADDI r3, r3, -1
SW   r3, -16(r6)      # b--

LW   r4, -8(r6)
ADDI r4, r4, 1
SW   r4, -8(r6)       # counter++

# -------------------------
# Loop Test
# -------------------------

L2:
LW   r4, -8(r6)
SLT  r1, r4, r5       # r1 = (counter < 20)
BNE  r1, r0, L3

# -------------------------
# Epilogue
# -------------------------

ADDI r7, r6, 0
LW   r6, 0(r7)
ADDI r7, r7, 4

end:
J end