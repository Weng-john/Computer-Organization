.data
input_msg: .asciiz "Please input a number: "
result_msg: .asciiz "The result of fibonacci(n) is "
newline: .asciiz "\n"

.text
.globl main

main:
	li $v0, 4
	la $a0, input_msg
	syscall

	li $v0, 5
	syscall
	move $a0, $v0

	add $v0, $zero, $zero
	jal fib
	move $t0, $v0

	li $v0, 4
	la $a0, result_msg
	syscall

	move $a0, $t0
	li $v0, 1
	syscall

	li $v0, 4
	la $a0, newline
	syscall

	li $v0, 10
	syscall

fib:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)

	slti $t0, $a0, 2          # if n < 2 then $t0 = 1, else $t0 = 0
	beq $t0, $zero, L1        # if $t0 == 0 then jump to branch L1
	add $v0, $v0, $a0
	addi $sp, $sp, 8
	jr $ra

L1:
	addi $a0, $a0, -1
	jal fib                   # return f(n - 1)
	addi $a0, $a0, -1
	jal fib                   # return f(n - 2)
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi, $sp, $sp, 8
	jr $ra
