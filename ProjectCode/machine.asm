.data
_s1: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s2: .asciiz "RUNTIME ERROR: Index is negative\n"
_s3: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s4: .asciiz "RUNTIME ERROR: Index is negative\n"
_s5: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s6: .asciiz "RUNTIME ERROR: Index is negative\n"
_s7: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s8: .asciiz "RUNTIME ERROR: Index is negative\n"
_s9: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s10: .asciiz "RUNTIME ERROR: Index is negative\n"
_s11: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s12: .asciiz "RUNTIME ERROR: Index is negative\n"
_s13: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s14: .asciiz "RUNTIME ERROR: Index is negative\n"
_s15: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s16: .asciiz "RUNTIME ERROR: Index is negative\n"
_s17: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s18: .asciiz "RUNTIME ERROR: Index is negative\n"
_s19: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s20: .asciiz "RUNTIME ERROR: Index is negative\n"
_s21: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s22: .asciiz "RUNTIME ERROR: Index is negative\n"
_s23: .asciiz "The array is: "
_s24: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s25: .asciiz "RUNTIME ERROR: Index is negative\n"
_s26: .asciiz " "
_s27: .asciiz "Sorted array is"
_s28: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s29: .asciiz "RUNTIME ERROR: Index is negative\n"
_s30: .asciiz " "
.text 
.globl main 
main:

#funCall main.main

#call label37
addiu $sp, $sp, -140
jal label37

#exit
li $v0, 10
syscall

#label1:
label1:

#function start main.partition

#setReturn
sw $ra, 0($sp)

#if ( high_1 <i _arr_1_1_1 ) goto label2
lw $8, 192($sp)
lw $9, 200($sp)
blt $8, $9, label2

#strconst _s1 _t1_1 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s1
sw $8, 188($sp)

#print string _t1_1
li $2, 4
lw $4, 188($sp)
syscall

#exit
li $v0, 10
syscall

#label2:
label2:

#if ( high_1 >=i #0 ) goto label3
lw $8, 192($sp)
li $9, 0
bge $8, $9, label3

#strconst _s2 _t2_1 #"RUNTIME ERROR: Index is negative\n"
la $8, _s2
sw $8, 184($sp)

#print string _t2_1
li $2, 4
lw $4, 184($sp)
syscall

#exit
li $v0, 10
syscall

#label3:
label3:

#_t3_1 =i high_1 *i #4
lw $8, 192($sp)
li $9, 4
mul $10, $8, $9
sw $10, 180($sp)

#_t3_1 =i arr_1 +i _t3_1
lw $8, 204($sp)
lw $9, 180($sp)
add $10, $8, $9
sw $10, 180($sp)

#pivot_1 =i *_t3_1
lw $8, 180($sp)
lw $8, ($8)
sw $8, 176($sp)

#_t4_1 =i #1
li $8, 1
sw $8, 172($sp)

#_t5_1 =i low_1 -i _t4_1
lw $8, 196($sp)
lw $9, 172($sp)
sub $10, $8, $9
sw $10, 168($sp)

#i_1 =i _t5_1
lw $8, 168($sp)
sw $8, 164($sp)

#j_2 =i low_1
lw $8, 196($sp)
sw $8, 160($sp)

#label4:
label4:

#if ( j_2 <=i high_1 ) goto label5
lw $8, 160($sp)
lw $9, 192($sp)
ble $8, $9, label5

#_t6_2 =b #false
li $8, 0
sw $8, 156($sp)

#goto label6
j label6

#label5:
label5:

#_t6_2 =b #true
li $8, 1
sw $8, 156($sp)

#label6:
label6:

#if ( _t6_2 !=b #true ) goto label9
lw $8, 156($sp)
beqz $8, label9

#goto label7
j label7

#label8:
label8:

#_t7_2 =i j_2
lw $8, 160($sp)
sw $8, 152($sp)

#j_2 =i j_2 +i #1
lw $8, 160($sp)
li $9, 1
addi $10, $8, 1
sw $10, 160($sp)

#goto label4
j label4

#label7:
label7:

#if ( j_2 <i _arr_1_1_1 ) goto label10
lw $8, 160($sp)
lw $9, 200($sp)
blt $8, $9, label10

#strconst _s3 _t8_2 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s3
sw $8, 148($sp)

#print string _t8_2
li $2, 4
lw $4, 148($sp)
syscall

#exit
li $v0, 10
syscall

#label10:
label10:

#if ( j_2 >=i #0 ) goto label11
lw $8, 160($sp)
li $9, 0
bge $8, $9, label11

#strconst _s4 _t9_2 #"RUNTIME ERROR: Index is negative\n"
la $8, _s4
sw $8, 144($sp)

#print string _t9_2
li $2, 4
lw $4, 144($sp)
syscall

#exit
li $v0, 10
syscall

#label11:
label11:

#_t10_2 =i j_2 *i #4
lw $8, 160($sp)
li $9, 4
mul $10, $8, $9
sw $10, 140($sp)

#_t10_2 =i arr_1 +i _t10_2
lw $8, 204($sp)
lw $9, 140($sp)
add $10, $8, $9
sw $10, 140($sp)

#if ( *_t10_2 <i pivot_1 ) goto label12
lw $8, 140($sp)
lw $8, ($8)
lw $9, 176($sp)
blt $8, $9, label12

#_t11_2 =b #false
li $8, 0
sw $8, 136($sp)

#goto label13
j label13

#label12:
label12:

#_t11_2 =b #true
li $8, 1
sw $8, 136($sp)

#label13:
label13:

#if ( _t11_2 !=b #true ) goto label14
lw $8, 136($sp)
beqz $8, label14

#_t12_3 =i i_1
lw $8, 164($sp)
sw $8, 132($sp)

#i_1 =i i_1 +i #1
lw $8, 164($sp)
li $9, 1
addi $10, $8, 1
sw $10, 164($sp)

#if ( i_1 <i _arr_1_1_1 ) goto label16
lw $8, 164($sp)
lw $9, 200($sp)
blt $8, $9, label16

#strconst _s5 _t13_3 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s5
sw $8, 128($sp)

#print string _t13_3
li $2, 4
lw $4, 128($sp)
syscall

#exit
li $v0, 10
syscall

#label16:
label16:

#if ( i_1 >=i #0 ) goto label17
lw $8, 164($sp)
li $9, 0
bge $8, $9, label17

#strconst _s6 _t14_3 #"RUNTIME ERROR: Index is negative\n"
la $8, _s6
sw $8, 124($sp)

#print string _t14_3
li $2, 4
lw $4, 124($sp)
syscall

#exit
li $v0, 10
syscall

#label17:
label17:

#_t15_3 =i i_1 *i #4
lw $8, 164($sp)
li $9, 4
mul $10, $8, $9
sw $10, 120($sp)

#_t15_3 =i arr_1 +i _t15_3
lw $8, 204($sp)
lw $9, 120($sp)
add $10, $8, $9
sw $10, 120($sp)

#temp_3 =i *_t15_3
lw $8, 120($sp)
lw $8, ($8)
sw $8, 116($sp)

#if ( i_1 <i _arr_1_1_1 ) goto label18
lw $8, 164($sp)
lw $9, 200($sp)
blt $8, $9, label18

#strconst _s7 _t16_3 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s7
sw $8, 112($sp)

#print string _t16_3
li $2, 4
lw $4, 112($sp)
syscall

#exit
li $v0, 10
syscall

#label18:
label18:

#if ( i_1 >=i #0 ) goto label19
lw $8, 164($sp)
li $9, 0
bge $8, $9, label19

#strconst _s8 _t17_3 #"RUNTIME ERROR: Index is negative\n"
la $8, _s8
sw $8, 108($sp)

#print string _t17_3
li $2, 4
lw $4, 108($sp)
syscall

#exit
li $v0, 10
syscall

#label19:
label19:

#_t18_3 =i i_1 *i #4
lw $8, 164($sp)
li $9, 4
mul $10, $8, $9
sw $10, 104($sp)

#_t18_3 =i arr_1 +i _t18_3
lw $8, 204($sp)
lw $9, 104($sp)
add $10, $8, $9
sw $10, 104($sp)

#if ( j_2 <i _arr_1_1_1 ) goto label20
lw $8, 160($sp)
lw $9, 200($sp)
blt $8, $9, label20

#strconst _s9 _t19_3 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s9
sw $8, 100($sp)

#print string _t19_3
li $2, 4
lw $4, 100($sp)
syscall

#exit
li $v0, 10
syscall

#label20:
label20:

#if ( j_2 >=i #0 ) goto label21
lw $8, 160($sp)
li $9, 0
bge $8, $9, label21

#strconst _s10 _t20_3 #"RUNTIME ERROR: Index is negative\n"
la $8, _s10
sw $8, 96($sp)

#print string _t20_3
li $2, 4
lw $4, 96($sp)
syscall

#exit
li $v0, 10
syscall

#label21:
label21:

#_t21_3 =i j_2 *i #4
lw $8, 160($sp)
li $9, 4
mul $10, $8, $9
sw $10, 92($sp)

#_t21_3 =i arr_1 +i _t21_3
lw $8, 204($sp)
lw $9, 92($sp)
add $10, $8, $9
sw $10, 92($sp)

#*_t18_3 =i *_t21_3
lw $8, 92($sp)
lw $8, ($8)
lw $11, 104($sp)
sw $8, ($11)

#if ( j_2 <i _arr_1_1_1 ) goto label22
lw $8, 160($sp)
lw $9, 200($sp)
blt $8, $9, label22

#strconst _s11 _t22_3 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s11
sw $8, 88($sp)

#print string _t22_3
li $2, 4
lw $4, 88($sp)
syscall

#exit
li $v0, 10
syscall

#label22:
label22:

#if ( j_2 >=i #0 ) goto label23
lw $8, 160($sp)
li $9, 0
bge $8, $9, label23

#strconst _s12 _t23_3 #"RUNTIME ERROR: Index is negative\n"
la $8, _s12
sw $8, 84($sp)

#print string _t23_3
li $2, 4
lw $4, 84($sp)
syscall

#exit
li $v0, 10
syscall

#label23:
label23:

#_t24_3 =i j_2 *i #4
lw $8, 160($sp)
li $9, 4
mul $10, $8, $9
sw $10, 80($sp)

#_t24_3 =i arr_1 +i _t24_3
lw $8, 204($sp)
lw $9, 80($sp)
add $10, $8, $9
sw $10, 80($sp)

#*_t24_3 =i temp_3
lw $8, 116($sp)
lw $11, 80($sp)
sw $8, ($11)

#goto label15
j label15

#label14:
label14:

#label15:
label15:

#goto label8
j label8

#label9:
label9:

#_t25_1 =i #1
li $8, 1
sw $8, 76($sp)

#_t26_1 =i i_1 +i _t25_1
lw $8, 164($sp)
lw $9, 76($sp)
add $10, $8, $9
sw $10, 72($sp)

#if ( _t26_1 <i _arr_1_1_1 ) goto label24
lw $8, 72($sp)
lw $9, 200($sp)
blt $8, $9, label24

#strconst _s13 _t27_1 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s13
sw $8, 68($sp)

#print string _t27_1
li $2, 4
lw $4, 68($sp)
syscall

#exit
li $v0, 10
syscall

#label24:
label24:

#if ( _t26_1 >=i #0 ) goto label25
lw $8, 72($sp)
li $9, 0
bge $8, $9, label25

#strconst _s14 _t28_1 #"RUNTIME ERROR: Index is negative\n"
la $8, _s14
sw $8, 64($sp)

#print string _t28_1
li $2, 4
lw $4, 64($sp)
syscall

#exit
li $v0, 10
syscall

#label25:
label25:

#_t29_1 =i _t26_1 *i #4
lw $8, 72($sp)
li $9, 4
mul $10, $8, $9
sw $10, 60($sp)

#_t29_1 =i arr_1 +i _t29_1
lw $8, 204($sp)
lw $9, 60($sp)
add $10, $8, $9
sw $10, 60($sp)

#t_1 =i *_t29_1
lw $8, 60($sp)
lw $8, ($8)
sw $8, 56($sp)

#_t30_1 =i #1
li $8, 1
sw $8, 52($sp)

#_t31_1 =i i_1 +i _t30_1
lw $8, 164($sp)
lw $9, 52($sp)
add $10, $8, $9
sw $10, 48($sp)

#if ( _t31_1 <i _arr_1_1_1 ) goto label26
lw $8, 48($sp)
lw $9, 200($sp)
blt $8, $9, label26

#strconst _s15 _t32_1 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s15
sw $8, 44($sp)

#print string _t32_1
li $2, 4
lw $4, 44($sp)
syscall

#exit
li $v0, 10
syscall

#label26:
label26:

#if ( _t31_1 >=i #0 ) goto label27
lw $8, 48($sp)
li $9, 0
bge $8, $9, label27

#strconst _s16 _t33_1 #"RUNTIME ERROR: Index is negative\n"
la $8, _s16
sw $8, 40($sp)

#print string _t33_1
li $2, 4
lw $4, 40($sp)
syscall

#exit
li $v0, 10
syscall

#label27:
label27:

#_t34_1 =i _t31_1 *i #4
lw $8, 48($sp)
li $9, 4
mul $10, $8, $9
sw $10, 36($sp)

#_t34_1 =i arr_1 +i _t34_1
lw $8, 204($sp)
lw $9, 36($sp)
add $10, $8, $9
sw $10, 36($sp)

#if ( high_1 <i _arr_1_1_1 ) goto label28
lw $8, 192($sp)
lw $9, 200($sp)
blt $8, $9, label28

#strconst _s17 _t35_1 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s17
sw $8, 32($sp)

#print string _t35_1
li $2, 4
lw $4, 32($sp)
syscall

#exit
li $v0, 10
syscall

#label28:
label28:

#if ( high_1 >=i #0 ) goto label29
lw $8, 192($sp)
li $9, 0
bge $8, $9, label29

#strconst _s18 _t36_1 #"RUNTIME ERROR: Index is negative\n"
la $8, _s18
sw $8, 28($sp)

#print string _t36_1
li $2, 4
lw $4, 28($sp)
syscall

#exit
li $v0, 10
syscall

#label29:
label29:

#_t37_1 =i high_1 *i #4
lw $8, 192($sp)
li $9, 4
mul $10, $8, $9
sw $10, 24($sp)

#_t37_1 =i arr_1 +i _t37_1
lw $8, 204($sp)
lw $9, 24($sp)
add $10, $8, $9
sw $10, 24($sp)

#*_t34_1 =i *_t37_1
lw $8, 24($sp)
lw $8, ($8)
lw $11, 36($sp)
sw $8, ($11)

#if ( high_1 <i _arr_1_1_1 ) goto label30
lw $8, 192($sp)
lw $9, 200($sp)
blt $8, $9, label30

#strconst _s19 _t38_1 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s19
sw $8, 20($sp)

#print string _t38_1
li $2, 4
lw $4, 20($sp)
syscall

#exit
li $v0, 10
syscall

#label30:
label30:

#if ( high_1 >=i #0 ) goto label31
lw $8, 192($sp)
li $9, 0
bge $8, $9, label31

#strconst _s20 _t39_1 #"RUNTIME ERROR: Index is negative\n"
la $8, _s20
sw $8, 16($sp)

#print string _t39_1
li $2, 4
lw $4, 16($sp)
syscall

#exit
li $v0, 10
syscall

#label31:
label31:

#_t40_1 =i high_1 *i #4
lw $8, 192($sp)
li $9, 4
mul $10, $8, $9
sw $10, 12($sp)

#_t40_1 =i arr_1 +i _t40_1
lw $8, 204($sp)
lw $9, 12($sp)
add $10, $8, $9
sw $10, 12($sp)

#*_t40_1 =i t_1
lw $8, 56($sp)
lw $11, 12($sp)
sw $8, ($11)

#_t41_1 =i #1
li $8, 1
sw $8, 8($sp)

#_t42_1 =i i_1 +i _t41_1
lw $8, 164($sp)
lw $9, 8($sp)
add $10, $8, $9
sw $10, 4($sp)

#return _t42_1
lw $ra, 0($sp)
lw $8 4($sp)
addiu $sp, $sp, 212
sw $8 -4($sp)
jr $ra

#return
lw $ra, 0($sp)
addiu $sp, $sp, 212
jr $ra

#label32:
label32:

#function start main.quickSort

#setReturn
sw $ra, 0($sp)

#if ( low_4 <i high_4 ) goto label33
lw $8, 44($sp)
lw $9, 40($sp)
blt $8, $9, label33

#_t43_4 =b #false
li $8, 0
sw $8, 36($sp)

#goto label34
j label34

#label33:
label33:

#_t43_4 =b #true
li $8, 1
sw $8, 36($sp)

#label34:
label34:

#if ( _t43_4 !=b #true ) goto label35
lw $8, 36($sp)
beqz $8, label35

#funCall main.partition

#param arr_4 4
li $9, 0
li $10, -8
add $10, $10, $sp
li $11, 52
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#param _arr_4_1_4 4
li $9, 0
li $10, -12
add $10, $10, $sp
li $11, 48
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#param low_4 4
li $9, 0
li $10, -16
add $10, $10, $sp
li $11, 44
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#param high_4 4
li $9, 0
li $10, -20
add $10, $10, $sp
li $11, 40
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#call label1
addiu $sp, $sp, -212
jal label1

#_t44_5 = returnVal
lw $8 -4($sp)
sw $8 32($sp)

#pi_5 =i _t44_5
lw $8, 32($sp)
sw $8, 28($sp)

#funCall main.quickSort

#param arr_4 4
li $9, 0
li $10, -8
add $10, $10, $sp
li $11, 52
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#param _arr_4_1_4 4
li $9, 0
li $10, -12
add $10, $10, $sp
li $11, 48
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#param low_4 4
li $9, 0
li $10, -16
add $10, $10, $sp
li $11, 44
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#_t45_5 =i #1
li $8, 1
sw $8, 24($sp)

#_t46_5 =i pi_5 -i _t45_5
lw $8, 28($sp)
lw $9, 24($sp)
sub $10, $8, $9
sw $10, 20($sp)

#param _t46_5 4
li $9, 0
li $10, -20
add $10, $10, $sp
li $11, 20
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#call label32
addiu $sp, $sp, -60
jal label32

#_t47_5 = returnVal
lw $8 -4($sp)
sw $8 16($sp)

#funCall main.quickSort

#param arr_4 4
li $9, 0
li $10, -8
add $10, $10, $sp
li $11, 52
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#param _arr_4_1_4 4
li $9, 0
li $10, -12
add $10, $10, $sp
li $11, 48
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#_t48_5 =i #1
li $8, 1
sw $8, 12($sp)

#_t49_5 =i pi_5 +i _t48_5
lw $8, 28($sp)
lw $9, 12($sp)
add $10, $8, $9
sw $10, 8($sp)

#param _t49_5 4
li $9, 0
li $10, -16
add $10, $10, $sp
li $11, 8
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#param high_4 4
li $9, 0
li $10, -20
add $10, $10, $sp
li $11, 40
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#call label32
addiu $sp, $sp, -60
jal label32

#_t50_5 = returnVal
lw $8 -4($sp)
sw $8 4($sp)

#goto label36
j label36

#label35:
label35:

#label36:
label36:

#return
lw $ra, 0($sp)
addiu $sp, $sp, 60
jr $ra

#label37:
label37:

#function start main.main

#setReturn
sw $ra, 0($sp)

#_t51_6 =i #10
li $8, 10
sw $8, 132($sp)

#n_6 =i _t51_6
lw $8, 132($sp)
sw $8, 128($sp)

#_arr_6_1_6 =i n_6
lw $8, 128($sp)
sw $8, 124($sp)

#array arr_6 4 _arr_6_1_6 
li $8, 1
lw $9, 124($sp)
mul $8, $8, $9
li $10, 4
mul $8, $8, $10
li $2, 9
move $4, $8
syscall
sw $2, 120($sp)

#_t52_7 =i #0
li $8, 0
sw $8, 116($sp)

#i_7 =i _t52_7
lw $8, 116($sp)
sw $8, 112($sp)

#label38:
label38:

#_t53_7 =i #10
li $8, 10
sw $8, 108($sp)

#if ( i_7 <i _t53_7 ) goto label39
lw $8, 112($sp)
lw $9, 108($sp)
blt $8, $9, label39

#_t54_7 =b #false
li $8, 0
sw $8, 104($sp)

#goto label40
j label40

#label39:
label39:

#_t54_7 =b #true
li $8, 1
sw $8, 104($sp)

#label40:
label40:

#if ( _t54_7 !=b #true ) goto label43
lw $8, 104($sp)
beqz $8, label43

#goto label41
j label41

#label42:
label42:

#_t55_7 =i i_7
lw $8, 112($sp)
sw $8, 100($sp)

#i_7 =i i_7 +i #1
lw $8, 112($sp)
li $9, 1
addi $10, $8, 1
sw $10, 112($sp)

#goto label38
j label38

#label41:
label41:

#if ( i_7 <i _arr_6_1_6 ) goto label44
lw $8, 112($sp)
lw $9, 124($sp)
blt $8, $9, label44

#strconst _s21 _t56_7 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s21
sw $8, 96($sp)

#print string _t56_7
li $2, 4
lw $4, 96($sp)
syscall

#exit
li $v0, 10
syscall

#label44:
label44:

#if ( i_7 >=i #0 ) goto label45
lw $8, 112($sp)
li $9, 0
bge $8, $9, label45

#strconst _s22 _t57_7 #"RUNTIME ERROR: Index is negative\n"
la $8, _s22
sw $8, 92($sp)

#print string _t57_7
li $2, 4
lw $4, 92($sp)
syscall

#exit
li $v0, 10
syscall

#label45:
label45:

#_t58_7 =i i_7 *i #4
lw $8, 112($sp)
li $9, 4
mul $10, $8, $9
sw $10, 88($sp)

#_t58_7 =i arr_6 +i _t58_7
lw $8, 120($sp)
lw $9, 88($sp)
add $10, $8, $9
sw $10, 88($sp)

#scan int *_t58_7
li $2, 5
syscall
lw $4, 88($sp)
sw $2, ($4)

#goto label42
j label42

#label43:
label43:

#strconst _s23 _t59_6 #"The array is: "
la $8, _s23
sw $8, 84($sp)

#print string _t59_6
li $2, 4
lw $4, 84($sp)
syscall

#print newline
li $4, 10
li $2, 11
syscall

#_t60_8 =i #0
li $8, 0
sw $8, 80($sp)

#i_8 =i _t60_8
lw $8, 80($sp)
sw $8, 76($sp)

#label46:
label46:

#if ( i_8 <i n_6 ) goto label47
lw $8, 76($sp)
lw $9, 128($sp)
blt $8, $9, label47

#_t61_8 =b #false
li $8, 0
sw $8, 72($sp)

#goto label48
j label48

#label47:
label47:

#_t61_8 =b #true
li $8, 1
sw $8, 72($sp)

#label48:
label48:

#if ( _t61_8 !=b #true ) goto label51
lw $8, 72($sp)
beqz $8, label51

#goto label49
j label49

#label50:
label50:

#_t62_8 =i i_8
lw $8, 76($sp)
sw $8, 68($sp)

#i_8 =i i_8 +i #1
lw $8, 76($sp)
li $9, 1
addi $10, $8, 1
sw $10, 76($sp)

#goto label46
j label46

#label49:
label49:

#if ( i_8 <i _arr_6_1_6 ) goto label52
lw $8, 76($sp)
lw $9, 124($sp)
blt $8, $9, label52

#strconst _s24 _t63_8 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s24
sw $8, 64($sp)

#print string _t63_8
li $2, 4
lw $4, 64($sp)
syscall

#exit
li $v0, 10
syscall

#label52:
label52:

#if ( i_8 >=i #0 ) goto label53
lw $8, 76($sp)
li $9, 0
bge $8, $9, label53

#strconst _s25 _t64_8 #"RUNTIME ERROR: Index is negative\n"
la $8, _s25
sw $8, 60($sp)

#print string _t64_8
li $2, 4
lw $4, 60($sp)
syscall

#exit
li $v0, 10
syscall

#label53:
label53:

#_t65_8 =i i_8 *i #4
lw $8, 76($sp)
li $9, 4
mul $10, $8, $9
sw $10, 56($sp)

#_t65_8 =i arr_6 +i _t65_8
lw $8, 120($sp)
lw $9, 56($sp)
add $10, $8, $9
sw $10, 56($sp)

#print int *_t65_8
lw $8, 56($sp)
lw $8, 0($8)
li $2, 1
move $4, $8
syscall

#strconst _s26 _t66_8 #" "
la $8, _s26
sw $8, 52($sp)

#print string _t66_8
li $2, 4
lw $4, 52($sp)
syscall

#goto label50
j label50

#label51:
label51:

#print newline
li $4, 10
li $2, 11
syscall

#funCall main.quickSort

#param arr_6 4
li $9, 0
li $10, -8
add $10, $10, $sp
li $11, 120
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#param _arr_6_1_6 4
li $9, 0
li $10, -12
add $10, $10, $sp
li $11, 124
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#_t67_6 =i #0
li $8, 0
sw $8, 48($sp)

#param _t67_6 4
li $9, 0
li $10, -16
add $10, $10, $sp
li $11, 48
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#_t68_6 =i #9
li $8, 9
sw $8, 44($sp)

#param _t68_6 4
li $9, 0
li $10, -20
add $10, $10, $sp
li $11, 44
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#call label32
addiu $sp, $sp, -60
jal label32

#_t69_6 = returnVal
lw $8 -4($sp)
sw $8 40($sp)

#strconst _s27 _t70_6 #"Sorted array is"
la $8, _s27
sw $8, 36($sp)

#print string _t70_6
li $2, 4
lw $4, 36($sp)
syscall

#print newline
li $4, 10
li $2, 11
syscall

#_t71_9 =i #0
li $8, 0
sw $8, 32($sp)

#i_9 =i _t71_9
lw $8, 32($sp)
sw $8, 28($sp)

#label54:
label54:

#if ( i_9 <i n_6 ) goto label55
lw $8, 28($sp)
lw $9, 128($sp)
blt $8, $9, label55

#_t72_9 =b #false
li $8, 0
sw $8, 24($sp)

#goto label56
j label56

#label55:
label55:

#_t72_9 =b #true
li $8, 1
sw $8, 24($sp)

#label56:
label56:

#if ( _t72_9 !=b #true ) goto label59
lw $8, 24($sp)
beqz $8, label59

#goto label57
j label57

#label58:
label58:

#_t73_9 =i i_9
lw $8, 28($sp)
sw $8, 20($sp)

#i_9 =i i_9 +i #1
lw $8, 28($sp)
li $9, 1
addi $10, $8, 1
sw $10, 28($sp)

#goto label54
j label54

#label57:
label57:

#if ( i_9 <i _arr_6_1_6 ) goto label60
lw $8, 28($sp)
lw $9, 124($sp)
blt $8, $9, label60

#strconst _s28 _t74_9 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s28
sw $8, 16($sp)

#print string _t74_9
li $2, 4
lw $4, 16($sp)
syscall

#exit
li $v0, 10
syscall

#label60:
label60:

#if ( i_9 >=i #0 ) goto label61
lw $8, 28($sp)
li $9, 0
bge $8, $9, label61

#strconst _s29 _t75_9 #"RUNTIME ERROR: Index is negative\n"
la $8, _s29
sw $8, 12($sp)

#print string _t75_9
li $2, 4
lw $4, 12($sp)
syscall

#exit
li $v0, 10
syscall

#label61:
label61:

#_t76_9 =i i_9 *i #4
lw $8, 28($sp)
li $9, 4
mul $10, $8, $9
sw $10, 8($sp)

#_t76_9 =i arr_6 +i _t76_9
lw $8, 120($sp)
lw $9, 8($sp)
add $10, $8, $9
sw $10, 8($sp)

#print int *_t76_9
lw $8, 8($sp)
lw $8, 0($8)
li $2, 1
move $4, $8
syscall

#strconst _s30 _t77_9 #" "
la $8, _s30
sw $8, 4($sp)

#print string _t77_9
li $2, 4
lw $4, 4($sp)
syscall

#goto label58
j label58

#label59:
label59:

#print newline
li $4, 10
li $2, 11
syscall

#return
lw $ra, 0($sp)
addiu $sp, $sp, 140
jr $ra
