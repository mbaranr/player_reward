	.text
	.globl main
	j main
	
main:
	
	# set up queue for key pressess
	
	la	$t0, kb_buffer			# get index 0 of buffer
	
	sw	$t0, kb_buffer_head		# set head
	
	sw	$t0, kb_buffer_tail		# and tail to 0
	
	li	$t0, 0xffff0000			# keyboard control register
	li	$t1, 2				# interrupt enable bit -> 1
	sw	$t1, ($t0)			# enable interrupts on keyboard
	
	
	jal	init_env			# initialize the game environment
	
	
loop:

	jal	available_key			# check for and process key presses
	
	j 	loop				# loop forever
	

	
