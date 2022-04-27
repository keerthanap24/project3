#02933771
# N = 31
# M = 21
# beta = 'u'
# delta = 'U'
        .data
                input: .space 1001            # amount of space for the input
                message: .ascii "-"           # message if input is invalid or greater than 4 characters
                test: .ascii "test"
                comma: .ascii ","
        .text
              

main:
        # reads input from user
        li $v0, 8                       # syscall for read input
        la $a0, input                   # loads address of input to $a0
        li $a1, 1001                    # initializes pointer
        syscall                         # prompts system call
        la $s0, input                   # saves the address of input to $s0
        addi $sp, $sp, -4               # pass input string as a parameter to sub_a on stack
        sw $s0, 0($sp)
        jal sub_a                       #call sub_a
        li $v0, 10                      # mips system call to exit program
	syscall

sub_a:
        lw $t0, 0($sp)                  # loads the string address into the subprogram from stack        
        
        # t0 = string addr, t1 = length t2=';' t3 = '\0'
        li $t1, 0                   # initializes the length of the string
        li $t2, 59                      # register for ';' ascii value
        li $t3, 0                   # register for '\0' value

        loop: 
                addi $sp, $sp, -4           #push the sub string pointer on the stack
                sw $t0, 0($sp)

                loop_find_length:
                        lw $t7, 0($t0)
                        beq $t2, $t7, continue   # if pointer value is ';' branch to continue label
                        beq $t3, $t7, continue   # if pointer value is zero branch to continue label
                        addi $t1, $t1, 1            # else increment length by one
                        addi $t0, $t0, 1            # goto next character
                        j loop_find_length          # jump back to beginning of loop
                continue:
                        beqz $t7, exit_sub_a        # if end of the string exit sub_a
                        addi $sp, $sp, -12          # else push the length of the string and two return values on to stack
                        sw $t1, 8($sp)              # push length of string onto stack

                        addi $sp, $sp, -16          # push register values to stack to use them in sub_b
                        sw $t0, 12($sp)
                        sw $t1, 8($sp)
                        sw $t2, 4($sp)
                        sw $t3, 0($sp)
                        jal sub_b                   # calls subprogram b
                        lw $t3, 0($sp)              # pulling register values back after sub_b used them
                        lw $t2, 4($sp)
                        lw $t1, 8($sp)
                        lw $t0, 12($sp)                
                        lw $t4, 16($sp)             # gets return value (0 or 1) check return value 1 for success or failure
                        lw $t5, 20($sp)             # gets decimal return value from stack
                        addi $sp, $sp, 28           # pop the stack 
                        beqz $t4, invalid           # if return value is zero branch to invalid label
                        li $v0, 1                   # syscall for print decimal
                        add $a0, $t5, 0             # a0 should be decimal to print
                        syscall
                sub_string_done:
                        beqz $t7, exit_sub_a        # if end of the string exit sub_a
                        li $v0, 4                   # prints comma if semicolon is found
                        la $a0, comma
                        syscall
                        addi $t0, $t0, 1            # increment pointer to character after semicolon
                        li $t1, 0                   # start length count again from 0
                        j loop                      # jump back to beginning of loop label
                invalid:
                        la $a0, message             # load address of message (defined in data section) to $a0
                        li $v0, 4                   # system call for print message
                        syscall                 
                        j sub_string_done
                exit_sub_a:
                        jr $ra

sub_b:
        lw $s0, 28($sp)                         # get sub-string pointer
        lw $s1, 24($sp)                         # get sub-string length
        add $s2, $s0, $s1                       # finds the address of the last character
        addi $s2, $s2, -1                       # s2 = (s0 + s1) -1
        beqz $s1, error		        	# if length of string is 0 exit sub_b

        move $a0, $s1		                # pass length of string as an argument for whitespace subprogram
        move $a1, $s0		                # pass pointer to beginning of string as an argument for whitespace subprogram
        jal removeleadingws                     # calling subprogram for removing leading whitespaces
        move $s0, $v0			        # store address of first non-whitespace character in $s0

        beqz $s1, error	                	# if length of string is 0 exit the program

        move $a0, $s2			        # pass pointer to end of string as an argument for removeendingws subprogram
        addi $a1, $s1, 0		        # pass length of string to removeendingws
        jal removeendingws                      # calling subprogram for removing ending whitespaces

        beqz $s1, error  	                # exit program if length of input string ($s1) is 0
	bgt $s1, 4, error		        # if length of input string ($s1) is greater than 4 branch to error

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
                beq $t0, $a0, error              # branch to error if length of string is 0
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
	        beq $t0, $a0, success           # branch to success label if length of string is 0
        checkiffrom09:                          # checks if current character is between 0 and 9
                li $t2, '0'                     # $t2 stores the value '0'
                li $t3, '9'                     # $t3 stores the value '9'
                blt $t1, $t2, error             # branches to error if current character (t1) is less than 0 (t2)
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
                sw $t5, 20($sp)                 # push final conversion to stack
                addi $a1, $a1, 1		# increment string pointer
                addi $t0, $t0, 1		# increment loop index
                j loop_3                        # jumps back to loop_3

        checkiffromAU:                          # checks if current character is between A and U
                li $t2, 'A'                     # $t2 stores the value 'A'
                li $t3, 'U'                     # $t3 stores the value 'U'
                blt $t1, $t2, error             # branches to error if current character (t1) is less than A (t2)
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
                sw $t5, 20($sp)                 # push final conversion to stack
                addi $a1, $a1, 1		# increment string pointer
                addi $t0, $t0, 1		# increment loop index
                j loop_3                        # jumps back to loop_3

        checkiffromau:                          # checks if current character is between a and u
                li $t2, 'a'                     # $t2 stores the value 'a'
                li $t3, 'u'                     # $t3 stores the value 'u'
                blt $t1, $t2, error             # branches to error if current character (t1) is less than a (t2)
                bgt $t1, $t3, error             # branches to error if current character (t1) is greater than u (t3)

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
                sw $t5, 20($sp)                 # push final conversion to stack
                addi $a1, $a1, 1		# increment string pointer
                addi $t0, $t0, 1		# increment loop index
                j loop_3                        # jumps back to loop_3

        success:
                li $t7, 1
                sw $t7, 16($sp)
                jr $ra

        error:
                li $t8, 0
                sw $t8, 16($sp)
                jr $ra

	            
