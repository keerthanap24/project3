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

        jal sub_a


           
        
       

        checkiffrom09:                          # checks if current character is between 0 and 9
                li $t2, '0'                     # $t2 stores the value '0'
                li $t3, '9'                     # $t3 stores the value '9'
                


        checkiffromAU:                          # checks if current character is between A and U
                li $t2, 'A'                     # $t2 stores the value 'A'
                li $t3, 'U'                     # $t3 stores the value 'U'
                


        checkiffromau:                          # checks if current character is between a and u
                li $t2, 'a'                     # $t2 stores the value 'a'
                li $t3, 'u'                     # $t3 stores the value 'u'
                

       valid:
	            jr $ra           
                
                     
        invalid:
               	la $a0, message         # load address of message (defined in data section) to $a0
	            li $v0, 4               # system call for print message
	            syscall                 
	            j exit                  # jumps to exit subprogram

        
        
        exit:	
	            li $v0, 10              # mips system call to exit program
	            syscall