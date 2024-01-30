INCLUDE Irvine32.inc
main EQU start@0

.stack 4096


;------------------------------------------------------------------------------- PROTO Create ----------------------------------------------------------------------------------
WriteLine PROTO, color: PTR WORD, charc: PTR BYTE, nWidth: DWORD
DrawColor PROTO, color: PTR WORD, nWidth: DWORD
EndScreen PROTO
EndScreenWin PROTO
showChecker PROTO
WriteDot PROTO
Change PROTO
Gameover PROTO
CopyCheckerLogic PROTO
Over PROTO
PrintCheckNum PROTO
ResetChecker PROTO
showCaption PROTO

;-------------------------------------------------------------------------------- Constant ---------------------------------------------------------------------------------
captionWidth = 120
checkerWidth = 13
checkerHeight = 7

.data



;------------------------------------------------------------------------------ Initial Screen -----------------------------------------------------------------------------------
captionTop		    BYTE 0DAh, (captionWidth - 2) DUP(0C4h), 0BFh
captionLineEEmpty	BYTE captionWidth DUP(020h)
captionLineEmpty	BYTE 0B3h, "                                                                                                                      ", 0B3h
captionLine1		BYTE 0B3h, "                                            _________    ________     _________                                       ", 0B3h
captionLine2		BYTE 0B3h, "                                           /  ___   /\  /  _____/\   /  ______/\                                      ", 0B3h
captionLine3		BYTE 0B3h, "                                          /  /__/  / / /  /_____\/  /  /\____ \/                                      ", 0B3h
captionLine4		BYTE 0B3h, "                                         /  ______/ / /  _____/\   /  //__  /\                                        ", 0B3h
captionLine5		BYTE 0B3h, "                                        /  /\_____\/ /  /_____\/  /  /_\/  / /                                        ", 0B3h
captionLine6		BYTE 0B3h, "                                       /__/ /       /________/\  /________/ /                                         ", 0B3h
captionLine7		BYTE 0B3h, "                                       \__\/        \________\/  \________\/                                          ", 0B3h
captionLine8		BYTE 0B3h, "      _________    _________    ___         _________   _________    _______      _________    _________    ________  ", 0B3h
captionLine9		BYTE 0B3h, "     /  ______/\  /  ___   /\  /  /\       /__   ___/\ /__   ___/\  /  __   \    /__   ___/\  /  ___   /\  /  _____/\ ", 0B3h
captionLine10		BYTE 0B3h, "    /  /_____\/  /  /\_/  / / /  / /       \_/  /\__\/ \_/  /\__\/ /  /\ /  /\   \_/  /\__\/ /  /__/  / / /  /_____\/ ", 0B3h
captionLine11		BYTE 0B3h, "   /______  /\  /  / //  / / /  / /         /  / /      /  / /    /  /__/  / /    /  / /    /      __/ / /  _____/\   ", 0B3h
captionLine12		BYTE 0B3h, "  _\_____/ / / /  /_//  / / /  /_/___   ___/  /_/_     /  / /    /  ___   / / ___/  /_/_   /  /\   \_\/ /  /_____\/   ", 0B3h
captionLine13		BYTE 0B3h, " /________/ / /________/ / /________/\ /_________/\   /  / /    /__/\ /__/ / /_________/\ /__/ /\___\  /________/\    ", 0B3h
captionLine14		BYTE 0B3h, " \________\/  \________\/  \________\/ \_________\/   \__\/     \__\/ \__\/  \_________\/ \__\/  \___\ \________\/    ", 0B3h
captionLine15		BYTE 0B3h, "                              \_____________________________________________________/                                 ", 0B3h
captionLine16		BYTE 0B3h, "                                       \__________________________________/                                           ", 0B3h
captionLine17		BYTE 0B3h, "                                              \_____________________/                                                 ", 0B3h
captionBottom		BYTE 0C0h, (captionWidth - 2) DUP(0C4h), 0D9h
captionNotify		BYTE (captionWidth - 12)/2 DUP(020h), " TAP TO PLAY ", (captionWidth - 12)/2 DUP(020h)

titleStr BYTE "Peg solitaire", 0	;title



;----------------------------------------------------------------------------- Initial Checkboard -----------------------------------------------------------------------------------
checkerLine1    BYTE "    O O O    "
checkerLine2    BYTE "    O O O    "
checkerLine3	BYTE "O O O O O O O"
checkerLine4	BYTE "O O O   O O O"
checkerLine5	BYTE "O O O O O O O"
checkerLine6    BYTE "    O O O    "
checkerLine7    BYTE "    O O O    "


checkerLineL0    BYTE "X X X X X X X X X"
checkerLineL1    BYTE "X X X O O O X X X"
checkerLineL2    BYTE "X X X O O O X X X"
checkerLineL3	 BYTE "X O O O O O O O X"
checkerLineL4	 BYTE "X O O O   O O O X"
checkerLineL5	 BYTE "X O O O O O O O X"
checkerLineL6    BYTE "X X X O O O X X X"
checkerLineL7    BYTE "X X X O O O X X X"
checkerLineL8    BYTE "X X X X X X X X X"

checkerLineR1    BYTE "    O O O    "
checkerLineR2    BYTE "    O O O    "
checkerLineR3 	 BYTE "O O O O O O O"
checkerLineR4	 BYTE "O O O   O O O"
checkerLineR5	 BYTE "O O O O O O O"
checkerLineR6    BYTE "    O O O    "
checkerLineR7    BYTE "    O O O    "

winString		 BYTE "You Win"
overString		 BYTE "Game Over, there are"	;20
printNum         BYTE " 00 pieces left"			;15

;down/top => +/-13
;right/left +> +/-2

;--------------------------------------------------------------------------- Console Control Variable ---------------------------------------------------------------------
outputHandle	 DWORD 0
consoleHandle    DWORD ?
bytesWritten	 DWORD 0
cellsWritten	 DWORD ?

;---------------------------------------------------------------------------- Chess Related Variable -----------------------------------------------------------------------
selectedX		 DWORD ?
selectedY		 DWORD ?
fixedX			 DWORD ?
fixedY			 DWORD ?
middleX			 DWORD ?
middleY			 DWORD ?

checksNum		 DWORD ?

;----------------------------------------------------------------------------- Current Position -----------------------------------------------------------------------------
xyPosition COORD <56, 13>
xyInit	   COORD <56, 13>		; starting coordinate
xyPos	   COORD <56, 13>		; position of cursor
xyBound	   COORD <80, 25>
xyNow	   COORD <? , ? >


;------------------------------------------------------------------------------- Color Control ------------------------------------------------------------------------------
attributes0		 WORD checkerWidth DUP(67h)
attributesB		 WORD checkerWidth+10 DUP(0EEh)
attributes3		 WORD 3 DUP(0EEh)
attributesw		 WORD 35 DUP(87h)
attributeDot	 WORD 64h
attributesCap    WORD captionWidth DUP(08h)
attributesCap1   WORD 008h, captionWidth-2 DUP(01h), 008h
attributesCap2   WORD 008h, captionWidth-2 DUP(02h), 008h
attributesCap3   WORD 008h, captionWidth-2 DUP(03h), 008h
attributesCap4	 WORD 008h, captionWidth-2 DUP(04h), 008h
attributesCap5	 WORD 008h, captionWidth-2 DUP(05h), 008h
attributesCap6	 WORD 008h, captionWidth-2 DUP(06h), 008h
attributesCap7	 WORD 008h, captionWidth-2 DUP(07h), 008h
attributesNotify WORD (captionWidth - 12)/2-1 DUP(00h), 14h, 13 DUP(81h), 14h, (captionWidth - 12)/2-1 DUP(00h)



;---------------------------------------------------------------------------------¡i MAIN ¡j--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
.code
main PROC
	INVOKE SetConsoleTitle, ADDR titleStr		; Set the title
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE		; Get the console ouput handle
	mov outputHandle , eax						; save console handle
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE	
	mov consoleHandle, eax						; Moving the handle to consoleHandle variable
	call Clrscr
	call showCaption							;Show initial screen
	call WaitMsg



;---------------------------------- Set initial position --------------------------
INITIAL:										
	mov ax     , xyInit.x
	mov xyPos.x, ax
	mov ax     , xyInit.y
	mov xyPos.y, ax


;------------------------------------------------------- Game Loop --------------------------------------------------------------
START:


;-------------------------- Show screen -----------------------------------
	call ClrScr
	call showChecker
	call PrintCheckNum
	call WriteDot


;------------------------- Detect User Movement ------------------------------

	INVOKE SetConsoleCursorPosition,	; Setting console cursor position
		consoleHandle,
		xyPos  

	call ReadChar

	;------------ Control direction ------------
	.IF ax == 1177h		; UP ARROW (w)
		sub xyPos.y, 1
	.ENDIF
	.IF ax == 1f73h		; DOWN ARROW (s)
		add xyPos.y, 1
	.ENDIF
	.IF ax == 1e61h		; LEFT ARROW (a)
		sub xyPos.x, 2
	.ENDIF
	.IF ax == 2064h		; RIGHT ARROW (d)
		add xyPos.x, 2
	.ENDIF


	; ------------ End game ------------
	.IF ax == 011Bh     ;ESC 
		jmp END_FUNC
	.ENDIF

	;---------- Cancel Chosen Chess ------------
	.IF ax == 1071h		; (q)
		mov selectedX, 200
		mov selectedY, 200
	.ENDIF


	;---------- Choosing check to move ----------
	.IF ax == 1c0dh		 ; (enter)
		movzx eax	    , xyPos.x
		mov   selectedX , eax
		movzx eax  	    , xyPos.y
		mov   selectedY , eax

		;--- Find the check char ---
		mov   esi	  , OFFSET checkerLine1
		mov   eax	  , selectedY
		sub   eax	  , 10
		imul  eax	  , 13
		add   eax	  , selectedX
		sub   eax	  , 50
		movzx edx	  , BYTE PTR [esi + eax]

		;---- Remember position ----
		.IF dl != ' '   ; Check if it is "O"
			mov eax    , selectedX
			mov fixedX , eax
			mov eax	   , selectedY
			mov fixedY , eax
		.ENDIF
		
	.ENDIF


	;---------- Choosing position to move to ----------
	.IF ax == 2e63h      ; (c)
		movzx eax		, xyPos.x
		mov   selectedX , eax
		movzx eax		, xyPos.y
		mov	  selectedY , eax

		;---- Check the target position ----
		mov   esi, OFFSET checkerLine1
		mov   eax, selectedY
		sub   eax, 10
		imul  eax, 13
		add   eax, selectedX
		sub   eax, 50
		movzx edx, BYTE PTR [esi + eax]
		

		;------------ Check if the choosing place is legal ------------
		.IF dl == ' '	    
			mov eax, selectedX
			sub eax, fixedX

			mov ecx, selectedY
			sub ecx, fixedY

			mov edx, eax 
			add edx, ecx

			.IF eax != 4 && eax != -4 && ecx != 2 && ecx != -2  ; Illegal
				mov selectedX, 200
				mov selectedY, 200

			.ELSE	; Legal
				.IF edx == 4 || edx == -4 || edx == 2 || edx == -2
					; Find middle x
					mov eax    , selectedX
					add eax    , fixedX
					shr eax    , 1				
					mov middleX, eax

					; Find middle y
					mov eax    , selectedY
					add eax    , fixedY
					shr eax	   , 1				
					mov middleY, eax

					;check the middle char
					mov   esi, OFFSET checkerLine1
					mov   eax, middleY
					sub   eax, 10
					imul  eax, 13
					add	  eax, middleX
					sub	  eax, 50
					movzx edx, byte ptr [esi + eax]
					.IF dl != ' '
						call Change
					.ENDIF
				.ENDIF
			.ENDIF
		.ENDIF
	.ENDIF
	

	;---------------------------- Set boundary --------------------------------
	.IF xyPos.x == 50 || xyPos.x == 52 || xyPos.x == 60 || xyPos.x == 62
		.IF xyPos.y == 11
			add xyPos.y, 1
		.ENDIF
	.ENDIF

	.IF xyPos.x == 50 || xyPos.x == 52 || xyPos.x == 60 ||  xyPos.x == 62
		.IF xyPos.y == 15
			sub xyPos.y, 1
		.ENDIF
	.ENDIF

	.IF xyPos.x == 54 || xyPos.x == 56 || xyPos.x == 58
		.IF xyPos.y == 9
			add xyPos.y, 1
		.ENDIF
	.ENDIF

	.IF xyPos.x == 54 || xyPos.x == 56 || xyPos.x == 58
		.IF xyPos.y == 17
			sub xyPos.y, 1
		.ENDIF
	.ENDIF

	.IF xyPos.y == 10 || xyPos.y == 11 || xyPos.y == 15 || xyPos.y == 16  
		.IF xyPos.x == 52
			add xyPos.x, 2
		.ENDIF
	.ENDIF

	.IF xyPos.y == 10 || xyPos.y == 11 || xyPos.y == 15 || xyPos.y == 16  
		.IF xyPos.x == 60
			sub xyPos.x, 2
		.ENDIF
	.ENDIF

	.IF xyPos.y == 12 || xyPos.y == 13 || xyPos.y == 14 
		.IF xyPos.x == 48
			add xyPos.x, 2
		.ENDIF
	.ENDIF

	.IF xyPos.y == 12 || xyPos.y == 13 || xyPos.y == 14   
		.IF xyPos.x == 64
			sub xyPos.x, 2
		.ENDIF
	.ENDIF


	jmp START		; Jumping back to START
END_FUNC:
	exit
main ENDP


;------------------------------------------------------------------------¡i PROC Completion¡j-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; ---------- ¡i Complete one move ¡j ----------
change PROC USES eax esi 
	; Target Position
	mov esi, OFFSET checkerLine1
	mov eax, selectedY
	sub eax,10
	imul eax, 13
	add eax, selectedX
	sub eax, 50
	add esi, eax 
	mov BYTE PTR [esi], "O"

	; Origin chess
	mov esi, OFFSET checkerLine1
	mov eax, fixedY
	sub eax,10
	imul eax, 13
	add eax, fixedX
	sub eax, 50
	add esi, eax 
	mov BYTE PTR[esi], " "

	; Middle chess
	mov esi, OFFSET checkerLine1
	mov eax, middleY
	sub eax,10
	imul eax, 13
	add eax, middleX
	sub eax, 50
	add esi, eax 
	mov BYTE PTR[esi], " "
	dec checksNum

	mov selectedX, 200
	mov selectedY, 200
	call Gameover
	ret
change ENDP


; ---------- ¡i Show the chosen chess ¡j ----------
WriteDot PROC USES ax
	mov eax, selectedX
	mov xyNow.x, ax
	mov eax, selectedY
	mov xyNow.y, ax
	INVOKE WriteConsoleOutputAttribute,
	  outputHandle, 
	  OFFSET attributeDot,
	  1, 
	  xyNow,
	  ADDR cellsWritten
	ret
WriteDot ENDP


; --------------- ¡i Show chess line ¡j ---------------
WriteLine PROC,
	color: PTR WORD, 
	charc: PTR BYTE, 
	nWidth: DWORD

	 ; Show Color
	INVOKE WriteConsoleOutputAttribute,
		outputHandle, 
		color,
		nWidth, 
		xyPosition,
		ADDR cellsWritten

	; Show Char 
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,		
		charc,				
		nWidth,				
		xyPosition,			
		ADDR bytesWritten	

	inc xyPosition.y
	ret
WriteLine ENDP

DrawColor PROC,
	color: PTR WORD, 
	nWidth: DWORD

	 ; Show Color
	INVOKE WriteConsoleOutputAttribute,
		outputHandle, 
		color,
		nWidth, 
		xyPosition,
		ADDR cellsWritten

	inc xyPosition.y
	ret
DrawColor ENDP


; ------------------------ ¡i Show all chess ¡j -----------------------
ShowChecker PROC USES ebx ecx
	mov xyPosition.x, 45
    mov xyPosition.y, 7
	mov ebx, 23

	INVOKE DrawColor, OFFSET attributesB, ebx
	INVOKE DrawColor, OFFSET attributesB, ebx
	INVOKE DrawColor, OFFSET attributesB, ebx
	INVOKE DrawColor, OFFSET attributesB, ebx
	INVOKE DrawColor, OFFSET attributesB, ebx
	INVOKE DrawColor, OFFSET attributesB, ebx
	INVOKE DrawColor, OFFSET attributesB, ebx
	INVOKE DrawColor, OFFSET attributesB, ebx
	INVOKE DrawColor, OFFSET attributesB, ebx
	INVOKE DrawColor, OFFSET attributesB, ebx
	INVOKE DrawColor, OFFSET attributesB, ebx
	INVOKE DrawColor, OFFSET attributesB, ebx
	INVOKE DrawColor, OFFSET attributesB, ebx

	mov ebx, checkerWidth
	mov xyPosition.x, 50
    mov xyPosition.y, 10
	INVOKE WriteLine, OFFSET attributes0, OFFSET checkerLine1, ebx
	INVOKE WriteLine, OFFSET attributes0, OFFSET checkerLine2, ebx
	INVOKE WriteLine, OFFSET attributes0, OFFSET checkerLine3, ebx
	INVOKE WriteLine, OFFSET attributes0, OFFSET checkerLine4, ebx
	INVOKE WriteLine, OFFSET attributes0, OFFSET checkerLine5, ebx
	INVOKE WriteLine, OFFSET attributes0, OFFSET checkerLine6, ebx
	INVOKE WriteLine, OFFSET attributes0, OFFSET checkerLine7, ebx

	mov xyPosition.x, 49
	mov xyPosition.y, 12
	mov ebx, 3
	mov xyPosition.x, 50
    mov xyPosition.y, 10
	INVOKE DrawColor, OFFSET attributes3, ebx
	INVOKE DrawColor, OFFSET attributes3, ebx
	mov xyPosition.x, 60
    mov xyPosition.y, 10
	INVOKE DrawColor, OFFSET attributes3, ebx
	INVOKE DrawColor, OFFSET attributes3, ebx
	mov xyPosition.x, 50
    mov xyPosition.y, 15
	INVOKE DrawColor, OFFSET attributes3, ebx
	INVOKE DrawColor, OFFSET attributes3, ebx
	mov xyPosition.x, 60
    mov xyPosition.y, 15
	INVOKE DrawColor, OFFSET attributes3, ebx
	INVOKE DrawColor, OFFSET attributes3, ebx
	ret
ShowChecker ENDP


; ------------------------------- ¡i Show Caption ¡j -----------------------------
ShowCaption PROC USES ebx
	mov xyPosition.x, 47
    mov xyPosition.y, 5
	call resetChecker
	call clrscr
	mov ebx, captionWidth
	INVOKE WriteLine, OFFSET attributesCap , OFFSET captionTop		  , ebx
	INVOKE WriteLine, OFFSET attributesCap , OFFSET captionLineEmpty  , ebx
	INVOKE WriteLine, OFFSET attributesCap , OFFSET captionLineEmpty  , ebx
	INVOKE WriteLine, OFFSET attributesCap7, OFFSET captionLine1	  , ebx
	INVOKE WriteLine, OFFSET attributesCap7, OFFSET captionLine2	  , ebx
	INVOKE WriteLine, OFFSET attributesCap7, OFFSET captionLine3	  , ebx
	INVOKE WriteLine, OFFSET attributesCap7, OFFSET captionLine4	  , ebx
	INVOKE WriteLine, OFFSET attributesCap3, OFFSET captionLine5	  , ebx
	INVOKE WriteLine, OFFSET attributesCap3, OFFSET captionLine6	  , ebx
	INVOKE WriteLine, OFFSET attributesCap3, OFFSET captionLine7	  , ebx
	INVOKE WriteLine, OFFSET attributesCap3, OFFSET captionLineEmpty  , ebx
	INVOKE WriteLine, OFFSET attributesCap , OFFSET captionLineEmpty  , ebx
	INVOKE WriteLine, OFFSET attributesCap3, OFFSET captionLine8	  , ebx
	INVOKE WriteLine, OFFSET attributesCap1, OFFSET captionLine9	  , ebx
	INVOKE WriteLine, OFFSET attributesCap1, OFFSET captionLine10	  , ebx
	INVOKE WriteLine, OFFSET attributesCap1, OFFSET captionLine11	  , ebx
	INVOKE WriteLine, OFFSET attributesCap5, OFFSET captionLine12	  , ebx
	INVOKE WriteLine, OFFSET attributesCap5, OFFSET captionLine13	  , ebx
	INVOKE WriteLine, OFFSET attributesCap5, OFFSET captionLine14	  , ebx
	INVOKE WriteLine, OFFSET attributesCap , OFFSET captionLineEmpty  , ebx
	INVOKE WriteLine, OFFSET attributesCap5, OFFSET captionLine15	  , ebx
	INVOKE WriteLine, OFFSET attributesCap5, OFFSET captionLine16	  , ebx
	INVOKE WriteLine, OFFSET attributesCap5, OFFSET captionLine17	  , ebx
	INVOKE WriteLine, OFFSET attributesCap , OFFSET captionLineEmpty  , ebx
	INVOKE WriteLine, OFFSET attributesCap , OFFSET captionLineEmpty  , ebx
	INVOKE WriteLine, OFFSET attributesCap , OFFSET captionLineEmpty  , ebx
	INVOKE WriteLine, OFFSET attributesCap , OFFSET captionLineEmpty  , ebx
	INVOKE WriteLine, OFFSET attributesCap , OFFSET captionBottom	  , ebx
	INVOKE WriteLine, OFFSET attributesCap , OFFSET captionLineEEmpty , ebx
	INVOKE WriteLine, OFFSET attributesCap , OFFSET captionLineEEmpty , ebx
	INVOKE WriteLine, OFFSET attributesCap , OFFSET captionLineEEmpty , ebx
	INVOKE WriteLine, OFFSET attributesNotify , OFFSET captionNotify  , ebx
	ret
ShowCaption ENDP

ResetChecker PROC USES ecx esi edi
	mov checksNum, 32
	mov selectedX, 56
	mov selectedY, 13
	mov ecx, 91
	mov esi, OFFSET checkerLineR1
	mov edi, OFFSET checkerLine1
	rep movsb

	ret
ResetChecker ENDP





; ------¡i for checking if there's valid movement ¡j-----------

CopyCheckerLogic PROC USES ecx esi edi

	mov ecx, 5
	mov esi, OFFSET checkerLine1 + 4
	mov edi, OFFSET checkerLineL1 + 6
	rep movsb

	mov ecx, 5
	mov esi, OFFSET checkerLine2 + 4
	mov edi, OFFSET checkerLineL2 + 6
	rep movsb

	mov ecx, 13
	mov esi, OFFSET checkerLine3
	mov edi, OFFSET checkerLineL3 + 2
	rep movsb

	mov ecx, 13
	mov esi, OFFSET checkerLine4
	mov edi, OFFSET checkerLineL4 + 2
	rep movsb

	mov ecx, 13
	mov esi, OFFSET checkerLine5
	mov edi, OFFSET checkerLineL5 + 2
	rep movsb

	mov ecx, 5
	mov esi, OFFSET checkerLine6 + 4
	mov edi, OFFSET checkerLineL6 + 6
	rep movsb

	mov ecx, 5
	mov esi, OFFSET checkerLine7 + 4
	mov edi, OFFSET checkerLineL7 + 6
	rep movsb

	ret
CopyCheckerLogic ENDP


; -------- ¡i Check If Gameover¡j--------
Gameover PROC USES esi ecx edx ebx eax
	call CopyCheckerLogic
	mov esi, OFFSET checkerLineL1 + 2
	mov ecx, 7
L11:
	push ecx
		mov ecx, 13
		Check:
			movzx edx, BYTE PTR [esi]
			.IF dl == 'O'
				; Up
				movzx ebx, BYTE PTR [esi - 11h]
				movzx eax, BYTE PTR [esi - 22h]
				.IF bl == "O" && al == " "
					pop ecx
					ret
				.ENDIF

				; Down
				movzx ebx, BYTE PTR [esi + 11h]
				movzx eax, BYTE PTR [esi + 22h]
				.IF bl == "O" && al == " "
					pop ecx
					ret
				.ENDIF

				; Right
				movzx ebx, BYTE PTR [esi + 2h]
				movzx eax, BYTE PTR [esi + 4h]
				.IF bl == "O" && al == " "
					pop ecx
					ret
				.ENDIF

				; Left
				movzx ebx, BYTE PTR [esi - 2h]
				movzx eax, BYTE PTR [esi - 4h]
				.IF bl == "O" && al == " "
					pop ecx
					ret
				.ENDIF
			.ENDIF
			inc esi
		loop Check
	add esi, 4
	pop ecx
	loop L11

	showGameover:
		call Over
	ret
Gameover ENDP


; -------- ¡i Show Gameover Screen ¡j--------
Over PROC USES eax

	call PrintCheckNum
	.IF eax == 1
		call EndScreenWin
	.ELSE
		call EndScreen
	.ENDIF
	call ClrScr
	call ShowCaption
	call WaitMsg
	ret
Over ENDP

EndScreen PROC USES eax ebx edx
	call clrscr
	call showChecker
	mov xyPosition.x, 40
    mov xyPosition.y, 21
	mov edx, 0
	mov eax, checksnum
	mov ebx, 0Ah
	div ebx
	mov esi, OFFSET printNum
	add eax, 30h
	add edx, 30h
	inc esi
	mov BYTE PTR [esi], al
	inc esi
	mov BYTE PTR [esi], dl	
	INVOKE WriteLine, OFFSET attributesw , OFFSET overString  , 35
	call waitMsg
	ret
EndScreen ENDP

EndScreenWin PROC USES eax ebx edx
	call clrscr
	call showChecker
	mov xyPosition.x, 53
    mov xyPosition.y, 21
	INVOKE WriteLine, OFFSET attributesw , OFFSET winString  , 7
	call waitMsg
	ret
EndScreenWin ENDP

; ------- ¡i Show How Many Chess Still Remain ¡j ------
PrintCheckNum PROC USES ecx esi edx
    mov eax, 0
	mov esi, OFFSET checkerLine1
	mov ecx, 91
		Check2:
			movzx edx, BYTE PTR [esi]
			.IF dl == 'O'
				inc eax
			.ENDIF
			inc esi
		loop Check2
	mov checksNum, eax             
    ret
PrintCheckNum ENDP

END main

