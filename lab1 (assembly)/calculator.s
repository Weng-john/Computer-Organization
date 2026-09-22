.data
input_msg: .asciiz "Please enter option (1: add, 2: sub, 3: mul): "
firstNum_msg: .asciiz "Please enter the first number: "
secondNum_msg: .asciiz "Please enter the second number: "
result_msg: .asciiz "The calculation result is: "
newline: .asciiz "\n"

.text
.globl main
main:
	# Print the input msg
	li $v0, 4
	la $a0, input_msg
	syscall

	# Read the operation option
	li $v0, 5
	syscall
	move $t0, $v0

	# Print the firstNum msg
	li $v0, 4
	la $a0, firstNum_msg
	syscall

	# Read the firstNum
	li $v0, 5
	syscall
	move $t1, $v0

	# Print the secondNum msg
	li $v0, 4
	la $a0, secondNum_msg
	syscall

	# Read the secondNum
	li $v0, 5
	syscall
	move $t2, $v0

	# based on the option to select function
	li $v0, 0
	beq $t0, 1, add_opt
	beq $t0, 2, sub_opt
	beq $t0, 3, mul_opt
	
        # behavior not define
        li $v0, 10
        syscall

add_opt:
	add $t3, $t1, $t2
	j print_result

sub_opt:
	sub $t3, $t1, $t2
	j print_result

mul_opt:
	mul $t3, $t1, $t2

print_result:
	# Print the result message
	li $v0, 4
	la $a0, result_msg
	syscall

	# Print the calculation result
	li $v0, 1
	move $a0, $t3
	syscall

	# Print newline
	li $v0, 4
	la $a0, newline
	syscall

	# Exit the program
	li $v0, 10
	syscall

