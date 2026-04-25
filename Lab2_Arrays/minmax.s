.data

    A : .word 5, 4, 3, 2, 1, 10, 9, 8, 7, 6
    sz_A : .word 10
    min : .word 0x7FFFFFFF  # max signed value 2^31 - 1 
    max : .word 0x80000000  # min signed value -2^31    

    prompt_min: .asciiz "The minimum value in the array is: "
    prompt_max: .asciiz "The maximum value in the array is: "
    new_line: .asciiz "\n"

.text
    .globl main # assembly directive that makes the symbol main
                # global and this is where execution starts

main:
    #  Load base address of A and array size 
    la   s0, A          # s0 = &A[0]
    la   t3, sz_A       # load address of sz_A
    lw   s1, 0(t3)      # s1 = sz_A (10)

    #  Load initial min and max sentinel values 
    la   t3, min
    lw   s2, 0(t3)      # s2 = min = 0x7FFFFFFF largest possible signed int
    la   t3, max
    lw   s3, 0(t3)      # s3 = max = 0x80000000 smallest possible signed int

    li   t0, 0          # t0 = i = 0 loop index

    #  Main loop: iterate over each element of A 
loop:
    lw   t1, 0(s0)      # t1 = A[i] load current element

    # if t1 < s2 (current < min), update min
    bge  t1, s2, skip_min   # if t1 >= s2, skip the update
    mv   s2, t1             # s2 = t1 new minimum found
skip_min:

    # if t1 > s3 (current > max), update max
    ble  t1, s3, skip_max   # if t1 <= s3, skip the update
    mv   s3, t1             # s3 = t1 new maximum found
skip_max:

    addi t0, t0, 1      # i++
    addi s0, s0, 4      # advance pointer to next element 4 bytes per word
    bne  t0, s1, loop   # if i != sz_A, continue loop

    #  Print minimum result 
    li   a0, 4          # syscall 4 = print_str
    la   a1, prompt_min
    ecall

    li   a0, 1          # syscall 1 = print_int
    mv   a1, s2         # a1 = minimum value
    ecall

    li   a0, 4          # syscall 4 = print_str
    la   a1, new_line
    ecall

    #  Print maximum result 
    li   a0, 4          # syscall 4 = print_str
    la   a1, prompt_max
    ecall

    li   a0, 1          # syscall 1 = print_int
    mv   a1, s3         # a1 = maximum value
    ecall

    li   a0, 4          # syscall 4 = print_str
    la   a1, new_line
    ecall

    #  Exit 
    li   a0, 10         # syscall 10 = exit
    ecall
