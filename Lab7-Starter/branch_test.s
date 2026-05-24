.text           
	.globl  main      # assembly directive that makes the symbol main 
					  # global and this is where execution starts

main:

    li t0, 0
    li t1, 3

BNE_TEST:
    loop_ne:
        addi t0, t0, 1
        bne t0, t1, loop_ne

    mv s2, t1  #t1 should equal 3

BEQ_TEST:
    li t0, 0
    li t1, 3
    loop_eq:
        beq t0, t1, end_eq
        addi t0, t0, 1
        j loop_eq
    end_eq:

    mv s3, t1  #t1 should equal 3

BLT_TEST:
    li t0, 0
    li t1, 3
    loop_lt:
        blt t0, t1, end_lt
        addi t0, t0, 1
        j loop_lt
    end_lt:

    mv s4, t1  #t1 should equal 3

   

BGE_TEST:
    li t0, 0
    li t1, 3
    loop_gte:
        addi t0, t0, 1
        bge t1, t0, loop_gte

    mv s5, t1  #t1 should equal 3
    
nop