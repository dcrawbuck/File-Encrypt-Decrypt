; Chapter 11 Project
; Read from file and decrypt
; Duncan Crawbuck
; CS 21 Komenetsky
; 12/19/17

%include "./linuxFunctions/functions.inc"
bits 32
section .data
	
	commandArgErrorMsg	db		"Error: Exactly one argument needed."	; Error message for improper amount of command arguments
		.size			EQU		$-commandArgErrorMsg					; Size of message
		
	encryptKeyInputMsg	db		"Encryption Key"						; Input message for encryption key
		.size			EQU		$-encryptKeyInputMsg					; Size of message
		
	decryptOutputMsg	db		"Decrypted: "							; Input message for encryption key
		.size			EQU		$-decryptOutputMsg						; Size of message
	
section .bss
	decryptedText		resb	50										; Decrypted text
	filename			resd	1										; Memory address of filename for encrypted text to be saved, entered by user
	encryptKey			resb	1										; Encryption key, entered by user
	encryptedText		resb	50										; Text to be decrypted, read from file
	
section .text
	global _start
_start:
	nop
	
	; Check command arguments
	pop		eax															; Get number of arguments from stack
	cmp		eax, 2														; Compare eax and 1 (correct number of command arguments)
	jne		CommandArgError												; If not equal jump to CommandArgError
	
	; Save command arguments
	pop		eax															; Trash first, Program name
	pop		DWORD [filename]											; Save filename
	
	; Encryption key input
	push	encryptKeyInputMsg											; Push message to print
	push	DWORD encryptKeyInputMsg.size								; Push message length to print
	call	PrintText													; Call print function
	call 	InputUInt													; Call int input function
	mov		[encryptKey], al											; Save encrypt key
	
	; Read from file
	push	DWORD [filename]											; Push memory address of filename
	push	encryptedText												; Push memory address of encrypted text
	call	ReadFromFile												; Call read from file function
	
	; Decrypt text
	push	encryptKey													; Push memory address of encryption key
	push	encryptedText												; Push memory address of text to be decrypted
	push	decryptedText												; Push memory address to store decrypted text in
	call	DecryptText													; Call encrypt text function
	
	; Print decrypted text
	push	decryptOutputMsg											; Push message to print
	push	DWORD decryptOutputMsg.size									; Push message length to print
	call	PrintText													; Call print function
	push	decryptedText												; Push memory address of string to print
	call	PrintString													; Call print string function
	call	Printendl													; Call print end line function
	
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
;	memory address to store decrypted text in
;	memory address of text to be decrypted
;	memory address of encryption key
DecryptText:
	push	ebp															; Save ebp in stack
	mov		ebp, esp													; Copy stack pointer to ebp as reference
	
	mov		ecx, [ebp+8]											; ecx = [ebp+ 8] = memory address to store decrypted text
	mov		edx, [ebp+12]											; edx = [ebp+12] = memory address of text to be decrypted
	mov		esi, [ebp+16]												; bl  = [ebp+16] = memory address of encryption key
	mov		ebx, [esi]													;
	
	mov		esi, 0														; Set index to 0
	
	DecryptLoop:
		mov		al, [edx+esi]										; Move current character into al
		
		cmp		al, 0x00												; Compare current character with null character
		je		EndOfString												; Character is null character
		
		xor		al, bl													; Encrypt al
		mov		[ecx+esi], al											; Store al (encrypted) at index esi in encrypted text memory address 
		
		inc		esi														; Increment index
		jmp		DecryptLoop												; Repeat loop
		
	EndOfString:														; Loop has reached end of string
		mov		BYTE [ecx+esi], 0x00									; Store null character at end of encrypted text
	
	
	mov		esp, ebp													; Restore esp from ebp
	pop		ebp															; Restore ebp
	ret	

; Arguments (Stack)
; 	TOP
; 	memory address of encrypted text
; 	memory address of the file name
ReadFromFile:
	push	ebp															; Save ebp in stack
	mov		ebp, esp													; Copy stack pointer to ebp as reference
	
	sub		esp, 8														; Reserve 8 bytes of memory in the stack for local vars
																		; [ebp-4] = string size
																		; [ebp-8] = outputFileD
	
	; Move addresses of addresses into registers
	mov		esi, [ebp+8]												; [ebp+ 8] = memory address of encrypted text
	mov		edx, [ebp+12]												; [ebp+12] = memory address of the file name
	
	; Open file (input)
	mov		eax, 0x005													; Open the file for input
	mov		ebx, edx													; Filename address is placed in ebx
	mov		ecx, 0x0													; File access mode for Read only
	;mov		edx, 0x01c0												; Read/write/execute owner only, 700 octal = 01C0h (Not needed for input)
	int 	0x80														; Tickle the kernel
	
	; Copy the file descriptor to a temporary variable
	mov		[ebp-8], eax												; Store the file descriptor in a temporary variable
	
	; Check if openened correctly
	cmp		eax, 0														; If eax > 0, all good
	jge		FileOpen													; If eax < 0, opening error
	
	jmp EndReadFromFile
	
	FileOpen:
		; Read
		mov		eax, 3h													; Set read file
		mov 	ebx, [ebp-8]											; Put file descriptor in ebx
		mov		ecx, esi												; Put input buffer address in ecx
		mov		edx, 50													; Put input bufer length in edx
		int 	80h														; Tickle the kernel
		
		; Print out input
		;push	esi														; Push the message for print function
		;push	eax														; Push the message length for print function
		;call	PrintText
		;call	Printendl
	
	
		; Close file
		mov		eax, 6h													; Put 6 into eax
		mov		ebx, [ebp-8]											; Put file descriptor into ebx
		int		0x80													; Tickle the kernel
	
	EndReadFromFile:
	
	mov		esp, ebp													; Restore esp from ebp
	pop		ebp															; Restore ebp
	ret
