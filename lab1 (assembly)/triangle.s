.data
prompt1: .asciiz "Please enter option (1: triangle, 2: inverted triangle): "
prompt2: .asciiz "Please input a triangle size: "
newline: .asciiz "\n"
space: .asciiz " "
star: .asciiz "*"

.text
.globl main

main:
    # Print the first prompt
    li $v0, 4
    la $a0, prompt1
    syscall

    # Read the option (1 or 2)
    li $v0, 5
    syscall
    move $t0, $v0  # Store option in $t0

    # Print the second prompt
    li $v0, 4
    la $a0, prompt2
    syscall

    # Read the triangle size
    li $v0, 5
    syscall
    move $t1, $v0  # Store size in $t1

    # Initialize loop counter
    li $t2, 0  # i = 0

loop:
    bge $t2, $t1, end_loop  # if (i >= n) break

    # Check option
    beq $t0, 1, option1
    beq $t0, 2, option2

option1:
    move $t3, $t2  # l = i
    j print_layer

option2:
    sub $t3, $t1, $t2
    addi $t3, $t3, -1  # l = n - i - 1
    j print_layer

print_layer:
    # Print spaces
    sub $t4, $t1, $t3  # t4 = n - l
    li $t5, 1

space_loop:
    bge $t5, $t4, print_stars  # if (j >= n-l) break

    # Print space
    li $v0, 4
    la $a0, space
    syscall

    addi $t5, $t5, 1
    j space_loop

print_stars:
    # Print stars
    add $t6, $t1, $t3  # t6 = n + l

star_loop:
    bgt $t5, $t6, print_newline  # if (j > n+l) break

    # Print star
    li $v0, 4
    la $a0, star
    syscall

    addi $t5, $t5, 1
    j star_loop

print_newline:
    # Print newline
    li $v0, 4
    la $a0, newline
    syscall

    # Increment loop counter
    addi $t2, $t2, 1
    j loop

end_loop:
    # Exit program
    li $v0, 10
    syscall

