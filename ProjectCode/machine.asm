.data
_t_9: .word 0
.text 
.globl main 
main:

 #code starts

 #int _t_9 = #1
li $8, 1
lw $9, =
mul $8, $8, $9
lw $9, #1
mul $8, $8, $9
li $10, 4
mul $8, $8, $10
li $2, 9
move $4, $8
syscall
sw $2, _t_9
li $v0, 10
syscall
