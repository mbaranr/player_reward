	.data

int_ascii_values:	.space	12		# array of integer ascci values

	.text
	.globl	convert_ascii, int_ascii_values

# parameter:	$a0 = integer to convert into ascii

# converting an integer into ascii values by dividing the number and adding the ascii value of 0 into the remainder

convert_ascii:

	li 	$t0, 10  			# set $t0 to 10
	la	$t2, int_ascii_values		# loading the address of the array that will contain up to 3 ascii values
	
convert_loop:

	div 	$a0, $a0, $t0   		# divide integer by 10 and store the result in $a0
    	mfhi 	$t1        			# get remainder and store it in $t0
    	add 	$t1, $t1, 48   			# add ASCII '0' to remainder to get ascii value
    	sw 	$t1, ($t2)   			# store ascii value in array

    	# check if the integer value is equal to zero
    	
   	beq 	$a0, $zero, end_conversion    	# if integer is zero, exit loop

    	# increment array pointer, and loop
    		
    	addi 	$t2, $t2, 4    			# increment array pointer to next element
    	
    	j 	convert_loop      		# jump to beginning of loop
    	
end_conversion:
	
	jr	$ra				# return
