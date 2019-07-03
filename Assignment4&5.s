#Henri Thomas				David Lee
#hmgdthomas@gmail.com			kirby9990@hotmail.com
#
#Assignment 4
#
#Purpose:   The purpose of the assignment is to implement a Reverse Polish Notation (RPN). This program will prompt the user to enter
#		numbers and operands into the program. At each input, the program will determine whether or not the program is in violation of the 
#		RPN (if it is in violation of the RPN, it will return an error) and after the user enters "="
#
#Algorithm:
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#Inputs:	Determined by the user
#
#Outputs:	Will show the result as 0 since it will not do any calculations, but it will tell whether or not the user is violating the RPN.
#
		.data
Storage: 	.space 	20 #array will hold 20 integers
Prompt: 	.asciiz	"Enter the numbers and operands you would like to use for this RPN (to end entering the inputs, enter =) : "
Overflow: 	.asciiz	 "Too many tokens"
PostFixError: 	.asciiz 	"Invalid postfix"
DividebyZeroError: 	.asciiz "Divide by zero"
result: 	.asciiz "Postfix Evaluation (output): "
errorPostfix: 	.asciiz "Invalid Postfix"
	
	.text
	#final static int MAX = 20
	addi 	$s0, $zero, 0 #s0 = MAX
	#static int i=0
	addi 	$s1, $zero, 0

  	#Print prompt
	li 	$v0, 4
	la 	$a0, Prompt
	syscall
	
	
Do:
   	addi 	$s0, $s0, 1
   	# Get next char
   	jal 	EnterInputs
   	bne 	$t0, 32 , notSpace
   	j 	Do
   	
notSpace:			#If a space was entered first, it'll place a 0 in its place instead.
   	addi 	$t2, $zero ,0 # number($t2) =0
   	
While:
   	blt 	$t0, 48, ExitWhile #Conditions
   	bgt 	$t0, 57, ExitWhile
   	
   	
   	mul 	$t2, $t2, 10 # number = 10*number + (ch-48)
   	sub 	$t0, $t0, 48
   	add 	$t2, $t2, $t0
   	
  	jal 	EnterInputs
  	j 	While
  	
ExitWhile:
   	beq 	$t0, 43, If # if  ((ch == '+') 
   	beq 	$t0, 45, If # || (ch == '-')
   	beq 	$t0, 42, If # ||(ch == '*')
   	beq 	$t0, 47, If # ||(ch == '/')) 
   	b 	Else #go to Else
   	
If:
   	jal 	Pop #call Pop() function 
   	move 	$t4, $v0 # move the return value stored in $v0 to $t4=x2
   	jal 	Pop #Pop()
   	move 	$t3, $v0 # move the return value stored in $v0 to $t3=x1
    jal calc
    move $t2, $v0
   	jal Push
   	j 	Do
   	
Else:
   	#(ch != '=')
   	bne $t0, 61, PushAccess
   	b 	ContinuePushing
PushAccess:			#It is similar to a wrapper function for the method Push
   	jal 	Push
   
ContinuePushing:
   	beq 	$t0, 61, ExitDo
   	j 	Do
   	
ExitDo:
   	beq 	$s1, 1, printResult
   	
   	#Print else: " Invalid postfix" and "Stack: "
   	li 	$v0, 4
   	la 	$a0, errorPostfix
   	syscall
   	addi 	$t7, $zero, 0
   	#b 	printStackLoop
calc:
    beq $t0, 43, add
    beq $t0, 45, subtract
    beq $t0, 42, multiply
    beq $t0, 47, divide

add:
    add $v0, $t3, $t4
    j exitCalc

subtract:
    sub $v0, $t3, $t4
    j exitCalc

multiply:
    mul $v0, $t3,$t4
    j exitCalc

divide:
    beq $t4, $zero, DividebyZero
    div $v0, $t3, $t4
    j exitCalc

exitCalc:
    jr $ra
   
printResult:						#prints the result for the rpn
	bgt 	$s2, 19, ExitProgram
   	#Print: Postfix Evaluation (output):
   	li 	$v0, 4
   	la 	$a0, result
   	syscall
   	lw 	$t6, Storage($zero) #retrieve first Storage element
   	#Print Result
   	li 	$v0, 1
   	addi 	$a0, $t6, 0
   	syscall
	#b 	printStackLoop
ExitProgram:
    li 	$v0,10
    syscall

EnterInputs:				#This method will allow the user to enter their numbers and operands
	#Get the users input(ch)
	li 	$v0, 12
	syscall
	#Store input in $t0
	move 	$t0, $v0
   	jr 	$ra	 	 	 	 	
  	 	 	 	 	 	 	 	 	 	
Push:						#If an integer is entered, it'll be pushed into the stack (storage) then move to the next bit place for a new integer
   	beq 	$s1, $s0, OverflowError
   	sw 	$t2 , Storage($t7)#p[i] = result
   	addi 	$t7, $t7, 4  #go to space for next int
   	addi 	$s1, $s1, 1 # i++
	jr $ra

Pop:					
   	addi 	$t7, $t7, -4
    beq 	$s1, $zero, UnderflowError
   	lw 	$v0, Storage($t7)
   	addi 	$s1, $s1, -1 # i--
   	jr 	$ra

Exit:		
   	addi 	$v0, $t5, 0
   	jr 	$ra		
   	
OverflowError:
   	#Print error
   	li 	$v0, 4
   	la 	$a0, Overflow
   	syscall
   	#System exit
   	li 	$v0,10
   	syscall
   		
UnderflowError:
   	#Print error
   	li 	$v0, 4
   	la 	$a0, PostFixError
   	syscall
   	#System exit
   	li 	$v0,10
   	syscall

DividebyZero:
   	#Print error
   	li 	$v0, 4
   	la 	$a0, DividebyZeroError
   	syscall
   	#System exit
   	li 	$v0,10
   	syscall
