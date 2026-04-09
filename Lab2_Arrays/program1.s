.data # where we declare the global variables that live in memory like declaring globals before main()
    A : .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 # int A[] = {1,2,...,10}
    sum : .word 0 # int sum = 0
    sz_A : .word 10 # int sz_A = 10

    # .word means "reserve space for 32 bits integers"
    

    prompt: .asciiz "The sum of the array is: " #  null-terminated string for printing like in C
    new_line: .asciiz "\n"
    
.text
    .globl main # assembly directive that makes the symbol main
                # global and this is where execution starts


main:
    la s0, A # s0 = &A[0] # la = Load Address — puts the memory address of A into register s0
    lw s1, sz_A # s1 = sz_A # lw = Load Word — reads the value at the sz_A memory address into s1
    li t0, 0 # t0 = 0 i will be the index # li = Load Immediate — puts a literal number directly into a register
    # we will use t1 to store the current array element
    li t2, 0 # t2 = 0 sum will be stored here

    #for each array element we will be first calculating the
    #address using A[i] = &A + (i * 4)

sum_loop:
    lw t1, 0(s0) # loads the values at s0 memory address starting at index 0 into t1
    add t2, t2, t1 # t2 = t2 + t1 # use add when format is a destination, address 1 and address 2 # accumulate the sum
    addi t0, t0, 1 # t0 = t0 + 1 # use addi when adding include literal numbers and not just registers # increase the index 
    addi s0, s0, 4 # s0 = s0 + 4 # advances the pointer by one word in A (one word = 4 bytes)
    bne t0, s1, sum_loop # bne = branch if not equal -> if t0 != s1 jump to sum_loop


#now save the total in sum variable which is in t2
    la t0, sum
    sw t2, 0(t0)

#print the results
    #print the prompt
    li a0, 4 # 4 is syscall for print_str
    la a1, prompt
    ecall

    # Print the sum value
    la t1, sum
    lw t1, 0(t1)
    li a0, 1 # 1 is syscall for print_int
    mv a1, t1
    ecall

    #print the newline
    li a0, 4 # 4 is syscall for print_str
    la a1, new_line
    ecall

    #now exit
    li a0, 10 # Exit code for ecall
    ecall