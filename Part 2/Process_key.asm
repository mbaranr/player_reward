	.globl 	available_key, exit_moveptr
	
	.text
	
# Check if a key has been pressed, process that key and update the position of the player accordingly

available_key:

	# check if new key available to process

	addi	$sp, $sp, -4			# make space on stack
	sw	$ra, 0($sp)			# save the return address
	
	lw	$t0, kb_buffer_head		# check if head
	lw	$t1, kb_buffer_tail		# and tail
	beq	$t0, $t1, exit_key		# are the same, if they are, return
	
	j	process_key
	
process_key:

	# process key
	
	lw	$t0, kb_buffer_tail 		# loading tail pointer
	
	lw	$t1, ($t0)			# dereference to get key
	
	beq	$t1, 's', move_up		# check
	beq	$t1, 'w', move_down		# which
	beq	$t1, 'a', move_left		# key
	beq	$t1, 'd', move_right		# has been pressed
	
	# if none of those, we ignore the key press	
	
	j	exit_moveptr

exit_moveptr:

	lw	$t0, kb_buffer_tail		# loading tail pointer
	
	# adding 4 to that pointer to have space for next word
	
	addi	$t1, $t0, 4			# move pointer forward
	
	# check if we need to wrap tail pointer 
	
	la	$t0, kb_buffer			# get buffer address
	
	addi	$t0, $t0, 200			# add 200 to get offset max offset
	
	beq	$t0, $t1, reset_tail		# check if tail is equal to buffer + 200
	
	sw	$t1, kb_buffer_tail		# push tail pointer back
	
	j	exit_key

reset_tail:

	# wrap tail pointer round to start of queue
	
	la	$t0, kb_buffer			# get buffer address
	
	sw	$t0, kb_buffer_tail		# push tail pointer to start of the queue
	
	j	exit_key			# return
	

exit_key:

	lw	$ra, 0($sp)			# restore
	addi	$sp, $sp, 4			# and
	jr	$ra				# exit
	
