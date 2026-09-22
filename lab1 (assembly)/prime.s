.data
input_msg: .asciiz "Please input a number: "
prime_msg: .asciiz "It's a prime\n"
not_prime_msg: .asciiz "It's not a prime\n"

.text
.globl main

main:
	#print the input_msg
	li $v0, 4
	la $a0, input_msg
	syscall

	#Read input
	li $v0, 5
	syscall
	move $t0, $v0

	#check if the number is prime
	jal prime
	move $t1, $v0

	#print the result
	li $v0, 4
	beq $t1, 1, print_prime
	la $a0, not_prime_msg
	syscall
	j end

print_prime:
	la $a0, prime_msg
	syscall

end:
	li $v0, 10
	syscall

prime:
	move $t2, $t0
	li $v0, 1

	#check if number is 0
	beq $t2, $zero, not_prime
	
	#check if number is 1
	li $t3, 1
	beq $t2, $t3, not_prime

	#check start from 2 to sqrt(n)
	li $t4, 2

check_loop:
	mul $t5, $t4, $t4
	bgt $t5, $t2, end_prime_check

	# check if n%i==0
	rem $t6, $t2, $t4
	beq $t6, $zero, not_prime

	addi $t4, $t4, 1
	j check_loop

not_prime:
	li $v0, 0

end_prime_check:
	jr $ra
