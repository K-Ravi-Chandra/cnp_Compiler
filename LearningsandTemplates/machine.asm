.data
.text 
.globl main 
main:

#funCall main.main

#call label12
addiu $sp, $sp, 16
jal label12

#exit
li $v0, 10
syscall

#label1:
label1:

#function start main.fibonacci

#_t1_1 =i #0
li $8, 0
sw $8, 8($sp)

#if ( n_1 <=i _t1_1 ) goto label2
lw $8, 4($sp)
lw $9, 8($sp)
ble $8, $9, label2

#_t2_1 =b #false
li $8, 0
sw $8, 12($sp)

#goto label3
j label3

#label2:
label2:

#_t2_1 =b #true
li $8, 1
sw $8, 12($sp)

#label3:
label3:

#if ( _t2_1 !=b #true ) goto label4
lw $8, 12($sp)
beqz $8, label4

#_t3_2 =i #0
li $8, 0
sw $8, 13($sp)

#return _t3_2

#goto label5
j label5

#label4:
label4:

#_t4_1 =i #1
li $8, 1
sw $8, 17($sp)

#if ( n_1 ==i _t4_1 ) goto label6
lw $8, 4($sp)
lw $9, 17($sp)
beq $8, $9, label6

#_t5_1 =b #false
li $8, 0
sw $8, 21($sp)

#goto label7
j label7

#label6:
label6:

#_t5_1 =b #true
li $8, 1
sw $8, 21($sp)

#label7:
label7:

#if ( _t5_1 !=b #true ) goto label8
lw $8, 21($sp)
beqz $8, label8

#_t6_3 =i #1
li $8, 1
sw $8, 22($sp)

#return _t6_3

#goto label5
j label5

#label8:
label8:

#_t7_1 =i #2
li $8, 2
sw $8, 26($sp)

#if ( n_1 ==i _t7_1 ) goto label9
lw $8, 4($sp)
lw $9, 26($sp)
beq $8, $9, label9

#_t8_1 =b #false
li $8, 0
sw $8, 30($sp)

#goto label10
j label10

#label9:
label9:

#_t8_1 =b #true
li $8, 1
sw $8, 30($sp)

#label10:
label10:

#if ( _t8_1 !=b #true ) goto label11
lw $8, 30($sp)
beqz $8, label11

#_t9_4 =i #1
li $8, 1
sw $8, 31($sp)

#return _t9_4

#goto label5
j label5

#label11:
label11:

#label5:
label5:

#funCall main.fibonacci

#_t10_1 =i #1
li $8, 1
sw $8, 35($sp)

#_t11_1 =i n_1 -i _t10_1
lw $8, 4($sp)
lw $9, 35($sp)
sub $10, $8, $9
sw $10, 39($sp)

#param _t11_1

#call label1
addiu $sp, $sp, 63
jal label1

#_t12_1 = returnVal

#funCall main.fibonacci

#_t13_1 =i #2
li $8, 2
sw $8, 47($sp)

#_t14_1 =i n_1 -i _t13_1
lw $8, 4($sp)
lw $9, 47($sp)
sub $10, $8, $9
sw $10, 51($sp)

#param _t14_1

#call label1
addiu $sp, $sp, 63
jal label1

#_t15_1 = returnVal

#_t16_1 =i _t12_1 +i _t15_1
lw $8, 43($sp)
lw $9, 55($sp)
add $10, $8, $9
sw $10, 59($sp)

#return _t16_1

#return

#function end main.fibonacci

#label12:
label12:

#function start main.main

#funCall main.fibonacci

#param n_5

#call label1
addiu $sp, $sp, 63
jal label1

#_t17_5 = returnVal

#res_5 =i _t17_5
lw $8, 4($sp)
sw $8, 8($sp)

#print int res_5
li $2, 1
lw $4, 8($sp)
syscall

#print newline
lb $4, 10
li $2, 11
syscall

#return

#function end main.main
li $v0, 10
syscall
