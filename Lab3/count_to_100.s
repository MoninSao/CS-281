.data
                   #76543210
    digits: .word 0b00111111,   # 0
            .word 0b00000110,   # 1   
            .word 0b01011011,   # 2
            .word 0b01001111,   # 3
            .word 0b01100110,   # 4
            .word 0b01101101,   # 5
            .word 0b01111101,   # 6
            .word 0b00000111,   # 7
            .word 0b01111111,   # 8
            .word 0b01100111    # 9
     digit_msk : .word 0b111111111111111
     digit_max : .word 100
     digits_sz : .word 10

.text           
	.globl  main 

main:
li s0, 0
la s1, digit_max
lw s1, 0(s1)

loop:
    blt s0, s1, next
    li s0, 0
next:
    #with the correct value of the
    #digit in s3, we will extract
    #the digits using the BCD function
    mv a0, s0

    jal write_lcd

    li a0, 500
    jal sleep
    

    addi s0, s0, 1
    j loop
  
    ret

write_lcd:
    addi sp, sp, -4
    sw ra, 0(sp)

    #digit is in a0
    jal extract_bcd #a0 = 10's place, a1 = 1's place
    jal encode_digit #a0 = encoded for 7 segment display
    mv a1,a0    #a1 = argument for 7 seg display update

    #now get the mask
    la t0, digit_msk
    lw a2, 0(t0)

    #a1 and a2 args are now setup
    li a0, 0x120
    ecall

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

    

#accepts a number and returns the bitfield for the 
#seven segment display
extract_bcd:
    # Load the input number from a0
    mv t0, a0           # t0 = input number

    # Extract the 10's place by dividing by 10
    li t1, 10           # t1 = 10
    div t2, t0, t1      # t2 = t0 / 10 (10's place)
    rem t3, t0, t1      # t3 = t0 % 10 (1's place)

    # Store the results in a0 and a1
    mv a0, t2           # a0 = 10's place
    mv a1, t3           # a1 = 1's place

    # Return from the function
    ret

encode_digit:
    # Load the input 10s place from a0
    
    # Calculate the address of the digit table
    la t0, digits       # t1 = &digits[0]

    # Calculate the offset for the digit table
    slli a0, a0, 2      # Table offset for 10's place
    slli a1, a1, 2      # Table offset for 1's place

    add t1, t0, a0      # address of 10's place digit
    add t2, t0, a1      # address of 1's place digit
    lw a0, 0(t1)        # a0 = 10's place digit
    lw a1, 0(t2)        # a1 = 1's place digit

    # Combine the 10's and 1's place digits
    slli a0, a0, 8      # Shift 10's place to the left
    or a0, a0, a1       # Combine 10's and 1's place

    #a0 now has the bitfield for the seven segment display
    # [ digit 10's place ][ digit 1's place ]
    ret

sleep:
    mv t0, a0
    sleep_loop:
        addi t0, t0, -1  # Decrement counter
        bnez t0, sleep_loop  # Continue loop if t0 is not zero
ret