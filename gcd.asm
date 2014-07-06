.text 0x00400000
    add $sp, $zero, $zero
    lui $sp, 0x4000
    
read_a:
    lw $s0, 32($sp)
    andi $s0, $s0, 8
    beq $s0, $zero, read_a
    lw $a0, 28($sp)
read_b:
    lw $s0, 32($sp)
    andi $s0, $s0, 8
    beq $s0, $zero, read_b
    lw $a1, 28($sp)
    
    add $s1, $a0, $zero
    add $s2, $a1, $zero
gcd:
    beq $s1, $s2, output
    slt $s0, $s1, $s2
    beq $s0, $zero, diff
    add $s3, $s1, $zero
    add $s1, $s2, $zero
    add $s2, $s3, $zero
diff:
    sub $s2, $s1, $s2
    sub $s1, $s1, $s2
    j gcd
output:
    add $v0, $s1, $zero
    sw $v0, 12($sp)
uart:
    lw $s0, 32($sp)
    andi $s0, $s0, 16
    bne $s0, $zero, uart
    sw $v0, 24($sp)
    