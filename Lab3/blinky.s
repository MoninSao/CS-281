.text           
	.globl  main 

main:
loop:
    li a0, 0x121
    li a1, 0b01
    ecall
    li a0, 1000
    jal sleep
    li a0, 0x121
    li a1, 0b10
    ecall
    li a0, 1000
    jal sleep
j loop


sleep:
    mv t0, a0
    sleep_loop:
        addi t0, t0, -1  # Decrement counter
        bnez t0, sleep_loop  # Continue loop if t0 is not zero
ret