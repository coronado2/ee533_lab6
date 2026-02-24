ADDI  r4, r0, 352
NOP
NOP
NOP

ADDI  r1, r0, 323
NOP
NOP
NOP
SW    r1, 0(r4)
NOP
NOP
NOP

ADDI  r1, r0, 123
NOP
NOP
NOP
SW    r1, 1(r4)
NOP
NOP
NOP

ADDI  r1, r0, -455
NOP
NOP
NOP
SW    r1, 2(r4)
NOP
NOP
NOP

ADDI  r1, r0, 2
NOP
NOP
NOP
SW    r1, 3(r4)
NOP
NOP
NOP

ADDI  r1, r0, 98
NOP
NOP
NOP
SW    r1, 4(r4)
NOP
NOP
NOP

ADDI  r1, r0, 125
NOP
NOP
NOP
SW    r1, 5(r4)
NOP
NOP
NOP

ADDI  r1, r0, 10
NOP
NOP
NOP
SW    r1, 6(r4)
NOP
NOP
NOP

ADDI  r1, r0, 65
NOP
NOP
NOP
SW    r1, 7(r4)
NOP
NOP
NOP

ADDI  r1, r0, -56
NOP
NOP
NOP
SW    r1, 8(r4)
NOP
NOP
NOP

ADDI  r1, r0, 0
NOP
NOP
NOP
SW    r1, 9(r4)
NOP
NOP
NOP

ADDI  r6, r0, 9
NOP
NOP
NOP
NOP

NOP
outer:
BEQ   r6, r0, done
NOP
NOP
NOP
NOP

ADDI  r3, r0, 0
NOP
NOP
NOP
ADD   r5, r4, r0
NOP
NOP
NOP

inner_cond:
SLT   r2, r3, r6
NOP
NOP
NOP
BEQ   r2, r0, inner_done
NOP
NOP
NOP
NOP

LW    r7, 0(r5)
NOP
NOP
NOP
LW    r1, 1(r5)
NOP
NOP
NOP

SLT   r7, r1, r7
NOP
NOP
NOP
BEQ   r7, r0, noswap
NOP
NOP
NOP
NOP

LW    r7, 0(r5)
NOP
NOP
NOP
LW    r1, 1(r5)
NOP
NOP
NOP

SW    r1, 0(r5)
NOP
NOP
NOP
SW    r7, 1(r5)
NOP
NOP
NOP

noswap:
ADDI  r5, r5, 1
NOP
NOP
NOP
ADDI  r3, r3, 1
NOP
NOP
NOP

NOP
inner_cond_jump:
J     inner_cond
NOP
NOP
NOP
NOP

inner_done:
ADDI  r6, r6, -1
NOP
NOP
NOP
NOP

J     outer
NOP
NOP
NOP
NOP

done:
end:
J end
NOP
NOP
NOP
NOP