.data

.text           
	.globl  main 

main:
loop:
    li a0, 0x122
    ecall
    jal update_led
j loop


update_led:
    addi sp, sp, -4
    sw ra, 0(sp)

    mv a1,a0    #a1 is what led to update
    li a0, 0x121
    ecall

    #wait a little
    li a0, 500
    jal sleep

    lw ra, 0(sp)
    addi sp, sp, 4

    ret

sleep:
    mv t0, a0
    sleep_loop:
        addi t0, t0, -1  # Decrement counter
        bnez t0, sleep_loop  # Continue loop if t0 is not zero
ret

