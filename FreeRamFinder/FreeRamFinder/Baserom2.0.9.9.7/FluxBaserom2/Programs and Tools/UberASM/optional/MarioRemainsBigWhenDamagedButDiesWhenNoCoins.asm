; A.k.a. "Sonic style powerdown" 
; You'll start off big, and REMAIN big when you take damage.
; You'll finally die when you're out of coins (can set the counter to be different)

; By MFG, edits by SJC


!CoinsToStartWith = $02		 ; He'll lose a coin whenever damaged, and then die if damaged after zero coins.				
!CoinLoss = 01			     ; How many coins you'll lose whenever you take damage.
                              

AnimationTimer = read1($00F5ED)-1
KillMario = $00F606|!bank

load:
	LDA #!CoinsToStartWith
	STA $13CC
	RTL

main: 
	LDA $19				; Force player to be big
	BNE .Big			;
	INC $19				;
.Big:					;
	LDA $71				; Hurt animation?
	DEC					;
	BNE .NotHurt		;
	LDA $1496|!addr		; Start of animation?
	CMP.b #AnimationTimer
	BNE .NotHurt		; Skip
	
	; Custom hurt code
	LDA $0DBF|!addr		; Any coins in the pocket?
	BNE .NoDeath		;
    JML KillMario			; RIP
						;
.NoDeath:				;
	SEC : SBC #!CoinLoss;
	BCS .NoUnderflow	;
	LDA #$00			; No coins in the negative
.NoUnderflow:			;
	STA $0DBF|!addr		;

.NotHurt:
RTL
