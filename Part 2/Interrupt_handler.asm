	.data
	
kb_buffer_head:	.word  	0			# pointer to most recent data
kb_buffer:	.space 	200			# 50 words / 200 bytes
kb_buffer_tail:	.word	0			# pointer to most recently processed data

	.globl kb_buffer_head, kb_buffer, kb_buffer_tail

######################################################################################################
	
	# exception handling / IRQs	
	
	.ktext 	0x80000180
	
	mfc0	$k0, $13			# move cause contents to k0
	
	srl	$k0, $k0, 2			# shift right by 2
	
	andi	$k0, $k0, 0x1F			# mask off final 5 bits
	
	beq	$k0, $zero, IRQ			# 0 -> hardware interrupt
		
	eret					# return to normal code

IRQ:    

	# check where interrupt came from
	
	mfc0	$k0, $13			# move cause contents to k0
	
	andi	$k1, $k0, 0x0100		# check if it was a keyboard that caused the interrupt
	
	bne	$k1, $zero, IRQ_KB		# jump to kb IRQ

	eret					# return to normal code

IRQ_KB:

	# store key pressed in head of buffer
	
	lw	$k1, kb_buffer_head		# pull current size of buffer
	
	li	$k0, 0xffff0004			# keyboard data register
	
	lw	$k0, 0($k0)			# get character
	
	sw	$k0, 0($k1)			# store in head of buffer
	
	add	$k1, $k1, 4			# increment to cover new character
	
	# if head has reached the max offset of buffer, reset it to 0
	
	la	$k0, kb_buffer			# load the address of buffer
	
	addi	$k0, $k0, 200			# offset this address by 200 bytes
	
	beq	$k0, $k1, reset_head		# check if head has reached max offset, if it did, reset it
	
	sw	$k1, kb_buffer_head		# push head pointer back
	
	eret					# return to normal code 

reset_head:
	
	# push back the head to start of buffer
	
	la	$k0, kb_buffer			# load the address of buffer
	
	sw	$k0, kb_buffer_head 		# reset head pointer to start of buffer
	
	eret					# return to normal code


	
	
	
	
	


	
	
	
	
	
	
	
	
	
	
	
	
	
