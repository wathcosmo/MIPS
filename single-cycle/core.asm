    j initial
    j scan
    jr $26
initial:
    add $Ra, $0, $0  //0c
    lui $Ra, 0x0040 
    add $sp, $0, $0
    lui $sp, 0x4000
    sw $0, 8($sp)
    add $s1, $0, $0  
    lui $s1, 0xffff
    sw $s1, 0($sp)
    addiu $s1, $0, 0xffff
    lui $s1, 0xffff  
    sw $s1, 4($sp)
    addi $s1, $0, 3
    sw $s1, 8($sp)
    jr $Ra     
scan:
    addi $26, $26, -4  //44
    sw $0, 8($sp)
    sll $s1, $a0, 8
    add $s1, $s1, $a1
    sw $s1, 20($sp)
    addi $s1, $0, 3
    sw $s1, 8($sp)
    jr $26