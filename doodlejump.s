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
	middlePipePos: .word 4
	bottomPipePos: .word 4
	topPipePos: .word 4
	startMovingPipes: .word 2424
	endOfScreen: .word 4096
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
			li $a0, 64	# Jessica slowed down the animation
			syscall
		
			jal paintSky
			jal adjustPipes
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

	sw $t1, 0($t0) # Store new jump height
	
	j checkBirdHitPipe
	here:
		jr $ra
		
checkBirdHitPipe:
	lw $t0, birdPos			# Get pos of bird
	
	addi $t1, $t0, 380		# Get left leg
	addi $t2, $t0, 388		# Get right leg
	
	lw $t3, middlePipePos		# Get start point of middle pipe 
	addi $t4, $t3, 32		# Get end point of middle pipe (= start + (8 * 4))
	lw $t5, bottomPipePos		# Get start of bottom pipe
	addi $t6, $t5, 32		# Get end of bottom pipe	
	
checkLeftGreaterThanMiddlePipe:
	blt $t1, $t3, checkRightGreaterThanMiddlePipe

checkLeftLessThanMiddlePipe:
	ble $t1, $t4, BirdHit

checkRightGreaterThanMiddlePipe:
	blt $t2, $t3, checkLeftGreaterThanBottomPipe

checkRightLessThanMiddlePipe:
	ble $t2, $t4, BirdHit

checkLeftGreaterThanBottomPipe:
	blt $t1, $t5, checkRightGreaterThanBottomPipe

checkLeftLessThanBottomPipe:
	ble $t1, $t6, BirdHit
	
checkRightGreaterThanBottomPipe:
	blt $t2, $t5, BirdNotHit

checkRightLessThanBottomPipe:
	ble $t2, $t6, BirdHit
	j BirdNotHit
	
BirdHit:
	la $t0, height # Address of jump
	sw $zero, 0($t0)
	
	la $t0, up
	li $t1, 1
	sw $t1, up
	
	j here
	
BirdNotHit:
	j here
	
adjustPipes:
	lw $t0, birdPos
	lw $t1, startMovingPipes
	
	bge $t0, $t1, redrawPipes # only move pipes if bird is at least at the middle row
	la $t0, up
	beq $zero, $t0, redrawPipes # and if bird is moving up
	
	lw $t0, topPipePos
	addi $t0, $t0, 128
	sw $t0, topPipePos
	
	lw $t0, middlePipePos
	addi $t0, $t0, 128
	sw $t0, middlePipePos
	
	lw $t0, bottomPipePos
	addi $t0, $t0, 128
	sw $t0, bottomPipePos	
	
	lw $t1, endOfScreen	# if bottom pipe is on last row, generate a new pipe
	bge $t0, $t1, generateNewPipe
	
redrawPipes: 		# re-draw all pipes in same positions
	jal paintPipesInit

	# bottom pipe
	lw $t2, bottomPipePos
	jal paintPipes
	
	# middle pipe
	lw $t2, middlePipePos
	jal paintPipes
	
	# top pipe
	lw $t2, topPipePos
	jal paintPipes
	
	j mainLoop
	
generateNewPipe:
	lw $t0, middlePipePos	# bottom pipe becomes the middle pipe
	sw $t0, bottomPipePos
	
	lw $t0, topPipePos		# top pipe becomes the middle pipe
	sw $t0, middlePipePos
	
	# generate new random pipe on the top row
	li $v0, 42
	li $a0, 0
	li $a1, 23
	syscall
	
	li $t2, 4
	mult $a0, $t2
	mflo $t2
	
	li $t3, 1024		# 1920 is the top row of platforms
	add $t2, $t2, $t3
	
	sw $t2, topPipePos

	j redrawPipes

paintFirstPipe:	
	jal paintPipesInit
	
	li $v0, 42 		# 42 syscall to randomize between range
	li $a0, 0   		# min to choose from
	li $a1, 23		# set max to 23 (32 - 8 - 1)
	syscall
	
	li $t2, 4
	mult $a0, $t2
	mflo $t2
	
	sub $t3, $t3, $t4
	add $t2, $t2, $t3
	
	sw $t2, bottomPipePos
	
	jal paintPipes
	
secondPipe:
	li $v0, 42 		# 42 syscall to randomize between range
	li $a0, 0   		# min to choose from
	li $a1, 23		# set max to 23 (32 - 8 - 1)
	syscall
	
	li $t2, 4
	mult $a0, $t2
	mflo $t2
	
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
	
	sub $t3, $t3, $t4
	add $t2, $t2, $t3
	
	sw $t2, topPipePos

	jal paintPipes
	j mainLoop
	
paintPipesInit:
	li $t3, 2944		# start drawing pipes on bottom row
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
