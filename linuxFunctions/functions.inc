;
;Include file for the functions library
;
sys_exit	equ	1h
sys_read	equ	3h
sys_write	equ	4h
stdin		equ	0h
stdout		equ	1h
stderr		equ	3h

;Print a string with no delimeter to the console
;Arguments:	Address of the String (Stack)
;			Length of the String (Stack)
extern		PrintText

;Print an endl character to the console
;Arguments:	None
extern		Printendl

;Print a 32bit numeric value as a Decimal to the console
;Arguments:	DWORD Value (stack)
extern		Print32bitNumDecimal

;Print a 32bit signed numeric value as a Decimal to the console
;Arguments:	DWORD Value (stack)
extern		Print32bitSNumDecimal

;Print a 32bit numeric value as a Binary to the console
;Arguments:	DWORD Value (stack)
extern		Print32bitNumBinary

;Print a 32bit numeric value as a Binary to the console
;Arguments:	DWORD Value (stack)
extern		Print32bitFullBinary

;
;Print a full 32-bits binary number in Floating Point format.
;Stack contents:
;	Value to Print to an Ascii String
extern		Print32bitFloatBinary

;Print a 32bit numeric value as a Hexidecimal to the console
;Arguments:	DWORD Value (stack)
extern		Print32bitNumHex

;Print The General Purpose Registers to the console
;Arguments:	None
extern		PrintRegisters

;Print The floating point Registers to the console
;Arguments:	None
extern		PrintFloatingRegisters

;Print a string with an ending 00h delimiter to the console
;Arguments:	Address of the String (Stack)
extern		PrintString

;Print a space to the console
;Arguments:	None
extern		PrintSpace

;Print a comma followed by a space to the console
;Arguments:	None
extern		PrintComma

;Print a Double Word floating point number
;Arguments: The floating point number to be printed (Stack)
extern		PrintDWFloat

;Call the function to get the CPU's Time Stamp Counter
;Arguments: None
;Return:  eax
extern		GetTSC

;Input Unsigned Int	
;This function will let the user input a string, then it will check it to make sure it
;is a positive integer.  It will then convert the ASCII string into a DWORD and return
;that value in the EAX register.
;Arguments: None
;Return: 	eax will contain the usigned ingeter
;			Carry flag will be set if invalid integer was input
extern		InputUInt

;Input Signed Int  TBD (just copied from input unsigned int - no code updated)
;This function will let the user input a string, then it will check it to make sure it
;is a positive integer.  It will then convert the ASCII string into a DWORD and return
;that value in the EAX register.
;Arguments: None
;Return: 	eax will contain the usigned ingeter
;			Carry flag will be set if invalid integer was input
extern		InputSInt

;Input Binary Number	
;This function will let the user input a string, then it will check it to make sure it
;is a binary number.  It will then convert the ASCII string into a DWORD and return
;that value in the EAX register.
;Arguments: None
;Return: 	eax will contain the number
;			Carry flag will be set if invalid binary number was input
extern		InputBin

;Input Hexidecimal Number	
;This function will let the user input a string, then it will check it to make sure it
;is a binary number.  It will then convert the ASCII string into a DWORD and return
;that value in the EAX register.
;Arguments: None
;Return: 	eax will contain the number
;			Carry flag will be set if invalid binary number was input
extern		InputHex

;Input a Floating Point Number	
;This function will let the user input a string, then it will check it to make sure it
;is a valid decimal number.  It will then convert the ASCII string into a DWORD and return
;that value in the ST(0) register.
;Arguments: None
;Return: 	eax will contain the number
;			Carry flag will be set if invalid binary number was input
extern		InputFloat

