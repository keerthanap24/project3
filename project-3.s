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
        # push the sub_a parameters to stack

sub_a:
        addi $sp, $sp, -4               
        sw $ra, 0($sp)                  # pushes the return address to the stack
        lw $t0, 4($sp)                  # loads the string address into the subprogram
        li $t1, $zero                   # initializes the length of the string
        li $t2, ‘;’                     # register for ';' value
        li $t3, $zero                   # register for '0' value

        addi $sp, $sp, -4               
        sw $t0, 0($sp)                  # pushes initial pointer value into stack
