ADDI r4, r0, 352
ADDI r1, r0, 111
NOP
NOP
NOP
SW   r1, 0(r4)
ADDI r2, r0, 1
ADDI r3, r0, 0
NOP
NOP
NOP
BNE  r2, r3, skip_bad
NOP
NOP
NOP
NOP   
ADDI r1, r0, 222
NOP
NOP
NOP
SW   r1, 0(r4)
skip_bad:
end:
J end
NOP
NOP
NOP
NOP