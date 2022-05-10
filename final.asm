#Min Jung, Victor Phan, Owen Lovett, Bailey Chean, _____  -- 5/15/2022
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
gamemode_msg: .asciiz "\nEnter 1 for PVP or 2 to play against the computer (easy): "
win_msg: .asciiz "We have a winner!"
winner_player_X: .asciiz "Player X! \n"
winner_player_O: .asciiz "Player O! \n"
winner_computer: .asciiz "the Computer! \n"
out_of_bounds: .asciiz "Please enter a valid input!\n"
already_there: .asciiz "There's already a tile there!\n"

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
	invalidGameTypeLoop:
		beq $s3, 1, validGameTypeInput
	
		#print gamemode message
		la $a0, gamemode_msg
		li $v0, 4
		syscall
	
		#make user input their choice (1 for pvp and 2 for computer(easy))
		li $v0, 5
		syscall
	
		move $a0, $v0
		li $a1, 1
		li $a2, 2
		jal validation
		
		move $s3, $v0
		move $s4, $a0
		
		j invalidGameTypeLoop
	validGameTypeInput:
	
	#initialize value for computer(easy)
	li $s5, 2
	
	#allow user to choose to play either X or O
	jal choose_char
	
	#jump to make_board to print out the board setting
	jal board_demo 
	
	# if user imputs 2 then jump to gameLoopEasy
	beq $s4, $s5, gameLoopEasy
	
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
		
choose_char:
	#save ra in sp
	subi $sp, $sp, 4
	sw $ra, ($sp)

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
		
		move $a0, $v0
		li $a1, 1
		li $a2, 2
		jal validation
		
		move $s3, $v0
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
		#save ra in sp
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
	
#validation
#a0 will define the input
#a1 = lower bound
#a2 = upper bound
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
		
check_if_not_overwriting:
	#locate corresponding value in table
	mul $t0, $a0, 4
	subi $t0, $t0, 4
	
	#t1 = s1 (board) + t0 (offset)
	add $t1, $s1, $t0
	
	#t2 = value from table
	lw $t2, ($t1)
	
	bne $t2, 0, cannotOverwrite
	
	li $v0, 1
	jr $ra
	
	cannotOverwrite:
		la $a0, already_there
		li $v0, 4
		syscall
		li $v0, 0
		jr $ra
	
user_input:	
	#push to stack
	subi $sp, $sp, 4
	sw $ra, ($sp)
	
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
		
		move $a0, $v0
		li $a1, 1
		li $a2, 9
		jal validation
		
		move $s3, $v0
		move $v0, $a0
		
		jal check_if_not_overwriting
		move $s3, $v0
	
		j invalidInputLoop
	validInput:
	
	#pop from stack
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	jr $ra

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
	#TODO
		
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

	#store $ra
	subi $sp, $sp, 4
	sw $ra, ($sp)

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
	
	#pop $ra
	lw $ra, ($sp)
	addi $sp, $sp, 4

	jr $ra

print_symbol:
	#a0 - a value from board (s1)
	beq $a0, 1, printOne
	beq $a0, 2, printTwo
	
	la $a0, space
	
	li $v0, 4
	syscall
	jr $ra
	
	printOne: la $a0, x
	
	li $v0, 4
	syscall
	jr $ra
	
	printTwo: la $a0, o
	
	li $v0, 4
	syscall
	jr $ra

switch_player_control:
	#x is 1
	beq $s6, 1, switchToO	
	li $s6, 1
	jr $ra
	
	switchToO: li $s6, 2
	jr $ra
	
	
check_win_condition:
#check values in the board table to see if a match 3 has been made.
	#if it has, check which numbers in the winning match correspond to which player.
	#for example, a table of [1,0,2,  0,1,2,  2,0,1] is a winning match.
	#the player who made the match is player 1.

#save ra in sp
	subi $sp, $sp, 4
	sw $ra, ($sp)

#procedure
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

#pop ra from sp
	lw $ra, ($sp)
	addi $sp, $sp, 4

#return
	jr $ra

checkLine:
#a0 - a2   -   indices of positions to check
#a3 - which player to check for
#s1 - base address of board
#s6 - the player during this turn (1 for X, 2 for O)

#procedure
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

#return
	getOut: jr $ra
			
randomizer:
	#max number (0-8)
	addi $a1, $zero, 9
	
	#random int into a0
	addi $v0, $zero, 42
	syscall
	
	#add 1 to a0 so range is 1-9
	addi $a0, $a0, 1
	jr $ra

exit: 
	la $a0, win_msg
	li $v0, 4
	syscall
	
	li $v0, 10
     	syscall 
      
#end of program
