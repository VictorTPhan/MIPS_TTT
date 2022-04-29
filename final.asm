#Min Jung--04/20/2022
#I/O
# X	print to board 
# X	allow user input  choose the positions
#	output the board with "O" marked on the position they chose
# X	"X" = playerX
# X	"O" = playerO

.data
#tic tac toe board
space: .asciiz " "
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
choose_msg: .asciiz "\nEnter 1 for X and 2 for O: "
playerX: .asciiz "\nYou are X.\n" 
playerO: .asciiz "\nYou are O.\n"
cell_msg: .asciiz "\nYour turn!\n\Choose your cell(1-9): "
compueter_msg: .asciiz "Computer's turn.\n\n"
playerX_msg: "Player X's turn\n\n"

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
	
	#allow user to choose to play either X or O
	jal choose_char
	
	#jump to make_board to print out the board setting
	jal board_demo 
	
	gameLoop:	
		#get user input
		jal user_input
	
		#set new value for table
		jal place_cell

		#print out the board
		jal curr_board
	
		#switch control to other player
		jal switch_player_control
		
		j gameLoop
	exitGameLoop:
	
	j exit
		
	
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
	
	#pass in v0
	move $a0, $v0
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

exit: 
	li $v0, 10
     	syscall 
      
#end of program
