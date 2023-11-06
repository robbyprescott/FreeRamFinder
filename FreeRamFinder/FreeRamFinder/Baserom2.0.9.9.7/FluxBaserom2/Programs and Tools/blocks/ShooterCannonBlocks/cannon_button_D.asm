!ReduceHitbox = 0

;this cannon block will launch mario if jump is pressed.
;behaves $025
db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

;JMP ret : JMP ret : JMP ret : JMP ret : JMP ret : JMP ret
;JMP ret : JMP ret : JMP main : JMP main

incsrc cannon_defs.txt

MarioAbove:
MarioBelow:
TopCorner:
MarioSide:
    LDA $7B
    ORA $7D
    BEQ ret ; if BNE, will constantly glitter while you're in it
    LDA #$10
    STA $1DF9
    %glitter()
    ;BRA ret
BodyInside:
HeadInside:
    if !ReduceHitbox    ; Added SJC
    %Collision12x16()	;\If too far, don't trigger block
	BCC ret				;/
	endif
	LDA $187A|!addr ;\if mario carrying something/on yoshi
	ORA $1470|!addr	;|
	ORA $148F|!addr	;|
	BNE ret			;/return
	LDA !freeram_interact	;\if he is prior launched
	BNE ret			;/then do nothing
	LDA $16			;\if player press B and/or A
	AND #$80		;|
	BNE launchplayer	;|then launch player
	LDA $18			;|
	AND #$80		;|
	BNE launchplayer	;/
;hold_player:
	LDA #$09
	STA !freeram_dir
	JSR center_player
SpriteV:
SpriteH: 
MarioCape: 
MarioFireball:
ret:
	RTL

launchplayer:
    %create_smoke() ; added by SJC
	LDA #!cannon_sfx_num		;\sfx (bullet bill shoot)
	STA !cannon_bank	;/
	LDA #$06		;\set timer to unable to interact temporaly
	STA !freeram_interact	;/
	LDA #$05		;\set direction
	STA !freeram_dir	;/
	JSR center_player
	RTL
center_player:
	LDA $9A			;\center player horizontally
	AND #$F0		;|
	STA $94			;|
	LDA $9B			;|
	STA $95			;/

	LDA $19			;\if mario is small
	BEQ small_mario		;/then center vertically differently

	LDA $98			;\center player vertically
	AND #$F0		;|
	SEC : SBC #$0A		;|
	STA $96			;|
	LDA $99			;|
	SBC #$00		;|
	STA $97			;|
	RTS			;|
small_mario:			;|
	LDA $98			;|
	AND #$F0		;|
	SEC : SBC #$10		;|
	STA $96			;|
	LDA $99			;|
	SBC #$00		;|
	STA $97			;/
skip_small:
	RTS
print "A cannon launches the player down if jump pressed. Requires the relevant UberASM."