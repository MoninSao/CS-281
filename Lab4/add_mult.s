
.text           
	.globl  main      # assembly directive that makes the symbol main 
					  # global and this is where execution starts

main:
   # Load the values of a and b from memory
    li s0, 5         # a = 5
    li s1, 3         # 

    # Call the multiply function
    mv a0, s0
    mv a1, s1
    jal better_multiply

    # a0 should have the result
    
    ecall

########################################
#ALGORITHM
#  multiply(a,b):
#    if b == 0:
#      return 0
#    else:
#      return a + multiply(a, b-1)
######################################
better_multiply:
    bgt a0,a1, multiply
    nop                 #you need to figure this out
multiply:
    # Save the current state on the stack
    addi sp, sp, -8     # Push 2 words on stack
    sw a0, 4(sp)        # Save a 
    sw ra, 0(sp)        # Save ra

    # Base case: b == 0
    bne a1, zero, recursive_case
    li   a0, 0          # Return 0
    addi sp, sp, 8      # Pop the stack
    jr   ra

recursive_case:
    # Recursive case: result += a, b--
    addi a1, a1, -1
     # Call the multiply function
    jal multiply        # Recursive call mult(a, b-1)

    lw t0, 4(sp)        # Load the address of result into t0
    add a0, a0, t0      # result in a0 = a + mult(a, b-1)

    #Get ready to return from recursive call
    lw ra, 0(sp)        # Restore ra
    addi sp, sp, 8      # Pop stack
    jr ra