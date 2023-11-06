; By SJandCharlieTheCat

print "Works like a normal question mark block, but can set this to spawn any block ABOVE the original block when hit. You can also set the original to turn into something other than a brown used block."

!BlockToSpawnAbove = $012F
!OriginalBlockTurnsInto = $0132 ; brown used block by default. $0124 is question block

!SFX = $03 
!SFXBank = $1DFC ; $10 : $1DF9 is magikoopa magic, but $1DF9 same as hit head sound. Vine growing is LDA #$03 : STA $1DFC

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioBelow:
    LDA $7D			;\Must be going up.
	BPL Return		;/ Necessary to prevent weird side activation
    BRA Spawn
	RTL
SpriteH:
    %sprite_block_position()
	%check_sprite_kicked_horiz_alt() ; changed from %check_sprite_kicked_horizontal()
	BCS Spawn
    RTL
SpriteV:
    %sprite_block_position()
	LDA $14C8,x
	CMP #$09
	BCC Return
	LDA $AA,x
	BPL Return
	LDA #$10
	STA $AA,x	
Spawn:
    PHX					; \ 
	REP #$10				; |
	LDX #!OriginalBlockTurnsInto				; | Change into Map16 tile, used brown block.
	%change_map16()				; |
	SEP #$10				; |
	PLX					; /	
	
    LDA #!SFX 
	STA !SFXBank
	
    REP #$20				; \
	LDA $98					; |
	PHA					; |
	LDA #$FFF0				; |
	CLC					; |
	ADC $98					; |
	STA $98					; |
	SEP #$20				; |
	PHX					; | 
	REP #$10				; |
	LDX #!BlockToSpawnAbove				; |
	%change_map16()				; | 
	SEP #$10				; |
	PLX					; |
	REP #$20				; |
	PLA					; |
	STA $98					; |
	SEP #$20				; /
	
	Return:
TopCorner:
MarioAbove:
MarioSide:
HeadInside:
MarioCape:
MarioFireBall:
BodyInside:
    RTL
