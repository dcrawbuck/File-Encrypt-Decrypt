; Chapter 11 Project
; Encrypt and save to file
; Duncan Crawbuck
; CS 21 Komenetsky
; 12/19/17

%include "./linuxFunctions/functions.inc"
bits 32
section .data
	
	testMsg				db		"Testing123"
		.size			EQU		$-testMsg
	
	testFilename		db		"text.txt", 0x00
		.size			EQU		$-testFilename
	
	commandArgErrorMsg	db		"Error: Exactly two arguments needed."	; Error message for improper amount of command arguments
		.size			EQU		$-commandArgErrorMsg					; Size of message
		
	encryptKeyInputMsg	db		"Encryption Key"						; Input message for encryption key
		.size			EQU		$-encryptKeyInputMsg					; Size of message
	
section .bss
	textToEncrypt		resd	1										; Memory address of text to be encrypted, entered by user
	filename			resd	1										; Memory address of filename for encrypted text to be saved, entered by user
	encryptKey			resb	1										; Encryption key, entered by user
	encryptedText		resb	50										; Encrypted text
	
section .text
	global _start
_start:
	nop
	
	; Check command arguments
	pop		eax															; Get number of arguments from stack
	cmp		eax, 3														; Compare eax and 2 (correct number of command arguments)
	jne		CommandArgError												; If not equal jump to CommandArgError
	
	; Save command arguments
	pop		eax															; Trash first, Program name
	pop		DWORD [textToEncrypt]										; Save text to encrypt
	pop		DWORD [filename]											; Save filename
	
	; Encryption key input
	push	encryptKeyInputMsg											; Push message to print
	push	DWORD encryptKeyInputMsg.size								; Push message length to print
	call	PrintText													; Call print function
	call 	InputUInt													; Call int input function
	mov		[encryptKey], al											; Save encrypt key
	
	; Encrypt text
	push	encryptKey													; Push memory address of encryption key
	push	DWORD [textToEncrypt]										; Push memory address of text to be encrypted
	push	encryptedText												; Push memory address to store encrypted text in
	call	EncryptText													; call encrypt text function
	
	; Save to file
	push	DWORD [filename]											; Push memory address of filename
	push	encryptedText												; Push memory address of encrypted text
	call	SaveToFile													; Call save to file function
	
	jmp 	EndProgram
	
	CommandArgError:													; Number of command args is not two
		push	commandArgErrorMsg										; Push message to print
		push	DWORD commandArgErrorMsg.size							; Push message length to print
		call	PrintText												; Call print function
		call	Printendl												; Call print end line function
	
	EndProgram:
	
	nop
	mov 	eax, 1      												; Exit system call value
	mov 	ebx, 0    													; Exit return code
	int 	80h        													; Call the kernel

; Arguments: (Stack)
; 	TOP
;	memory address to store encrypted text in
;	memory address of text to be encrypted
;	memory address of encryption key
EncryptText:
	push	ebp															; Save ebp in stack
	mov		ebp, esp													; Copy stack pointer to ebp as reference
	
	mov		ecx, [ebp+8]												; ecx = [ebp+ 8] = memory address to store encrypted text
	mov		edx, [ebp+12]												; edx = [ebp+12] = memory address of text to be encrypted
	mov		esi, [ebp+16]												; bl  = [ebp+16] = memory address of encryption key
	mov		ebx, [esi]													;
	
	mov		esi, 0														; Set index to 0
	
	EncryptLoop:
		mov		eax, 0
		mov		al, [edx+esi]											; Move current character into al
		
		cmp		al, 0x00												; Compare current character with null character
		je		EndOfString												; Character is null character
		
		xor		al, bl													; Encrypt al
		mov		[ecx+esi], al											; Store al (encrypted) at index esi in encrypted text memory address 
		
		inc		esi														; Increment index
		jmp		EncryptLoop												; Repeat loop
		
	EndOfString:														; Loop has reached end of string
		mov		BYTE [ecx+esi], 0x00									; Store null character at end of encrypted text
	
	
	mov		esp, ebp													; Restore esp from ebp
	pop		ebp															; Restore ebp
	ret	

; Arguments (Stack)
; 	TOP
; 	memory address of encrypted text
; 	memory address of the file name
SaveToFile:
	push	ebp															; Save ebp in stack
	mov		ebp, esp													; Copy stack pointer to ebp as reference
	
	sub		esp, 8														; Reserve 8 bytes of memory in the stack for local vars
																		; [ebp-4] = string size
																		; [ebp-8] = outputFileD
	
	mov		esi, [ebp+8]												; [ebp+ 8] = memory address of encrypted text
	mov		edx, [ebp+12]												; [ebp+12] = memory address of the file name
	
	; Open/Create the file
	mov		eax, 0x008													; Create and open the file
	mov		ebx, edx													; Filename address is placed in ebx
	mov		ecx, 0x01c0													; File access specifier
																		; Read/write/execute owner only, 700 octal = 01C0h
	int		0x80														; Tickle the kernel
	
	; Copy the file descriptor to a temporary variable
	mov 	[ebp-8], eax												; Store the file descriptor in outputFileD
	
	; Open file (output)
	mov		eax, 0x0004													; Write to the file
	mov		ebx, [ebp-8]												; Output file descriptor
	mov		ecx, esi													; Point to a buffer
;	mov		ecx, [ebp+8]												; Point to a buffer
;	mov		ecx, testMsg												; Point to a buffer
	mov		edx, 50;fileText.size										; Output buffer size
	int 	0x80														; Tickle the kernel
	
	; Close file
	mov		eax, 6h														; Put 6 into eax
	mov		ebx, [ebp-8]												; Put file descriptor into ebx
	int		0x80														; Tickle the kernel
	
	
	mov		esp, ebp													; Restore esp from ebp
	pop		ebp															; Restore ebp
	ret
