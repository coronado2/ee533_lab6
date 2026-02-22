ADDI  r7, r0, 512
NOP
NOP
NOP

ADDI  r7, r7, -8
NOP
NOP
NOP

SW    r6, 0(r7)

ADDI  r6, r7, 0
NOP
NOP
NOP

ADDI  r7, r7, -160
NOP
NOP
NOP

ADDI  r4, r6, 0
NOP
NOP
NOP

ADDI  r4, r4, -152
NOP
NOP
NOP


ADDI  r1, r0, 323
NOP
NOP
NOP
SW    r1, 0(r4)

ADDI  r1, r0, 123
NOP
NOP
NOP
SW    r1, 8(r4)

ADDI  r1, r0, -455
NOP
NOP
NOP
SW    r1, 16(r4)

ADDI  r1, r0, 2
NOP
NOP
NOP
SW    r1, 24(r4)

ADDI  r1, r0, 98
NOP
NOP
NOP
SW    r1, 32(r4)

ADDI  r1, r0, 125
NOP
NOP
NOP
SW    r1, 40(r4)

ADDI  r1, r0, 10
NOP
NOP
NOP
SW    r1, 48(r4)

ADDI  r1, r0, 65
NOP
NOP
NOP
SW    r1, 56(r4)

ADDI  r1, r0, -56
NOP
NOP
NOP
SW    r1, 64(r4)

ADDI  r1, r0, 0
NOP
NOP
NOP
SW    r1, 72(r4)

ADDI  r1, r0, 9
NOP
NOP
NOP
SW    r1, -8(r6)


outer_loop:
    LW    r2, -8(r6)
    NOP
    NOP
    NOP

    SLT   r3, r0, r2
    NOP
    NOP
    NOP

    BNE   r3, r0, outer_continue
    NOP
    NOP
    NOP

    J     sort_done
    NOP
    NOP
    NOP


outer_continue:
    ADDI  r1, r0, 0
    NOP
    NOP
    NOP
    SW    r1, -16(r6)


inner_loop:
    LW    r3, -16(r6)
    LW    r2, -8(r6)
    NOP
    NOP
    NOP

    SLT   r1, r3, r2
    NOP
    NOP
    NOP

    BNE   r1, r0, inner_continue
    NOP
    NOP
    NOP

    J     inner_done
    NOP
    NOP
    NOP


inner_continue:
    ADD   r5, r4, r0
    NOP
    NOP
    NOP

    ADDI  r1, r0, 0
    NOP
    NOP
    NOP
    SW    r1, -24(r6)


addr_walk_A:
    LW    r1, -24(r6)
    NOP
    NOP
    NOP

    SLT   r2, r1, r3
    NOP
    NOP
    NOP

    BNE   r2, r0, do_add8_A
    NOP
    NOP
    NOP

    J     addrA_done
    NOP
    NOP
    NOP


do_add8_A:
    ADDI  r5, r5, 8
    NOP
    NOP
    NOP

    ADDI  r1, r1, 1
    NOP
    NOP
    NOP
    SW    r1, -24(r6)

    J     addr_walk_A
    NOP
    NOP
    NOP


addrA_done:
    LW    r1, 0(r5)
    NOP
    NOP
    NOP

    ADDI  r5, r5, 8
    NOP
    NOP
    NOP

    LW    r2, 0(r5)
    NOP
    NOP
    NOP

    SLT   r7, r2, r1
    NOP
    NOP
    NOP

    BNE   r7, r0, do_swap
    NOP
    NOP
    NOP


no_swap:
    SW    r7, -24(r6)

    LW    r3, -16(r6)
    NOP
    NOP
    NOP

    ADDI  r3, r3, 1
    NOP
    NOP
    NOP
    SW    r3, -16(r6)

    LW    r7, -24(r6)
    NOP
    NOP
    NOP

    J     inner_loop
    NOP
    NOP
    NOP


do_swap:
    ADDI  r5, r5, -8
    NOP
    NOP
    NOP
    SW    r2, 0(r5)

    ADDI  r5, r5, 8
    NOP
    NOP
    NOP
    SW    r1, 0(r5)

    LW    r3, -16(r6)
    NOP
    NOP
    NOP

    ADDI  r3, r3, 1
    NOP
    NOP
    NOP
    SW    r3, -16(r6)

    J     inner_loop
    NOP
    NOP
    NOP


inner_done:
    LW    r2, -8(r6)
    NOP
    NOP
    NOP

    ADDI  r2, r2, -1
    NOP
    NOP
    NOP
    SW    r2, -8(r6)

    J     outer_loop
    NOP
    NOP
    NOP


sort_done:
    ADDI  r7, r6, 0
    NOP
    NOP
    NOP

    LW    r6, 0(r7)
    NOP
    NOP
    NOP

    ADDI  r7, r7, 8
    NOP
    NOP
    NOP


end:
    J     end
    NOP
    NOP
    NOP