	.text
	.globl rand_num_reward

#Parameters:	$a3 = rows
#		$a2 = columns

# generate random integers and assign them to x and y pos of the reward

rand_num_reward:
	
	la	$t2, x_r		# loading the address of x and y pos
	la	$t3, y_r		# of the current reward
	
rand_loop_x:
	
	li 	$v0, 42         	# system call to generate random int
	move 	$a1, $a3      		# $a1 will contain the upper bound
	syscall				# $a0 contains the number from 0 to rows - 2
	
	addi	$a0, $a0, 1		# add 1 to a0 to avoid generating rewards in walls (min 1, rows-1)
	
	sw	$a0, ($t2)		# pushing this value into x_r
	
rand_loop_y:

	li 	$v0, 42         	# system call to generate random int
	move 	$a1, $a2      		# $a1 will contain the upper bound
	syscall				# $a0 contains the number from 0 to columns - 1
	
	addi	$a0, $a0, 2		# add 2 to a0 to avoid generating rewards in walls (min 2, columns)
		
	sw	$a0, ($t3)		# pushing this value into y_r
	
	j	check_rand
	
check_rand:

# checking if reward position is same as player position

	la	$t0, x_p		# loading the x
	la	$t1, y_p		# and y address  for the coords of player
	
	lw	$t0, ($t0)		# loading the 
	lw	$t1, ($t1)		# contents fo those addresses
	
	lw	$t2, ($t2)		# loading x and
	lw	$t3, ($t3)		# y pos of reward	
	
	sll	$t2, $t2, 8		# shifting x pos of reward by 8
	sll	$t0, $t0, 8		# shifting y pos of player by 8
	
	or	$t2, $t2, $t3		# joining both 
	or	$t0, $t0, $t1		# x and y pos of player and reward into single variables
	
	beq	$t2, $t0, rand_loop_x	
	
end_rand:

	jr	$ra			# exit
	
	
	
