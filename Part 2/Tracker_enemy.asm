	.data

phase:	.word	0	# phase of the enemy, defense = 0, offense = 1
	.globl	track
	.text
	
###########################################################################################################################################################################################################################################################
# there is a hierarchy of things we need to check in order to create an enemy that is smart enough to annoy the player, but doesn't go to far														  #		
# 1. check if the player is on the enemy's "range of vision", represented by a taxicab topological ball of radius 3, we are doing this to prevent the player from chasing the player if it is too far away for it to realistically kill it		  #								
# 2. check the phase status | this has the second highest priority as the enemy needs to stop doing whatever it was up to before to only follow the player (if the phase is set to 1), even if this means stealing a reward 			          #
# 3. check if the enemy is one move away from the player | if we reached this step, we know the enemy is on defensive mode, so if it is one move away from the player, we prioritize not killing the player over everything else, so the enemy won't move #
# 4. check if the enemy is one move away from the target cell | if that is the case, we will always prioritize going for the target cell, even if this means that the enemy is next to a reward								  #
# 5. check if the enemy is one move away from the reward | if this is the case, and the target cell is on a different side, we want the enemy to correct its position by moving away from the reward to make it avoid stealing it on its path		  #
# 6. if none of this conditions is met, we just want the enemy to track its target cell																					  #			
###########################################################################################################################################################################################################################################################

track:
	addi	$sp, $sp, -4			# add 4 bytes to the stack
	sw	$ra, ($sp)			# save the return address
	
	# step 1.
	
	lw	$a0, x_p			# load the x
	lw	$a1, x_e			# and
	lw	$a2, y_p			# y coords
	lw	$a3, y_e			# of both enemy and player on the arguments
	
	jal	manhattan_distance		# compute the manhattan distance between enemy and player
	
	sgt	$t1, $v0, 3			# check if player is in enemy's "range of vision", taxicab cirfumference of radius 3
	
	beq	$t1, 1, defense			# if player is outside this range, go to defense mode
	
offense:

	# step 2.
	
	lw	$t0, phase			# load the enemy's phase: offense or defense
	
	beq	$t0, 1, track_player		# if $t0 is not 0, track the player
	
defense:
 
 	jal	target_cell			# compute the target cell for the enemy to track based on the position of the player and reward
 	
	#step 3.
	
	lw	$a0, x_p			# load the x
	lw	$a1, x_e			# and
	lw	$a2, y_p			# y coords
	lw	$a3, y_e			# of both enemy and player on the arguments
	
	jal	manhattan_distance		# compute the manhattan distance between enemy and player
	
	beq	$v0, 1, end_track		# if the enemy is one move away from the player, don't move at all
	
	# step 4.
	
	lw	$a0, x_t			# load the x
	lw	$a1, x_e			# and
	lw	$a2, y_t			# y coords
	lw	$a3, y_e			# of both the enemy and target cell on the arguments
	
	jal	manhattan_distance		# compute the manhattan distance between enemy and target
	
	beq	$v0, 1, track_target		# if $t1 is 1, track the target
	
	# step 5.
		
	lw	$a0, x_r			# load the x
	lw	$a1, x_e			# and
	lw	$a2, y_r			# y coords
	lw	$a3, y_e			# of both the enemy and reward on the arguments
	
	jal	manhattan_distance		# compute the manhattan distance between enemy and reward
	
	beq	$v0, 1, correct_enemy_pos	# if the enemy is one move away from the reward, correct its position
	
	# step 6.
	
	j	track_target			# if not, track reward

####################################################################################################################################################################################
# the tracking for any given position works by moving in the direction where the enemy has to travel the most steps first, this fits nicely when wanting to avoid stealing rewards #
####################################################################################################################################################################################		

track_player:

	# deactivating the offensive mode
	
	li	$t0, 0				# turning off aggro	
	sw	$t0, phase
	
	# checking which direction represents more moves
	
	lw	$a0, x_e			# loading the 
	lw	$a1, x_p			# x coords of enemy and player
	
	jal	absolute_value			# check how far is the enemy from the reward target cell in the x axis
	
	move	$t2, $v0			# storing the absolute value into $t2
	
	lw	$a0, y_e			# loading the
	lw	$a1, y_p			# y coords of enemy and player
	
	jal	absolute_value			# check how far is the enemy from the reward target cell in the y axis
	
	move	$t3, $v0			# storing the absolute value into $t3
	
	beq	$t2, 0, move_enemy_vertical_p		# if the enemy and player are in the same x coord, move vertically
	beq	$t3, 0, move_enemy_horizontal_p		# if the enemy and player are in the same y coord, move horizontally
	
	slt	$t1, $t2, $t3				# if the enemy is closer to the reward in the x axis, set $t1 to 1
	
	# making the enemy take the longest path first, in terms of x and y distance
	
	beq	$t1, 1, move_enemy_vertical_p		# if $t1 is equal to 1, the enemy will move vertically
	
	j	move_enemy_horizontal_p			# if not, it will move horizontally

move_enemy_vertical_p:
	
	# decide if enemy should move up or down
	
	lw	$t2, y_e				# loading both y
	lw	$t3, y_p				# coords of enemy and player
	
	slt	$t1, $t2, $t3				# if the y coord of enemy is less than the y coord of player, set $t1 to 1
	
	beq	$t1, 1, move_enemy_down			# if $t1 is 1, move the enemy down
	
	j	move_enemy_up				# if not, move enemy up
	
move_enemy_horizontal_p:
	
	# decide if enemy should move left or right
	
	lw	$t2, x_e				# loading both x
	lw	$t3, x_p				# coords of enemy and player
	
	slt	$t1, $t2, $t3				# if the x coord of enemy is less than the x coord of player, set $t1 to 1
	
	beq	$t1, 1, move_enemy_right		# if $t1 is 1, move the enemy right
	
	j	move_enemy_left				# if not, move enemy up

track_target:
	
	# checking which directing represents more moves
	
	lw	$a0, x_e				# loading the 
	lw	$a1, x_t				# x coords of enemy and target cell
	
	jal	absolute_value				# check how far is the enemy from the reward target cell in the x axis
	
	move	$t2, $v0				# storing the absolute value into $t2
	
	lw	$a0, y_e				# loading the 
	lw	$a1, y_t				# y coords of enemy and target cell				
	
	jal	absolute_value				# check how far is the enemy from the target cell in the y axis
	
	move	$t3, $v0				# storing the absolute value into $t3
	
	add	$t0, $t2, $t3				# adding both abs values
	
	beq	$t0, 0, end_track			# if the enemy has reached its tracking position, return without moving
	
	beq	$t2, 0, move_enemy_vertical		# if the enemy and reward are in the same x coord, move vertically
	
	beq	$t3, 0, move_enemy_horizontal		# if the enemy and reward are in the same y coord, move horizontally
	
	slt	$t1, $t2, $t3				# if the enemy is closer to the reward in the x axis, set $t1 to 1
	
	# making the enemy take the longest path first, in terms of x and y distance
	
	beq	$t1, 1, move_enemy_vertical		# if $t1 is equal to 1, the enemy will move vertically
	
	j	move_enemy_horizontal			# if not, it will move horizontally

move_enemy_vertical:
	
	# calculating if enemy should move up or down
	
	lw	$t2, y_e			# loading both y coords
	lw	$t3, y_t			# of enemy and target
				
	slt	$t1, $t2, $t3			# if the y coord of enemy is less than the y coord of target, set $t1 to 1
	
	beq	$t1, 1, move_enemy_down		# if $t1 is 1, move the enemy down
	
	j	move_enemy_up			# if not, move enemy up
	
move_enemy_horizontal:
	
	# calculating if enemy should move right or left
	
	lw	$t2, x_e			# loading both x coords
	lw	$t3, x_t			# of enemy and target
	
	slt	$t1, $t2, $t3			# if the x coord of enemy is less than the x coord of target cell, set $t1 to 1
	
	beq	$t1, 1, move_enemy_right	# if $t1 is 1, move the enemy right
	
	j	move_enemy_left			# if not, move enemy up
	
move_enemy_up:

	lw	$a0, x_e			# loading current enemy coords
	lw	$a1, y_e			# into arguments | set cursor to (x_e,y_e)
		
	jal	delete_curr_pos			# delete the current pos of enemy by printing a white space
	
	addi	$a1, $a1, -1			# decrement and
	sw	$a1, y_e			# push back
	
	jal 	enemy				# display the enemy in its new position

	j	end_track			# return
	
move_enemy_down:

	lw	$a0, x_e			# loading current enemy coords
	lw	$a1, y_e			# into arguments | set cursor to (x_e,y_e)
	
	jal	delete_curr_pos			# delete the current pos of enemy by printing a white space
	
	addi	$a1, $a1, 1			# increment and
	sw	$a1, y_e			# push back
	
	jal 	enemy				# display the enemy in its new position

	j	end_track			# return
	
move_enemy_left:

	lw	$a0, x_e			# loading current enemy coords
	lw	$a1, y_e			# into arguments | set cursor to (x_e,y_e)
	
	jal	delete_curr_pos			# delete the current pos of enemy by printing a white space
	
	addi	$a0, $a0, -1			# decrement and
	sw	$a0, x_e			# push back
	
	jal 	enemy				# display the enemy in its new position
	
	j	end_track			# return
	
move_enemy_right:

	lw	$a0, x_e			# loading current enemy coords
	lw	$a1, y_e			# into arguments | set cursor to (x_e,y_e)
	
	jal	delete_curr_pos			# delete the current pos of enemy by printing a white space
	
	addi	$a0, $a0, 1			# increment and
	sw	$a0, x_e			# push back
	
	jal 	enemy				# display the enemy in its new position
	
	j	end_track			# return



######################################################################################################
# if enemy is one move away from reward, correct its position to avoid stealing it in defensive mode #
######################################################################################################

correct_enemy_pos:

	lw	$t2, x_e				# loading the x coords
	lw	$t3, x_r				# of enemy and reward
	
	bne	$t2, $t3, correct_enemy_vertical	# if the x coord is different, correct the enemy pos vertically
	
	j	correct_enemy_horizontal		# if not, correct the position horizontally
	
correct_enemy_horizontal:

	# check if target cell is closer to LEFT or RIGHT

	lw	$t2, x_e				# loading the x coords of 
	lw	$t3, x_t				# enemy and target

	slt	$t1, $t2, $t3				# if the x coord of enemy is less than target, set $t1 to 1
	
	beq	$t1, 1, move_enemy_right		# if $t1 is 1, move right
	
	j	move_enemy_left				# if not, move left
	

correct_enemy_vertical:

	# check if target cell is closer UP or DOWN
	
	lw	$t2, y_e				# loading the y coords of
	lw	$t3, y_t				# enemy and target

	slt	$t1, $t2, $t3				# if the y coord of enemy is less than target, set $t1 to 1
	
	beq	$t1, 1, move_enemy_down			# if $t1 is 1, move down
		
	j	move_enemy_up				# if not, move up

#################################################################################################################################

target_cell:

# because we don't want the enemy to overlap a reward, but just guard it, we will calculate the pos of a cell close to the reward
# based on the current player position
# ie. if the player is 3 cells up from the reward, the reward cell offset has to be 2 cells up from the reward
# ie. if the player is 3 cells up and 2 cells right from the reward, the reward cell offset has to be 2 cells right 
	
	addi	$sp, $sp, -4				# add 4 bytes to the stack
	sw	$ra, ($sp)				# save the return address
		
	lw	$a0, x_p				# loading the x coords of player 
	lw	$a1, x_r				# and reward
	
	jal	absolute_value				# check how far is the player from the reward in the x axis
	
	move	$t2, $v0				# storing the abs value in $t2
	
	lw	$a0, y_p				# loading the y coords of player 
	lw	$a1, y_r				# and reward
	
	jal	absolute_value				# check how far is the player from the reward in the y axis
	
	move	$t3, $v0				# storing the abs value in $t3
	
	slt	$t1, $t2, $t3				# if the player is closer to the reward in the x axis, set $t1 to 1
	
	beq	$t1, 1, target_vertical			# if $t1 is equal to 1, the taget cell for guarding the reward will be set in a cell with a horizontal offset from the reward
	
	j	target_horizontal			# if not, in a vertical offset 
	
target_vertical:

	# check if target cell should be UP or DOWN from the reward
	
	lw	$t2, y_p			# getting y coords
	lw	$t3, y_r			# of player and reward		
	
	slt	$t1, $t2, $t3			# if the y coord of player is less than the y coord of reward, set $t1 to 1
	
	beq	$t1, 1, target_up		# if $t1 is 1, set the target cell one pos up from the current reward
	
	j	target_down			# if not, set the target cell one unit down

target_horizontal:

	# check if target cell should be LEFT or RIGHT from the reward

	lw	$t2, x_p			# getting x coords
	lw	$t3, x_r			# of player and reward
		
	slt	$t1, $t2, $t3			# if the x coord of player is less than the x coord of reward, set $t1 to 1
	
	beq	$t1, 1, target_left		# if $t1 is 1, set the target cell in the left side of the current reward
	
	j	target_right			# if not, set the target cell in the right side

target_up:

	# set the target 2 cells up from the reward pos

	la	$t2, x_t			# loading address of coords 
	la	$t3, y_t			# from target cell
	
	lw	$t0, x_r			# loading the coords	
	lw	$t1, y_r			# of the reward
	
	subi	$t1, $t1, 2			# increment y pos by 2
	
	sw	$t0, ($t2)			# push 
	sw	$t1, ($t3)			# back
	
	lw	$ra, 0($sp)			# restore
	addi	$sp, $sp, 4			# and
	jr	$ra				# exit

target_down:

	# set the target 2 cells down from the reward pos
	
	la	$t2, x_t			# loading address of coords 
	la	$t3, y_t			# from target cell
	
	lw	$t0, x_r			# loading the coords	
	lw	$t1, y_r			# of the reward
	
	addi	$t1, $t1, 2			# increment y pos by 2
	
	sw	$t0, ($t2)			# push 
	sw	$t1, ($t3)			# back
	
	lw	$ra, 0($sp)			# restore
	addi	$sp, $sp, 4			# and
	jr	$ra				# exit
	
target_left:
	
	# set the target 2 cells left from the reward pos
	
	la	$t2, x_t			# loading address of coords 
	la	$t3, y_t			# from target cell
	
	lw	$t0, x_r			# loading the coords	
	lw	$t1, y_r			# of the reward
	
	subi	$t0, $t0, 2			# increment y pos by 2
	
	sw	$t0, ($t2)			# push 
	sw	$t1, ($t3)			# back
	
	lw	$ra, 0($sp)			# restore
	addi	$sp, $sp, 4			# and
	jr	$ra				# exit

target_right:
	
	# set the target 2 cells right from the reward pos
	
	la	$t2, x_t			# loading address of coords 
	la	$t3, y_t			# from target cell
	
	lw	$t0, x_r			# loading the coords	
	lw	$t1, y_r			# of the reward
	
	addi	$t0, $t0, 2			# increment y pos by 2
	
	sw	$t0, ($t2)			# push 
	sw	$t1, ($t3)			# back
	
	lw	$ra, 0($sp)			# restore
	addi	$sp, $sp, 4			# and
	jr	$ra				# exit
	
##################################################################################################################

absolute_value:

	# compute the absolute value of the difference between $a0 and $a1

	sub	$v0, $a0, $a1
	
	abs	$v0, $v0 
	
	jr	$ra
	
	
manhattan_distance:

	# compute the manhattan distance between two points (this being the number of moves one has to take to take reach the other)
	# parameters:	($a0, $a2) ($a1, $a3)

	addi	$sp, $sp, -4			# add 4 bytes to the stack
	sw	$ra, ($sp)			# save the return address
	
	jal 	absolute_value			# compute the abs value between x coords
	
	move	$t0, $v0			# store the abs value in $t0
	
	move	$a0, $a2			# moving y coords
	move	$a1, $a3			# into arguments for function
	
	jal 	absolute_value			# compute the abs value between y coords
	
	move	$t1, $v0			# storing the abs value in $t1
	
	add	$v0, $t0, $t1			# add the abs values and return $v0
	
	lw	$ra, 0($sp)			# restore
	addi	$sp, $sp, 4			# and
	jr	$ra				# exit
	
############################################################################################################
	
aggro_chance:
	
	# get a random number from 0 to n | smaller the n, higher the chance of setting the enemy in to offensive mode
	
	li 	$v0, 42         	# system call to generate random int
	li	$a1, 5		      	# $a1 will contain the upper bound
	syscall				# $a0 contains the number from 0 to 4
	
	beq	$a0, 2, set_aggro	# if the number is 2, set aggro
	
	jr	$ra

############################################################################################################

set_aggro:
	
	li	$t1, 1			# load 1
	sw	$t1, phase		# into phase
	
	jr	$ra			# return
	
############################################################################################################
	
remove_aggro:
	
	li	$a0, 13			# setting the cursor
	li	$a1, 0			# to (13,0)
	
remove_aggro_loop:
	
	beq	$a0, 19, return_track	# if x coord of cursor is 19, return
	
	jal	delete_curr_pos		# printing a whitespace in that pos
	
	addi	$a0, $a0, 1		# adding 1 to x coord
	
	j	remove_aggro_loop	# loop
	
####################################################################################################
	
end_track:

	jal	aggro_chance		# get a random chance to set aggro
	
	lw	$t0, phase		# check the phase value
	
	beq	$t0, 0, remove_aggro	# if 0, remove the aggro alert
	
	jal 	aggro			# if 1, print the aggro alert
	
	j	return_track		# return 
		
return_track:

	lw	$ra, 0($sp)		# restore
	addi	$sp, $sp, 4		# and
	jr	$ra			# exit

	
