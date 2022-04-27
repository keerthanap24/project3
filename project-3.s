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
        loop:
                beq $t2, 0($t0), continue   # if pointer value is ';' branch to continue label
                beq $t3, 0($t0), continue   # if pointer value is zero branch to continue label
                addi $t1, $t1, 1            # else increment length by one
                addi $t0, $t0, 1            # else increment pointer by one
                j loop                      # jump back to beginning of loop
        continue:
                lw $ra, 16($sp)             # call return address back from stack
                beqz $t1, jr $ra            # if length of string is zero exit subprogram
                addi $sp, $sp, -12  
                sw $t1, 8($sp)              # push length of string onto stack
                                        # push two more values on to the stack for return values
                jal sub_b                   # calls subprogram b
                lw $t4, 0($sp)              # gets return value (0 or 1) check return value 1 for success or failure
                beq $t4, $zero, invalid     # if return value is zero branch to invalid label
                lw $t5, 4($sp)              # gets decimal return value from stack
                li $v0, 1                   # syscall for print decimal
                syscall
                beq $t0, $t2, comma         # branch to comma label if last character is semicolon
                beqz $t0, jr $ra            # if last character is zero exit the loop
                addi $t0, $t0, 1            # increment pointer to character after semicolon
                li $t1, $zero               # start length count again from 0
                j loop                      # jump back to beginning of loop label
        comma:
                li $t6, ','
                li $v0, 4                   # prints comma if semicolon is found