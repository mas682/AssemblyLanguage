.data
	sumTitle:	.asciiz	"Summation: sum(n)\n"
	integer_n:	.asciiz	"Please enter an integer (greater than or equal to 0): "
	sumResult:	.asciiz	"sum("
	powTitle:	.asciiz	"Power: pow(x,y)\n"
	integer_x:	.asciiz	"Please enter an integer for x (greater than or equal to 0): "
	integer_y:	.asciiz	"Please enter an integer for y (greater than or equal to 0): "
	powResult:	.asciiz "pow("
	comma:		.asciiz	","
	fTitle:		.asciiz	"Fibonacci: F(n)\n"
	fResult:	.asciiz	"F("
	isMsg:		.asciiz	") is "
	period:		.asciiz ".\n"
.text
	# Sum
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, sumTitle		# Set $a0 to sumTitle
	syscall				# Print "Summation..."
	la   $a0, integer_n		# Set $a0 to integer_n
	syscall				# Print "Please..."
	addi $v0, $zero, 5		# Syscall 5: Read integer
	syscall				# Read an integer
	add  $s0, $zero, $v0		# $s0 is n
	add  $a0, $zero, $s0		# Set argument for _sum
	jal  _sum			# Call the _sum function
	add  $s1, $zero, $v0		# $s1 = sum(n)
	# Print result (sum)
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, sumResult		# Set $a0 to sumResult
	syscall				# Print "sum("
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s0		# Set $a0 to n
	syscall				# Print n
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, isMsg			# Set $a0 to isMsg
	syscall				# Print ") is "
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s1		# Set $a0 to result of sum
	syscall				# Print result
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, period		# Set $a0 to period
	syscall				# Print ".\n"

	# Power
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, powTitle		# Set $a0 to powTitle
	syscall				# Print "Summation..."
	la   $a0, integer_x		# Set $a0 to integer_x
	syscall				# Print "Please..."
	addi $v0, $zero, 5		# Syscall 5: Read integer
	syscall				# Read an integer
	add  $s0, $zero, $v0		# $s0 is x
	addi $v0, $zero, 4		# Syscall 4: Print string	
	la   $a0, integer_y		# Set $a0 to integer_y
	syscall				# Print "Please..."
	addi $v0, $zero, 5		# Syscall 5: Read integer
	syscall				# Read an integer
	add  $s1, $zero, $v0		# $s1 is y
	add  $a0, $zero, $s0		# Set argument x for _pow
	add  $a1, $zero, $s1		# Set argument y for _pow
	jal  _pow			# Call the _pow function
	add  $s2, $zero, $v0		# $s2 = pow(x,y)
	# Print result (pow)
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, powResult		# Set $a0 to powResult
	syscall				# Print "pow("
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s0		# Set $a0 to x
	syscall				# Print x
	addi $v0, $zero, 4		# Syscal 4: Print string
	la   $a0, comma			# Set $a0 to comma
	syscall				# Print ","
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s1		# Set $a0 to y
	syscall				# Print y
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, isMsg			# Set $a0 to isMsg
	syscall				# Print ") is "
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s2		# Set $a0 to result of pow
	syscall				# Print result
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, period		# Set $a0 to period
	syscall				# Print ".\n"

	# Fibonacci
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, fTitle		# Set $a0 to fTitle
	syscall				# Print "Fibonacci..."
	la   $a0, integer_n		# Set $a0 to integer_n
	syscall				# Print "Please..."
	addi $v0, $zero, 5		# Syscall 5: Read integer
	syscall				# Read an integer
	add  $s0, $zero, $v0		# $s0 is n
	add  $a0, $zero, $s0		# Set argument for _fibonacci
	jal  _fibonacci			# Call the _fabonacci function
	add  $s1, $zero, $v0		# $s1 = fibonacci(n)
	# Print result (fibonacci)
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, fResult		# Set $a0 to sumResult
	syscall				# Print "F("
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s0		# Set $a0 to n
	syscall				# Print n
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, isMsg			# Set $a0 to isMsg
	syscall				# Print ") is "
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s1		# Set $a0 to result of fibonacci
	syscall				# Print result
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, period		# Set $a0 to period
	syscall				# Print ".\n"
	# Terminate Program
	addi $v0, $zero, 10		# Syscall 10: Terminate program
	syscall				# Terminate Program

# _sum
#
# Recursively calculate summation of a given number
#   sum(n) = n + sum(n - 1)
# where n >= 0 and sum(0) = 0.
#
# Argument:
#   $a0 - n
# Return Value:
#   $v0 = sum(n)
_sum:
	addi $sp, $sp, -8
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	
	add $s0, $a0, $zero 	#add the argument to $s0
	addi $t1, $zero, -1	#used to determine if n = -1
	beq $s0, $t1, done 	#if n < 0, return
	addi $t0, $s0, -1	#send n-1
	add $a0, $t0, $zero	#add new n value to argument
	add $v0, $zero, $zero
	jal _sum 		#go to sum
	add $v0, $v0, $s0	#on return, add the return value + n
	done:
	lw $s0, 4($sp)		#restore registers
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	#restore registers
	jr   $ra

# _pow
#
# Recursively calculate x^y
#   x^y = x * (x^(y - 1))
# where x >= 0 and y >= 0
#
# Arguments:
#   - $a0 - x
#   - $a1 - y
# Return Value
#   - $v0 = x^y
_pow:	
	#store registers
	addi $sp, $sp, -12
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $ra, 0($sp)
	
	add $v0, $zero, $zero
	add $s0, $a0, $zero	#store x in $s0
	add $s1, $a1, $zero	#store y in $s1
	addi $t0, $s1, -1	#decrement y value
	addi $t1, $zero, -1	#used to determine when to return
	beq  $t1, $s1, finishedPOW
	add $a1, $t0, $zero
	jal _pow
	multiply:
	beq $s1, $zero, zero
	mult $s0, $v0
	mflo $t7
	add $v0, $t7, $zero
	j finishedPOW

	zero:
	addi $v0, $v0, 1
	
	finishedPOW:
	lw $s0, 8($sp)
	lw $s1, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	
	jr   $ra

# _fibonacci
#
# Calculate a Fibonacci number (F) where
#   F(0) = 0
#   F(1) = 1
#   F(n) = F(n - 1) + F(n - 2)
# Argument:
#   $a0 = n
# Return Value:
#   $v0 = F(n)
_fibonacci:
    	addi $sp, $sp, -12            # Allocate activation frame
      	sw   $s1, 8($sp)              # Backup $s1
      	sw   $s0, 4($sp)                # Backup $s0
      	sw   $ra, 0($sp)                 # Backup $ra
 	add  $s0, $zero, $a0               # $s0 is n
  	beq  $s0, 0000, returnZero2  # Check whether n == 0
     	beq  $s0, 0001, returnOne2    # Check if n == 1
    	addi $a0, $s0, -1
   	jal _fibonacci
 	addi $s1, $v0, 0
        addi $a0, $s0, -2
        jal _fibonacci
        add  $v0, $v0, $s1
 
   return3:
  	lw $s1, 8($sp)                 # Restore $s1
 	lw $s0, 4($sp)                  # Restore $s0
 	lw $ra, 0($sp)                  # Restore $ra
 	addi $sp, $sp, 12                 # Deallocate activation frame
 	jr $ra                                 # Go back to caller
	      
   returnOne2:
       addi $v0, $zero, 1           # Set return value to 1
       j return3
        
   returnZero2:
       addi $v0, $zero, 0            # Set return value to 0
       j return3
	
jr   $ra
	
