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
	bottomPipeOffset: .word 4
	topPipeOffset: .word 4
	middlePipeOffset: .word 4
	middlePipePos: .word 4
	newline: .asciiz "\n"
	pipeString: .asciiz "pipe: "
	birdString: .asciiz "bird: "
	
	# Colors for painting on the screen
	sky: .word 0x2c7493
	pipe: .word 0x361414
	bird: .word 0x2f5c2c
	

.text
# main to start from which leads to a loop to 
# create our static view
main:
	jal paintSky
	j paintFirstPipe

	mainLoop: # Main loop until the game is over

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
			li $a0, 32	# Jessica slowed down the animation
			syscall
		
			jal paintSky
			j checkBirdHitPipe
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
	
checkBirdHitPipe:
	lw $t0, birdPos			# Get pos of bird
	lw $t1, middlePipePos	# Get pos of middle pipe
	
	#addi $t0, $t0, 28	# check bird address down one row because it's currently on top of the pipe
	
	# check if the bird is on any part of the pipe	
	li $t3, 0	# initialize loop condition
	li $t4, 7
	
checkBirdHitPipeLoop:
	beq $t0, $t1, BirdHit
	bge $t3, $t4, BirdNotHit
	
	li $v0, 4			# syscall to print string
	la $a0, birdString		# a0 = "\n"
	syscall
	
	li $v0, 1			# syscall to print string
	move $a0, $t0			# a0 = "\n"
	syscall
	
	li $v0, 4			# syscall to print string
	la $a0, newline			# a0 = "\n"
	syscall
	
	li $v0, 4			# syscall to print string
	la $a0, pipeString		# a0 = "\n"
	syscall
	
	li $v0, 1			# syscall to print string
	move $a0, $t1			# a0 = "\n"
	syscall
	
	li $v0, 4			# syscall to print string
	la $a0, newline			# a0 = "\n"
	syscall 	
	
	addi $t1, $t1, 4
	addi $t3, $t3, 1
	
	j checkBirdHitPipeLoop
	
BirdHit:
	# draw new bottom pipe
	jal paintPipesInit
	
	lw $a0, middlePipeOffset	# bottom pipe gets middle pipe's offset
	li $t2, 4
	mult $a0, $t2
	mflo $t2
	
	sub $t3, $t3, $t4
	add $t2, $t2, $t3
	
	sw $t2, bottomPipeOffset
	
	jal paintPipes	# draw bottom pipe

	# draw new middle pipe
	lw $a0, topPipeOffset	# middle pipe gets top pipe's offset
	li $t2, 4
	mult $a0, $t2
	mflo $t2
	
	sub $t3, $t3, $t4
	add $t2, $t2, $t3
	
	sw $t2, middlePipeOffset
	
	jal paintPipes		# draw middle pipe
	
	# draw new top pipe
	li $v0, 42 		# top pipe is a new random pipe
	li $a0, 0   		
	li $a1, 23		
	syscall
	
	li $t2, 4
	mult $a0, $t2
	mflo $t2
	
	sub $t3, $t3, $t4
	add $t2, $t2, $t3
	
	sw $t2, topPipeOffset		
	
	jal paintPipes		# draw top pipe
	j mainLoop		# back to main loop
	
BirdNotHit:	# re-draw all pipes in same positions
	# re-draw first pipe
	jal paintPipesInit
		
	lw $t2, bottomPipeOffset
	sub $t3, $t3, $t4
	add $t2, $t2, $t3
	jal paintPipes
	
	# re-draw second pipe
	lw $t2, middlePipeOffset
	sub $t3, $t3, $t4
	add $t2, $t2, $t3
	jal paintPipes
	
	# re-draw thirs pipe
	lw $t2, topPipeOffset
	sub $t3, $t3, $t4
	add $t2, $t2, $t3
	jal paintPipes
	
	j mainLoop
	
paintFirstPipe:
	jal paintPipesInit
	
	li $v0, 42 		# 42 syscall to randomize between range
	li $a0, 0   		# min to choose from
	li $a1, 23		# set max to 23 (32 - 8 - 1)
	syscall
	
	li $t2, 4
	mult $a0, $t2
	mflo $t2
	
	sw $t2, bottomPipeOffset
	
	sub $t3, $t3, $t4
	add $t2, $t2, $t3
	
	jal paintPipes
	
secondPipe:
	li $v0, 42 		# 42 syscall to randomize between range
	li $a0, 0   		# min to choose from
	li $a1, 23		# set max to 23 (32 - 8 - 1)
	syscall
	
	li $t2, 4
	mult $a0, $t2
	mflo $t2
	
	sw $t2, middlePipeOffset
	
	sub $t3, $t3, $t4
	add $t2, $t2, $t3
	
	sw $t2, middlePipePos
	
	jal paintPipes
	
thirdPipe:
	li $v0, 42 		# 42 syscall to randomize between range
	li $a0, 0   		# min to choose from
	li $a1, 23		# set max to 23 (32 - 8 - 1)
	syscall
	
	li $t2, 4
	mult $a0, $t2
	mflo $t2
	
	sw $t2, topPipeOffset
	
	sub $t3, $t3, $t4
	add $t2, $t2, $t3

	jal paintPipes
	j mainLoop

paintPipesInit:
	li $t3, 3968		# start drawing pipes on bottom row
	li $t4, 0		# row offset
	
	jr $ra

paintPipes:	
	lw $t0, displayAddress
	
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
	jr $ra
	
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
