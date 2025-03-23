.section .text
.global _start
_start:
    li a0, 5        # Load test value 1
    li a1, 7        # Load test value 2
    add a2, a0, a1  # a2 = a0 + a1
    li a3, 12       # Expected result
    bne a2, a3, fail# Compare result
    li a0, 0        # Success code
    j exit
fail:
    li a0, 1        # Error code
exit:
    nop
    j exit          # Infinite loop
