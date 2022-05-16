#Min Jung, Victor Phan, Owen Lovett, Bailey Chean, Sunveer Bhullar  -- 5/15/2022
#final.asm
#Description: Create Tic-Tac -Toe game using MIPS
#	Display game board.
#	Allow user input.
#	Allow PVP and P V. Computer

#Registers used:
#	s1 - the board table (see .data)
#	s2 - win state. If 0, no winner. If 1, somebody has won. Depends on what s6 is
#	s4 - initialized to 1
#	s5 - initialized to 2
#	s6 - player control variable. If 1, player X is in control. If 2, player O is in control.
#	s7 - used to hold a value to check for taken positions
# 	v0
#	a0
#	a1
#	t0- t0 = $a0 - 1 * 4  (used in place_cell)
#	t1- t1 = s1 (board) + t0 (offset)  (used  in place_cell)
#	t2 - to store value from , also to initialize X as 1
#	t3 - use to initialize O as 2
#	t4 - store user input their choice (1 for pvp and 2 for computer(easy))
#	t5 - initialize value for computer(easy)
#	t6 - used as a pointer in computer(hard)
#	t7 - used to hold a position in computer(hard)
#	t8 - used to hold a position in computer(hard)
#	t9 - used to hold a position in computer(hard)
#	ra - to return address
#	sp- to create stack



.data
#tic tac toe board
space: .asciiz " "
rows: .asciiz "\n-----+-----+-----\n" 
cols: .asciiz " | " 
x: .asciiz "X"
o: .asciiz "O"
#for empty spaces on the board
empty: .asciiz "   "
row1: .asciiz "\n  1  |  2  |  3  "
row2: .asciiz "  4  |  5  |  6  "
row3: .asciiz "  7  |  8  |  9  \n"

#messages 
welcome_msg: .asciiz "\n\n*****Welcome to Tic Tac Toe!!!*****\n"
explain_msg: .asciiz "\nInput the cell number to enter your play!\n"
choose_msg: .asciiz "\nEnter 1 for X and 2 for O: "
playerX: .asciiz "\nYou are X.\n" 
playerO: .asciiz "\nYou are O.\n"
cell_msg: .asciiz "\nYour turn!\n\Choose your cell(1-9): "
computer_msg: .asciiz "\nComputer's turn.\n\n"
playerX_msg: "Player X's turn\n\n"
playerO_msg: "Player O's turn\n\n"
unavailable_msg: "\nPosition already taken. Please choose a different one.\n"
gameOver_msg: "\nGame Over!!! \nThe winner is: "
gamemode_msg: "\nEnter 1 for PVP, 2 to play against the computer (easy), or 3 to play against the computer (hard): "

board: .word -1, -2, -3, -4, -5, -6, -7, -8, -9

.text
main:
	#print message
	la $a0, welcome_msg
	li $v0, 4
	syscall
	
	#print cell explanation message
	la $a0, explain_msg
	li $v0, 4
	syscall
	
	#print gamemode message
	la $a0, gamemode_msg
	li $v0, 4
	syscall
	
	#make user input their choice (1 for pvp and 2 for computer(easy))
	li $v0, 5
	syscall
	
	move $t4, $v0
	
	#initialize value for computer(easy)
	li $t5, 2
	
	#allow user to choose to play either X or O
	jal choose_char
	
	#jump to make_board to print out the board setting
	jal board_demo 
	
	# if user imputs 2 then jump to gameLoopEasy
	beq $t4, $t5, gameLoopEasy
	
	# if user imputs 3 then jump to gameLoopHard
	addi $t5, $t5, 1
	beq $t4, $t5, gameLoopHard
	
	gameLoop:	
		beq $s2, 1, exitGameLoop
		
		#get user input
		jal user_input
	
		#set new value for table
		jal place_cell

		#print out the board
		jal curr_board
	
		#did someone win?
		jal check_win_condition
	
		#switch control to other player
		jal switch_player_control
		
		j gameLoop
		
	exitGameLoop:
		j exit
		
	gameLoopEasy:	
		beq $s2, 1, exitGameLoop
		
		#get user input
		jal user_input
	
		#set new value for table
		jal place_cell

		#print out the board
		jal curr_board
		
		#did someone win?
		jal check_win_condition
		
		#switch control to other player
		jal switch_player_control
		
		#computer move
		jal randomizer
		
		#set new value for table
		jal place_cell
		
		#print computer
		la $a0, computer_msg
		li $v0, 4
		syscall
		
		#print out the board
		jal curr_board
		
		#did someone win?
		jal check_win_condition
		
		#switch control to other player
		jal switch_player_control

		j gameLoopEasy
		
	exitGameLoopEasy:
		j exit
		
#-------------------------------------------------------------------------------------------------------------------------
		
	gameLoopHard:	
		beq $s2, 1, exitGameLoop
		
		#get user input
		jal user_input
	
		#set new value for table
		jal place_cell

		#print out the board
		jal curr_board
		
		#did someone win?
		jal check_win_condition
		
		#switch control to other player
		jal switch_player_control
		
		#computer move
		jal hardBot
		
		#set new value for table
		#jal place_cell
		
		#print computer's turn
		la $a0, computer_msg
		li $v0, 4
		syscall
		
		#print out the board
		jal curr_board
		
		#did someone win?
		jal check_win_condition
		
		#switch control to other player
		jal switch_player_control

		j gameLoopHard
		
	exitGameLoopHard:
		j exit
		
#-------------------------------------------------------------------------------------------------------------------------
		
choose_char:
	#print message
	la $a0, choose_msg
	li $v0, 4
	syscall
	
	#make user input their choice (1 for X and 2 for O)
	li $v0, 5
	
	#store the user input into an address
	li $a1, 20
	syscall
	
	move $t0, $v0	
	
	#initialize x
	li $t2, 1	
	#initialize o
	la $t3, 2
	
	#if user input (t0) is X
	beq $t0, $t2, YouX

	YouO:
		#print message that the user is playing O
		la $a0, playerO
		li $v0, 4
		syscall
		
		#set s6 (control variable) to o
		move $s6, $t3

	#REMOVE LATER
	la $s1, board
	jr $ra


	YouX:
		#print message that the user is playing X
		la $a0, playerX
		li $v0, 4
		syscall
		
		#set s6 (control variable) to x
		move $s6, $t2
		
	la $s1, board
	jr $ra

#print out the board with cell numbers	
board_demo: 
	la $a0, row1
	li $v0, 4
	syscall
	
	la $a0, rows
	li $v0, 4
	syscall
	
	la $a0, row2
	li $v0, 4
	syscall
	
	la $a0, rows
	li $v0, 4
	syscall
	
	la $a0, row3
	li $v0, 4
	syscall
	
	
	jr $ra
	
	
	
	
user_input:	
	#print cell message
	la $a0, cell_msg
	li $v0, 4
	syscall

	#read cell number from user
	li $v0, 5
	syscall
	
	#checks if the position is already taken
	move $t6, $v0
	addi $t6, $t6, -1  
	mul $t6, $t6, 4  
	lw $s7, board($t6)	
	bgt $s7, $0, unavailable 
	
	#pass in v0
	move $a0, $v0
	jr $ra
	
unavailable:
	la $a0, unavailable_msg		#prints a message telling playerposition is unavailableand to choose another 
	li $v0, 4
	syscall
	
	j user_input

place_cell:
	#push registers to stack
	sw $t0, ($sp)
	subi $sp, $sp, 4
	#procedure body
	#t0 = $a0 - 1 * 4
	#this is the index to replace in the table
	subi $a0, $a0, 1
	mul $t0, $a0, 4
		
	#t1 = s1 (board) + t0 (offset)
	add $t1, $s1, $t0
		
	#t2 = value from table
	lw $t2, ($t1)
		
	#is there already a value in the table? (is it not 0?)
	#I HAVE NOT ADDED THIS YET
		
	sw $s6, ($t1)
	#result	
	#restore any registers
	lw $t0, ($sp)
	addi $sp, $sp, 4
	#return
	jr $ra

curr_board:
	#display the current board
	#used after each player finishes a move
	
	move $t0, $s1
	add $t1, $s1, 36

	#build the rows
	buildAllRow:
		beq $t0, $t1, exitBuildAllRow
		
		#print " "
		la $a0, space
		li $v0, 4
		syscall
		
		li $t2, 0
		buildRow:
			beq $t2, 3, exitBuildRow
			
			#print " "
			la $a0, space
			li $v0, 4
			syscall
		
			#print table entry
			lw $a0, ($t0)
			li $v0, 1
			syscall
		
			#print " "
			la $a0, space
			li $v0, 4
			syscall
		
			#print "|"
			la $a0, cols
			li $v0, 4
			syscall
			
			addi $t2, $t2, 1
			addi $t0, $t0, 4
			j buildRow
		exitBuildRow:
		
		#print "\n-----+-----+-----\n" 
		la $a0, rows
		li $v0, 4
		syscall
		
		j buildAllRow
	exitBuildAllRow:

	jr $ra

switch_player_control:

	#x is 1
	beq $s6, 1, switchToO	
	li $s6, 1
	jr $ra
	
	switchToO: li $s6, 2
	jr $ra
	
	
#check_win_condition: #runs win1,win2,wni3 checks
#check values in the board table to see if a match 3 has been made.
	#if it has, check which numbers in the winning match correspond to which player.
	#for example, a table of [1,0,2,  0,1,2,  2,0,1] is a winning match.
	#the player who made the match is player 1.


#will add later if logic seems correct

	
	
win1: 
#checks horizontal spaces for win [0,1,2]
addi $t6, $0, 0 # spot 0
lw $t7, board($t6)
addi $t6, $0, 4 # spot 1
lw $t8, board($t6)
addi $t6, $0, 8  # spot 2
lw $t9, board($t6)
and $t4, $t7, $t8 # $t4 = $t7 and $t8 (0 and 1)
and $t5, $t4, $t9 # $t5 = $t4 and $t9 (0 and 1 and 2)
#beq $t5, $7, is_valid

jr $ra
	
win2:
#checks vertical spaces for win [0,3,6]


	
win3:
#checks diagonal spaces for win [0,4,8]
	
#is_valid
#checks to see if there are inputs and not spaces
#bne $t5, $0 #will add later - goes to loop that displays if player or cpu won 
#jr $ra
	
	
	
	
jr $ra
	
randomizer:
		
	#max number (0-8)
	addi $a1, $zero, 9
	
	#random int into a0
	addi $v0, $zero, 42
	syscall
	
	#add 1 to a0 so range is 1-9
	addi $a0, $a0, 1
	
	#checks if the position is already taken
	move $t6, $a0
	addi $t6, $t6, -1  
	mul $t6, $t6, 4  
	lw $s7, board($t6)	
	bgt $0, $s7, randomizer 
	
	
	jr $ra
	
#-------------------------------------------------------------------------------------------------------------------------------

hardBot:
	# used to initialize x and o values
	li $s4, 1
	li $s5, 2
	 
	# store return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# All the different combinations for a win
	
	# Row 1: 
	li $t6, 0 
	lw $t7, board($t6)	# position 1
	li $t6, 4 
	lw $t8, board($t6)	# position 2
	li $t6, 8  
	lw $t9, board($t6)	# position 3
	
	Row1_1:	
		li $t6, 8		# 3rd position on the board
		lw $s7, board($t6)	# Get the value in position 3
		bgt $s7, $0, Row1_2	# If there is already a Xor an O in this position, move on to check the next combination		
		beq $t7, $t8, P3	# If position 2 and 3 have the same value, have a character be placed in position 3 to either win or stop opponent
	Row1_2:
		li $t6, 4
		lw $s7, board($t6)
		bgt $s7, $0, Row1_3
		beq $t7, $t9, P2
	Row1_3:
		li $t6, 0
		lw $s7, board($t6)
		bgt $s7, $0, Row2_1
		beq $t8, $t9, P1
	
	# Row 2:
	li $t6, 12 
	lw $t7, board($t6)	# position 4
	li $t6, 16 
	lw $t8, board($t6)	# position 5
	li $t6, 20  
	lw $t9, board($t6)	# position 6
	
	Row2_1:
		li $t6, 20
		lw $s7, board($t6)
		bgt $s7, $0, Row2_2
		beq $t7, $t8, P6
	Row2_2:
		li $t6, 16
		lw $s7, board($t6)
		bgt $s7, $0, Row2_3
		beq $t7, $t9, P5
	Row2_3:
		li $t6, 12
		lw $s7, board($t6)
		bgt $s7, $0, Row3_1
		beq $t8, $t9, P4
		
	# Row 3: 
	li $t6, 24 
	lw $t7, board($t6)	# position 7
	li $t6, 28 
	lw $t8, board($t6)	# position 8
	li $t6, 32  
	lw $t9, board($t6)	# position 9
	
	Row3_1:
		li $t6, 32
		lw $s7, board($t6)
		bgt $s7, $0, Row3_2
		beq $t7, $t8, P9
	Row3_2:
		li $t6, 28
		lw $s7, board($t6)
		bgt $s7, $0, Row3_3
		beq $t7, $t9, P8
	Row3_3:
		li $t6, 24
		lw $s7, board($t6)
		bgt $s7, $0, Column1_1
		beq $t8, $t9, P7
		
	# Column 1:
	li $t6, 0
	lw $t7, board($t6)	# position 1
	li $t6, 12 
	lw $t8, board($t6)	# position 4
	li $t6, 24 
	lw $t9, board($t6)	# position 7
	
	Column1_1:
		li $t6, 24
		lw $s7, board($t6)
		bgt $s7, $0, Column1_2
		beq $t7, $t8, P7
	Column1_2:
		li $t6, 12
		lw $s7, board($t6)
		bgt $s7, $0, Column1_3
		beq $t7, $t9, P4
	Column1_3:
		li $t6, 0
		lw $s7, board($t6)
		bgt $s7, $0, Column2_1
		beq $t8, $t9, P1
	
	# Column 2:
	li $t6, 4 
	lw $t7, board($t6)	# position 2
	li $t6, 16 
	lw $t8, board($t6)	# position 5
	li $t6, 28  
	lw $t9, board($t6)	# position 8
	
	Column2_1:
		li $t6, 28
		lw $s7, board($t6)
		bgt $s7, $0, Column2_2
		beq $t7, $t8, P8
	Column2_2:
		li $t6, 16
		lw $s7, board($t6)
		bgt $s7, $0, Column2_3
		beq $t7, $t9, P5
	Column2_3:
		li $t6, 4
		lw $s7, board($t6)
		bgt $s7, $0, Column3_1
		beq $t8, $t9, P2

	# Column 3:
	li $t6, 8 
	lw $t7, board($t6)	# position 3
	li $t6, 20 
	lw $t8, board($t6)	# position 6
	li $t6, 32  
	lw $t9, board($t6)	# position 9
	
	Column3_1:
		li $t6, 32
		lw $s7, board($t6)
		bgt $s7, $0, Column3_2
		beq $t7, $t8, P9
	Column3_2:
		li $t6, 20
		lw $s7, board($t6)
		bgt $s7, $0, Column3_3
		beq $t7, $t9, P6
	Column3_3:
		li $t6, 8
		lw $s7, board($t6)
		bgt $s7, $0, Diagonal1_1
		beq $t8, $t9, P3
		
	# All combinations to win diagonaly
	
	# Diagonal 1:
	li $t6, 24 
	lw $t7, board($t6)	# position 7
	li $t6, 16 
	lw $t8, board($t6)	# position 5
	li $t6, 8  
	lw $t9, board($t6)	# position 3
	
	Diagonal1_1:
		li $t6, 8
		lw $s7, board($t6)
		bgt $s7, $0, Diagonal1_2
		beq $t7, $t8, P3
	Diagonal1_2:
		li $t6, 16
		lw $s7, board($t6)
		bgt $s7, $0, Diagonal1_3
		beq $t7, $t9, P5
	Diagonal1_3:
		li $t6, 24
		lw $s7, board($t6)
		bgt $s7, $0, Diagonal2_1
		beq $t8, $t9, P7
	
	# Diagonal 2:
	li $t6, 0 
	lw $t7, board($t6)	# position 1
	li $t6, 16 
	lw $t8, board($t6)	# position 5
	li $t6, 32  
	lw $t9, board($t6)	# position 9
	
	Diagonal2_1:
		li $t6, 32
		lw $s7, board($t6)
		bgt $s7, $0, Diagonal2_2
		beq $t7, $t8, P9
	Diagonal2_2:
	
		li $t6, 16
		lw $s7, board($t6)
		bgt $s7, $0, Diagonal2_3
		beq $t7, $t9, P5
	Diagonal2_3:
		li $t6, 0
		lw $s7, board($t6)
		bgt $s7, $0, random
		beq $t8, $t9, P1
	
	random:
		jal randomizer	# if there are no possibilities to win or prevent a win, take a random spot 
		mul $a0, $a0, 4
		sw $s6, board($a0)	# saves the character in this position of the board
	j switchBack	# to exit this loop
	
	P1:	# puts a character in position 1
		li $t6, 0
		sw $s6, board($t6)	# saves the character in this position of the board
		j switchBack	# to exit the hardBot loop
	P2:
		li $t6, 4
		sw $s6, board($t6)
		j switchBack
	P3:
		li $t6, 8
		sw $s6, board($t6)
		j switchBack
	P4:
		li $t6, 12
		sw $s6, board($t6)
		j switchBack
	P5:
		li $t6, 16
		sw $s6, board($t6)
		j switchBack
	P6:
		li $t6, 20
		sw $s6, board($t6)
		j switchBack
	P7:
		li $t6, 24
		sw $s6, board($t6)
		j switchBack
	P8:
		li $t6, 28
		sw $s6, board($t6)
		j switchBack
	P9:
		li $t6, 32
		sw $s6, board($t6)
		j switchBack
		
	switchBack:	# to exit this loop
		lw $ra, 0($sp)	# get original 
		addi $sp, $sp, 4	# reset stack pointer
		jr $ra	# jump back to return address
		
#-------------------------------------------------------------------------------------------------------------------------------

exit: 
	li $v0, 10
     	syscall 
      

# checks for a win
check_win_condition:

	addi $sp, $sp, -4	
	sw $ra, 0($sp)

	# Row 1: 
	li $t6, 0 
	lw $t7, board($t6)	# position 1
	li $t6, 4 
	lw $t8, board($t6)	# position 2
	li $t6, 8  
	lw $t9, board($t6)	# position 3
	
	jal checkForWin
	
	# Row 2: 
	li $t6, 12 
	lw $t7, board($t6)	# position 4
	li $t6, 16 
	lw $t8, board($t6)	# position 5
	li $t6, 20  
	lw $t9, board($t6)	# position 6
	
	jal checkForWin
	
	# Row 3: 
	li $t6, 24 
	lw $t7, board($t6)	# position 7
	li $t6, 28 
	lw $t8, board($t6)	# position 8
	li $t6, 32  
	lw $t9, board($t6)	# position 9
	
	jal checkForWin
	
	# Column 1:
	li $t6, 0
	lw $t7, board($t6)	# position 1
	li $t6, 12 
	lw $t8, board($t6)	# position 4
	li $t6, 24 
	lw $t9, board($t6)	# position 7
	
	jal checkForWin
	
	# Column 2:
	li $t6, 4
	lw $t7, board($t6)	# position 2
	li $t6, 16 
	lw $t8, board($t6)	# position 5
	li $t6, 28 
	lw $t9, board($t6)	# position 8
	
	jal checkForWin
	
	# Column 3:
	li $t6, 8
	lw $t7, board($t6)	# position 3
	li $t6, 20 
	lw $t8, board($t6)	# position 6
	li $t6, 32 
	lw $t9, board($t6)	# position 9
	
	jal checkForWin
	
	# Diagonal 1:
	li $t6, 24 
	lw $t7, board($t6)	# position 7
	li $t6, 16 
	lw $t8, board($t6)	# position 5
	li $t6, 8  
	lw $t9, board($t6)	# position 3
	
	jal checkForWin
	
	# Diagonal 2:
	li $t6, 0
	lw $t7, board($t6)	# position 1
	li $t6, 16 
	lw $t8, board($t6)	# position 5
	li $t6, 32  
	lw $t9, board($t6)	# position 9
	
	jal checkForWin
	
	lw $ra, 0($sp)	# get origina
	addi $sp, $sp, 4	# reset stack pointer
	jr $ra	# jump back to return address
	
checkForWin:
	add $t7, $t7, $t8	# adds the values of the rows
	add $t9, $t9, $t7
	li $t6, 3
	beq  $t9, $t6, printWinX	# if the sum is three then there are 3 Xs
	li $t6, 6
	beq  $t9, $t6, printWinO	# if the sum is six then there are 3 Os
	
	jr $ra
	
printWinX:
	la $a0, gameOver_msg
	li $v0, 4
	syscall
	
	la $a0, x
	li $v0, 4
	syscall
	
	j exit
	
printWinO:
	la $a0, gameOver_msg
	li $v0, 4
	syscall
	
	la $a0, o
	li $v0, 4
	syscall
	
	j exit
	







