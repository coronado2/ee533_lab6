ADDI r1, r1, 10
ADDI r2, r2, 20
ADDI r3, r3, 30
ADDI r4, r4, 40



SW   r2, 0(r1)



BEQ  r6, r3, break




SW   r3, 0(r1)




LW   r7, 0(r1)

break:
LW   r7, 0(r1)

end:
J end