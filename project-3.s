#02933771
# N = 31
# M = 21
# beta = 'u'
# delta = 'U'
        .data
                input: .space 1001            # amount of space for the input
                message: .ascii "-"           # message if input is invalid or greater than 4 characters
                test: .ascii "test"
        .text
              

main:
        # reads input from user
        li $v0, 8                       # syscall for read input
        la $a0, input                   # loads address of input to $a0
        li $a1, 1001                    # initializes pointer
        syscall                         # prompts system call
        la $s0, input                   # saves the address of input to $s0

sub_a:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        lw $t0, 4($sp)
        li $t1, $zero
        li $t2, ‘;’
        li $t3, $zero
