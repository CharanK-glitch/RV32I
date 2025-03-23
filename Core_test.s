# core_test.s
.section .text
.global _start
_start:
    # Arithmetic test
    li t0, 0x1234
    li t1, 0x5678
    add t2, t0, t1    # t2 = 0x68AC
    sub t3, t1, t0    # t3 = 0x4444
    
    # Memory test
    li s0, 0x10000000
    sw t2, 0(s0)
    lw t4, 0(s0)
    
    # Branch test
    beq t2, t4, test_ok
    j test_fail

test_ok:
    li a0, 0xDEADBEEF
    j exit

test_fail:
    li a0, 0xBADBADBA

exit:
    j exit
