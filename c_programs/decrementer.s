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

# counter = 20
ADDI r2, r0, 20
SW   r2, -8(r6)

J L2

# -------------------------
# Loop Body
# -------------------------

L3:
LW   r2, -8(r6)       # r2 = counter
SW   r2, -12(r6)      # temp = counter

LW   r2, -8(r6)
ADDI r2, r2, -1       # counter--
SW   r2, -8(r6)

# -------------------------
# Loop Test
# while(counter > 0)
# -------------------------

L2:
LW   r2, -8(r6)
SLT  r3, r0, r2       # r3 = (0 < counter)
BNE  r3, r0, L3

# -------------------------
# Epilogue
# -------------------------

ADDI r7, r6, 0
LW   r6, 0(r7)
ADDI r7, r7, 4

end:
J end