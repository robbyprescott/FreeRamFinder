!SoundEffect = $25
!Bank = $1DFC

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP BodyInside : JMP HeadInside

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP BodyInside : JMP HeadInside

SpriteV:
SpriteH:
MarioCape:
    RTL
MarioSide:
HeadInside:
MarioFireBall:
BodyInside:
MarioAbove:
TopCorner:
MarioBelow:
    LDA $191C ; check if key Yoshi mouth
    BEQ Return
Destroy:
	LDY #$01		;\
    LDA #$30		;| Act solid during Map16 change, handles janky side interaction
    STA $1693|!addr       ;/

	%create_smoke()			;>smoke
	%erase_block()			;>Delete self.

	LDA $5B				;\Check if vertical level = true
	AND #$01			;|
	BEQ +				;|
	PHY				;|
	LDA $99				;|Fix the $99 and $9B from glitching up if placed
	LDY $9B				;|other than top-left subscreen boundaries of vertical
	STY $99				;|levels!!!!! (barrowed from the map16 change routine of GPS).
	STA $9B				;|(this switch values $99 <-> $9B, since the subscreen boundaries are sideways).
	PLY				;|
+					;/
	REP #$20			;\Move 1 block down.
	LDA $98				;|
	CLC : ADC #$0010		;|
	STA $98				;|
	SEP #$20			;/
	
	STZ $18AC ; destroy Yosh mouth sprte

	%create_smoke()			;
	%erase_block()			;

    LDA #!SoundEffect			;\Play sfx.
	STA !Bank|!addr		;/
    Return:
	RTL

print "Can only be unlocked when you have a key in Yoshi's mouth. (This is the top block of a two-block pair.) Don't use in true vertical levels! If you had planned on doing this, use the tall horizontal level mode to emulate a vertical level instead."