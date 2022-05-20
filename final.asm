#Min Jung, Victor Phan, Owen Lovett, Bailey Chean, Sunveer Bhullar -- 5/15/2022
#final.asm
#Description: Create Tic-Tac -Toe game using MIPS
#	Display game board.
#	Allow user input.
#	Allow PVP and P V. Computer

#Registers used:
#	s1 - the board table (see .data)
#	s2 - win state. If 0, no winner. If 1, somebody has won. Depends on what s6 is
#	s6 - player control variable. If 1, player X is in control. If 2, player O is in control.
#	s3 - input flag. If 1, input is valid. If 0, input is invalid.
#	s4 - store user input their choice (1 for pvp and 2 for computer(easy))
#	s5 - initialize value for computer(easy)
# 	v0
#	a0
#	a1
#	t0- t0 = $a0 - 1 * 4  (used in place_cell)
#	t1- t1 = s1 (board) + t0 (offset)  (used  in place_cell)
#	t2 - to store value from , also to initialize X as 1
#	t3 - use to initialize O as 2
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
computer_msg: .asciiz "Computer's turn.\n\n"
playerX_msg: .asciiz "Player X's turn\n\n"
playerO_msg: .asciiz "Player O's turn\n\n"
gamemode_msg: "\nEnter 1 for PVP, 2 to play against the computer (easy), or 3 to play against the computer (hard): "
win_msg: .asciiz "We have a winner!"
winner_is: .asciiz "The winner is... \n"
winner_player_X: .asciiz "Player X! \n"
winner_player_O: .asciiz "Player O! \n"
out_of_bounds: .asciiz "Please enter a valid input!\n"
already_there: .asciiz "There's already a tile there!\n"
draw_msg: .asciiz "We have a draw!"

board: .word 0, 0, 0, 0, 0, 0, 0, 0, 0

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
	
	#make sure user input is valid
	#s3 represents whether an input is valid or not.
	#	0 = invalid
	#	1 = valid
	invalidGameTypeLoop:
		beq $s3, 1, validGameTypeInput
	
		#print gamemode message
		la $a0, gamemode_msg
		li $v0, 4
		syscall
	
		#make user input their choice (1 for pvp, 2 for computer(easy), and 3 for computer(hard))
		li $v0, 5
		syscall
	
		#validation(a0, 1, 3)
		#will check is a0 is between 1 and 3 (inclusive)
		move $a0, $v0
		li $a1, 1
		li $a2, 3
		jal validation
		
		#save result to s3
		move $s3, $v0
		
		#save input to s4
		move $s4, $a0
		
		j invalidGameTypeLoop
	validGameTypeInput:
	
	
	#allow user to choose to play either X or O
	jal choose_char
	
	#jump to make_board to print out the board setting
	jal board_demo 
	
	# if user imputs 2 then jump to gameLoopEasy
	beq $s4, 2, gameLoopEasy
	
	#if user inputs 3 then jump to gameLoopHard
	beq $s4, 3, gameLoopHard
	
	gameLoop:	
		beq $s2, 1, exitGameLoop
		
		#get user input
		jal user_input
	
		#set new value for table
		jal place_cell

		#print out the board
		jal curr_board
	
		#did someone win?
		#if someone won, we jump straight to the exit
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
		#if someone won, we jump straight to the exit
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
		
	gameLoopHard:
		beq $s2, 1, exitGameLoop
	
		#get user input
		jal user_input
	
		#set new value for table
		jal place_cell

		#print out the board
		jal curr_board
		
		#did someone win?
		#if someone won, we jump straight to the exit
		jal check_win_condition
		
		# checks if all positions are filled in the case of a tie
		jal check_if_full
		
		#switch control to other player
		jal switch_player_control
		
		#computer move
		jal HardAI
		
		#print computer
		la $a0, computer_msg
		li $v0, 4
		syscall
		
		#print out the board
		jal curr_board
		
		#did someone win?
		jal check_win_condition
		
		# checks if all positions are filled in the case of a tie
		jal check_if_full
		
		#switch control to other player
		jal switch_player_control

		j gameLoopHard
	
	exitGameLoopHard:
		j exit
		

#function:
#	will allow user to choose which symbol they want.
#	asks user for input from 1 to 2.
#		1 = X
#		2 = O
#registers:
#	sp - stack pointer
#	ra - return addres
#	s3 - whether an input is valid or not.
#		0 = invalid
#		1 = valid
#	a0 - user's input (that is then saved to t0)
#	v0 - output of validation function (that is then saved to s3)
#	t0 - user's input
#	t2 - const 1
#	t3 - const 2
#	s6 - control variable
#		1 - player X's turn
#		2 - player O's turn
choose_char:
	#push ra in sp
	subi $sp, $sp, 4
	sw $ra, ($sp)

	#assume that user input will be invalid
	li $s3, 0

	invalidCharInput:
		beq $s3, 1, validCharInput
		
		#print message
		la $a0, choose_msg
		li $v0, 4
		syscall
	
		#make user input their choice (1 for X and 2 for O)
		li $v0, 5
		syscall
		
		#validation(a0, 1, 2)
		#will check is a0 is between 1 and 2 (inclusive)
		move $a0, $v0
		li $a1, 1
		li $a2, 2
		jal validation
		
		#save result to s3
		move $s3, $v0
		
		#save input to t0
		move $t0, $a0	
		
		j invalidCharInput
	validCharInput:
	
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

	j selected

	YouX:
		#print message that the user is playing X
		la $a0, playerX
		li $v0, 4
		syscall
		
		#set s6 (control variable) to x
		move $s6, $t2
		
	selected:	
		#pop ra from sp
		lw $ra, ($sp)
		addi $sp, $sp, 4
	
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


#function:
#	will determine if an input is between a min and max (inclusive)
#registers:
#	ra - return addres
#	a0 - value to determine
#	a1 - min
#	a2 - max
#	v0 - output
#		0 - invalid
#		1 - valid
validation:
	blt $a0, $a1, invalid
	bgt $a0, $a2, invalid
	
	li $v0, 1
	jr $ra
	
	invalid:
		la $a0, out_of_bounds
		li $v0, 4
		syscall
		li $v0, 0
		jr $ra
		
#function:
#	will determine if a desired location on the board has been taken.
#registers:
#	ra - return addres
#	s3 - whether an input is valid or not.
#		0 = invalid
#		1 = valid
#	a0 - value to determine
#	t0 - offset for table lookup
#	t1 - address of desired location in board
#	t2 - value at address t1
#	v0 - output
#		0 - invalid (user is trying to overwrite)
#		1 - valid (spot is empty)
check_if_not_overwriting:
	#locate corresponding value in table
	mul $t0, $a0, 4
	subi $t0, $t0, 4
	
	#t1 = s1 (board) + t0 (offset)
	add $t1, $s1, $t0
	
	#t2 = value from table
	lw $t2, ($t1)
	
	#is the spot empty?
	bne $t2, 0, cannotOverwrite
	
	#if so, we're good to go
	li $v0, 1
	jr $ra
	
	#if not, print a warning
	cannotOverwrite:
		la $a0, already_there
		li $v0, 4
		syscall
		li $v0, 0
		jr $ra
	
#function:
#	will allow user to specify location on a board to play
#	from 1 to 9 (inclusive)
#registers:
#	sp - stack pointer
#	ra - return address
#	s3 - whether an input is valid or not.
#		0 = invalid
#		1 = valid
#	a0 - value to determine
#	t0 - offset for table lookup
#	t1 - address of desired location in board
#	t2 - value at address t1
#	v0 - output
#		0 - invalid (user is trying to overwrite)
#		1 - valid (spot is empty)
user_input:	
	#push to stack
	subi $sp, $sp, 4
	sw $ra, ($sp)
	
	#assume input is invalid
	li $s3, 0
	
	invalidInputLoop:
		beq $s3, 1, validInput
	
		#print cell message
		la $a0, cell_msg
		li $v0, 4
		syscall
	
		#read cell number from user
		li $v0, 5
		syscall
		
		#validation(a0, 1, 9)
		#will check is a0 is between 1 and 9 (inclusive)
		move $a0, $v0
		li $a1, 1
		li $a2, 9
		jal validation
		
		#save result to s3
		move $s3, $v0
		
		jal check_if_not_overwriting
		
		#save result to s3
		move $s3, $v0
	
		j invalidInputLoop
	validInput:
	
	#pop from stack
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	jr $ra


#function:
#	writes new value into table
#registers:
#	ra - return address
#	s3 - whether an input is valid or not.
#		0 = invalid
#		1 = valid
#	a0 - index to place tile on (assume empty spot)
#	t0 - offset for table lookup
#	t1 - address of desired location in board
#	s6 - control variable
#		1 - player X's turn
#		2 - player O's turn
place_cell:
	#t0 = $a0 - 1 * 4
	#this is the index to replace in the table
	subi $a0, $a0, 1
	mul $t0, $a0, 4
		
	#t1 = s1 (board) + t0 (offset)
	add $t1, $s1, $t0
		
	#save current player's symbol in table location
	sw $s6, ($t1)
	
	#return
	jr $ra


#function:
#	displays the current board
#registers:
#	ra - return address
#	a0 - arguments for syscall
#	v0 - syscall variable
#	t0 - indices of table units (from units 1 to 9)
#	t1 - stopper for t0
#	t2 - which tile in the row you are currently on
curr_board:
	#push $ra to stack
	subi $sp, $sp, 4
	sw $ra, ($sp)

	#i = 0
	move $t0, $s1
	#max = 36
	add $t1, $s1, 36

	#build the rows
	buildAllRow:
		#while (i<=36)
		beq $t0, $t1, exitBuildAllRow
		
		#print " "
		la $a0, space
		li $v0, 4
		syscall
		
		#j = 0
		li $t2, 0
		buildRow:
			#while (j<=3)
			beq $t2, 3, exitBuildRow
			
			#print " "
			la $a0, space
			li $v0, 4
			syscall
		
			#print_symbol(a0)
			lw $a0, ($t0)
			jal print_symbol
		
			#print " "
			la $a0, space
			li $v0, 4
			syscall
		
			#print "|"
			la $a0, cols
			li $v0, 4
			syscall
			
			#j++
			addi $t2, $t2, 1
			
			#i+=4
			addi $t0, $t0, 4
			j buildRow
		exitBuildRow:
		
		#print "\n-----+-----+-----\n" 
		la $a0, rows
		li $v0, 4
		syscall
		
		j buildAllRow
	exitBuildAllRow:
	
	#pop $ra
	lw $ra, ($sp)
	addi $sp, $sp, 4

	jr $ra


#function:
#	prints requested symbols
#registers:
#	ra - return address
#	a0 - value from table to print/arguments for syscall
#	v0 - syscall variable
print_symbol:
	#if a0 is 1, print "X"
	beq $a0, 1, printOne
	
	#if a0 is 2, print "O"
	beq $a0, 2, printTwo
	
	#if a0 is 0, print " "
	la $a0, space
	li $v0, 4
	syscall
	jr $ra
	
	#print "X"
	printOne: la $a0, x
	
	li $v0, 4
	syscall
	jr $ra
	
	#print "O"
	printTwo: la $a0, o
	
	li $v0, 4
	syscall
	jr $ra


#function:
#	switches control of t6 from 1 to 2 and vice-versa
#registers:
#	ra - return address
#	s6 - control variable
#		1 - player X's turn
#		2 - player O's turn
switch_player_control:
	beq $s6, 1, switchToO	
	li $s6, 1
	jr $ra
	
	switchToO: li $s6, 2
	jr $ra
	
check_if_full:
	li $t0, 0
	
	#loop through board to see if all values are nonzero
	checkEmptyLoop:
		bgt $t0, 32, checkEmptyExit
		
		#t1 = address of next tile from board
		add $t1, $t0, $s1
		
		#t2 = value of next tile from board
		lw $t2, ($t1)
		
		#there exists an empty tile
		beq $t2, $zero, foundEmptyTile
		
		addi $t0, $t0, 4
		j checkEmptyLoop
		
	checkEmptyExit:
		#there were no empty tiles found
		#we can't place anything anymore
		#we can conclude that no player has won at this point
		
		li $s6, 0 #0 = no one won
		j exit
	
	foundEmptyTile:
		#there exists an empty tile
		#we can continue like normal
		jr $ra
	
#function:
#	check values in the board table to see if a match 3 has been made.
#		if it has, check which numbers in the winning match correspond to which player.
#		for example, a table of [1,0,2,  0,1,2,  2,0,1] is a winning match.
#		the player who made the match is player 1.
#registers:
#	sp - stack pointer
#	ra - return address
#	a0-a2 - indices of positions to check
check_win_condition:

	#save ra in sp
	subi $sp, $sp, 4
	sw $ra, ($sp)

	#HORIZONTAL
	li $a0, 0
	li $a1, 4
	li $a2, 8
	jal checkLine
	
	li $a0, 12
	li $a1, 16
	li $a2, 20
	jal checkLine
	
	li $a0, 24
	li $a1, 28
	li $a2, 32
	jal checkLine
	
	#VERTICAL
	li $a0, 0
	li $a1, 12
	li $a2, 24
	jal checkLine
	
	li $a0, 4
	li $a1, 16
	li $a2, 28
	jal checkLine
	
	li $a0, 8
	li $a1, 20
	li $a2, 32
	jal checkLine
	
	#DIAGONAL
	li $a0, 0
	li $a1, 16
	li $a2, 32
	jal checkLine
	
	li $a0, 8
	li $a1, 16
	li $a2, 24
	jal checkLine

	#Check if we have any empty tiles
	jal check_if_full

	#pop ra from sp
	lw $ra, ($sp)
	addi $sp, $sp, 4

	jr $ra


#function:
#	checks to see if 3 given values match the current player's value.
#registers:
#	ra - return address
#	a0-a2 - indices of positions to check
#	s1 - base address of board
#	t0-t2 - values from table
#	t3-t5 - address locations
#	s6 - control variable
#		1 - player X's turn
#		2 - player O's turn
checkLine:
	#create address locations
	add $t3, $a0, $s1
	add $t4, $a1, $s1
	add $t5, $a2, $s1

	#get values from table
	lw $t0, ($t3)
	lw $t1, ($t4)
	lw $t2, ($t5)

	#do any of these values not match $s6?
	bne $t0, $s6, getOut
	bne $t1, $s6, getOut
	bne $t2, $s6, getOut

	#we have a match
	j exit

	getOut: jr $ra
			
HardAI:
	# used to check if 2 values are equal
	li $s4, 1
	li $t5, 4
	 
	# store return address
	li $sp, 0
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	# All the different combinations for a win
	Row1_1:	
		# Used to call the function to get the values in the row
		jal SetRow1
		
		# Checks if position is taken 
		li $t6, 8		# 3rd position on the board
		lw $s7, board($t6)	# Get the value in position 3
		bgt $s7, $0, Row1_2	# If there is already a character in this position, move on to the next combination		
		
		# Checks if computer can get a win
		add $s7, $t7, $t8	# Add the two values, Ex. 1+1=2, 1+2=3, 2+2=4
		beq $t5, $s7, P3	# If if the sum of the values in position 1 and 2 == 4 then place an O in position 3
		j Row1_2	# Go to next combination

		# To prevent the player from winning
		PreventRow1_1Win:
			jal SetRow1	# Get the values in the row
			li $t6, 8	# 3rd position on the board
			lw $s7, board($t6)	# Get the value in position 3
			bgt $s7, $0, PreventRow1_2Win	# If there is already a character in this position, move on to the next combination	
		
			mult $t7, $t8	# Multiply the values in position 2 and 3 
			mflo $s7	# Put the result in $s7
			beq $s7, $s4, P3	# 1x1 = 1, so if both == 1 then take position 3 to prevent a win
			j PreventRow1_2Win	# Go to next prevent win combination

	Row1_2:
		# Checks if position is taken 
		li $t6, 4
		lw $s7, board($t6)
		bgt $s7, $0, Row1_3
		
		# Checks if computer can get a win
		add $s7, $t7, $t9
		beq $t5, $s7, P2
		j Row1_3
		
		# To prevent the player from winning
		PreventRow1_2Win:
			li $t6, 4
			lw $s7, board($t6)
			bgt $s7, $0, PreventRow1_3Win
		
			mult $t7, $t9
			mflo $s7
			beq $s7, $s4, P2
			j PreventRow1_3Win
		

	Row1_3:
		# Checks if position is taken 
		li $t6, 0
		lw $s7, board($t6)
		bgt $s7, $0, Row2_1
		
		# Checks if computer can get a win
		add $s7, $t8, $t9
		beq $t5, $s7, P1
		j Row2_1
		
		# To prevent the player from winning
		PreventRow1_3Win:
			li $t6, 0
			lw $s7, board($t6)
			bgt $s7, $0, PreventRow2_1Win
		
			mult $t8, $t9
			mflo $s7
			beq $s7, $s4, P1
			j PreventRow2_1Win
		
	
	
	Row2_1:
		# Checks if position is taken 
		jal SetRow2
		li $t6, 20
		lw $s7, board($t6)
		bgt $s7, $0, Row2_2
		
		# Checks if computer can get a win
		add $s7, $t7, $t8
		beq $t5, $s7, P6
		j Row2_2
		
		# To prevent the player from winning
		PreventRow2_1Win:
			jal SetRow2
			li $t6, 20
			lw $s7, board($t6)
			bgt $s7, $0, PreventRow2_2Win
		
			mult $t7, $t8
			mflo $s7
			beq $s7, $s4, P6
			j PreventRow2_2Win

	Row2_2:
		# Checks if position is taken 
		li $t6, 16
		lw $s7, board($t6)
		bgt $s7, $0, Row2_3
		
		# Checks if computer can get a win
		add $s7, $t7, $t9
		beq $t5, $s7, P5
		j Row2_3
		
		# To prevent the player from winning
		PreventRow2_2Win:
			li $t6, 16
			lw $s7, board($t6)
			bgt $s7, $0, PreventRow2_3Win
		
			mult $t7, $t9
			mflo $s7
			beq $s7, $s4, P5
			j PreventRow2_3Win
	
	Row2_3:
		# Checks if position is taken 
		li $t6, 12
		lw $s7, board($t6)
		bgt $s7, $0, Row3_1
		
		# Checks if computer can get a win
		add $s7, $t8, $t9
		beq $t5, $s7, P4
		j Row3_1
		
		# To prevent the player from winning
		PreventRow2_3Win:
			li $t6, 12
			lw $s7, board($t6)
			bgt $s7, $0, PreventRow3_1Win
		
			mult $t8, $t9
			mflo $s7
			beq $s7, $s4, P4
			j PreventRow3_1Win
	
	Row3_1:
		# Checks if position is taken 
		jal SetRow3
		li $t6, 32
		lw $s7, board($t6)
		bgt $s7, $0, Row3_2
		
		# Checks if computer can get a win
		add $s7, $t7, $t8
		beq $t5, $s7, P9
		j Row3_2
		
		# To prevent the player from winning
		PreventRow3_1Win:
			jal SetRow3
			li $t6, 32
			lw $s7, board($t6)
			bgt $s7, $0, PreventRow3_2Win
			
			mult $t7, $t8
			mflo $s7
			beq $s7, $s4, P9
			j PreventRow3_2Win
	
	Row3_2:
		# Checks if position is taken 
		li $t6, 28
		lw $s7, board($t6)
		bgt $s7, $0, Row3_3
		
		# Checks if computer can get a win
		add $s7, $t7, $t9
		beq $t5, $s7, P8
		j Row3_3
		
		# To prevent the player from winning
		PreventRow3_2Win:
			li $t6, 28
			lw $s7, board($t6)
			bgt $s7, $0, PreventRow3_3Win
		
			mult $t7, $t9
			mflo $s7
			beq $s7, $s4, P8
			j PreventRow3_3Win
	
	Row3_3:
		# Checks if position is taken 
		li $t6, 24
		lw $s7, board($t6)
		bgt $s7, $0, Column1_1
		
		# Checks if computer can get a win
		add $s7, $t8, $t9
		beq $t5, $s7, P7
		j Column1_1
		
		# To prevent the player from winning
		PreventRow3_3Win:
			li $t6, 24
			lw $s7, board($t6)
			bgt $s7, $0, PreventColumn1_1Win
		
			mult $t8, $t9
			mflo $s7
			beq $s7, $s4, P7
			j PreventColumn1_1Win
		
	
	Column1_1:
		# Checks if position is taken 
		jal SetColumn1
		li $t6, 24
		lw $s7, board($t6)
		bgt $s7, $0, Column1_2
		
		# Checks if computer can get a win
		add $s7, $t7, $t8
		beq $t5, $s7, P7
		j Column1_2
		
		# To prevent the player from winning
		PreventColumn1_1Win:
			jal SetColumn1
			li $t6, 24
			lw $s7, board($t6)
			bgt $s7, $0, PreventColumn1_2Win

			mult $t7, $t8
			mflo $s7
			beq $s7, $s4, P7
			j PreventColumn1_2Win
	
	Column1_2:
		# Checks if position is taken 
		li $t6, 12
		lw $s7, board($t6)
		bgt $s7, $0, Column1_3
		
		# Checks if computer can get a win
		add $s7, $t7, $t9
		beq $t5, $s7, P4
		j Column1_3
			
		# To prevent the player from winning
		PreventColumn1_2Win:
			li $t6, 12
			lw $s7, board($t6)
			bgt $s7, $0, PreventColumn1_3Win
		
			mult $t7, $t9
			mflo $s7
			beq $s7, $s4, P4
			j PreventColumn1_3Win
	
	Column1_3:
		# Checks if position is taken 
		li $t6, 0
		lw $s7, board($t6)
		bgt $s7, $0, Column2_1
		
		# Checks if computer can get a win
		add $s7, $t8, $t9
		beq $t5, $s7, P1
		j Column2_1
		
		# To prevent the player from winning
		PreventColumn1_3Win:
			li $t6, 0
			lw $s7, board($t6)
			bgt $s7, $0, PreventColumn2_1Win
		
			mult $t8, $t9
			mflo $s7
			beq $s7, $s4, P1
			j PreventColumn2_1Win

	Column2_1:
		# Checks if position is taken 
		jal SetColumn2
		li $t6, 28
		lw $s7, board($t6)
		bgt $s7, $0, Column2_2
		
		# Checks if computer can get a win
		add $s7, $t7, $t8
		beq $t5, $s7, P8
		j Column2_2
		
		# To prevent the player from winning
		PreventColumn2_1Win:
			jal SetColumn2
			li $t6, 28
			lw $s7, board($t6)
			bgt $s7, $0, PreventColumn2_2Win
		
			mult $t7, $t8
			mflo $s7
			beq $s7, $s4, P8
			j PreventColumn2_2Win
	
	Column2_2:
		# Checks if position is taken 
		li $t6, 16
		lw $s7, board($t6)
		bgt $s7, $0, Column2_3
		
		# Checks if computer can get a win
		add $s7, $t7, $t9
		beq $t5, $s7, P5
		j Column2_3
		
		# To prevent the player from winning
		PreventColumn2_2Win:
			li $t6, 16
			lw $s7, board($t6)
			bgt $s7, $0, PreventColumn2_3Win
		
			mult $t7, $t9
			mflo $s7
			beq $s7, $s4, P5
			j PreventColumn2_3Win
	
	Column2_3:
		# Checks if position is taken 
		li $t6, 4
		lw $s7, board($t6)
		bgt $s7, $0, Column3_1
		
		# Checks if computer can get a win
		add $s7, $t8, $t9
		beq $t5, $s7, P2
		j Column3_1
		
		# To prevent the player from winning
		PreventColumn2_3Win:
			li $t6, 4
			lw $s7, board($t6)
			bgt $s7, $0, PreventColumn3_1Win
		
			mult $t8, $t9
			mflo $s7
			beq $s7, $s4, P2
			j PreventColumn3_1Win

	Column3_1:
		# Checks if position is taken 
		jal SetColumn3
		li $t6, 32
		lw $s7, board($t6)
		bgt $s7, $0, Column3_2
		
		# Checks if computer can get a win
		add $s7, $t7, $t8
		beq $t5, $s7, P9
		j Column3_2
		
		# To prevent the player from winning
		PreventColumn3_1Win:
			jal SetColumn3
			li $t6, 32
			lw $s7, board($t6)
			bgt $s7, $0, PreventColumn3_2Win
		
			mult $t7, $t8
			mflo $s7
			beq $s7, $s4, P9
			j PreventColumn3_2Win
		
	Column3_2:
		# Checks if position is taken 
		li $t6, 20
		lw $s7, board($t6)
		bgt $s7, $0, Column3_3
		
		# Checks if computer can get a win
		add $s7, $t7, $t9
		beq $t5, $s7, P6
		j Column3_3
		
		# To prevent the player from winning
		PreventColumn3_2Win:
			li $t6, 20
			lw $s7, board($t6)
			bgt $s7, $0, PreventColumn3_3Win
		
			mult $t7, $t9
			mflo $s7
			beq $s7, $s4, P6
			j PreventColumn3_3Win
	
	Column3_3:
		# Checks if position is taken 
		li $t6, 8
		lw $s7, board($t6)
		bgt $s7, $0, Diagonal1_1
		
		# Checks if computer can get a win
		add $s7, $t8, $t9
		beq $t5, $s7, P3
		j Diagonal1_1
		
		# To prevent the player from winning
		PreventColumn3_3Win:
			li $t6, 8
			lw $s7, board($t6)
			bgt $s7, $0, PreventDiagonal1_1Win
		
			mult $t8, $t9
			mflo $s7
			beq $s7, $s4, P3
			j PreventDiagonal1_1Win
		
	# All combinations to win diagonaly
	Diagonal1_1:
		# Checks if position is taken 
		jal SetDiagonal1
		li $t6, 8
		lw $s7, board($t6)
		bgt $s7, $0, Diagonal1_2
		
		# Checks if computer can get a win
		add $s7, $t7, $t8
		beq $t5, $s7, P3
		j Diagonal1_2
		
		# To prevent the player from winning
		PreventDiagonal1_1Win:
			jal SetDiagonal1
			li $t6, 8
			lw $s7, board($t6)
			bgt $s7, $0, PreventDiagonal1_2Win
		
			mult $t7, $t8
			mflo $s7
			beq $s7, $s4, P3
			j PreventDiagonal1_2Win
		
	Diagonal1_2:
		# Checks if position is taken 
		li $t6, 16
		lw $s7, board($t6)
		bgt $s7, $0, Diagonal1_3
		
		# Checks if computer can get a win
		add $s7, $t7, $t9
		beq $t5, $s7, P5
		j Diagonal1_3
		
		# To prevent the player from winning
		PreventDiagonal1_2Win:
			li $t6, 16
			lw $s7, board($t6)
			bgt $s7, $0, PreventDiagonal1_3Win
		
			mult $t7, $t9
			mflo $s7
			beq $s7, $s4, P5
			j PreventDiagonal1_3Win
	
	Diagonal1_3:
		# Checks if position is taken 
		li $t6, 24
		lw $s7, board($t6)
		bgt $s7, $0, Diagonal2_1
		
		# Checks if computer can get a win
		add $s7, $t8, $t9
		beq $t5, $s7, P7
		j Diagonal2_1
		
		# To prevent the player from winning
		PreventDiagonal1_3Win:
			li $t6, 24
			lw $s7, board($t6)
			bgt $s7, $0, PreventDiagonal2_1Win
		
			mult $t8, $t9
			mflo $s7
			beq $s7, $s4, P7
			j PreventDiagonal2_1Win

	Diagonal2_1:
		# Checks if position is taken 
		jal SetDiagonal2
		li $t6, 32
		lw $s7, board($t6)
		bgt $s7, $0, Diagonal2_2
		
		# Checks if computer can get a win
		add $s7, $t7, $t8
		beq $t5, $s7, P9
		j Diagonal2_2
		
		# To prevent the player from winning
		PreventDiagonal2_1Win:
			jal SetDiagonal2
			li $t6, 32
			lw $s7, board($t6)
			bgt $s7, $0, PreventDiagonal2_2Win
			
			mult $t7, $t8
			mflo $s7
			beq $s7, $s4, P9
			j PreventDiagonal2_2Win
		
	Diagonal2_2:
		# Checks if position is taken 
		li $t6, 16
		lw $s7, board($t6)
		bgt $s7, $0, Diagonal2_3
		
		# Checks if computer can get a win
		add $s7, $t7, $t9
		beq $t5, $s7, P5
		j Diagonal2_3
		
		# To prevent the player from winning
		PreventDiagonal2_2Win:
			li $t6, 16
			lw $s7, board($t6)
			bgt $s7, $0, PreventDiagonal2_3Win
	
			mult $t7, $t9
			mflo $s7
			beq $s7, $s4, P5
			j PreventDiagonal2_3Win
	
	Diagonal2_3:
		# Checks if position is taken 
		li $t6, 0
		lw $s7, board($t6)
		bgt $s7, $0, PreventRow1_1Win
		
		# Checks if computer can get a win
		add $s7, $t8, $t9
		beq $t5, $s7, P1
		j PreventRow1_1Win
		
		# To prevent the player from winning
		PreventDiagonal2_3Win:
			li $t6, 0
			lw $s7, board($t6)
			bgt $s7, $0, random
		
			mult $t8, $t9
			mflo $s7
			beq $s7, $s4, P1
			j random
	
	random:
		jal randomizer	# if there are no possibilities to win or prevent a win, take a random spot 
		mul $a0, $a0, 4
		sw $s6, board($a0)	# saves the character in this position of the board
	j switchBack	# to exit this loop
	
	P1:	# puts a character in position 1
		li $t6, 0	# create a pointer
		sw $s6, board($t6)	# saves the character in this position of the board
		j switchBack	# to exit the HardAI loop
	P2:	# puts a character in position 2
		li $t6, 4	# create a pointer
		sw $s6, board($t6)	# saves the character in this position of the board
		j switchBack	# to exit the HardAI loop
	P3:	# puts a character in position 3
		li $t6, 8	# create a pointer
		sw $s6, board($t6)	# saves the character in this position of the board
		j switchBack	# to exit the HardAI loop
	P4:	# puts a character in position 4
		li $t6, 12	# create a pointer
		sw $s6, board($t6)	# saves the character in this position of the board
		j switchBack	# to exit the HardAI loop
	P5:	# puts a character in position 5
		li $t6, 16	# create a pointer
		sw $s6, board($t6)	# saves the character in this position of the board
		j switchBack	# to exit the HardAI loop
	P6:	# puts a character in position 6
		li $t6, 20	# create a pointer
		sw $s6, board($t6)	# saves the character in this position of the board
		j switchBack	# to exit the HardAI loop
	P7:	# puts a character in position 7
		li $t6, 24	# create a pointer
		sw $s6, board($t6)	# saves the character in this position of the board
		j switchBack	# to exit the HardAI loop
	P8:	# puts a character in position 8
		li $t6, 28	# create a pointer
		sw $s6, board($t6)	# saves the character in this position of the board
		j switchBack	# to exit the HardAI loop
	P9:	# puts a character in position 9
		li $t6, 32	# create a pointer
		sw $s6, board($t6)	# saves the character in this position of the board
		j switchBack	# to exit the HardAI loop
		
	switchBack:	# to exit this loop
		lw $ra, ($sp)	# get original 
		addi $sp, $sp, 4	# reset stack pointer
		jr $ra	# jump back to return address
		
	# Puts the values on the board into registers to check each combination
	# Row 1 
	SetRow1:
	li $t6, 0 
	lw $t7, board($t6)	# position 1
	li $t6, 4 
	lw $t8, board($t6)	# position 2
	li $t6, 8  
	lw $t9, board($t6)	# position 3
	jr $ra
	
	# Row 2
	SetRow2:
	li $t6, 12 
	lw $t7, board($t6)	# position 4
	li $t6, 16 
	lw $t8, board($t6)	# position 5
	li $t6, 20  
	lw $t9, board($t6)	# position 6
	jr $ra
	
	# Row 3
	SetRow3:
	li $t6, 24 
	lw $t7, board($t6)	# position 7
	li $t6, 28 
	lw $t8, board($t6)	# position 8
	li $t6, 32  
	lw $t9, board($t6)	# position 9
	jr $ra
	
	# Column 1
	SetColumn1:
	li $t6, 0
	lw $t7, board($t6)	# position 1
	li $t6, 12 
	lw $t8, board($t6)	# position 4
	li $t6, 24 
	lw $t9, board($t6)	# position 7
	jr $ra	
		
	# Column 2
	SetColumn2:
	li $t6, 4 
	lw $t7, board($t6)	# position 2
	li $t6, 16 
	lw $t8, board($t6)	# position 5
	li $t6, 28  
	lw $t9, board($t6)	# position 8
	jr $ra	
		
	# Column 3
	SetColumn3:
	li $t6, 8 
	lw $t7, board($t6)	# position 3
	li $t6, 20 
	lw $t8, board($t6)	# position 6
	li $t6, 32  
	lw $t9, board($t6)	# position 9
	jr $ra	
		
	# Diagonal 1
	SetDiagonal1:
	li $t6, 24 
	lw $t7, board($t6)	# position 7
	li $t6, 16 
	lw $t8, board($t6)	# position 5
	li $t6, 8  
	lw $t9, board($t6)	# position 3
	jr $ra
	
	# Diagonal 2
	SetDiagonal2:
	li $t6, 0 
	lw $t7, board($t6)	# position 1
	li $t6, 16 
	lw $t8, board($t6)	# position 5
	li $t6, 32  
	lw $t9, board($t6)	# position 9
	jr $ra
			
randomizer:

	#push to stack
	subi $sp, $sp, 4
	sw $ra, ($sp)
	
	#assume input is invalid
	li $s3, 0
	
	random_input:

		# if tile is empty, return placement
		beq $s3, 1, exit_random
	
		#max number (0-8)
		addi $a1, $zero, 9
	
		#random int into a0
		addi $v0, $zero, 42
		syscall
	
		#add 1 to a0 so range is 1-9
		addi $a0, $a0, 1
	
		# check if tile is empty
		jal check_if_not_overwriting_comp
		
		#save result to s3
		move $s3, $v0
	
		j random_input
		
	
	exit_random:
	
		#pop from stack
		lw $ra, ($sp)
		addi $sp, $sp, 4
		
		jr $ra
		
check_if_not_overwriting_comp:
	#locate corresponding value in table
	mul $t0, $a0, 4
	subi $t0, $t0, 4
	
	#t1 = s1 (board) + t0 (offset)
	add $t1, $s1, $t0
	
	#t2 = value from table
	lw $t2, ($t1)
	
	#is the spot empty?
	bne $t2, 0, cannotOverwrite_comp
	
	#if so, we're good to go
	li $v0, 1
	jr $ra
	
	#if not, return
	cannotOverwrite_comp:
		li $v0, 0
		jr $ra

exit: 
	#Is $s6 = 0? (do we have a draw?)
	beq $s6, $zero, noOneWon

	#"We have a winner!"
	la $a0, win_msg
	li $v0, 4
	syscall
	
	#"The winner is..."
	la $a0, winner_is
	li $v0, 4
	syscall
	
	beq $s6, 1, playerXWon
	beq $s6, 2, playerOWon
	
	playerXWon:
		la $a0, winner_player_X
		li $v0, 4
		syscall
		j terminate
	
	playerOWon:
		la $a0, winner_player_O
		li $v0, 4
		syscall
		j terminate
		
	noOneWon:
		la $a0, draw_msg
		li $v0, 4
		syscall
		j terminate
		
terminate:
	li $v0, 10
     	syscall 
      
#end of program
