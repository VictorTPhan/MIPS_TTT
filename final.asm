#Min Jung--04/20/2022
#I/O
# X	print to board 
# X	allow user input  choose the positions
#	output the board with "O" marked on the position they chose
# X	"X" = playerX
# X	"O" = playerO

.data
#tic tac toe board
rows: .asciiz "\n-----+-----+-----\n" 
cols: .asciiz " | " 
board1: .asciiz "    |     |     \n-----+-----+-----\n     |     |     \n-----+-----+-----\n     |     |     "
x: .asciiz " X "
o: .asciiz " O "
#for empty spaces on the board
empty: .asciiz "   "
row1: .asciiz "\n  1  |  2  |  3  "
row2: .asciiz "  4  |  5  |  6  "
row3: .asciiz "  7  |  8  |  9  \n"

#messages 
welcome_msg: .asciiz "*****Welcome to Tic Tac Toe!!!*****\n"
explain_msg: .asciiz "\nInput the cell number to enter your play!\n"
choose_msg: .asciiz "\nEnter X or O: "
playerX: .asciiz "\nYou are X.\n" 
playerO: .asciiz "\nYou are O.\n"
cell_msg: .asciiz "\nYour turn!\n\Choose your cell(1-9): "
compueter_msg: .asciiz "Computer's turn.\n\n"
playerX_msg: "Player X's turn\n\n"

board: .word 0, 0, 0, 0, 0, 0, 0, 0, 0
buffer: .space 20

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
	
	#allow user to choose to play either X or O
	jal choose_char
	
	#jump to make_board to print out the board setting
	jal board_demo 
	
	
	jal user_input

		
	
choose_char:
	#print message
	la $a0, choose_msg
	li $v0, 4
	syscall
	
	#make user input their choice
	li $v0, 8
	
	#store the user input into an address
	la $a0, buffer
	li $a1, 20
	move $t0, $a0
	syscall
	
	#initialize x
	la $t2, x	
	#initialize o
	la $t3, o
	
	#if user input is X print playerX
	#if user input is O print playerO
	bne $t0, $t2, YouX
	#print message that the user is playing O
	la $a0, playerO
	li $v0, 4
	syscall
	j exit
	
	#print message that the user is playing X
	YouX:
		la $a0, playerX
		li $v0, 4
		syscall
		
	la $s1, board

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
	
	
user_input:
	#print cell message
	la $a0, cell_msg
	li $v0, 4
	syscall
	
	
	#read cell number from user
	li $v0, 5
	
	la $a0, buffer
	li $a1, 20
	move $t4, $a0
	syscall
	
	beq $t4 ,1 , cell_1
	beq $t4 ,2 , cell_2
	beq $t4 ,3 , cell_3
	beq $t4 ,4 , cell_4
	beq $t4 ,5 , cell_5
	beq $t4 ,6 , cell_6
	beq $t4 ,7 , cell_7
	beq $t4 ,8 , cell_8
	beq $t4 ,9 , cell_9

cell_1:	
	#check if the space is occupied
	#place the char in the cell position
	#both X and O
	#print current board
cell_2:
cell_3:
cell_4:
cell_5:
cell_6:
cell_7:
cell_8:
cell_9:

curr_board:
	#display the current board
	#used after each player finishes a move



exit: li $v0, 10
      syscall 
      
#end of program
