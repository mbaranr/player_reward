	.text
	.globl	collisions

# parameters:	$a0 = x coord
#		$a1 = y coord

	# test if player has collided with wall, reward or enemy
	# also test if enemy collided with reward

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
	
test_enemy:
	
	# test if player collided with enemy
	
	lw	$t0, x_e			# load x
	lw	$t1, y_e			# and y pos of enemy
	
	sll	$a0, $a0, 8			# shifting x pos of player by 8
	sll	$t0, $t0, 8			# shifting x pos of enemy by 8
	
	or	$a0, $a0, $a1			# joining both
	or	$t0, $t0, $t1			# x and y pos of player and enemy into single variables
	
	beq	$a0, $t0, game_over		# if these coords are equal, finish the game

test_reward:

	# test if enemy collided with reward
	
	lw	$t0, x_r			# load x
	lw	$t1, y_r			# and y pos of reward
		
	sll	$t0, $t0, 8			# shifting x pos of reward by 8
	
	or	$t0, $t0, $t1			# x and y pos of reward into a single register
	
	lw	$t2, x_e			# load x
	lw	$t3, y_e			# and y pos of enemy
	
	sll	$t2, $t2, 8			# shifting x pos of enemy by 8
	
	or	$t2, $t2, $t3			# x and y pos of enemy into a single register
	
	beq	$t2, $t0, new_reward		# if these coords are equal, print new reward
	
	# test if player collided with reward
	
	beq	$a0, $t0, plus_score		# if these coords are equal, add 5 to the score and print new reward
	
	j 	end_collision			# if not, exit
	
new_reward:

	# display a new reward in a new random position of the grid
	
	jal	reward				# display new reward
	
	j 	end_collision			
	
plus_score:
	
	# add 5 points to the current score
	
	la	$t0, score_track		# getting current 
	lw	$a0, ($t0)			# score
	
	addi	$a0, $a0, 5			# add 5 to the score
	
	sw	$a0, ($t0)			# store the new score
	
	jal	one_hundred			# check if the score is 100
	
	jal	score_amount			# print new score
	
	j	new_reward			# print new reward
	
end_collision:

	lw	$ra, 0($sp)			# restore
	addi	$sp, $sp, 4			# and
	jr	$ra				# exit
