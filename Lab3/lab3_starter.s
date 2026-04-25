# Lab 3 - IoT and Hardware Interfacing
# Author: Monin Sao
#
# Extra Credit Attempted:
#   EC1 (+3 pts): flash_led(a0) blinks both LEDs 'a0' times; errors blink 5x
#   EC2 (+3 pts): Green (top) LED on for even values, Red (bottom) LED for odd
#   EC3 (+4 pts): Both LEDs on when current value is a power of 2 (overrides EC2)

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

# Button state constants (returned by ecall 0x122)
.equ LEFT_PRESS,  0b10     # left button pressed
.equ RIGHT_PRESS, 0b01     # right button pressed
.equ NO_PRESS,    0b00     # no button pressed

# Counter boundaries
.equ MIN_VAL, 0
.equ MAX_VAL, 99

# LED control constants (a1 argument for ecall 0x121)
.equ LED_BOTH_ON,  0b11    # both LEDs on
.equ LED_BOTH_OFF, 0b00    # both LEDs off
.equ LED_GREEN,    0b01    # top (green) LED on only
.equ LED_RED,      0b10    # bottom (red) LED on only

    .globl  main

# ============================================================
# main: Initialize display to "00" then enter the main loop
# ============================================================
main:
    li s0, 0            # initialize counter to 0
    mv a0, s0
    jal write_lcd       # display "00" on 7-segment
    jal update_leds     # set initial LED state (green for even 0)

loop:
    li a0, 0x122        # ecall to read button state
    ecall
    mv a1, s0           # pass current counter as second argument
    jal adjust_counter  # returns updated counter in a0
    mv s0, a0           # save updated counter value
    j loop

    ret                 # never reached

# ============================================================
# adjust_counter(a0 = button state, a1 = current counter)
# Increments or decrements the counter based on button press,
# updates the display, and returns the new value in a0.
# ============================================================
adjust_counter:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    mv s0, a1           # hold current counter in s0

    # Branch based on which button was pressed
    li t0, NO_PRESS
    beq a0, t0, exit_adj_counter
    li t0, LEFT_PRESS
    beq a0, t0, dec_counter
    li t0, RIGHT_PRESS
    beq a0, t0, inc_counter
    j err_counter       # unknown state, treat as error

# --- Decrement counter (LEFT button) ---
dec_counter:
    li t0, MIN_VAL
    beq s0, t0, err_counter  # at minimum – cannot decrement, signal error
    addi s0, s0, -1           # decrement the counter
    mv a0, s0
    jal write_lcd             # update the 7-segment display
    jal update_leds           # EC2/EC3: update LED indicator
    j exit_adj_counter

# --- Increment counter (RIGHT button) ---
inc_counter:
    li t0, MAX_VAL
    beq s0, t0, err_counter  # at maximum – cannot increment, signal error
    addi s0, s0, 1            # increment the counter
    mv a0, s0
    jal write_lcd             # update the 7-segment display
    jal update_leds           # EC2/EC3: update LED indicator
    j exit_adj_counter

# --- Boundary error: flash LEDs to notify user ---
err_counter:
    li a0, 5            # EC1: blink 5 times (parameterised, not hard-coded)
    jal flash_led
    jal update_leds     # restore LED state after flashing

# --- Return the (possibly unchanged) counter ---
exit_adj_counter:
    mv a0, s0           # return counter value
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# ============================================================
# write_lcd(a0 = counter value 0-99)
# Encodes the value and writes it to the dual 7-segment display
# ============================================================
write_lcd:
    addi sp, sp, -4
    sw ra, 0(sp)

    jal extract_bcd     # a0 = 10s digit, a1 = 1s digit
    jal encode_digit    # a0 = combined 16-bit segment bitfield

    mv a1, a0           # a1 = segment data for the ecall
    la t0, digit_msk
    lw a2, 0(t0)        # a2 = update mask (all 1s = update every segment)

    li a0, 0x120        # ecall to update 7-segment display
    ecall

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# ============================================================
# extract_bcd(a0 = number 0-99)
# Returns: a0 = 10s digit, a1 = 1s digit
# ============================================================
extract_bcd:
    mv t0, a0
    li t1, 10
    div t2, t0, t1      # t2 = 10s place
    rem t3, t0, t1      # t3 = 1s place
    mv a0, t2
    mv a1, t3
    ret

# ============================================================
# encode_digit(a0 = 10s digit, a1 = 1s digit)
# Returns: a0 = 16-bit bitfield for both 7-segment displays
# Upper byte (bits 8-15) = left display, lower byte = right display
# ============================================================
encode_digit:
    la t0, digits
    slli a0, a0, 2      # word offset into digit table for 10s digit
    slli a1, a1, 2      # word offset into digit table for 1s digit
    add t1, t0, a0      # address of 10s digit entry
    add t2, t0, a1      # address of 1s digit entry
    lw a0, 0(t1)        # segment bitfield for 10s digit
    lw a1, 0(t2)        # segment bitfield for 1s digit
    slli a0, a0, 8      # shift 10s digit to upper byte (left display)
    or a0, a0, a1       # combine both digits into one 16-bit field
    ret

# ============================================================
# update_leds()
# EC3: Both LEDs on if s0 is a power of 2 (checked first)
# EC2: Green LED if s0 is even, Red LED if s0 is odd
# Reads current counter directly from s0 (no argument needed)
# ============================================================
update_leds:
    # EC3: check power of 2 using the identity: (n & (n-1)) == 0 for powers of 2
    # Special case: 0 is NOT a power of 2
    beqz s0, not_power2         # 0 fails the power-of-2 check
    addi t0, s0, -1
    and t1, s0, t0
    bnez t1, not_power2         # (n & (n-1)) != 0 means multiple bits set

    # Value is a power of 2 – turn on both LEDs
    li a0, 0x121
    li a1, LED_BOTH_ON
    ecall
    ret

not_power2:
    # EC2: test the least significant bit to determine odd vs even
    andi t0, s0, 1
    beqz t0, even_val

odd_val:
    # Odd number: turn on red (bottom) LED only
    li a0, 0x121
    li a1, LED_RED
    ecall
    ret

even_val:
    # Even number: turn on green (top) LED only
    li a0, 0x121
    li a1, LED_GREEN
    ecall
    ret

# ============================================================
# flash_led(a0 = number of blink cycles)
# EC1: Flashes both LEDs the specified number of times.
# Called with a0=5 on boundary errors.
# ============================================================
flash_led:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)

    mv s1, a0           # s1 = total blink count
    li s0, 0            # s0 = current blink index

flash_loop:
    beq s0, s1, flash_done
    addi s0, s0, 1

    li a0, 0x121        # turn on both LEDs
    li a1, LED_BOTH_ON
    ecall
    li a0, 250
    jal sleep

    li a0, 0x121        # turn off both LEDs
    li a1, LED_BOTH_OFF
    ecall
    li a0, 250
    jal sleep

    j flash_loop

flash_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret

# ============================================================
# sleep(a0 = loop iteration count)
# Busy-wait delay loop
# ============================================================
sleep:
    mv t0, a0
sleep_loop:
    addi t0, t0, -1
    bnez t0, sleep_loop
    ret