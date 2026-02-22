# -------------------------
# Initialize stack pointer
# -------------------------

ADDI r7, r0, 256      # sp = 256

# -------------------------
# Prologue
# -------------------------

ADDI r7, r7, -4       # sp -= 4
SW   r6, 0(r7)        # push old fp
ADDI r6, r7, 0        # fp = sp
ADDI r7, r7, -12      # allocate 12 bytes

# r4 = 20 (loop limit)
ADDI r4, r0, 20

# counter = 0
ADDI r2, r0, 0
SW   r2, -8(r6)

J L2

# -------------------------
# Loop Body
# -------------------------

L3:
LW   r2, -8(r6)       # r2 = counter
SW   r2, -12(r6)      # temp = counter

LW   r2, -8(r6)
ADDI r2, r2, 1
SW   r2, -8(r6)       # counter++

# -------------------------
# Loop Test
# while(counter <= 19)
# same as (counter < 20)
# -------------------------

L2:
LW   r2, -8(r6)
SLT  r3, r2, r4       # r3 = (counter < 20)
BNE  r3, r0, L3

# -------------------------
# Epilogue
# -------------------------

ADDI r7, r6, 0        # sp = fp
LW   r6, 0(r7)        # restore old fp
ADDI r7, r7, 4        # pop

end:
J end