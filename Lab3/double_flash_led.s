.text           
	.globl  main 

main:
loop:
    jal flash_led
    li a0, 1000
    jal sleep
j loop

flash_led:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)

    li s0, 0
    li s1, 2 #flash twice
flash_loop:
    beq s0, s1, flash_done
    addi s0, s0, 1 #update counter

    #turn on both LEDs
    li a0, 0x121
    li a1, 0b11
    ecall
    #wait a little
    li a0, 250
    jal sleep

    #turn off both LEDs
    li a0, 0x121
    li a1, 0b00
    ecall

     #wait a little
    li a0, 250
    jal sleep

    j flash_loop

flash_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret

sleep:
    mv t0, a0
    sleep_loop:
        addi t0, t0, -1  # Decrement counter
        bnez t0, sleep_loop  # Continue loop if t0 is not zero
ret