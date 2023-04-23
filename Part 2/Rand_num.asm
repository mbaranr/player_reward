	.text
	.globl rand_num_reward, rand_num_enemy

#Parameters:	$a3 = rows
#		$a2 = columns

# generate random integers and assign them to x and y pos of the reward or enemy
	
# rand pos for rewards	

rand_num_reward:

	addi	$sp, $sp, -4
	sw	$ra, ($sp)

checkpoint_r:

	la	$t2, x_r		# loading the address of x and y pos
	la	$t3, y_r		# of the current reward
	
	jal	rand_loop_x
	
	jal	rand_loop_y
	
	jal	check_rand_reward	# if invalid coords, return 1
	
	beq	$v0, 1, checkpoint_r	# if 1, generate new coords
	
	j	rand_end
	
	
	
# rand pos for enemy

rand_num_enemy:
	
	addi	$sp, $sp, -4
	sw	$ra, ($sp)

checkpoint_e:

	la	$t2, x_e		# loading the address of x and y pos
	la	$t3, y_e		# of the current reward

	jal	rand_loop_x
	
	jal	rand_loop_y
	
	jal	check_rand_enemy
	
	beq	$v0, 1, checkpoint_e
	
	j	rand_end
	
	
	
############################################################################################################	
	
	
	

rand_loop_x:
	
	li 	$v0, 42         	# system call to generate random int
	move 	$a1, $a3      		# $a1 will contain the upper bound
	syscall				# $a0 contains the number from 0 to rows - 2
	
	addi	$a0, $a0, 1		# add 1 to a0 to avoid generating rewards in walls (min 1, rows-1)
	
	sw	$a0, ($t2)		# pushing this value into x_r
	
	jr	$ra
	
rand_loop_y:

	li 	$v0, 42         	# system call to generate random int
	move 	$a1, $a2      		# $a1 will contain the upper bound
	syscall				# $a0 contains the number from 0 to columns - 1
	
	addi	$a0, $a0, 2		# add 2 to a0 to avoid generating rewards in walls (min 2, columns)
		
	sw	$a0, ($t3)		# pushing this value into y_r
	
	jr	$ra
	
check_rand_reward:

# checking if reward position is same as player position and enemy position

	lw	$t0, x_p		# loading the x
	lw	$t1, y_p		# and y coords of player
	
	lw	$t2, ($t2)		# loading x and
	lw	$t3, ($t3)		# y pos of reward	
	
	sll	$t2, $t2, 8		# shifting x pos of reward by 8
	sll	$t0, $t0, 8		# shifting x pos of player by 8
	
	or	$t2, $t2, $t3		# joining both 
	or	$t0, $t0, $t1		# x and y pos of player and reward into single variables
	
	beq	$t2, $t0, equal_coords
	
	lw	$t4, x_e
	
	lw	$t5, y_e
	
	sll	$t4, $t4, 8		# shifting x pos of enemy by 8
	
	or	$t4, $t4, $t5		# joining both x and y pos of enemy into single variable
	
	beq	$t2, $t0, equal_coords
	
	jr	$ra
	
check_rand_enemy:

# checking if enemy position is same as player position and reward position

	lw	$t0, x_p		# loading the x
	lw	$t1, y_p		# and y coords of player
	
	lw	$t2, ($t2)		# loading x and
	lw	$t3, ($t3)		# y pos of enemy	
	
	sll	$t2, $t2, 8		# shifting x pos of enemy by 8
	sll	$t0, $t0, 8		# shifting x pos of player by 8
	
	or	$t2, $t2, $t3		# joining both 
	or	$t0, $t0, $t1		# x and y pos of player and reward into single variables
	
	beq	$t2, $t0, equal_coords	
	
	lw	$t4, x_r
	
	lw	$t5, y_r
	
	sll	$t4, $t4, 8		# shifting x pos of reward by 8
	
	or	$t4, $t4, $t5		# joining both x and y pos of reward into single variable
	
	beq	$t2, $t0, equal_coords
	
	jr	$ra
	
equal_coords:
	
	li	$v0, 1
	
	jr	$ra
	
rand_end:

	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	
	jr	$ra

	
	
	
