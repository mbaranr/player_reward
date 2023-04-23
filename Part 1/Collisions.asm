	.text
	.globl	collisions

# parameters:	$a0 = x coord
#		$a1 = y coord

# test if player has collided with wall or reward

collisions:

	addi	$sp, $sp, -4			# add 4 bytes to the stack
	sw	$ra, ($sp)			# save the return address
	
test_walls:
			
	la	$t0, rows			# load the address for columns
	la	$t1, columns			# and rows
	
	lw	$t0, ($t0)			# dereference
	lw	$t1, ($t1)			# those addresses
	
	# test if player collided with a wall
	
	beq	$a0, 0, game_over		# if x pos is zero
	beq	$a0, $t0, game_over		# if x pos is equal to the number of rows of the board
	beq	$a1, 1, game_over		# if y pos is 1, because the score is displayed in pos 0
	beq	$a1, $t1, game_over		# if y pos is equal to the number of columns

test_reward:

	la	$t0, x_r			# load address of x
	la	$t1, y_r			# and y pos of reward
	
	lw	$t0, ($t0)			# dereference	
	lw	$t1, ($t1)			# address	
	
	sll	$a0, $a0, 8			# shifting x pos of player by 8
	sll	$t0, $t0, 8			# shifting x pos of player by 8
	
	or	$a0, $a0, $a1			# joining both
	or	$t0, $t0, $t1			# x and y pos of player and reward into single variables
	
	beq	$a0, $t0, plus_reward		# if these coords are equal, add 5 to the score and print new reward
	
	j 	end_collision			# if not, exit
	
plus_reward:
	
	jal	reward				# display new reward
	
	la	$t0, score_track		# getting current
	lw	$a0, ($t0)			# score
	
	addi	$a0, $a0, 5			# add 5 to the score
	
	sw	$a0, ($t0)			# store the new score
	
	jal	one_hundred			# check if the score is 100
	
	jal	score_amount			# print new score

end_collision:

	lw	$ra, 0($sp)			# restore
	addi	$sp, $sp, 4			# and
	jr	$ra				# exit
