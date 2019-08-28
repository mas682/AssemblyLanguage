.data
	userInput: .asciiz "Please enter a positive integer: "
	negative: .asciiz "A negative integer is not allowed."
	userInput2: .asciiz "Please enter another positive integer: "
	
.text

#need to loop so will keep repeating if value negative

prompt:
addi $v0, $zero, 4  #Syscall 4: print string
la $a0, userInput  #$a0 = address of the user prompt
syscall		#print the string userInput

#get user input
addi $v0, $zero, 5     #Syscall 5: read integer from user
syscall			#place value in register $v0

slt $t1, $v0, $zero #set $t1 to 1 if value negative
beq $t1, $zero, nextVal #if value negative reprompt

addi $v0, $zero, 4 #print string
la $a0, negative #print string labeled negative
syscall

#new line
addi $v0, $zero, 11
addi $a0, $zero, 10
syscall

j prompt #repromt

nextVal:
add $s0, $zero, $v0	#move value from user to register $s0

prompt2:

addi $v0, $zero, 4  #Syscall 4: print string
la $a0, userInput2  #$a0 = address of the user prompt
syscall		#print the string userInput

#get user input
addi $v0, $zero, 5     #Syscall 5: read integer from user
syscall			#place value in register $v0

slt $t1, $v0, $zero #set $t1 to 1 if value negative
beq $t1, $zero, answer #if value negative, reprompt

addi $v0, $zero, 4 #print string
la $a0, negative #print string labeled negative
syscall

#new line
addi $v0, $zero, 11
addi $a0, $zero, 10
syscall

j prompt2 #reprompt

answer:
add $s1, $zero, $v0	#move value from user to register $s0

#multiplicaion
#multiplicand in $s0
#multiplier in $s1

add $t0, $zero, $s0
add $t1, $zero, $s1
add $t3, $zero, $zero #productuct register
addi $t5, $t5, 32
 
repeat: 
sll $t4, $t1, 31
srl $t4, $t4, 31

beq $t4, $zero, update 
add $t3, $t0, $t3 #if value multiplying
bne $t5, $zero, update
beq $t5, $zero, done

update:
sll $t0, $t0, 1
srl $t1, $t1, 1
addi $t5, $t5, -1
bne $t5, $zero, repeat

done:

#exponential

beq $s1, $zero, zero#if to power 0, skip
addi $t8, $zero, 1
beq $s1, $t8, itself #value not multiplied at all
beq $s0, $t8, itself #value to be multiplied is one

add $t7, $s1, $zero #set number of times to repeat
addi $t7, $t7, -1 #decrement number of times to repeat by 1

add $t9, $zero, $s0
again:#outter loop to multiply again

add $t0, $zero, $t9 #number to multiply
add $t1, $zero, $s0#multiplier
add $t6, $zero, $zero #product register for inside loop
addi $t5, $t5, 32 #inner loop counter

repeat1:
sll $t4, $t1, 31 #for multiplier
srl $t4, $t4, 31

beq $t4, $zero, update1
add $t6, $t0, $t6
bne $t5, $zero, update1
beq $t5, $zero, done1

update1:
sll $t0, $t0, 1
srl $t1, $t1, 1
addi $t5, $t5, -1
bne $t5, $zero, repeat1

done1:

add $t9, $t6, $zero
addi $t7, $t7, -1
bne $t7, $zero, again
beq $t7, $zero, finished

zero:
addi $t6, $t6, 1
j finished

itself:
add $t6, $s0, $zero
j finished

finished:

#print first operand
addi $v0, $zero, 1	#Syscall 1: print Integer
add $a0, $zero, $s0     #set the value to print the first operand
syscall			#print the integer

#print multiplication symbol
addi $v0, $zero, 11	#Syscall 1: print Integer
addi $a0, $zero, 42    #set the value to *
syscall			#print the integer

#print second operand
addi $v0, $zero, 1	#Syscall 1: print Integer
add $a0, $zero, $s1    #set the value to print second operand
syscall			#print the integer

#print equals
addi $v0, $zero, 11	#Syscall 1: print Integer
addi $a0, $zero, 61    #set the value to =
syscall			#print the integer

#print product
addi $v0, $zero, 1	#Syscall 1: print Integer
add $a0, $zero, $t3     #set the value to print the product
syscall			#print the integer

#new line
addi $v0, $zero, 11
addi $a0, $zero, 10
syscall

#print first operand
addi $v0, $zero, 1	#Syscall 1: print Integer
add $a0, $zero, $s0     #set the value to print the first operand
syscall			#print the integer

#print exponential symbol
addi $v0, $zero, 11	#Syscall 1: print Integer
addi $a0, $zero, 94     #set the value to ^
syscall			#print the integer

#print second operand
addi $v0, $zero, 1	#Syscall 1: print Integer
add $a0, $zero, $s1    #set the value to print second operand
syscall			#print the integer

#print equals
addi $v0, $zero, 11	#Syscall 1: print Integer
addi $a0, $zero, 61    #set the value to =
syscall			#print the integer


#print exponential value
addi $v0, $zero, 1	#Syscall 1: print Integer
add $a0, $zero, $t6    #set the value to print the exponential
syscall			#print the integer

#terminate programn
addi $v0, $zero, 10
syscall
