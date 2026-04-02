.text
    # Lab 1 by Monin Sao 
    .globl _start

_start:
    add  t0, zero, zero     # 1. Initialize t0 to 0
    li   t1, 10             # 2. Load decimal 10 into t1
    li   t2, 0x14           # 3. Load hex 0x14 (20) into t2
    add  t0, t1, t2         # 4. t0 = t1 + t2  (10 + 20 = 30)
    addi t0, t0, 0b1000110  # 5. Add binary 0b1000110 (70) to t0

    # exit
    li   a0, 10             # exit ecall code
    ecall
