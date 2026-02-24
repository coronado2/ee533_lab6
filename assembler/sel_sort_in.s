ADDI  r4, r0, 10
NOP
NOP
NOP

ADDI  r5, r0, 20
NOP
NOP
NOP

ADDI  r1, r0, 0
NOP
NOP
NOP
SW    r1, 0(r5)
NOP
NOP
NOP

ADDI  r1, r0, 9
NOP
NOP
NOP
SW    r1, 1(r5)
NOP
NOP
NOP

outer:
LW    r3, 1(r5)
NOP
NOP
NOP
BEQ   r3, r0, done
NOP
NOP
NOP
NOP

LW    r3, 0(r5)
NOP
NOP
NOP
SW    r3, 3(r5)
NOP
NOP
NOP

ADDI  r1, r3, 1
NOP
NOP
NOP
SW    r1, 2(r5)
NOP
NOP
NOP

inner:
LW    r1, 2(r5)
NOP
NOP
NOP
ADDI  r2, r0, 10
NOP
NOP
NOP
SLT   r2, r1, r2
NOP
NOP
NOP
BEQ   r2, r0, inner_done
NOP
NOP
NOP
NOP

ADD   r2, r4, r1
NOP
NOP
NOP
LW    r2, 0(r2)
NOP
NOP
NOP

LW    r7, 3(r5)
NOP
NOP
NOP
ADD   r7, r4, r7
NOP
NOP
NOP
LW    r7, 0(r7)
NOP
NOP
NOP

SLT   r6, r2, r7
NOP
NOP
NOP
BEQ   r6, r0, inner_next
NOP
NOP
NOP
NOP

LW    r1, 2(r5)
NOP
NOP
NOP
SW    r1, 3(r5)
NOP
NOP
NOP

inner_next:
LW    r1, 2(r5)
NOP
NOP
NOP
ADDI  r1, r1, 1
NOP
NOP
NOP
SW    r1, 2(r5)
NOP
NOP
NOP

J     inner
NOP
NOP
NOP
NOP

inner_done:
LW    r3, 0(r5)
NOP
NOP
NOP
ADD   r6, r4, r3
NOP
NOP
NOP

LW    r7, 3(r5)
NOP
NOP
NOP
ADD   r2, r4, r7
NOP
NOP
NOP

BEQ   r6, r2, outer_next
NOP
NOP
NOP
NOP

LW    r1, 0(r6)
LW    r7, 0(r2)
NOP
NOP
NOP
SW    r7, 0(r6)
SW    r1, 0(r2)
NOP
NOP
NOP

outer_next:
LW    r3, 0(r5)
NOP
NOP
NOP
ADDI  r3, r3, 1
NOP
NOP
NOP
SW    r3, 0(r5)
NOP
NOP
NOP

LW    r3, 1(r5)
NOP
NOP
NOP
ADDI  r3, r3, -1
NOP
NOP
NOP
SW    r3, 1(r5)
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