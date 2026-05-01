
# Lab 4 - Part 3: Recursive factorial
#
# ALGORITHM (with +5 extra credit base case: a == 0 OR a == 1 -> 1)
#   factorial(a):
#       if a <= 1:
#           return 1
#       else:
#           return a * factorial(a-1)
#
# This file also includes the bigger extra credit: the multiplication
# step uses the recursive multiply() from Part 2 instead of the `mul`
# instruction.  The factorial routine calls multiply, which itself
# recurses  recursion on recursion.
#
# Register usage:
#   factorial: a0 = a (in/out)
#   multiply : a0 = a (in/out), a1 = b
#
# Stack frame for factorial (8 bytes):
#   0(sp) = saved ra
#   4(sp) = saved a0 (the value of `a` at entry, needed after the
#                     recursive call clobbers a0 with factorial(a-1))

.data
str_prefix: .asciiz "The result of "
str_fact:   .asciiz " != "
str_nl:     .asciiz "\n"

.text
    .globl main

main:
    li   s0, 4              # compute factorial(4) -> 24
    mv   a0, s0
    jal  factorial
    mv   s2, a0             # save result; a0 is needed for ecall arguments

    # Print "The result of "  (Venus: a0=service, a1=arg)
    li   a0, 4
    la   a1, str_prefix
    ecall

    # Print n
    li   a0, 1
    mv   a1, s0
    ecall

    # Print " != "
    li   a0, 4
    la   a1, str_fact
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


# factorial(a):  returns a! in a0

factorial:
    addi sp, sp, -8         # allocate frame
    sw   a0, 4(sp)          # save a
    sw   ra, 0(sp)          # save ra

    # Base case: a <= 1  ->  return 1   (covers a==0 and a==1, +5 EC)
    li   t0, 1
    bgt  a0, t0, fact_recurse
    li   a0, 1
    lw   ra, 0(sp)
    addi sp, sp, 8
    jr   ra

fact_recurse:
    # Recursive case: factorial(a-1)
    addi a0, a0, -1         # a0 = a - 1
    jal  factorial          # a0 <- factorial(a-1)

    # Now we need:  a0 = a * factorial(a-1)
    # a0 currently holds factorial(a-1); reload original a into a1
    # so we can call multiply(a, factorial(a-1)).
    mv   a1, a0             # a1 = factorial(a-1)
    lw   a0, 4(sp)          # a0 = original a
    jal  better_multiply    # a0 <- a * factorial(a-1)

    # Restore and return
    lw   ra, 0(sp)
    addi sp, sp, 8
    jr   ra


# better_multiply / multiply: from Part 2.
# Ensures a >= b for shallow recursion, then repeats addition.

better_multiply:
    ble  a1, a0, multiply
    mv   t0, a0
    mv   a0, a1
    mv   a1, t0
    # fall through

multiply:
    addi sp, sp, -8
    sw   a0, 4(sp)          # save a
    sw   ra, 0(sp)          # save ra

    bne  a1, zero, mult_recurse
    li   a0, 0
    addi sp, sp, 8
    jr   ra

mult_recurse:
    addi a1, a1, -1
    jal  multiply

    lw   t0, 4(sp)
    add  a0, a0, t0

    lw   ra, 0(sp)
    addi sp, sp, 8
    jr   ra
