.data
	fileName: .asciiz "Enter a filename: "
	firstTwo: .asciiz "The first two charachers: "
	bmpSize: .asciiz "The size of the BMP file (bytes): "
	startADD: .asciiz "The starting address of image data: "
	imgWidth: .asciiz "Image width (pixels): "
	imgHeight: .asciiz "Image height (pixels): "
	colorPlanes: .asciiz "The number of color planes: "
	bitsPix: .asciiz "The number of bits per pixel: "
	compMethod: .asciiz "The compression method: "
	rawBMP: .asciiz "The sizw of raw bitmap data (bytes): "
	horizRes: .asciiz "The horizontal resolution (pixels/meter): "
	vertRes: .asciiz "The vertical resolution (pixels/meter): "
	colors: .asciiz "The number of colors in the color palette: "
	impColors: .asciiz "The number of important colors used: "
	indx1Color: .asciiz "The color at index 0 (B G R): "
	indx2Color: .asciiz "The color at index 1 (B G R): "
	
	buffer:	.space	100 #used to get user input
	fileType: .space 2
	.align 2
	lastTwelve: .space 12
	DIBsize: .space 4
	colorArray: .space 8
	tempHolder: .space 8
	testing: .space 130
	
	
	
.text
	#prompt user for a file name
	addi $v0, $zero, 4 	 #Syscall 4: print string
	la $a0, fileName  	#$a0 = address of the user prompt
	syscall			#print the string fileName
	jal readString
	add $s0, $v0, $zero 	#store returned string address to $s0

#open the file given by the user	
	addi $v0, $zero, 13	 #Syscall 13: Open file
	la $a0, ($s0)		 # $a0 is the address of filename 
	add $a1, $zero, $zero 	 # $a1 = 0 
	add $a2, $zero, $zero    # $a2 = 0 
	syscall 		 # Open file 
	add $s0, $zero, $v0      # Copy the file descriptor to $s0
	
#read first 2 characters of file
	addi $v0, $zero, 14	 # Syscall 14: Read file 
	add $a0, $zero, $s0 	 # $a0 is the file descriptor 
	la $a1, fileType 	 # $a1 is the address of a buffer (fileType) 
	addi $a2, $zero, 2 	 # $s2 is the number of bytes to read 
	syscall  		 # Read file 
	la $s1, fileType 	 # Set $s1 to the address of firstTwo *****
	
#read next 12 bytes
	addi $v0, $zero, 14	#Syscall 14: Read file
	add $a0, $zero, $s0	# $a0 is the file descriptor
	la $a1, lastTwelve	#a1 is the address of a buffer (lastTwelve)
	addi $a2, $zero, 12	# $s2 is the number of bytes to read
	syscall			#read file
	la $s2, lastTwelve	#Set $s2 to the address of lastTwelve

	
#read DIB size
	addi $v0, $zero, 14	#Syscall 14: Read file
	add $a0, $zero, $s0	#$a0 is the file descriptor
	la $a1, DIBsize 	#$a1 is the address of a buffer(DIBsize)
	addi $a2, $zero, 4	#$s2 is the number of bytes to read
	syscall			#read file
	la $s3, DIBsize		#set $s2 to the address of DIBsize(in bytes)

#allocate heap
	addi $v0, $zero, 9	#Syscall 9: create heap
	lw $a0, 0($s3)		#pass size of DIBheader 0($s3) to $a0
	addi $a0, $a0, -4	#subtract 4 from DIB size as already read first 4 bytes
	syscall			#create heap
	add $s4, $zero, $v0  	#$s4 is the address of the memory for heap to contain DIB Header info
#take information out of DIB header
	addi $v0, $zero, 14	#Syscall 14: Read file
	add $a0, $zero, $s0	# $a0 is the file descriptor
	la $a1, ($s4)		#$a1 is the address of a buffer(the heap $s4)
	#addi $a2, $zero, 44	# $s2 is the number of bytes to read
	lw $a2, 0($s3)		#read the whole DIB header
	addi $a2, $a2, -4	#subtract 4 bytes as already read first 4
	syscall			#read file
	####$s4 contains all information of DIB Header

#get colors
	addi $v0, $zero, 14	#Syscall 14: Read file
	add $a0, $zero, $s0	#$a0 is the file descriptor
	la $a1, colorArray 	#$a1 is the address of a buffer(colorArray)
	addi $a2, $zero, 8	#$s2 is the number of bytes to read
	syscall			#read file
	la $s5, colorArray	#set $s5 to the address of colorArray

#allocate heap for rawdata
	addi $v0, $zero, 9	#create heap syscall
	#new
	#addi $s0, $s0, -104
	lw $a0, 16($s4) 	#pass size of raw bit map integer
	syscall
	la $s6, ($v0)  	#$s6 is the address of the memory
	#####$s6 is the address of the memory for heap for raw bit map data
	
#new line
	addi $v0, $zero, 11
	addi $a0, $zero, 10
	syscall
	
	addi $v0, $zero, 4 	 #Syscall 4: print string
	la $a0, firstTwo  	 #$a0 = address of the user prompt
	syscall			 #print the string first two characters
	addi $v0, $zero, 11 	 # Syscall 11: Print character 
	lb $a0, 0($s1) 	 	 # $a0 is the first byte of firstTwo 
	syscall 		 # Print a character 
	lb $a0, 1($s1) 		 # $a0 is the second byte of firstTwo 
	syscall 		 # Print a character	
	
	la $a0, bmpSize
	lw $a1, 0($s2)		 #bmpSize
	jal printInfo
	
	la $a0, startADD
	lw $a1, 8($s2)		#starting address of image data
	jal printInfo
	
	la $a0, imgWidth
	lw $a1, 0($s4)		#image width
	jal printInfo
	
	la $a0, imgHeight
	lw $a1, 4($s4)		#image height
	jal printInfo
	
	la $a0, colorPlanes
	lh $a1, 8($s4)		#number of color planes
	jal printInfo
	
	la $a0, bitsPix
	lh $a1, 10($s4)		#bitsPerPixel
	jal printInfo
	
	la $a0, compMethod
	lw $a1, 12($s4)		#compression method(should be 0)
	jal printInfo
	
	la $a0, rawBMP
	lw $a1, 16($s4)		#size of raw bitmap data
	jal printInfo
	
	la $a0,horizRes
	lw $a1, 20($s4)		#horizontal resolution
	jal printInfo
	
	la $a0, vertRes		#vertical resolution
	lw $a1, 24($s4)
	jal printInfo
	
	la $a0, colors
	lw $a1, 28($s4)		#number of colors in the color palett
	jal printInfo
	
	la $a0, impColors
	lw $a1, 32($s4)		#number of important colors used
	jal printInfo
	
	#new line
	addi $v0, $zero, 11
	addi $a0, $zero, 10
	syscall
	
	addi $v0, $zero, 4 	 #Syscall 4: print string
	la $a0, indx1Color	 #$a0 = address of the prompt
	syscall			 #print the string userInput

	addi $v0, $zero, 1	#Syscall 1: Print Integer
	lbu $a0, 0($s5)		#get blue for color 1
	syscall			#Print an integer
	addi $v0, $zero, 11	#print space
	addi $a0, $zero, 32
	syscall
	addi $v0, $zero, 1	#Syscall 1: Print Integer
	lbu $a0, 1($s5)		#get green for color 1
	syscall			#Print an integer
	addi $v0, $zero, 11	#print space
	addi $a0, $zero, 32
	syscall
	addi $v0, $zero, 1	#Syscall 1: Print Integer
	lbu $a0, 2($s5)		#get red for color 1
	syscall			#Print an integer

	#new line
	addi $v0, $zero, 11
	addi $a0, $zero, 10
	syscall
	
	addi $v0, $zero, 4 	 #Syscall 4: print string
	la $a0, indx2Color	 #$a0 = address of the prompt
	syscall			 #print the string userInput

	addi $v0, $zero, 1	#Syscall 1: Print Integer
	lbu $a0, 4($s5)		#get blue for color 2
	syscall			#Print an integer
	addi $v0, $zero, 11	#print space
	addi $a0, $zero, 32
	syscall
	addi $v0, $zero, 1	#Syscall 1: Print Integer
	lbu $a0, 5($s5)		#get green for color 2
	syscall			#Print an integer
	addi $v0, $zero, 11	#print space
	addi $a0, $zero, 32
	syscall
	addi $v0, $zero, 1	#Syscall 1: Print Integer
	lbu $a0, 6($s4)		#get red for color 2
	syscall			#Print an integer

#read remaining bytes
	addi $v0, $zero, 14	#Syscall 14: Read file
	add $a0, $zero, $s0	#$a0 is the file descriptor

	la $a1, ($s6)		#$a1 is the address of a buffer(the memory for the raw bit map heap)
	lw $a2, 16($s4)	#16($s4) is the number of bytes to read
	syscall
	
       	la $a0, ($s6)	#pass heap for raw bit map data to function
	lw $a1, 16($s4)	#pass the size of raw bit map data
	lw $a2, 0($s4)	#pass width of pixels
	lw $a3, 4($s4)	#height of pixels
	jal readData

#close file
	add $v0, $zero, 16 # Syscall 16: Close file 
	add $a0, $zero, $s0 # $a0 is the file descriptor 
	syscall # Close file	
	
	addi $v0, $zero, 10 # Syscall 10: Terminate program 
	syscall # Terminate the program
	
	
	
#used to print out information
#$a0: string to print
#$a1: value to print
printInfo:
	la $t0, ($a0)
	#new line
	addi $v0, $zero, 11
	addi $a0, $zero, 10
	syscall
	
	addi $v0, $zero, 4 	 #Syscall 4: print string
	la $a0, ($t0)	 	 #$a0 = address of the prompt
	syscall			 #print the string userInput
	
	addi $v0, $zero, 1		#Syscall 1: Print Integer
	add $a0, $a1, $zero		#put value to print in $a0
	syscall			#Print an integer
	
	jr $ra

#function reads the data to output
#arguments:
#$a0: the heap to store the data
#$a1: size of raw bmp data
#$a2: width
#$a3: height	
readData:
	addi $sp, $sp, -32
	sw $ra, 28($sp)
	sw $s0, 24($sp)
	sw $s1, 20($sp)
	sw $s2, 16($sp)
	sw $s3, 12($sp)
	sw $s4, 8($sp)
	sw $s5, 4($sp)
	sw $s6, 0($sp)

	lbu $t0, 0($s5)		#get blue for color 1
	add $t2, $zero, $zero
	bne $t0, $zero, skip
	addi $t2, $zero, 1
	skip:
	la $s1, ($a0)	#$s1 is the heap to store data in
	add $s2, $zero, $a2	#width of pixels
	add $t5, $zero, $a2	#width
	add $t6, $zero, $a3	#height
	add $s7, $s7, $a3 #height of pixels
	add $s0, $a1, $zero	#size of raw bit map data
	
	#bytes per row
	div $t3, $s0, $t6	#bytes per row

	add $s1, $s1, $s0	#go to end of file
	sub $s1, $s1, $t3	#go to beginning of row of end of file

	#add $s0, $s1, $zero

	addi $s3, $zero, 8	#counter for number of iterations
	addi $s4, $zero, 0	#shift left amount
	addi $s5, $zero, 31	#shift right amount
	add $s6, $zero, $zero	#used as value for 8 bits to print

	#used to read 8 bits for a line
	bitLine:
	lbu $t0, 0($s1)		#load the first byte
	sll $t0, $t0, 8		
	lbu $t1, 1($s1)		#load the second byte
	or $t0, $t1, $t0
	sll $t0, $t0, 8
	lbu $t1, 2($s1)		#load the third byte
	or $t0, $t0, $t1
	sll $t0, $t0, 8
	lbu $t1, 3($s1)		#load the fourth byte
	or $t0, $t0, $t1
	add $a0, $t0, $zero	#argument for word to pass
	add $a1, $s4, $zero	#argument for shift left amount
	add $a2, $s5, $zero	#argument for shift right amount
	add $a3, $s6, $zero	#argument for value to print
	jal getCurrentBit
	addi $s3, $s3, -1	#decrement counter of 8
	add $s6, $v0, $zero	#update value to print
	beq $s3, $zero, complete	#if it was done 8 times, finished
	sub $s1, $s1, $t3	#subtract num of bytes in a row to go to next row
	add $t4, $t3, $t4	#used to count how far address has changed
	j bitLine
	complete:
	beq $t2, $zero, positive
	nor $s6, $s6, $zero
	positive:
	add $a0, $zero, $s6	
	jal print
	addi $s2, $s2, -1		#decrement columns
	beq $s2, $zero, maxWidth	#if at max cols, go to rows
	
	bne $s5, $zero, noChange
	addi $s1, $s1, 4
	addi $s5, $zero, 31		#if all bits of word used, go to next word
	addi $s4, $zero, 0
	j changed
	noChange:
	addi $s4, $s4, 1		#update shift left amount if not at end of row
	addi $s5, $s5, -1		#update shift right amount if not at end of row
	
	changed:
	add $s1, $s1, $t4		#reset word you are looking at
	add $s6, $zero, $zero		
	addi $s3, $zero, 8		#reset counter
	add $t4, $zero, $zero
	j bitLine
	
	maxWidth:
	addi $s6, $zero, 480	#width you need to go
	sub $s6, $s6, $t5	#subtract maxwidth of pixels
	add $s3, $zero, $zero
	emptyPrint:
	beq $s6, $zero, checkRows
	add $a0, $s3, $zero
	jal print
	addi $s6, $s6, -1
	j emptyPrint
	
	checkRows:
	addi $s7, $s7, -8	#decrement rows
	slt $s0, $s7, $zero
	bne $s0, $zero, doneReading #if at max rows, go to finalCheck
	addi $s3, $zero, 8	#counter for number of iterations
	addi $s4, $zero, 0	#shift left amount
	addi $s5, $zero, 31	#shift right amount
	add $s6, $zero, $zero	#used as value for 8 bits to print
	
	sub $s1, $s1, $t3
	sub $s1, $s1, $t3
	addi $s1, $s1, 4

	add $t4, $zero, $zero	#reset offset
	add $s2, $t5, $zero	#reset width counter
	j bitLine
	#if no more bits to read in a word

doneReading:

	lw $ra, 28($sp)
	lw $s0, 24($sp)
	lw $s1, 20($sp)
	lw $s2, 16($sp)
	lw $s3, 12($sp)
	lw $s4, 8($sp)
	lw $s5, 4($sp)
	lw $s6, 0($sp)
	addi $sp, $sp, 32
	
	jr $ra
	
	
#arguments
#$a0 is the line to print
#return nothing
print:	
	addi $t9, $zero, 0		#clear $t9 to 0
	add $t8, $zero, $a0		#set $t8 to line to print
	addi $t9, $zero, 1		#print line
wait:	bne $t9, $zero, wait		#wait until $t9 is back to 0
	jr $ra				#return to caller
		
	
#arguments
#$a0 is a word of bytes
#$a1 is the shift amount left
#$a2 is the shift amount right
#$a3 is the 8-bit value to be changed
#return the 8 bit thing to print
getCurrentBit:

	add $t0, $a0, $zero
	sllv $t0, $t0, $a1	#shift left by value in $a1 to clear left bits
	srlv $t0, $t0, $a1	#shift back to normal place
	srlv $t0, $t0, $a2	#shift right to get msb
	sll $t1, $a3, 1		#shift left to insert new value
	or $t1, $t0, $t1	#add new value to insert
	add $v0, $t1, $zero	#place in $v0 to return
	jr $ra
	
#######used to get user input, and remove null character
readString:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	

	addi $v0, $zero, 8
	la $a0, buffer
	addi $a1, $zero, 100
	syscall		#read in string
	#string placed in buffer
	
	#2. get rid of lnefeed character at the end
	addi $t0, $zero, 0
	addi $t2, $zero, 10
	remove:
	lb $t1, buffer($t0)
	beq $t1, $t2, valfound 			#remove enter if $t1 = enter's value
	addi $t0, $t0, 1
	bne $t1, $zero, remove			 #repeat until at end of string 
	
	valfound:
	sb $zero, buffer($t0)
	
	la $a0, buffer			#set argument to string location
	jal _strLength
	add $t0, $v0, $zero 		#store the length of the string in $s0
	
	#3. allocate region in heap for storing this string
	addi $v0, $zero, 9		#create heap syscall
	add $a0, $zero, $t0		#place the number of bits returned from length
	syscall
	add $s0, $zero, $v0  		#$t0 is the address of the memory
	
	
	#4.copy string from temporary buffer to the memory allocated in previous step
	la $a0, ($s0)			#place heap address in $a0
	la $a1, buffer			#place string address in $a1
	jal _strCopy
	
	#5. return the memory address of the input string (in heap) using the register $v0
	add $v0, $zero, $s0
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

_strLength:
	#adjust stack pointer

	add $t0, $a0, $zero		 #set $a0 to address of string
	addi $t1, $zero, 0 		#counter for number of characters
	continue:
	lb $t3, ($t0)			#load the first byte
	addi $t1, $t1, 1		#increment number of characters
	addi $t0, $t0, 1		#shift to look at next byte
	bne $t3, $zero, continue	#look at next byte until null reached	
	add $v0, $zero, $t1		#set $v0 to number of characters + null character
	jr   $ra
	

##Arguments:
#   - $a0: An address of a destination
#   - $a1: An address of a source
# Return Value:
#   None
_strCopy:
	#save registers
	addi $sp $sp, -4		#adjust stack	
	sw $s0, 0($sp)			# store $s0
	add $t0, $zero, $a0 		#destination in t0
	add $t1, $zero, $a1		#address of string in $a1
	copyAgain:
	lb $t2, ($t1)			#load byte from string
	sb $t2, ($t0)			#store byte to heap
	addi $t0, $t0, 1		#go to next spot in heap
	addi $t1, $t1, 1		#go to next byte from string
	bne $t2, $zero, copyAgain	#if not at null char go to next byte
	
	#restore registers
	lw $s0, 0($sp)			#restore $s0
	addi $sp, $sp, 4		#adjust stack
	
	jr   $ra
