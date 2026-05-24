.text           
	.globl  main      # assembly directive that makes the symbol main 
					  # global and this is where execution starts

main:

    li a0, 0

    jal add_one
    mv s2, a0
    ecall

add_one:
    addi a0, a0, 1
    jr ra
