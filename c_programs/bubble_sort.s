ADDI  r7, r0, 512        
 

ADDI  r7, r7, -8         
SW    r6, 0(r7)         
ADDI  r6, r7, 0          
ADDI  r7, r7, -160       

ADDI  r4, r6, 0           
ADDI  r4, r4, -152        


ADDI  r1, r0, 323
SW    r1, 0(r4)

ADDI  r1, r0, 123
SW    r1, 8(r4)

ADDI  r1, r0, -455
SW    r1, 16(r4)

ADDI  r1, r0, 2
SW    r1, 24(r4)

ADDI  r1, r0, 98
SW    r1, 32(r4)

ADDI  r1, r0, 125
SW    r1, 40(r4)

ADDI  r1, r0, 10
SW    r1, 48(r4)

ADDI  r1, r0, 65
SW    r1, 56(r4)

ADDI  r1, r0, -56
SW    r1, 64(r4)

ADDI  r1, r0, 0
SW    r1, 72(r4)

ADDI  r1, r0, 9
SW    r1, -8(r6)         


outer_loop:
    LW    r2, -8(r6)      
   
    
    SLT   r3, r0, r2      
    BNE   r3, r0, outer_continue
   
    J     sort_done

outer_continue:
    ADDI  r1, r0, 0
    SW    r1, -16(r6)     

inner_loop:
    LW    r3, -16(r6)    
    LW    r2, -8(r6)      
   
    SLT   r1, r3, r2
    BNE   r1, r0, inner_continue
    
    J     inner_done

inner_continue:
  
    ADD   r5, r4, r0      ; r5 = base
    
    ADDI  r1, r0, 0
    SW    r1, -24(r6)     ; t = 0

addr_walk_A:
    
    LW    r1, -24(r6)
   
    SLT   r2, r1, r3
    BNE   r2, r0, do_add8_A
    
    J     addrA_done

do_add8_A:
    ADDI  r5, r5, 8       ; r5 += 8
   
    ADDI  r1, r1, 1
    SW    r1, -24(r6)
    J     addr_walk_A

addrA_done:
    
    
    LW    r1, 0(r5)       

    ADDI  r5, r5, 8       
    LW    r2, 0(r5)       

    SLT   r7, r2, r1      
    BNE   r7, r0, do_swap  

no_swap:
    SW    r7, -24(r6)

    LW    r3, -16(r6)
    ADDI  r3, r3, 1
    SW    r3, -16(r6)

    LW    r7, -24(r6)

    J     inner_loop

do_swap:
    ADDI  r5, r5, -8      
    SW    r2, 0(r5)
    ADDI  r5, r5, 8
    SW    r1, 0(r5)

    LW    r3, -16(r6)
    ADDI  r3, r3, 1
    SW    r3, -16(r6)

    J     inner_loop

inner_done:
    LW    r2, -8(r6)
    ADDI  r2, r2, -1
    SW    r2, -8(r6)
    J     outer_loop

sort_done:
    ADDI  r7, r6, 0    
    LW    r6, 0(r7)    
    ADDI  r7, r7, 8    
end:
    J     end