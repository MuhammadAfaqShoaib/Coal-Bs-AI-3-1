.MODEL SMALL
.STACK 100H

.DATA
    ; --- UI MESSAGES ---
    TITLE_MSG    DB '*** MEMORY GAME ***', 0Dh, 0Ah, '$'
    MENU_MSG     DB 0Dh, 0Ah, 'Choose Grid Size:', 0Dh, 0Ah
                 DB '1. Small (2x2)', 0Dh, 0Ah
                 DB '2. Large (4x4)', 0Dh, 0Ah
                 DB 'Enter choice (1 or 2): $'
                 
    ERR_MSG      DB 0Dh, 0Ah, 'Invalid Input! Try again.', 0Dh, 0Ah, '$'
    
    PROMPT_R     DB 0Dh, 0Ah, 'Row: $'
    PROMPT_C     DB ' Col: $'
    
    MATCH_MSG    DB 0Dh, 0Ah, 'MATCH! $'
    NOMATCH_MSG  DB 0Dh, 0Ah, 'NO MATCH... $' 
    
    ; --- NEW MSG FOR WAITING ---
    WAIT_MSG     DB 0Dh, 0Ah, 'Press any key to hide cards...', 0Dh, 0Ah, '$'
    
    WIN_MSG      DB 0Dh, 0Ah, 'YOU WON! Exiting...', 0Dh, 0Ah, '$'
    
    NEWLINE      DB 0Dh, 0Ah, '$'
    SPACE        DB '  $' 

    ; --- CONFIGURATION VARIABLES ---
    GRID_WIDTH   DB ?    ; Will be 2 or 4
    GRID_SIZE    DB ?    ; Will be 4 or 16
    PAIRS_LEFT   DB ?    ; Will be 2 or 8

    ; --- GAME BOARD (16 Slots max) ---
    BOARD        DB 'A','C','A','C'  ; 0-3 (For 2x2)
                 DB 'B','D','B','D'  ; 4-7
                 DB 'E','F','E','F'  ; 8-11
                 DB 'G','H','G','H'  ; 12-15
                 
    ; --- MASK (0=Hidden, 1=Revealed) ---
    MASK         DB 16 DUP(0) 

    ; --- TEMPORARY VARIABLES ---
    ROW_IN       DB ?
    COL_IN       DB ?
    IDX1         DW ?
    IDX2         DW ?

.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX

    ; --- 1. MENU SELECTION ---
MENU_LOOP:
    LEA DX, TITLE_MSG
    MOV AH, 09h
    INT 21h

    LEA DX, MENU_MSG
    MOV AH, 09h
    INT 21h
    
    MOV AH, 01h         ; Get User Input
    INT 21h
    
    CMP AL, '1'
    JE SETUP_2X2
    CMP AL, '2'
    JE SETUP_4X4
    
    ; Handle Error
    LEA DX, ERR_MSG
    MOV AH, 09h
    INT 21h
    JMP MENU_LOOP

SETUP_2X2:
    MOV GRID_WIDTH, 2
    MOV GRID_SIZE, 4
    MOV PAIRS_LEFT, 2
    JMP START_GAME

SETUP_4X4:
    MOV GRID_WIDTH, 4
    MOV GRID_SIZE, 16
    MOV PAIRS_LEFT, 8
    JMP START_GAME

    ; --- 2. MAIN GAME LOOP ---
START_GAME:
    
GAME_LOOP:
    CALL CLEAR_SCREEN
    
    ; Check if game is won
    CMP PAIRS_LEFT, 0
    JE VICTORY
    
    ; Print Header
    LEA DX, TITLE_MSG
    MOV AH, 09h
    INT 21h
    
    CALL DRAW_BOARD
    
    ; --- SELECT FIRST CARD ---
    LEA DX, NEWLINE
    MOV AH, 09h
    INT 21h
    
    CALL GET_COORDS 
    MOV AX, SI          ; SI holds the index calculated in GET_COORDS
    MOV IDX1, AX
    
    ; Reveal Card 1
    MOV SI, IDX1
    MOV MASK[SI], 1
    
    ; Redraw screen to show Card 1
    CALL CLEAR_SCREEN
    LEA DX, TITLE_MSG
    MOV AH, 09h
    INT 21h
    CALL DRAW_BOARD
    
    ; --- SELECT SECOND CARD ---
    LEA DX, NEWLINE
    MOV AH, 09h
    INT 21h
    
    CALL GET_COORDS
    MOV AX, SI
    MOV IDX2, AX
    
    ; Prevent picking the same card twice
    MOV BX, IDX1
    CMP AX, BX
    JE SAME_CARD_ERROR
    
    ; Reveal Card 2
    MOV SI, IDX2
    MOV MASK[SI], 1
    
    ; Redraw screen to show both cards
    CALL CLEAR_SCREEN
    LEA DX, TITLE_MSG
    MOV AH, 09h
    INT 21h
    CALL DRAW_BOARD
    
    ; --- COMPARE CARDS ---
    MOV SI, IDX1
    MOV DI, IDX2
    MOV AL, BOARD[SI]
    MOV BL, BOARD[DI]
    
    CMP AL, BL
    JE MATCHED
    
    ; ==========================================
    ; === UPDATED LOGIC FOR NO MATCH ===
    ; ==========================================
    
    ; 1. Print "No Match"
    LEA DX, NOMATCH_MSG
    MOV AH, 09h
    INT 21h
    
    ; 2. Print "Press any key..."
    LEA DX, WAIT_MSG
    MOV AH, 09h
    INT 21h
    
    ; 3. Wait for Keypress (Pause the game)
    MOV AH, 01h
    INT 21h
    
    ; 4. Hide both cards again
    MOV SI, IDX1
    MOV MASK[SI], 0
    MOV SI, IDX2
    MOV MASK[SI], 0
    
    ; 5. Restart Loop
    JMP GAME_LOOP
    ; ==========================================

MATCHED:
    LEA DX, MATCH_MSG
    MOV AH, 09h
    INT 21h
    DEC PAIRS_LEFT      ; Decrease pairs remaining
    CALL DELAY          ; Keep delay here so user sees "MATCH" briefly
    JMP GAME_LOOP

SAME_CARD_ERROR:
    LEA DX, ERR_MSG
    MOV AH, 09h
    INT 21h
    CALL DELAY
    JMP GAME_LOOP

VICTORY:
    LEA DX, WIN_MSG
    MOV AH, 09h
    INT 21h
    
    ; Exit to DOS
    MOV AH, 4Ch
    INT 21h

MAIN ENDP

; =================================================================
; PROCEDURES
; =================================================================

; --- INPUTS ROW AND COL, RETURNS INDEX IN SI ---
GET_COORDS PROC
    ; Get Row
    LEA DX, PROMPT_R
    MOV AH, 09h
    INT 21h
    
    CALL READ_DIGIT
    CMP AL, GRID_WIDTH  ; Check if Row < Width
    JAE INVALID_INPUT
    MOV ROW_IN, AL
    
    ; Get Col
    LEA DX, PROMPT_C
    MOV AH, 09h
    INT 21h
    
    CALL READ_DIGIT
    CMP AL, GRID_WIDTH  ; Check if Col < Width
    JAE INVALID_INPUT
    MOV COL_IN, AL
    
    ; Calculate Index: SI = (Row * Width) + Col
    MOV AL, ROW_IN
    MUL GRID_WIDTH      ; AL = AL * Width
    ADD AL, COL_IN
    MOV AH, 0
    MOV SI, AX
    
    ; Check if card is already visible
    CMP MASK[SI], 1
    JE ALREADY_REVEALED
    
    RET

INVALID_INPUT:
    LEA DX, ERR_MSG
    MOV AH, 09h
    INT 21h
    JMP GET_COORDS

ALREADY_REVEALED:
    LEA DX, ERR_MSG
    MOV AH, 09h
    INT 21h
    JMP GET_COORDS
GET_COORDS ENDP

; --- DRAWS THE GRID ---
DRAW_BOARD PROC
    MOV CL, GRID_WIDTH
    MOV CH, 0
    MOV SI, 0           ; Array Index
    
    ROW_LOOP:
        PUSH CX         ; Save outer loop count
        MOV CL, GRID_WIDTH
        MOV CH, 0
        
        COL_LOOP:
            CMP MASK[SI], 1 ; Check if card is revealed
            JE SHOW_CARD
            
            ; Show '*' if hidden
            MOV DL, '*'
            MOV AH, 02h
            INT 21h
            JMP PRINT_SPACE
            
        SHOW_CARD:
            MOV DL, BOARD[SI]
            MOV AH, 02h
            INT 21h
            
        PRINT_SPACE:
            PUSH DX
            LEA DX, SPACE
            MOV AH, 09h
            INT 21h
            POP DX
            
            INC SI
            LOOP COL_LOOP
            
        ; New Line after every row
        LEA DX, NEWLINE
        MOV AH, 09h
        INT 21h
        
        POP CX          ; Restore outer loop count
        LOOP ROW_LOOP
    RET
DRAW_BOARD ENDP

; --- HELPER: READ SINGLE DIGIT ---
READ_DIGIT PROC
    MOV AH, 01h
    INT 21h
    SUB AL, 30h         ; Convert ASCII ('0') to Integer (0)
    RET
READ_DIGIT ENDP

; --- HELPER: CLEAR CMD SCREEN ---
CLEAR_SCREEN PROC
    MOV AX, 03h
    INT 10h
    RET
CLEAR_SCREEN ENDP

; --- HELPER: SIMPLE DELAY ---
DELAY PROC
    MOV CX, 0FFFFh
DL1:
    PUSH CX
    MOV CX, 00FFh       ; Adjust this value to make it faster/slower
DL2:
    LOOP DL2
    POP CX
    LOOP DL1
    RET
DELAY ENDP

END MAIN