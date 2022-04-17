.data
n_1 : .word 0
_t1_1 : .word 0
_t2_1 : .word 0
_t3_2 : .word 0
_t4_1 : .word 0
_t5_1 : .word 0
_t6_3 : .word 0
_t7_1 : .word 0
_t8_1 : .word 0
_t9_4 : .word 0
_t10_1 : .word 0
_t11_1 : .word 0
_t12_1 : .word 0
_t13_1 : .word 0
_t14_1 : .word 0
_t15_1 : .word 0
_t16_1 : .word 0
_t17_5 : .word 0
res_5 : .word 0
.text 
.globl main 
main:
jal label12
li $v0, 10
syscall
label1:
li $8, 0
sw $8, _t1_1
lw $8, n_1
lw $9, _t1_1
ble $8, $9, label2
li $8, 0
sw $8, _t2_1
j label3
label2:
li $8, 1
sw $8, _t2_1
label3:
lw $8, _t2_1
beqz $8, label4
li $8, 0
sw $8, _t3_2
j label5
label4:
li $8, 1
sw $8, _t4_1
lw $8, n_1
lw $9, _t4_1
beq $8, $9, label6
li $8, 0
sw $8, _t5_1
j label7
label6:
li $8, 1
sw $8, _t5_1
label7:
lw $8, _t5_1
beqz $8, label8
li $8, 1
sw $8, _t6_3
j label5
label8:
li $8, 2
sw $8, _t7_1
lw $8, n_1
lw $9, _t7_1
beq $8, $9, label9
li $8, 0
sw $8, _t8_1
j label10
label9:
li $8, 1
sw $8, _t8_1
label10:
lw $8, _t8_1
beqz $8, label11
li $8, 1
sw $8, _t9_4
j label5
label11:
label5:
li $8, 1
sw $8, _t10_1
lw $8, n_1
lw $9, _t10_1
sub $10, $8, $9
sw $10, _t11_1
jal label1
li $8, 2
sw $8, _t13_1
lw $8, n_1
lw $9, _t13_1
sub $10, $8, $9
sw $10, _t14_1
jal label1
lw $8, _t12_1
lw $9, _t15_1
add $10, $8, $9
sw $10, _t16_1
label12:
jal label1
lw $8, _t17_5
sw $8, res_5
li $2, 1
lw $4, res_5
syscall
li $2, 11
lb $4, 10
syscall
li $v0, 10
syscall
