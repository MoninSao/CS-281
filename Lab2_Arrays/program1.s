.data # where we declare the global variables that live in memory like declaring globals before main()
    A : .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 # int A[] = {1,2,...,10}
    sum : .word 0 # int sum = 0 # to hold the sum of A

    # .word means "reserve space for 32 bits integers"
    # the difference: la gives you the address, lw gives you the value at that address
    

    prompt: .asciiz "The sum of the array is: " #  null-terminated string for printing like in C
    new_line: .asciiz "\n"
    
.text
    .globl main # assembly directive that makes the symbol main
                # global and this is where execution starts


main:
    la s0, A # s0 = &A[0] # la = Load Address: puts the memory address of A into register s0
    la s1, sum  # load the memory address of sum register s1 and sum sits right after A in memory if theres a another vairable between them the calculation would not work.
    sub s1, s1, s0 # sz_A_in_bytes = &sum - &A # use sub when format is a destination, register 1 and register 2
                                # obtain the total number of bytes used to store A
    srli s1, s1, 2 # each word is 4 bytes, so we need sz_A_in_words = sz_A_in_bytes / 4.
                   # shifting right by 2 bits divides by 4

    li t0, 0 # t0 = 0 i will be the index # li = Load Immediate:s puts a literal number directly into a register
    # we will use t1 to store the current array element
    li t2, 0 # t2 = 0 sum will be stored here

    #for each array element we will be first calculating the
    #address using A[i] = &A + (i * 4)

sum_loop:
    lw t1, 0(s0) # lw = load words: loads the values at s0 memory address into t1 # The zero is not starting at index 0 its just the byte offset from s0 # 0 the offset of how many bytes to move forward from that base before reading
    add t2, t2, t1 # t2 = t2 + t1 # use add when format is a destination, register 1 and register 2 # accumulate the sum
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