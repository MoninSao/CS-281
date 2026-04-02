.text           # assembly directive that indicates what follows
                # are instructions - really .text is a directive to
                # the assembler to put the following instructions in
                # a read-only section of memory. After all we don't
                # want our instructions to change while the program is
                # running. This is also a big security feature

    .globl main    # assembly directive that makes the symbol main
                    # global and this is where execution starts 

main: 
    addi t0, zero, 281  # This is a way to move a value
    li t1, 0x119        # specifying a hex constant
    li t2, 0b100011001  # specifying a binary constant
    li t3, 0431         # specifying an octal constant
    add t4, zero, zero  # This is a way to zero out a register

    # now exit
    li a0, 10           # Exit code for ecall
    ecall