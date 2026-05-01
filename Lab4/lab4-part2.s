
# Lab 4 - Part 2: Optimized recursive multiply
#
# ALGORITHM
#   multiply(a, b):
#       if b > a:
#           return multiply(b, a)     # swap so the smaller drives recursion
#       else if b == 0:
#           return 0
#       else:
#           return a + multiply(a, b-1)
#
# Calling convention used here:
#   a0 = a (first arg, also return value)
#   a1 = b (second arg)

.data
str_prefix: .asciiz "The result of "
str_times:  .asciiz " * "
str_equals: .asciiz " = "
str_nl:     .asciiz "\n"

.text
    .globl main

main:
    # Try the worst case from the lab: 2 * 100. Without the optimization
    # this would recurse 100 deep; with it, only 2 deep.
    li   s0, 2          # a = 2
    li   s1, 100        # b = 100

    mv   a0, s0
    mv   a1, s1
    jal  better_multiply
    mv   s2, a0         # save result; a0 is needed for ecall arguments

    # Print "The result of "  (Venus: a0=service, a1=arg)
    li   a0, 4
    la   a1, str_prefix
    ecall

    # Print a
    li   a0, 1
    mv   a1, s0
    ecall

    # Print " * "
    li   a0, 4
    la   a1, str_times
    ecall

    # Print b
    li   a0, 1
    mv   a1, s1
    ecall

    # Print " = "
    li   a0, 4
    la   a1, str_equals
    ecall

    # Print result
    li   a0, 1
    mv   a1, s2
    ecall

    # Print newline
    li   a0, 4
    la   a1, str_nl
    ecall

    # Exit
    li   a0, 10
    ecall


# better_multiply: ensures a >= b before entering the recursion

better_multiply:
    ble  a1, a0, multiply   # if b <= a, no swap needed -> fall into multiply
    # Swap a0 and a1 using t0 as scratch
    mv   t0, a0
    mv   a0, a1
    mv   a1, t0
    # fall through to multiply with the swapped (larger, smaller) pair


# multiply: recursive a + a + ... + a  (b times)
#
# Stack frame (8 bytes per call):
#   0(sp) = saved ra
#   4(sp) = saved a0 (the value of `a` at entry)

multiply:
    addi sp, sp, -8         # allocate frame
    sw   a0, 4(sp)          # save a (because a0 is reused as return value)
    sw   ra, 0(sp)          # save return address

    # Base case: b == 0  ->  return 0
    bne  a1, zero, recursive_case
    li   a0, 0
    addi sp, sp, 8          # deallocate frame
    jr   ra

recursive_case:
    addi a1, a1, -1         # b = b - 1
    jal  multiply           # a0 <- multiply(a, b-1)

    lw   t0, 4(sp)          # t0 <- saved a
    add  a0, a0, t0         # a0 = a + multiply(a, b-1)

    lw   ra, 0(sp)          # restore ra
    addi sp, sp, 8          # deallocate frame
    jr   ra
