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
                # push register values to stack to use them in sub_b
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
        invalid:
                la $a0, message             # load address of message (defined in data section) to $a0
                li $v0, 4                   # system call for print message
                syscall                 


sub_b:
        # save t0 to stack
        lw $t0, 12($sp)
        lw $t1, 8($sp)
        addi $s1, $t1, 0                        # stores string length in $s0 (saved register)
        add $v1, $t0, $s1                       # finds the address of the last character
        addi $s2, $v1, 0                        # stores last character address to $s2
        beqz $s1, invalid		        # if length of string is 0 exit the program

        move $a0, $s1		                # pass length of string as an argument for whitespace subprogram
        move $a1, $s0		                # pass pointer to beginning of string as an argument for whitespace subprogram
        jal removeleadingws                     # calling subprogram for removing leading whitespaces
        move $s0, $v0			        # store address of first non-whitespace character in $s0

        beqz $s1, invalid	                # if length of string is 0 exit the program

        move $a0, $s2			        # pass pointer to end of string as an argument for removeendingws subprogram
        addi $a1, $s1, 0		        # pass length of string to removeendingws
        jal removeendingws                      # calling subprogram for removing ending whitespaces

        beqz $s1, invalid	                # branch to invalid if length of input string ($s1) is 0 exit program
	bgt $s1, 4, invalid		        # if length of input string ($s1) is greater than 4 exit program

        addi $a0, $s1, 0	                # pass length of string to convert subprogram
        move $a1, $s0			        # pass pointer to start of string to convert subprogram
        li $a2, 31			        # pass the exponent base to convert subprogram
        jal convert                             # calling subprogram for converting string to decimal
        move $s3, $v0			        # store the final sum to $s3 after conversion


        removeleadingws:									
	        li $t1, 0		        # initialize index for loop
	        li $t2, 32		        # store ascii value for blank space character
	        li $t3, 9		        # store ascii value for tab character
        loop_1:
	        lb $t0, 0($a1)		        # store pointer to first character of the string in $t0
                beq $t0, $t2, whitespace        # branch to whitespace if current character is ' ' (blank space)	
                beq $t0, $t3, whitespace        # branch to whitespace if current character is '		' (horizontal tab)
                beq $t0, $a0, invalid           # branch to invalid if length of string is 0
                j return_1
        whitespace:                             # parses the string including whitespace characters
        	addi $a1, $a1, 1	        # increments string pointer
                addi $t1, $t1, 1	        # increments the loop
                j loop_1                        # starts the loop again
        return_1:
                move $v0, $a1		        # store pointer to first non-whitespace character as result
                sub $s1, $s1, $t1	        # store the length of the input without the leading whitespaces
                jr $ra                          


        removeendingws:									
                li $t1, 0		        # initialize index for loop
                li $t2, 32		        # store ascii value for blank space character
                li $t3, 9		        # store ascii value for tab character
        loop_2:
                beq $t1, $a1, return_2          # branch to return_2 if string length is 0
                lb $t0, 0($a0)		        # store pointer to last character of the string in $t0
                beq $t0, $t2, whitespace_1      # branch to whitespace_1 if current character is ' '	
                beq $t0, $t3, whitespace_1      # branch to whitespace_1 if current character is '		'
                j return_2
        whitespace_1:
                addi $a0, $a0, -1	        # decrement string pointer by 1
                addi $t1, $t1, 1	        # increment the loop by 1
                j loop_2                        # starts the loop again
        return_2:
                move $v0, $a0		        # store pointer to last non-whitespace character as result
                sub $s1, $s1, $t1	        # store the length of the input without the ending whitespaces
                jr $ra
        
       
        convert:                                # converts string to decimal
                li $t0, 0		        # initialize index for loop_3
                li $v0, 0		        # initialize register to store sum
        loop_3:
                lb $t1, 0($a1)		        # store pointer to current character
	        beq $t0, $a0, valid             # branch to valid subprogram if length of string is 0
        checkiffrom09:                          # checks if current character is between 0 and 9
                li $t2, '0'                     # $t2 stores the value '0'
                li $t3, '9'                     # $t3 stores the value '9'
                blt $t1, $t2, invalid           # branches to invalid if current character (t1) is less than 0 (t2)
                bgt $t1, $t3, checkiffromAU     # branches to checkiffromAU subprogram if current character (t1) is greater than 9 (t3)

        	sub $t1, $t1, $t2               # subtracts current character (t1) from 0 (t2)
                sub $t4, $a0, $t0	        # initialize index for exponent_loop
                li $t5, 1			# initialized value for exponent calculation
        exponent_loop:
                beq $t4, 1, else_1              # branch to else_1 if index is 1
                mul $t5, $t5, $a2               # multiplies exponent base with initialized value
                addi $t4, $t4, -1               # decrements index
                j exponent_loop                 # jumps to beginning of exponent loop
        else_1:
                mul $t5, $t5, $t1		# convert character
                add $v0, $v0, $t5		# add conversion of current character to sum
                addi $a1, $a1, 1		# increment string pointer
                addi $t0, $t0, 1		# increment loop index
                j loop_3                        # jumps back to loop_3

        checkiffromAU:                          # checks if current character is between A and U
                li $t2, 'A'                     # $t2 stores the value 'A'
                li $t3, 'U'                     # $t3 stores the value 'U'
                blt $t1, $t2, invalid           # branches to invalid if current character (t1) is less than A (t2)
                bgt $t1, $t3, checkiffromau     # branches to checkiffromau subprogram if current character (t1) is greater than U (t3)

        	addi $t1, $t1, -55
	        sub $t4, $a0, $t0		# initialize index for exponent_loop2
	        li $t5, 1			# initialized value for exponent calculation
        exponent_loop2:
                beq $t4, 1, else_2              # branch to else_2 if index is 1
                mul $t5, $t5, $a2               # multiplies exponent base with initialized value
                addi $t4, $t4, -1               # decrements index
                j exponent_loop2                # jumps to beginning of exponent loop
        else_2:
                mul $t5, $t5, $t1		# convert character
                add $v0, $v0, $t5		# add conversion of current character to sum
                addi $a1, $a1, 1		# increment string pointer
                addi $t0, $t0, 1		# increment loop index
                j loop_3                        # jumps back to loop_3

        checkiffromau:                          # checks if current character is between a and u
                li $t2, 'a'                     # $t2 stores the value 'a'
                li $t3, 'u'                     # $t3 stores the value 'u'
                blt $t1, $t2, invalid           # branches to invalid if current character (t1) is less than a (t2)
                bgt $t1, $t3, invalid           # branches to invalid if current character (t1) is greater than u (t3)

        	addi $t1, $t1, -87
	        sub $t4, $a0, $t0		# initialize index for exponent_loop2
	        li $t5, 1			# initialized value for exponent calculation
        exponent_loop3:
                beq $t4, 1, else_3              # branch to else_3 if index is 1
                mul $t5, $t5, $a2               # multiplies exponent base with initialized value
                addi $t4, $t4, -1               # decrements index
                j exponent_loop3                # jumps to beginning of exponent loop
        else_3:
                mul $t5, $t5, $t1		# convert character
                add $v0, $v0, $t5		# add conversion of current character to sum
                addi $a1, $a1, 1		# increment string pointer
                addi $t0, $t0, 1		# increment loop index
                j loop_3                        # jumps back to loop_3


