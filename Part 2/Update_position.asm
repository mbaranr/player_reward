	.globl move_up, move_down, move_left, move_right
	.text

# Decide in which direction to move, check for the validity of that new position, then update the display and enemy position accordingly

move_up:

	# Delete the player from its current pos, update that pos, and display the player in its new pos

	lw	$a0, x_p			# load position
	lw	$a1, y_p			# of player to delete | set cursor to (x_p, y_p)
	
	jal	delete_curr_pos			# delete the current pos of player by printing a white space
	
	addi	$a1, $a1, 1			# increment y coordinate and
	sw	$a1, y_p			# push back
	
	jal 	player				# display the player in its new position
	
	jal 	track				# update enemy position
	
	lw	$a0, x_p			# load the player position
	lw	$a1, y_p			# into arguments $a0 and $a1	
		
	jal	collisions			# check for collisions
	
	j	exit_moveptr			# return to the processing key step
	
move_down:

	# Delete the player from its current pos, update that pos, and display the player in its new pos

	lw	$a0, x_p			# load position
	lw	$a1, y_p			# of player to delete | set cursor to (x_p, y_p)
	
	jal	delete_curr_pos			# delete the current pos of player by printing a white space
	
	addi	$a1, $a1, -1			# decrement y coordinate and
	sw	$a1, y_p			# push back
	
	jal 	player				# display the player in its new position
	
	jal 	track				# update enemy position
	
	lw	$a0, x_p			# load the player position
	lw	$a1, y_p			# into arguments $a0 and $a1
	
	jal	collisions			# check for collisions
	
	j	exit_moveptr			# return to the processing key step
	
move_left:

	# Delete the player from its current pos, update that pos, and display the player in its new pos

	lw	$a0, x_p			# load position
	lw	$a1, y_p			# of player to delete | set cursor to (x_p, y_p)
		
	jal	delete_curr_pos			# delete the current pos of player by printing a white space
	
	addi	$a0, $a0, -1			# decrement x coordinate and
	sw	$a0, x_p			# push back
		
	jal 	player				# display the player in its new position
	
	jal 	track				# update enemy position
		
	lw	$a0, x_p			# load the player position
	lw	$a1, y_p			# into arguments $a0 and $a1
	
	jal	collisions			# check for collisions
	
	j	exit_moveptr			# return to the processing key step
	
move_right:

	# Delete the player from its current pos, update that pos, and display the player in its new pos

	lw	$a0, x_p			# load position
	lw	$a1, y_p			# of player to delete | set cursor to (x_p, y_p)
	
	jal	delete_curr_pos			# delete the current pos of player by printing a white space
	
	addi	$a0, $a0, 1			# increment x coordinate and
	sw	$a0, x_p			# push back
		
	jal 	player				# display the player in its new position
	
	jal 	track				# update enemy position	
	
	lw	$a0, x_p			# load the player position
	lw	$a1, y_p			# into arguments $a0 and $a1
	
	jal	collisions			# check for collisions
	
	j	exit_moveptr			# return to the processing key step