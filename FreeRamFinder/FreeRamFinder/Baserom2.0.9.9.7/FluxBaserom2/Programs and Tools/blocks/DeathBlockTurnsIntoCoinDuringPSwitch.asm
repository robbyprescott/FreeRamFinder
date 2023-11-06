db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
JMP WallFeet : JMP WallBody



SpriteV:
SpriteH:
	LDA $14AD
	BEQ Solid ; do the following if p-switch		
	LDY #$00		
	LDA #$2C
	STA $1693	
	RTL	
MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
BodyInside:
HeadInside:
WallFeet:
WallBody:
	LDA $14AD
	BEQ OffMario ; do the following if p-switch		
	LDY #$00		
	LDA #$2C
	STA $1693	
	RTL	
OffMario:
    JSL $00F606	
Solid:
	LDY #$01		
	LDA #$30
	STA $1693
MarioCape:
MarioFireball:
Return:
RTL



print "Mormal death block, but turns into a coin when a p-switch is active."