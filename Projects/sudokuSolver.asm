

addi $s0, $zero, 0xFFFF8000	#load data address to $s0
addi $s1, $zero, 81		#number of boxes in sodoku
addi $s2, $zero, 9		#variable used to print numbers in row

#used to read print out the board
read:
lbu $t0, 0($s0)			#read the byte at the current address

#print an integer
add $a0, $zero, $t0		#set $a0 to integer to print
addi $v0, $zero, 1		#Syscall 1: print ingteger
syscall
addi $s0, $s0, 1		#go to next spot in address
addi $s1, $s1, -1		#decrement number of boxes left to read
addi $s2, $s2, -1		#decrement number of items in row
beq $s2, $zero, nextLine	
bne $s1, $zero, read		#when $s1 = 0, finished reading boxes
j doneReading

nextLine:
addi $a0, $zero, 10		#print new line
addi $v0, $zero, 11		#Syscall 11: print character
syscall
addi $s2, $zero, 9		#reset counter for numbers left to print in row
bne $s1, $zero, read		#if still more blocks to read, go back to read

doneReading:

addi $a0, $zero, 0xFFFF8000	#load data address to $s0
addi $a1, $zero, 82		#number of bytes left to look at
addi $a2, $zero, -1		#current position in column
add $a3, $zero, $zero		#current row value
jal _solveSodoku

#terminate program
addi $v0, $zero, 10		#Syscall 10: terminate program
syscall

_solveSodoku:

	addi $sp, $sp, -36	#store registers
	sw $ra, 32($sp)
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, 0($sp)

	add $s0, $zero, $a0	#address to data
	lbu $t0, 0($s0)		#current value to look at
	add $s2, $zero, $a1	#number of boxes to look at
	add $s3, $zero, $a2	#current column position
	add $s5, $zero, $a3	#row count
	addi $s4, $zero, 8	#$s4 will always have a value of 9
	
	add $s2, $s2, -1	#decrement number of boxes to look at
	beq $s2, $zero, complete
	sub $t1, $s4, $s3	#see if row counter at last spot
	bne $t1, $zero, skipReset #if not at last spot, just add 1	
	addi $s3, $zero, -1	#if at last spot in row, set to -1
	addi $s5, $s5, 1	#increment row count
	skipReset:
	addi $s3, $s3, 1	#add 1 to row counter
		
	bne $t0, $zero, skipBox	#if the box already has a value, skip it
	add $s1, $zero, $zero
	
	fullCheck:
	addi $t9, $zero, 9
	beq $t9, $s1, setZero
	addi $s1, $s1, 1
	valChangedCol:
	add $a0, $zero, $s1	#pass the value to compare to
	add $a1, $zero, $s0	#pass current address
	add $a2, $zero, $s3	#current position within the row(0-8)
	jal checkRow		#returns a 1 if value in row, otherwise 0
	beq $v0, $zero, setZero	#if value cannot be placed, return
	add $s1, $zero, $v0

	add $a0, $zero, $s1	#pass the value to compare to
	add $a1, $zero, $s0	#pass current address
	add $a2, $zero, $s5	#current row
	jal checkCol		#returns 0 if no possible values
	beq $v0, $zero, setZero	#if value cannot be placed, return
	add $t1, $s1, $zero
	add $s1, $zero, $v0		#if value not 0, place in $s1
	bne $t1, $s1, valChangedCol		#check row again if value changed
	
	add $a0, $zero, $s1	#pass the value to compare to
	add $a1, $zero, $s0	#pass current address
	add $a2, $zero, $s5	#current row count(0-8)
	add $a3, $zero, $s3	#current position within the row(0-8)
	jal checkBox		#retuns 0 if no possible values
	beq $v0, $zero, setZero	#if value cannot be placed, return
	add $t1, $s1, $zero	#old value
	add $s1, $zero, $v0	#if value not 0, place in $s1
	bne $t1, $s1, valChangedCol	#if value changed, need to test again
	
	#val is okay
	sb $s1, 0($s0)		#if at this point, value is not contradicting
	addi $a0, $s0, 1	#go to next byte in address
	add $a1, $s2, $zero	#pass number of bytes left to look at
	add $a2, $s3, $zero
	add $a3, $s5, $zero
	jal _solveSodoku
	beq $v0, $zero, fullCheck
	j complete
	
	setZero:
	add $s1, $zero, $zero
	sb $s1, 0($s0)	
	j complete
	#need way to determine if finished or if wrong
	#beq $v0, $zero, complete
	#if not finished, try next value
	
	skipBox:
	addi $a0, $s0, 1	#go to next byte in address
	add $a1, $s2, $zero	#pass number of bytes left to look at
	add $a2, $s3, $zero
	add $a3, $s5, $zero
	jal _solveSodoku
	
	complete:	
	#return value to let program know when not correct	
	#return so restore values
	lw $ra, 32($sp)
	lw $s0, 28($sp)
	lw $s1, 24($sp)
	lw $s2, 20($sp)
	lw $s3, 16($sp)
	lw $s4, 12($sp)
	lw $s5, 8($sp)
	lw $s6, 4($sp)
	lw $s7, 0($sp)
	addi $sp, $sp, 36
	
	jr $ra
	

###############################CHECK ROW############
#$a0: current value to compare to
#$a1: current address to start from
#$a2: current position withing row
checkRow:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	add $t0, $a0, $zero	#current value to compare to
	add $t1, $a1, $zero	#current address
	sub $t6, $t1, $a2	#go to beginning of row
	addi $t2, $zero, 9	#count number of iterations for row
	
	rowCheck:
	lb $t3, 0($t6)		#load current byte
	beq $t3, $t0, invalid	#if the two values equal, go to next
	addi $t6, $t6, 1	#go to next byte
	addi $t2, $t2, -1
	bne $t2, $zero, rowCheck
	j finishedRow
			
	invalid:
	addi $t4, $zero, 9	#add 9 to $t4
	sub $t5, $t4, $t0	#subtract current value from 9 to see if any choices left
	beq $t5, $zero, noVals
	addi $t0, $t0, 1	#try next value
	sub $t6, $t1, $a2	#go back to beginning of row
	addi $t2, $zero, 9
	j rowCheck
	
	noVals:			#no more options to try
	add $t0, $zero, $zero	#set $t0 to 0 as nothing to place
	
	finishedRow:
	add $v0, $t0, $zero	#return value to place in current byte
	#if 0, no more values to try if anything else, check columns
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
##################CHECK ROW########################



#####################CHECK COL######################
#$a0: current value to compare to
#$a1: current address to start from
#$a2: current row
checkCol:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	add $t0, $a0, $zero	#current value to compare to
	add $t1, $a1, $zero	#current address
	addi $t2, $zero, 9	#count number of iterations for row
	multu $a2, $t2		#get value to go back to beginning of column
	mflo $t8
	sub $t6, $t1, $t8	#go to beginning of col
	addi $t2, $zero, 9	#count number of iterations for row

	colCheck:
	lb $t3, 0($t6)		#load current byte
	beq $t3, $t0, invalidColVal	#if the two values equal, go to next
	addi $t6, $t6, 9	#go to next byte
	addi $t2, $t2, -1
	bne $t2, $zero, colCheck
	j finishedCol

	invalidColVal:
	addi $t4, $zero, 9	#add 9 to $t4
	sub $t5, $t4, $t0	#subtract current value from 9 to see if any choices left
	beq $t5, $zero, noValsCols
	addi $t0, $t0, 1	#try next value
	sub $t6, $t1, $t8	#go back to beginning of column
	addi $t2, $zero, 9
	j colCheck
	
	noValsCols:			#no more options to try
	add $t0, $zero, $zero	#set $t0 to 0 as nothing to place
	
	finishedCol:
	add $v0, $t0, $zero	#return value to place in current byte
	#if 0, no more values to try if anything else, check whole box
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
####################check column ######################


#####################CHECK BOX########################	
#$a0: current value to compare to
#$a1: current address to start from
#$a2: current row
#$a3: current position in row
checkBox:

	addi $sp, $sp, -36
	sw $ra, 32($sp)
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	
	add $s0, $a0, $zero	#current value to compare to
	add $s1, $a1, $zero	#current address
	add $s2, $a2, $zero	#current row
	add $s3, $a3, $zero	#current position in row
	#addi $t2, $zero, 9	#count number of iterations for row

	addi $t3, $zero, 3
	addi $t6, $zero, 6
	addi $t9, $zero, 9
	
	#first part of plan
	slt $t0, $s2, $t3	
	bne $t0, $zero, boxRow1
	slt $t0, $s2, $t6
	bne $t0, $zero, boxRow2
	slt $t0, $s2, $t9
	bne $t0, $zero, boxRow3
	
	####
	boxRow2:
	addi $t0, $zero, 9	#used to multiply row value by 9
	add $t1, $zero, 3	#3 rows full at this point
	mult $t1, $t0		#count number of full rows completed
	mflo $t1		#place result in $t1
	add $t2, $t1, $zero	#offset to get to beggining of row
	mult $t0, $s2
	mflo $t1
	add $t1, $t1, $s3	#current offset for address
	sub $s4, $s1, $t1	#go to very beginning
	add $s4, $t2, $s4	#go to first spot in second row of boxes
	
	slt $t0, $s3, $t3	
	bne $t0, $zero, colsRow00
	slt $t0, $s3, $t6
	bne $t0, $zero, colsRow03
	slt $t0, $s3, $t9
	bne $t0, $zero, colsRow06
	
	####
	
	########
	boxRow3:
	addi $t0, $zero, 9	#used to multiply row value by 9
	add $t1, $zero, 6	#3 rows full at this point
	mult $t1, $t0		#count number of full rows completed
	mflo $t1		#place result in $t1
	add $t2, $t1, $zero	#offset to get to beggining of row
	mult $t0, $s2
	mflo $t1
	add $t1, $t1, $s3	#current offset for address
	sub $s4, $s1, $t1	#go to very beginning
	add $s4, $t2, $s4	#go to first spot in second row of boxes
	
	slt $t0, $s3, $t3	
	bne $t0, $zero, colsRow00
	slt $t0, $s3, $t6
	bne $t0, $zero, colsRow03
	slt $t0, $s3, $t9
	bne $t0, $zero, colsRow06
	
	###
	boxRow1:
	addi $t0, $zero, 9
	mult $s2, $t0
	mflo $t1
	add $t1, $t1, $s3	#current offset
	sub $s4, $s1, $t1	#should place $s4 at starting address
	
	slt $t0, $s3, $t3	
	bne $t0, $zero, colsRow00
	slt $t0, $s3, $t6
	bne $t0, $zero, colsRow03
	slt $t0, $s3, $t9
	bne $t0, $zero, colsRow06
	
	colsRow00:
	add $s5, $zero, $s4	#store address in $s5
	j checkCols0		#skip cols 3 and 6
	colsRow03:
	addi $s4, $s4, 3	#starting address + 3
	add $s5, $zero, $s4	#store address in $s5
	j checkCols0		#skip cols6
	colsRow06:
	addi $s4, $s4, 6	#starting address + 6
	add $s5, $zero, $s4	#store address in $s5
	
	checkCols0:
	addi $t7, $zero, 3	#$t7 counter for position in row
	add $t8, $zero, 3	#$t8 counter for row
	colBoxCheck:
	lbu $t2, 0($s4)			#load current byte
	beq $t2, $s0, nextValBox	#if the two values equal, go to next
	addi $t7, $t7, -1
	bne $t7, $zero, skipUpdate
	addi $t8, $t8, -1
	beq $t8, $zero, finishedBox
	addi $t7, $zero, 3
	addi $s4, $s4, 6
	skipUpdate:
	addi $s4, $s4, 1
	bne $t8, $zero, colBoxCheck
	j finishedCol
	
	nextValBox:
	sub $t5, $t9, $s0	#subtract current value from 9 to see if any choices left
	beq $t5, $zero, noBoxVals
	addi $s0, $s0, 1	#try next value
	add $s4, $s5, $zero	#go back to beginning of column
	addi $t7, $zero, 3
	addi $t8, $zero, 3
	j colBoxCheck

	noBoxVals:			#no more options to try
	add $s0, $zero, $zero	#set $t0 to 0 as nothing to place
	
	finishedBox:
	add $v0, $s0, $zero	#return value to place in current byte
	#if 0, no more values to try if anything else, check whole box
	
	#restore s registers too
	lw $ra, 32($sp)
	lw $s0, 28($sp)
	lw $s1, 24($sp)
	lw $s2, 20($sp)
	lw $s3, 16($sp)
	lw $s4, 12($sp)
	lw $s5, 8($sp)
	lw $s6, 4($sp)
	lw $s7, 0($sp)
	addi $sp, $sp, 36
	
	jr $ra
	#or...if less than 3 for rows, go to starting address
		#if less than 6, go to start + 27
		#if less than 9, go to start + 54
		#can figure out  position by multiplying (row*9)+ position in row
			#then once at start, if position less than 3, start at spot 0
				#if position less than 6, start at spot 3
				#if position less than 9, start at spot 6

	
	#use branches based off of where you are in row, which row
	

##################CHECK BOX##############################
