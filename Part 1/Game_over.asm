	.data

GAME_OVER:		.asciiz "GAME OVER!"
congratulations:	.asciiz "Congratulations!"

	.text
	.globl	game_over, one_hundred


game_over:
	
	la	$a2, clear_screen		# load address for clear_screen character "\f"
	li	$a0, 0				# set cursor
	li	$a1, 0				# to pos (0,0)
	
	jal 	display				# clear the screen
	
	la	$a2, GAME_OVER			# load address for "GAME OVER!" message
	li	$a0, 1				# set cursor
	li	$a1, 4				# to (1,4)
	
	jal 	display				# display the message
	
	la	$a2, score			# load address for "Score:" message
	li	$a0, 2				# set cursor 
	li	$a1, 5				# to (2,5)
	
	jal 	display				# display "Score:"
	
	jal	final_score			# display the final score
	
	j 	finish				# finish the game
	
	


# Parameter:	$a0 = score


one_hundred:

	beq	$a0, 100, completion		# if score == 100, game completed
	
	jr	$ra				# return
	
completion:

	la	$a2, clear_screen		# load address for clear_screen character "\f"
	li	$a0, 0				# set cursor
	li	$a1, 0				# to pos (0,0)
	
	jal 	display				# clear the screen
	
	la	$a2, congratulations		# load address for "congratulations!" message
	li	$a0, 1				# set cursor
	li	$a1, 4				# to (1,4)
	
	jal 	display				# display the message
	
	la	$a2, score			# load address for "Score:" message
	li	$a0, 2				# set cursor 
	li	$a1, 5				# to (2,5)
	
	jal 	display				# display "Score:"
	
	jal	final_score			# display the final score
	
	j 	finish				# finish the game
	
	
	
#########################################################################################################	
	
	
final_score:

	la	$a0, score_track		# loading address for value of score
	lw	$a0, ($a0)			# dereference the address
	
	jal	convert_ascii			# converting the integer value of score to ascii
	
	# because the conversion function stores the ascii values in reverse, we will iterate backwards through the array
	
	li	$a0, 8				# setting cursor to 
	li	$a1, 5				# (8, 5)
	
	la	$a2, int_ascii_values		
	addi	$a2, $a2, 8
	
	jal	display				# displaying the ones
	
	li	$a0, 9				# setting cursor	
	li	$a1, 5				# to (9,5)
	
	la	$a2, int_ascii_values		
	addi	$a2, $a2, 4
	
	jal	display				# displaying the tenths
	
	li	$a0, 10				# setting cursor to 
	li	$a1, 5				# (10, 5)
	
	la	$a2, int_ascii_values
	
	jal 	display				# displaying the onehundreths
	
	
finish:

	li	$v0, 10				# end
	syscall					# the game

