.data
	userInput: .asciiz "Enter a number between 0 and 9: "
	lowGuess: .asciiz "Your guess is too low."
	highGuess: .asciiz "Your guess was too high."
	lose: .asciiz "You lose. The number was "
	winOutput: .asciiz "Congratulation! You win!"
	
.text

#generate random number code
addi $v0, $zero, 30   #get time
syscall
add $s1, $zero, $a0 #place time in $s1

addi $v0, $zero, 40
addi $a0, $zero, 0
add $a1, $zero, $s1     #set $a1 to seed value
syscall     		#set seed for random number generator

#generate random number
addi $v0, $zero, 42	#Syscall 42: Random int range
addi $a0, $zero, 0	#Set RNG ID to 0
addi $a1, $zero, 10	#Set upper bound to 10 exclusive
syscall			#Generate a random number and put in $a0
add $s3, $a0, $zero	#copy the number to $s3

addi $s5, $zero, 3 	#counter for loop


loop:
beq $s5, $zero, gameOver

addi $v0, $zero, 4  #Syscall 4: print string
la $a0, userInput  #$a0 = address of the user prompt
syscall		#print the string userInput

#get user input
addi $v0, $zero, 5     #Syscall 5: read integer from user
syscall			#place value in register $v0
add $s0, $zero, $v0	#move value from user to register $s0

beq $s0, $s3, win #if value guesses is correct go to win
slt $t0, $s0, $s3  #set $t1 to 1 if guess less than random num
bne $t0, $zero, low #go to low guess statement, otherwise go through high

#high guess
addi $v0, $zero, 4  #Syscall 4: print string
la $a0, highGuess #$a0 = address of the low guess
syscall		#print the string userInput

addi $s5, $s5, -1 #decrement counter

#new line
addi $v0, $zero, 11
addi $a0, $zero, 10
syscall

j loop # go back to loop

low:
#low guess
addi $v0, $zero, 4  #Syscall 4: print string
la $a0, lowGuess #$a0 = address of the low guess
syscall		#print the string userInput

addi $s5, $s5, -1 #decrement counter

#new line
addi $v0, $zero, 11
addi $a0, $zero, 10
syscall

j loop #go back to loop

win:
#correct guess
addi $v0, $zero, 4  #Syscall 4: print string
la $a0, winOutput #$a0 = address of the winning  statement
syscall		#print the string userInput
j finished

#print losing string
gameOver:
addi $v0, $zero, 4 #Syscall 4: print string
la $a0, lose #$a0 = address of lose statement
syscall

#print random integer
addi $v0, $zero, 1	#Syscall 1: print Integer
add $a0, $zero, $s3     #set the value to print the random integer
syscall			#print the integer

finished:
#terminate programn
addi $v0, $zero, 10
syscall


