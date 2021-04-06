# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
	displayAddress:	.word 0x10008000
	pipeLength: .word 4
	birdPos: .word 3648
	height: .word 0
	up: .word 1

	# Colors for painting on the screen
	sky: .word 0x2c7493
	pipe: .word 0x361414
	bird: .word 0x2f5c2c
	

.text
# main to start from which leads to a loop to 
# create our static view
main:

	mainLoop: # Main loop until the game is over
		jal paintSky

		animateBird:
			lw $t0, up
			blez $t0, animateBirdDown
		
		animateBirdUp:
			lw $t0, displayAddress # Display Address
			lw $t1, bird # Bird Color
			jal animateUp
			j nothing
		
		animateBirdDown:
			lw $t0, displayAddress # Display Address
			lw $t1, bird # Bird Color
			jal animateDown
			j nothing

		nothing:

		# Sleep to delay animation
		li $v0, 32		
		move $a0, $v1
		syscall

		j mainLoop


paintSky:
	paintSkyLoopInit:
		lw $t0, displayAddress	# $t0 stores the base address for display
		lw $t1, sky				# $t1 stores the blue colour code
		addi $t2, $zero, 4096
		addi $t2, $t2, 0x10008000
		j paintSkyLoop

	paintSkyLoop:
		sw $t1, 0($t0)	 		# paint the first (top-left) unit red.
		addi $t0, $t0, 4 		# $t0 = $t0++
		ble $t0, $t2, paintSkyLoop
	
	jr $ra

#	addBirdInit:
#	lw $t0, displayAddress # Display Address
#	lw $t1, bird # Bird Color

animateUp:
	lw $t2, birdPos # Bird Offset
	add $s1, $t0, $t2 # Current Bird Location

	sw $t1, 0($s1)   # Next 5 lines drawing the bird
	sw $t1, 124($s1)
	sw $t1, 128($s1)
	sw $t1, 132($s1)
	sw $t1, 252($s1)
	sw $t1, 260($s1)

	la $t0, birdPos # Address of birdPos
	lw $t1, birdPos # Value of birdPos
	addi $t1, $t1, -128 # Move a line up
	sw $t1, 0($t0) # Store new bird location in birdPos

	la $t0, height # Address of jump
	lw $t1, height # Value of jump
	addi $t1, $t1, 1 # $t1 += 1

	jumpUpComplete:
		beq $t1, 9, jumpUpCompleteThen
		j jumpUpCompleteDone
	
	jumpUpCompleteThen:
		la $t2, up # Address of up
		li $t3, 0 
		sw $t3, 0($t2) # Make up true by setting it to 1

	jumpUpCompleteDone:
		sw $t1, 0($t0) # Store new jump height

	jr $ra

animateDown:
	lw $t2, birdPos # Bird Offset
	add $s1, $t0, $t2 # Current Bird Location

	sw $t1, 0($s1)   # Next 5 lines drawing the bird
	sw $t1, 124($s1)
	sw $t1, 128($s1)
	sw $t1, 132($s1)
	sw $t1, 252($s1)
	sw $t1, 260($s1)

	la $t0 birdPos # Address of birdPos
	lw $t1 birdPos # Value of birdPos
	addi $t1, $t1, 128 # Move a line down
	sw $t1, 0($t0) # Store new bird location in birdPos

	la $t0, height # Address of jump
	lw $t1, height # Value of jump
	addi $t1, $t1, -1 # $t1 += 1

	jumpDownComplete:
		beq $t1, $zero, jumpDownCompleteThen
		j jumpDownCompleteDone
	
	jumpDownCompleteThen:
		la $t2, up # Address of up
		li $t3, 1 
		sw $t3, 0($t2) # Make up true by setting it to 1

	jumpDownCompleteDone:
		sw $t1, 0($t0) # Store new jump height

	jr $ra

paintPipesInit:
	li $t3, 3968
	li $t4, 0
	
paintPipes:
	li $v0, 42 		# 42 syscall to randomize between range
	li $a0, 0   		# min to choose from
	li $a1, 23		# set max to 23 (32 - 8 - 1)
	syscall
	
	lw $t0, displayAddress
	 
	sub $t3, $t3, $t4 
	add $t0, $t0, $t3
	
	li $t2, 4
	mult $a0, $t2
	mflo $t2
	
	add $t0, $t0, $t2	
	
	lw $t1, pipe
	li $t6, 0
	li $t7, 7
	
	paintPipeLoop:
		sw $t1, 0($t0)
		addi $t0, $t0, 4
		addi $t6, $t6, 1
		ble, $t6, $t7, paintPipeLoop
	
	li $t4, 1024
	li $t5, 1920
	ble $t3, $t5, Exit
	

	j paintPipes

Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
