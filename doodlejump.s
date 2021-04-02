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
	displayAddress:	.word	0x10008000
	pipeLength: .word 4

	# Colors for painting on the screen
	sky: .word 0x2c7493
	pipe: .word 0x361414
	bird: .word 0x2f5c2c
	

.text
# main to start from which leads to a loop to 
# create our static view
main:
	j paintSkyLoopInit

paintSkyLoopInit:
	lw $t0, displayAddress	# $t0 stores the base address for display
	lw $t1, sky				# $t1 stores the blue colour code
	addi $t2, $zero, 65536
	addi $t2, $t2, 0x10008000
	j paintSkyLoop

paintSkyLoop:
	sw $t1, 0($t0)	 		# paint the first (top-left) unit red.
	addi $t0, $t0, 4 		# $t0 = $t0++
	ble $t0, $t2, paintSkyLoop

paintPipes:
	li $v0, 42 				# 42 syscall to randomize between range
	li $a0, 0   				# min to choose from
	li $a1, 23
	syscall
	
	#addi $t0, $zero, 57344
	#addi $t0, $t0, 0x10008000
	lw $t0, displayAddress
	#addi $t0, $t0, 0x100081e0
	
	li $t3, 3968
	add $t0, $t0, $t3
	
	li $t2, 4
	mult $a0, $t2
	mflo $t2
	
	add $t0, $t0, $t2	
	
	lw $t1, sky
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	
	# second pipe
	li $v0, 42 				# 42 syscall to randomize between range
	li $a0, 0   				# min to choose from
	li $a1, 23
	syscall
	
	#addi $t0, $zero, 57344
	#addi $t0, $t0, 0x10008000
	lw $t0, displayAddress
	#addi $t0, $t0, 0x100081e0
	
	li $t3, 2944
	add $t0, $t0, $t3
	
	li $t2, 4
	mult $a0, $t2
	mflo $t2
	
	add $t0, $t0, $t2	
	
	lw $t1, sky
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4


	# third pipe
	li $v0, 42 				# 42 syscall to randomize between range
	li $a0, 0   				# min to choose from
	li $a1, 23
	syscall
	
	#addi $t0, $zero, 57344
	#addi $t0, $t0, 0x10008000
	lw $t0, displayAddress
	#addi $t0, $t0, 0x100081e0
	
	li $t3, 1920
	add $t0, $t0, $t3
	
	li $t2, 4
	mult $a0, $t2
	mflo $t2
	
	add $t0, $t0, $t2	
	
	lw $t1, sky
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t0, $t0, 4

addBird:
	lw $t0, displayAddress
	


Exit:
	li $v0, 10 # terminate the program gracefully
	syscall



#	lw $t0, displayAddress	# $t0 stores the base address for display
#	li $t1, 0xff0000	# $t1 stores the red colour code
#	li $t2, 0x00ff00	# $t2 stores the green colour code
#	li $t3, 0x0000ff	# $t3 stores the blue colour code
	
#	sw $t1, 0($t0)	 # paint the first (top-left) unit red. 
#	sw $t2, 4($t0)	 # paint the second unit on the first row green. Why $t0+4?
#	sw $t3, 128($t0) # paint the first unit on the second row blue. Why +128?
#	sw $t2, 256($t0)




