.text           
	.globl  main      # assembly directive that makes the symbol main 
					  # global and this is where execution starts

main:

    li t0, 0
    li t1, 5

    loop:
        beq t0, t1, end
        addi t0, t0, 1
        j loop
    end:

    mv t2, t1  #t2 should equal 5
    