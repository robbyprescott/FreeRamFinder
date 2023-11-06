; Only minor mods by SJC

;	Kill sprite
;	HuFlungDu
;	This block will kill cause every one of one specific NON CUSTOM sprite to disapear in a puff of smoke
;	when mario touches it. To choose which sprite, just change !spritenum to the sprites number. Currently
;	kills regular boos, but you can make it kill whatever you like.
;	It doesn't really matter how it acts, just make it act like whatever you place it as.
;	No credit necessary

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall
JMP MarioC : JMP MarioB : JMP MarioH



MarioC:
MarioH:
MarioB:
MarioBelow: 
MarioSide: 
MarioAbove:
    PHX					;Push the X register
	LDX #$00			;innitiate the counter
	loop:
	LDA $14C8,x
    CMP #$08 ; sprite state
    BCC notkill
    LDA $9E,x			;Load the sprite numbers of all the sprites on screen (one at a time)
	CMP #$6D	     ;  Invisible solid block
	BEQ notkill			
	CMP #$7B 
	BEQ notkill      ; goal tape
	CMP #$B9	     ;     Message box
	BEQ notkill			
	CMP #$C8		 ; Red light-switch, sometimes used to block Mario but allow sprites, e.g. in skytrees
	BEQ notkill			;/
	LDA #$04			;\ Make the sprite dissapear in a puff of smoke
	STA $14C8,x			;/
	LDA #$38            ; 08 is normal spin jump sound
    STA $1DFC           ; 1DF9 
	LDA #$1F
	STA $1540,x

	notkill:
	INX					;Move on to the next slot
	CPX #$0C			;\If they haven't all been checked, go back to the beginning
	BCC loop			;/
	PLX					;Pull the X register from the stack
MarioCape: 
MarioFireBall:
SpriteV: 
SpriteH: 
	RTL
	
	print "Kills all on-screen sprites, except things like message boxes. Also will need to modify it to kill custom sprites."