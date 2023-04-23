	.data

rows:		.word	18		# dimensions of
columns:	.word	9		# board

x_p:		.word   7		# x and
y_p:		.word	5		# y coordinates for player (initial position)

x_r:		.word	0		# x and
y_r:		.word	0		# y coordinates for reward

score:		.asciiz "Score: "
score_track:	.word	0		# score amount
ws:		.asciiz " "
hash:		.asciiz "#"

p:		.asciiz "P"
r:		.asciiz "R"

clear_screen:	.asciiz "\f"

	.globl	init_env, rows, columns, x_p, y_p, x_r, y_r, delete_curr_pos, player, reward, score_track, score_amount, clear_screen, score
	
###################################################################################################################
	
	.text

init_env:

	# Initializing the game environment by printing the score, walls, player, reward and enemy

	addi	$sp, $sp, -4		# getting space in the stack
	sw	$ra, ($sp)		# storing the return address
	
	
Score:

	# Displaying the score 

	li	$a0, 0			# setting cursor to 
	li	$a1, 0			# (0, 0)
	
	la	$a2, score		# loading address for the asciiz value of score
	
	jal 	display			# displaying the characters "Score: "
	
	jal 	score_amount		# displaying the integer value of score
	
	j 	top_walls		# displaying the walls
	
score_amount:
	
	# Display the score amount

	addi	$sp, $sp, -4		# getting space in the stack
	sw	$ra, ($sp)		# saving the return address
	
	la	$a0, score_track	# loading address for value of score
	lw	$a0, ($a0)		# dereference that address
	
	jal	convert_ascii		# converting the int value of score into ascii values to display 
	
	li	$a0, 7			# setting cursor to 
	li	$a1, 0			# (7, 0)
	
	# because the conversion function stores the ascii values in reverse, we will iterate backwards through the array
	
	la	$a2, int_ascii_values	# getting address for the array with the ascii values
	addi	$a2, $a2, 8		# going to the last element of the array	
	
	jal	display			# displaying the ones
	
	li	$a0, 8			# setting cursor to 
	li	$a1, 0			# (8, 0)
	
	la	$a2, int_ascii_values	# getting address for the array with the ascii values
	addi	$a2, $a2, 4		# going to the second element of the array
	
	jal	display			# displaying the tenths
	
	li	$a0, 9			# setting cursor to 
	li	$a1, 0			# (9, 0)
	
	la	$a2, int_ascii_values	# getting address for the first element
	
	jal display			# displaying the onehundreths
	
end_score:

	# finalizing the score function

	lw	$ra, ($sp)		# restore
	addi	$sp, $sp, 4		# and
	jr	$ra			# exit
	
	
# displaying all the walls

top_walls:

	# displaying the top row of walls

	li	$a0, 0			# setting cursor to 
	li	$a1, 1			# (0, 1)
	
loop_tw:

	la	$a2, hash		# getting the address of hash
	
	jal 	display			# displaying a hash
	
	addi	$a0, $a0, 1		# incrementing x pos of cursor by 1
	
	la	$t0, rows		# getting the value of rows for the board
	
	lw	$t0, ($t0)
	
	beq	$a0, $t0, bottom_walls	# if x pos reached the number of rows, print bottom walls
	
	j	loop_tw			# loop

bottom_walls:

	# displaying the bottom row of walls
	
	la	$a1, columns		# getting the 
	lw	$a1, ($a1)		# value for columns of the board

	li	$a0, 0			# setting the cursor to (0, columns)
	
loop_bw:
	
	la	$a2, hash		# getting the address of hash	
	
	jal 	display			# displaying a hash
	
	la	$t0, rows		# getting the 
	lw	$t0, ($t0)		# value for rows of the board
	
	beq	$a0, $t0, left_walls	# if x pos reached the number of rows, print left walls
	
	addi	$a0, $a0, 1		# incrementing x pos of cursor by 1
	
	j	loop_bw			# loop

left_walls:
	
	# displaying the left column of walls
	
	li	$a0, 0			# setting cursor to 
	li	$a1, 1			# (0, 1)
	
loop_lw:
	
	la	$a2, hash		# getting the address of hash	
	
	jal 	display			# displaying a hash
	
	addi	$a1, $a1, 1		# incrementing y pos of cursor by 1
	
	la	$t1, columns		# getting value of
	lw	$t1, ($t1)		# columns of the board
	
	beq	$a1, $t1, right_walls	# check if y pos of cursor is equal to number of columns of the board
	
	j	loop_lw

right_walls:
	
	# displaying the right column of walls
	
	la	$a0, rows		# getting the
	lw	$a0, ($a0)		# number of rows for the board
	
	li	$a1, 1			# setting cursor to (rows, 1)
	
loop_rw:
	
	la	$a2, hash		# getting the address of hash	
	
	jal 	display			# getting address for hash
	
	addi	$a1, $a1, 1		# incrementing y pos of cursor by 1
	
	la	$t1, columns		# getting value
	lw	$t1, ($t1)		# of columns in board
	
	beq	$a1, $t1, end_walls	# checking if y pos is equal to number of rows of the board
	
	j	loop_rw			# loop
	
end_walls:

	jal 	player			# display initial position of player
		
	jal	reward			# display initial position of reward
		
	j	exit_env		# return 
	
exit_env:
	
	lw	$ra, ($sp)		# load the return address
	addi	$sp, $sp, 4		# restore the stack
	jr	$ra			# return
	
	
	
player:
# displaying the current player position
	addi	$sp, $sp, -4		# reserve space on the stack
	sw	$ra, ($sp)		# store the return address of nested call
	
	la	$a2, p			# load the address of "p" character
	
	la	$a0, x_p		# getting
	la	$a1, y_p		# x and y
	lw	$a0, ($a0)		# pos
	lw	$a1, ($a1)		# of player | setting cursor to (x_p, y_p)
	
	jal 	display			# displaying player
		
	lw	$ra, ($sp)		# restore
	addi	$sp, $sp, 4		# and
	jr	$ra			# exit

reward:
	# generating random numbers for x and y pos of reward
	
	addi	$sp, $sp, -4		# reserve space on the stack
	sw	$ra, ($sp)		# store the return address of nested call
	 
	lw	$a3, rows		# getting upper bound for x position
	subi	$a3, $a3, 1		# substracting 1 due to no considering the 
	
	lw	$a2, columns		# getting upper bound for y position
	subi	$a2, $a2, 2		# substracting 2 to the column value, because the score takes the 1 y cell
	
	jal 	rand_num_reward		# getting random position for reward
	
	# displaying a new reward in a random position
		
	la	$a2, r			# loading the address of "R" character
	
	la	$a0, x_r		# getting x
	la	$a1, y_r		# and
	lw	$a0, ($a0)		# y
	lw	$a1, ($a1)		# pos of reward | setting cursor to (x_r, y_r)
	
	jal 	display			# display the reward
	
	lw	$ra, ($sp)		# load the return address
	addi	$sp, $sp, 4		# restore stack pointer
	
	jr	$ra			# return
		
	
delete_curr_pos:

	# printing a whitespace in a specific position of the board
	# parameters	$a0 = x pos
	#		$a1 = y pos

	addi	$sp, $sp, -4		# reserve space in the stack
	sw	$ra, ($sp)		# store the return address
	
	la	$a2, ws			# loading address of whitespace
	
	jal 	display			# display the whitespace
		
	lw	$ra, ($sp)		# restore
	addi	$sp, $sp, 4		# and
	jr	$ra			# exit
	

	
	
	
	
	
	
