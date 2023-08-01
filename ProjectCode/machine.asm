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
_s13: .asciiz "Enter the size of the array"
_s14: .asciiz "Enter the elements of the array"
_s15: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s16: .asciiz "RUNTIME ERROR: Index is negative\n"
_s17: .asciiz "The array is: "
_s18: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s19: .asciiz "RUNTIME ERROR: Index is negative\n"
_s20: .asciiz " "
_s21: .asciiz "Sorted array is"
_s22: .asciiz "RUNTIME ERROR: Index out of Bounds\n"
_s23: .asciiz "RUNTIME ERROR: Index is negative\n"
_s24: .asciiz " "
.text 
.globl main 
main:

#funCall main.main

#call label30
addiu $sp, $sp, -80
jal label30

#exit
li $v0, 10
syscall

#label1:
label1:

#function start main.selectionSort

#setReturn
sw $ra, 0($sp)

#_t1_2 =i #0
li $8, 0
sw $8, 104($sp)

#i_2 =i _t1_2
lw $8, 104($sp)
sw $8, 100($sp)

#label2:
label2:

#if ( i_2 <i n_1 ) goto label3
lw $8, 100($sp)
lw $9, 108($sp)
blt $8, $9, label3

#_t2_2 =b #false
li $8, 0
sw $8, 96($sp)

#goto label4
j label4

#label3:
label3:

#_t2_2 =b #true
li $8, 1
sw $8, 96($sp)

#label4:
label4:

#if ( _t2_2 !=b #true ) goto label7
lw $8, 96($sp)
beqz $8, label7

#goto label5
j label5

#label6:
label6:

#_t3_2 =i i_2
lw $8, 100($sp)
sw $8, 92($sp)

#i_2 =i i_2 +i #1
lw $8, 100($sp)
li $9, 1
addi $10, $8, 1
sw $10, 100($sp)

#goto label2
j label2

#label5:
label5:

#minIndex_2 =i i_2
lw $8, 100($sp)
sw $8, 88($sp)

#_t1_3 =i #1
li $8, 1
sw $8, 84($sp)

#_t2_3 =i i_2 +i _t1_3
lw $8, 100($sp)
lw $9, 84($sp)
add $10, $8, $9
sw $10, 80($sp)

#j_3 =i _t2_3
lw $8, 80($sp)
sw $8, 76($sp)

#label8:
label8:

#if ( j_3 <i n_1 ) goto label9
lw $8, 76($sp)
lw $9, 108($sp)
blt $8, $9, label9

#_t3_3 =b #false
li $8, 0
sw $8, 72($sp)

#goto label10
j label10

#label9:
label9:

#_t3_3 =b #true
li $8, 1
sw $8, 72($sp)

#label10:
label10:

#if ( _t3_3 !=b #true ) goto label13
lw $8, 72($sp)
beqz $8, label13

#goto label11
j label11

#label12:
label12:

#_t4_3 =i j_3
lw $8, 76($sp)
sw $8, 68($sp)

#j_3 =i j_3 +i #1
lw $8, 76($sp)
li $9, 1
addi $10, $8, 1
sw $10, 76($sp)

#goto label8
j label8

#label11:
label11:

#if ( minIndex_2 <i _arr_1_1_1 ) goto label14
lw $8, 88($sp)
lw $9, 112($sp)
blt $8, $9, label14

#strconst _s1 _t1_3 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s1
sw $8, 84($sp)

#print string _t1_3
li $2, 4
lw $4, 84($sp)
syscall

#exit
li $v0, 10
syscall

#label14:
label14:

#if ( minIndex_2 >=i #0 ) goto label15
lw $8, 88($sp)
li $9, 0
bge $8, $9, label15

#strconst _s2 _t2_3 #"RUNTIME ERROR: Index is negative\n"
la $8, _s2
sw $8, 80($sp)

#print string _t2_3
li $2, 4
lw $4, 80($sp)
syscall

#exit
li $v0, 10
syscall

#label15:
label15:

#_t3_3 =i minIndex_2 *i #4
lw $8, 88($sp)
li $9, 4
mul $10, $8, $9
sw $10, 72($sp)

#_t3_3 =i arr_1 +i _t3_3
lw $8, 116($sp)
lw $9, 72($sp)
add $10, $8, $9
sw $10, 72($sp)

#if ( j_3 <i _arr_1_1_1 ) goto label16
lw $8, 76($sp)
lw $9, 112($sp)
blt $8, $9, label16

#strconst _s3 _t4_3 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s3
sw $8, 68($sp)

#print string _t4_3
li $2, 4
lw $4, 68($sp)
syscall

#exit
li $v0, 10
syscall

#label16:
label16:

#if ( j_3 >=i #0 ) goto label17
lw $8, 76($sp)
li $9, 0
bge $8, $9, label17

#strconst _s4 _t5_3 #"RUNTIME ERROR: Index is negative\n"
la $8, _s4
sw $8, 64($sp)

#print string _t5_3
li $2, 4
lw $4, 64($sp)
syscall

#exit
li $v0, 10
syscall

#label17:
label17:

#_t6_3 =i j_3 *i #4
lw $8, 76($sp)
li $9, 4
mul $10, $8, $9
sw $10, 60($sp)

#_t6_3 =i arr_1 +i _t6_3
lw $8, 116($sp)
lw $9, 60($sp)
add $10, $8, $9
sw $10, 60($sp)

#if ( *_t3_3 >i *_t6_3 ) goto label18
lw $8, 72($sp)
lw $8, ($8)
lw $9, 60($sp)
lw $9, ($9)
bgt $8, $9, label18

#_t7_3 =b #false
li $8, 0
sw $8, 56($sp)

#goto label19
j label19

#label18:
label18:

#_t7_3 =b #true
li $8, 1
sw $8, 56($sp)

#label19:
label19:

#if ( _t7_3 !=b #true ) goto label20
lw $8, 56($sp)
beqz $8, label20

#minIndex_2 =i j_3
lw $8, 76($sp)
sw $8, 88($sp)

#goto label21
j label21

#label20:
label20:

#label21:
label21:

#goto label12
j label12

#label13:
label13:

#if ( minIndex_2 <i _arr_1_1_1 ) goto label22
lw $8, 88($sp)
lw $9, 112($sp)
blt $8, $9, label22

#strconst _s5 _t1_2 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s5
sw $8, 104($sp)

#print string _t1_2
li $2, 4
lw $4, 104($sp)
syscall

#exit
li $v0, 10
syscall

#label22:
label22:

#if ( minIndex_2 >=i #0 ) goto label23
lw $8, 88($sp)
li $9, 0
bge $8, $9, label23

#strconst _s6 _t2_2 #"RUNTIME ERROR: Index is negative\n"
la $8, _s6
sw $8, 96($sp)

#print string _t2_2
li $2, 4
lw $4, 96($sp)
syscall

#exit
li $v0, 10
syscall

#label23:
label23:

#_t3_2 =i minIndex_2 *i #4
lw $8, 88($sp)
li $9, 4
mul $10, $8, $9
sw $10, 92($sp)

#_t3_2 =i arr_1 +i _t3_2
lw $8, 116($sp)
lw $9, 92($sp)
add $10, $8, $9
sw $10, 92($sp)

#temp_2 =i *_t3_2
lw $8, 92($sp)
lw $8, ($8)
sw $8, 40($sp)

#if ( minIndex_2 <i _arr_1_1_1 ) goto label24
lw $8, 88($sp)
lw $9, 112($sp)
blt $8, $9, label24

#strconst _s7 _t1_2 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s7
sw $8, 104($sp)

#print string _t1_2
li $2, 4
lw $4, 104($sp)
syscall

#exit
li $v0, 10
syscall

#label24:
label24:

#if ( minIndex_2 >=i #0 ) goto label25
lw $8, 88($sp)
li $9, 0
bge $8, $9, label25

#strconst _s8 _t2_2 #"RUNTIME ERROR: Index is negative\n"
la $8, _s8
sw $8, 96($sp)

#print string _t2_2
li $2, 4
lw $4, 96($sp)
syscall

#exit
li $v0, 10
syscall

#label25:
label25:

#_t3_2 =i minIndex_2 *i #4
lw $8, 88($sp)
li $9, 4
mul $10, $8, $9
sw $10, 92($sp)

#_t3_2 =i arr_1 +i _t3_2
lw $8, 116($sp)
lw $9, 92($sp)
add $10, $8, $9
sw $10, 92($sp)

#if ( i_2 <i _arr_1_1_1 ) goto label26
lw $8, 100($sp)
lw $9, 112($sp)
blt $8, $9, label26

#strconst _s9 _t4_2 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s9
sw $8, 24($sp)

#print string _t4_2
li $2, 4
lw $4, 24($sp)
syscall

#exit
li $v0, 10
syscall

#label26:
label26:

#if ( i_2 >=i #0 ) goto label27
lw $8, 100($sp)
li $9, 0
bge $8, $9, label27

#strconst _s10 _t5_2 #"RUNTIME ERROR: Index is negative\n"
la $8, _s10
sw $8, 20($sp)

#print string _t5_2
li $2, 4
lw $4, 20($sp)
syscall

#exit
li $v0, 10
syscall

#label27:
label27:

#_t6_2 =i i_2 *i #4
lw $8, 100($sp)
li $9, 4
mul $10, $8, $9
sw $10, 16($sp)

#_t6_2 =i arr_1 +i _t6_2
lw $8, 116($sp)
lw $9, 16($sp)
add $10, $8, $9
sw $10, 16($sp)

#*_t3_2 =i *_t6_2
lw $8, 16($sp)
lw $8, ($8)
lw $11, 92($sp)
sw $8, ($11)

#if ( i_2 <i _arr_1_1_1 ) goto label28
lw $8, 100($sp)
lw $9, 112($sp)
blt $8, $9, label28

#strconst _s11 _t1_2 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s11
sw $8, 104($sp)

#print string _t1_2
li $2, 4
lw $4, 104($sp)
syscall

#exit
li $v0, 10
syscall

#label28:
label28:

#if ( i_2 >=i #0 ) goto label29
lw $8, 100($sp)
li $9, 0
bge $8, $9, label29

#strconst _s12 _t2_2 #"RUNTIME ERROR: Index is negative\n"
la $8, _s12
sw $8, 96($sp)

#print string _t2_2
li $2, 4
lw $4, 96($sp)
syscall

#exit
li $v0, 10
syscall

#label29:
label29:

#_t3_2 =i i_2 *i #4
lw $8, 100($sp)
li $9, 4
mul $10, $8, $9
sw $10, 92($sp)

#_t3_2 =i arr_1 +i _t3_2
lw $8, 116($sp)
lw $9, 92($sp)
add $10, $8, $9
sw $10, 92($sp)

#*_t3_2 =i temp_2
lw $8, 40($sp)
lw $11, 92($sp)
sw $8, ($11)

#goto label6
j label6

#label7:
label7:

#return
lw $ra, 0($sp)
addiu $sp, $sp, 88
jr $ra

#label30:
label30:

#function start main.main

#setReturn
sw $ra, 0($sp)

#strconst _s13 _t1_5 #"Enter the size of the array"
la $8, _s13
sw $8, 68($sp)

#print string _t1_5
li $2, 4
lw $4, 68($sp)
syscall

#print newline
li $4, 10
li $2, 11
syscall

#scan int n_5
li $2, 5
syscall
sw $2, 72($sp)

#_arr_5_1_5 =i n_5
lw $8, 72($sp)
sw $8, 64($sp)

#array arr_5 4 _arr_5_1_5 
li $8, 1
lw $9, 64($sp)
mul $8, $8, $9
li $10, 4
mul $8, $8, $10
li $2, 9
move $4, $8
syscall
sw $2, 60($sp)

#strconst _s14 _t1_5 #"Enter the elements of the array"
la $8, _s14
sw $8, 68($sp)

#print string _t1_5
li $2, 4
lw $4, 68($sp)
syscall

#print newline
li $4, 10
li $2, 11
syscall

#_t1_6 =i #0
li $8, 0
sw $8, 56($sp)

#i_6 =i _t1_6
lw $8, 56($sp)
sw $8, 52($sp)

#label31:
label31:

#if ( i_6 <i n_5 ) goto label32
lw $8, 52($sp)
lw $9, 72($sp)
blt $8, $9, label32

#_t2_6 =b #false
li $8, 0
sw $8, 48($sp)

#goto label33
j label33

#label32:
label32:

#_t2_6 =b #true
li $8, 1
sw $8, 48($sp)

#label33:
label33:

#if ( _t2_6 !=b #true ) goto label36
lw $8, 48($sp)
beqz $8, label36

#goto label34
j label34

#label35:
label35:

#_t3_6 =i i_6
lw $8, 52($sp)
sw $8, 44($sp)

#i_6 =i i_6 +i #1
lw $8, 52($sp)
li $9, 1
addi $10, $8, 1
sw $10, 52($sp)

#goto label31
j label31

#label34:
label34:

#if ( i_6 <i _arr_5_1_5 ) goto label37
lw $8, 52($sp)
lw $9, 64($sp)
blt $8, $9, label37

#strconst _s15 _t1_6 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s15
sw $8, 56($sp)

#print string _t1_6
li $2, 4
lw $4, 56($sp)
syscall

#exit
li $v0, 10
syscall

#label37:
label37:

#if ( i_6 >=i #0 ) goto label38
lw $8, 52($sp)
li $9, 0
bge $8, $9, label38

#strconst _s16 _t2_6 #"RUNTIME ERROR: Index is negative\n"
la $8, _s16
sw $8, 48($sp)

#print string _t2_6
li $2, 4
lw $4, 48($sp)
syscall

#exit
li $v0, 10
syscall

#label38:
label38:

#_t3_6 =i i_6 *i #4
lw $8, 52($sp)
li $9, 4
mul $10, $8, $9
sw $10, 44($sp)

#_t3_6 =i arr_5 +i _t3_6
lw $8, 60($sp)
lw $9, 44($sp)
add $10, $8, $9
sw $10, 44($sp)

#scan int *_t3_6
li $2, 5
syscall
lw $4, 44($sp)
sw $2, ($4)

#goto label35
j label35

#label36:
label36:

#strconst _s17 _t1_5 #"The array is: "
la $8, _s17
sw $8, 68($sp)

#print string _t1_5
li $2, 4
lw $4, 68($sp)
syscall

#print newline
li $4, 10
li $2, 11
syscall

#_t1_7 =i #0
li $8, 0
sw $8, 40($sp)

#i_7 =i _t1_7
lw $8, 40($sp)
sw $8, 36($sp)

#label39:
label39:

#if ( i_7 <i n_5 ) goto label40
lw $8, 36($sp)
lw $9, 72($sp)
blt $8, $9, label40

#_t2_7 =b #false
li $8, 0
sw $8, 32($sp)

#goto label41
j label41

#label40:
label40:

#_t2_7 =b #true
li $8, 1
sw $8, 32($sp)

#label41:
label41:

#if ( _t2_7 !=b #true ) goto label44
lw $8, 32($sp)
beqz $8, label44

#goto label42
j label42

#label43:
label43:

#_t3_7 =i i_7
lw $8, 36($sp)
sw $8, 28($sp)

#i_7 =i i_7 +i #1
lw $8, 36($sp)
li $9, 1
addi $10, $8, 1
sw $10, 36($sp)

#goto label39
j label39

#label42:
label42:

#if ( i_7 <i _arr_5_1_5 ) goto label45
lw $8, 36($sp)
lw $9, 64($sp)
blt $8, $9, label45

#strconst _s18 _t1_7 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s18
sw $8, 40($sp)

#print string _t1_7
li $2, 4
lw $4, 40($sp)
syscall

#exit
li $v0, 10
syscall

#label45:
label45:

#if ( i_7 >=i #0 ) goto label46
lw $8, 36($sp)
li $9, 0
bge $8, $9, label46

#strconst _s19 _t2_7 #"RUNTIME ERROR: Index is negative\n"
la $8, _s19
sw $8, 32($sp)

#print string _t2_7
li $2, 4
lw $4, 32($sp)
syscall

#exit
li $v0, 10
syscall

#label46:
label46:

#_t3_7 =i i_7 *i #4
lw $8, 36($sp)
li $9, 4
mul $10, $8, $9
sw $10, 28($sp)

#_t3_7 =i arr_5 +i _t3_7
lw $8, 60($sp)
lw $9, 28($sp)
add $10, $8, $9
sw $10, 28($sp)

#print int *_t3_7
lw $8, 28($sp)
lw $8, 0($8)
li $2, 1
move $4, $8
syscall

#strconst _s20 _t4_7 #" "
la $8, _s20
sw $8, 24($sp)

#print string _t4_7
li $2, 4
lw $4, 24($sp)
syscall

#goto label43
j label43

#label44:
label44:

#print newline
li $4, 10
li $2, 11
syscall

#funCall main.selectionSort

#param arr_5 4
li $9, 0
li $10, -8
add $10, $10, $sp
li $11, 60
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#param _arr_5_1_5 4
li $9, 0
li $10, -12
add $10, $10, $sp
li $11, 64
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#param n_5 4
li $9, 0
li $10, -16
add $10, $10, $sp
li $11, 72
add $11, $11, $sp
add $10, $10, $9
add $11, $11, $9
lw $8, ($11)
sw $8, ($10)
addi $9, $9, 4

#call label1
addiu $sp, $sp, -88
jal label1

#_t1_5 = returnVal
lw $8 -4($sp)
sw $8 68($sp)

#strconst _s21 _t1_5 #"Sorted array is"
la $8, _s21
sw $8, 68($sp)

#print string _t1_5
li $2, 4
lw $4, 68($sp)
syscall

#print newline
li $4, 10
li $2, 11
syscall

#_t1_8 =i #0
li $8, 0
sw $8, 20($sp)

#i_8 =i _t1_8
lw $8, 20($sp)
sw $8, 16($sp)

#label47:
label47:

#if ( i_8 <i n_5 ) goto label48
lw $8, 16($sp)
lw $9, 72($sp)
blt $8, $9, label48

#_t2_8 =b #false
li $8, 0
sw $8, 12($sp)

#goto label49
j label49

#label48:
label48:

#_t2_8 =b #true
li $8, 1
sw $8, 12($sp)

#label49:
label49:

#if ( _t2_8 !=b #true ) goto label52
lw $8, 12($sp)
beqz $8, label52

#goto label50
j label50

#label51:
label51:

#_t3_8 =i i_8
lw $8, 16($sp)
sw $8, 8($sp)

#i_8 =i i_8 +i #1
lw $8, 16($sp)
li $9, 1
addi $10, $8, 1
sw $10, 16($sp)

#goto label47
j label47

#label50:
label50:

#if ( i_8 <i _arr_5_1_5 ) goto label53
lw $8, 16($sp)
lw $9, 64($sp)
blt $8, $9, label53

#strconst _s22 _t1_8 #"RUNTIME ERROR: Index out of Bounds\n"
la $8, _s22
sw $8, 20($sp)

#print string _t1_8
li $2, 4
lw $4, 20($sp)
syscall

#exit
li $v0, 10
syscall

#label53:
label53:

#if ( i_8 >=i #0 ) goto label54
lw $8, 16($sp)
li $9, 0
bge $8, $9, label54

#strconst _s23 _t2_8 #"RUNTIME ERROR: Index is negative\n"
la $8, _s23
sw $8, 12($sp)

#print string _t2_8
li $2, 4
lw $4, 12($sp)
syscall

#exit
li $v0, 10
syscall

#label54:
label54:

#_t3_8 =i i_8 *i #4
lw $8, 16($sp)
li $9, 4
mul $10, $8, $9
sw $10, 8($sp)

#_t3_8 =i arr_5 +i _t3_8
lw $8, 60($sp)
lw $9, 8($sp)
add $10, $8, $9
sw $10, 8($sp)

#print int *_t3_8
lw $8, 8($sp)
lw $8, 0($8)
li $2, 1
move $4, $8
syscall

#strconst _s24 _t4_8 #" "
la $8, _s24
sw $8, 4($sp)

#print string _t4_8
li $2, 4
lw $4, 4($sp)
syscall

#goto label51
j label51

#label52:
label52:

#print newline
li $4, 10
li $2, 11
syscall

#return
lw $ra, 0($sp)
addiu $sp, $sp, 80
jr $ra
