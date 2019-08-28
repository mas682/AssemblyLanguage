.text

wait: beq $t9, $zero, wait
add $s0, $zero, $a0 #store A in $s0
add $s1, $zero, $a1 #store B in $s1
 
#addition/subtraction
add $s2, $s0, $s1 #add A + B and place in $s2
sub $s3, $s0, $s1 #subtract A - B and place in $s3
add $v0, $zero, $s3 #place subtraction result in rightmost 16 bits
sll $v0, $v0, 16 #shift subtraction to leftmost 16 bits
andi $s2, $s2, 0xffff
or $v0, $v0, $s2 #add addtion result to leftmost 16 bits of $v0

#multiplication
add $t0, $zero, $s0 	#multiplicand
add $t1, $zero, $s1	 #multiplier
srl $t8, $t0,31		#get msb of multiplicand to determine if negative
srl $t2, $t1,31		#get msb of multiplier to determine if negative
add $s4, $t8, $t2
beq $s4, $zero, notNegative	#if $s4, = 0, neither value is negative
#negatite the values
beq $t8, $zero, nextVal		#if $s0 = 0, value not negative
#negate multiplicand
nor $t0, $zero, $t0		#negate $t0
addi $t0, $t0, 1		#add 1 to negatition
nextVal:
beq $t2, $zero, notNegative	#if value = 0, value not negative
#negate multiplier
nor $t1, $zero, $t1		#negate $t1
addi $t1, $t1, 1		#add 1 to negation
notNegative:
add $t3, $zero, $zero 	#productuct register
addi $t5, $zero, 16 	#number of iterations #changed to $zero
repeat: 
sll $t4, $t1, 31 #check to see if LSB is 0 or 1
srl $t4, $t4, 31
beq $t4, $zero, update #if LSB is 0 do not add
addu $t3, $t0, $t3 #if LSB is 1, add
update:
sll $t0, $t0, 1 #shift left multiplicand
srl $t1, $t1, 1 #shift right multiplier
addi $t5, $t5, -1
bne $t5, $zero, repeat
done:
add $t4, $t3, $zero 
beq $s4, $zero, FINAL
addi $t0, $zero, 2
beq $s4, $t0, FINAL
nor $t4, $zero, $t4	#negate value
addi $t4, $t4, 1	#add 1 to negation
FINAL:
srl $t4, $t4, 8 #result of mult.
add $s7, $t4, $zero

#division
add $t0, $zero, $zero #quotient
add $t1, $zero, $s0 #remainder register
add $t3, $zero, $s1 #divisor
addi $t2, $zero, 1 #iteration counter for division
addi $t6, $zero, 17
srl $t4, $t1, 31	#get msb of remainder
srl $t5, $t3, 31	#get msb of divisor 
add $t8, $t4, $t5	#add the result of seeing if 2 values less than each other
add $s3, $t8, $zero
beq $t8, $zero, divide1	#if neither value negative, go to divide
#negatitve values
beq $t4, $zero, divisor	#if $t4 = 0, remainder not negative so go to divisor
#otherwise negate remainder
nor $t1, $zero, $t1	#negate remainder
addi $t1, $t1, 1	#add 1 to remainder negation
divisor:
beq $t5, $zero, divide1	#if divisor not negative, go to divide
#otherwise negate divisor
nor $t3, $zero, $t3	#negate divisor
addi $t3, $t3, 1	#add 1 to negation of divisor
divide1:
add $s4, $t3, $zero
divide:
add $t0, $zero, $zero
sll $t3, $t3, 16
start:
sub $t1, $t1, $t3 #subtract divisor from remainder, place in remainder
slt $t5, $t1, $zero #set $t5 to 1 if remainder negative
bne $t5, $zero, less #if remainder < 0, go to less
sll $t0, $t0, 1
addi $t0, $t0, 1 #set LSB in quotient to 1
j next
#remainder less than 0
less:
add $t1, $t1, $t3 #restore remainder register
sll $t0, $t0, 1 #set LSB to 0 in quotient
next:
srl $t3, $t3, 1 #shift divisor right one bit
addi $t6, $t6, -1
bne $t6, $zero, start
slti $t8, $t2, 1 #see if only divided once or twice
beq $t8, $zero, firstDivision #update $s6 if first division
j change #on second division so skip ahead
firstDivision:
sll $s6, $t0, 8 #first division value
sll $t1, $t1, 8
add $t3, $s4, $zero
addi $t6, $zero, 17 #not sure why it has to be 16 instead of 17?
change:
beq $t2, $zero, final #if second division, finished
addi $t2, $t2, -1 #decrement number of divisions
j divide #divide remainder

final:
or $s6, $t0, $s6
beq $s3, $zero, FINAL1	#VALUES NOT NEGATIVE
addi $s5, $zero, 2
beq $s3, $s5, FINAL1	#values already in correct form
nor $s6, $zero, $s6	#negate answer
addi $s6, $s6, 1	#add 1 to negation
FINAL1:
add $v1, $s6, $zero
sll $v1, $v1, 16
sll $s7, $s7, 16	#set leftmost 16 bits of multiplication result to 0
srl $s7, $s7, 16
or $v1, $v1, $s7

#square root
add $t0, $zero, $s0	#value to get square root of
srl $s4, $t0, 31
beq $s4, $zero, nextStep
nor $t0, $t0, $zero	#negate the value to get square root of
addi $t0, $t0, 1	#add 1 to negation
nextStep:
addi $t1, $zero, 1	#multiplier
addi $t4, $zero, 12	#loop counter #changed from 8 to 12
addi $t5, $zero, 30	#shift right value
addi $t6, $zero, 16	#shift left value
addi $t8, $zero, 0	#$t8 used for answer
add $s5, $zero, $zero

sqroot:

sllv $t2, $t0, $t6	#shift left to clear leftmost bits
srlv $t7, $t2, $t5	#get first 2 bits by shifting right
or $s5, $s5, $t7	#add next two bits to square root
beq $t1, $s5, one	#jump to one if 2 values equal
slt $t3, $t1, $s5	#set $t3 to 1 if it is multiplier less than 2 bits
bne $t3, $zero, one
#if value greater than the 2 bits
addi $t1, $t1, -1 	#do not multiply, so place 0 in lsb of multiplier
sll $t8, $t8, 1		#place zero in lsb of solution
sll $s5, $s5, 2		#shift next value to be square rooted left to bring down 2 more bits
sll $t1, $t1, 1		#shift multipler to left one spot
addi $t1, $t1, 1	#place one in multiplier to test
addi $t6, $t6, 2
addi $t4, $t4, -1
bne $t4, $zero, sqroot
j sqRootFinal

#for this, just need to see if number is negative first, if so flip
one:
sll $t8, $t8, 1		#shift left, add one
addi $t8, $t8, 1	#place a one in solution lsb
subu $s5, $s5, $t1	#subtract multipler from sq root value
sll $s5, $s5, 2
addi $t1, $t1, 1	#add 1 to multiplier
sll $t1, $t1, 1		#shift multiplier left one spot
addi $t1, $t1, 1	#place one in multiplier
addi $t6, $t6, 2	#update $t6 to get next 2 bits
addi $t4, $t4, -1

bne $t4, $zero, sqroot

sqRootFinal:

add $a2, $t8, $zero

add $t0, $t0, $zero
add $t1, $t1, $zero
add $t2, $t2, $zero
add $t3, $t3, $zero
add $t4, $t4, $zero
add $t5, $t5, $zero
add $t6, $t6, $zero
add $t7, $t7, $zero
add $t8, $t8, $zero
add $s0, $s0, $zero
add $s1, $s1, $zero
add $s2, $s2, $zero
add $s3, $s3, $zero
add $s4, $s4, $zero
add $s5, $s5, $zero
add $s6, $s6, $zero
add $s7, $s7, $zero

add $t9, $zero, $zero
j wait
