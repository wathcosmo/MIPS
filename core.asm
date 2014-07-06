    j initial
    j scan
    jr $26
initial:
    add $at, $0, $0
    lui $at, 0x4000
    sw $0, 8($at)
    add $k1, $0, $0
    lui $k1, 0xfff0
    sw $k1, 0($at)
    addiu $k1, $0, 0xffff
    lui $k1, 0xffff
    sw $k1, 4($at)
    addi $k1, $0, 3
    sw $k1, 8($at)
    addi $Ra, $0, 0x1000
    jr $Ra
scan:
    add $at, $0, $0
    lui $at, 0x4000
    sw $0, 8($at)
    sll $k1, $a0, 8
    add $k1, $k1, $a1
    sw $k1, 20($at)
    addi $k1, $0, 3
    sw $k1, 8($at)
    jr $26
    