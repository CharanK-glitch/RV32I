_start:
    li s0, 0x20000000   # GPIO base address
    li s1, 0x30000000   # UART base address
    li s2, 0x10000000   # Timer base address

    # Configure GPIO as output
    li t0, 0xFFFFFFFF
    sw t0, 0(s0)

    # Send message via UART
    li t0, 'H'
    sb t0, 0(s1)
    li t0, 'i'
    sb t0, 0(s1)

    # Blink GPIO
loop:
    li t0, 0xAAAAAAAA
    sw t0, 4(s0)
    call delay
    li t0, 0x55555555
    sw t0, 4(s0)
    call delay
    j loop

delay:
    li t1, 1000000
delay_loop:
    addi t1, t1, -1
    bnez t1, delay_loop
    ret
