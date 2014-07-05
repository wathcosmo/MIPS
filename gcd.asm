    add $v0, $zero, $zero
    add $sp, $zero, $zero
    lui $sp, 0x4000
read_a:
    lw $s0, 32($sp)
    andi $s0, $s0, 8
    beq $s0, $zero, read_a
    lw $s1, 28($sp)
read_b:
    lw $s0, 32($sp)
    andi $s0, $s0, 8
    beq $s0, $zero, read_b
    lw $s2, 28($sp)
gcd:
    beq $s1, $s2, result
    slt $s0, $s1, $s2
    beq $s0, $zero, diff
    add $s3, $s1, $zero
    add $s1, $s2, $zero
    add $s2, $s3, $zero
diff:
    sub $s2, $s1, $s2
    sub $s1, $s1, $s2
    j gcd
result:
    add $v0, $s1, $zero
