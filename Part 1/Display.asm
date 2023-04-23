	.text
	.globl	display
	
##############################################################################################################################

# parameters: $a0 = x position of character to display
#	      $a1 = y position of character to display
#	      $a2 = address of character to display

# moving the cursor of the display device to a specific postion (x,y) 
move_cursor:

	li 	$t0, 0xffff000c 	# transmitter data register memory address
   	li 	$t1, 0x00000007 	# ASCII bell character
   	
   	move	$t2, $a0		# setting x position into $t2
   	move	$t3, $a1		# setting y position into $t3
   	
    	sll 	$t2, $t2, 20 		# shift x position to bit positions 20-31
    	
    	sll 	$t3, $t3, 8 		# shift y position to bit positions 8-19
    	
    	or 	$t1, $t1, $t2 		# set x position
    	or 	$t1, $t1, $t3 		# set y position
    	sw 	$t1, ($t0) 		# store transmitter control register value
    	
    	jr	$ra			# return
	
display:

	addi	$sp, $sp, -4		# adding 4 bytes to the stack
	sw	$ra, ($sp)		# saving the return address
	
	# moving the cursor to pos ($a0, $a1)
	jal 	move_cursor
	
   
    	li 	$t1, 0xffff000c  	# Load address of the display device
    	
    
# loop through the string and write characters to the display device
loop_display:
        lbu	$t2, 0($a2)   		# load character
        beqz 	$t2, end_display     	# if character is NULL the string is over
        sb 	$t2, 0($t1)   		# store character into transmitter register
        addi 	$a2, $a2, 1  		# advance string index by 1
        j 	loop_display		
        
end_display:
	
	lw	$ra, ($sp)		# restore
	addi	$sp, $sp, 4		# and
	
	jr	$ra			# exit
	
	
	
	
	
	
	
