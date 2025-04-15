# Simple arithmetic test program
main:
    addi x1, x0, 5      # x1 = 5
    addi x2, x0, 3      # x2 = 3
    add  x3, x1, x2     # x3 = x1 + x2 = 8
    sub  x4, x1, x2     # x4 = x1 - x2 = 2
    and  x5, x1, x2     # x5 = x1 & x2 = 1
    or   x6, x1, x2     # x6 = x1 | x2 = 7
    addi x7, x0, 10     # x7 = 10
loop:
    addi x7, x7, -1     # x7 = x7 - 1
    bne  x7, x0, loop   # loop until x7 == 0
    sw   x3, 0(x0)      # store x3 to memory[0]
    lw   x8, 0(x0)      # load x8 from memory[0]
