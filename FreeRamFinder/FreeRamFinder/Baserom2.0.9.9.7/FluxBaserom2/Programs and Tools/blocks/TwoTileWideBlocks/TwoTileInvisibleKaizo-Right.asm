; By SJandCharlieTheCat

!Block = $0132
!SpriteActAs = $0025
!YXPPCCCT = $04 ; 04 is Palette A

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP BodyInside : JMP HeadInside



MarioBelow:	
	LDA $7D
	BPL Return
	
	LDA #$05 ; or higher, 10?
	STA $7D
	
	PHX
	PHY
	LDA #$03 ; $1699, bounce sprite. 01 normal turnblock. 07 is turning turnblock
	LDX #$16 ; $9C, Map16 tile. 02 is tile 25. 05 is always turning.
	LDY #$00
	%spawn_bounce_sprite()
	LDA #!YXPPCCCT ; #$01 is second GFX page
	STA $1901,y
	PLY
	PLX
	
	LDY #$01		;\
    LDA #$30		;| Act solid during Map16 change, handles janky side interaction
    STA $1693       ;/
	
	PHB
	LDA #$02
	PHA			; spawn coin above block
	PLB
	JSL $02889D
	PLB	

	;%create_smoke()			;>smoke
	;%erase_block()			;>Delete self.
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
	REP #$20			;\Move 1 block left.
	LDA $9A				;|
	CLC : ADC #$FFF0		;|
	STA $9A				;|
	SEP #$20			;/
	
	PHX
	PHY
	LDA #$03 ; $1699, bounce sprite. 01 normal turnblock. 07 is turning turnblock
	LDX #$16 ; $9C, Map16 tile. 02 is tile 25. 05 is always turning.
	LDY #$00
	%spawn_bounce_sprite()
	LDA #!YXPPCCCT ; #$01 is second GFX page
	STA $1901,y
	PLY
	PLX
	
	PHB
	LDA #$02
	PHA			; spawn coin above block
	PLB
	JSL $02889D
	PLB	

	LDA #$01			;\Play sfx.
	STA $1DFC		;/
	RTL
TopCorner:
MarioAbove:
MarioSide:
HeadInside:
MarioCape:
MarioFireBall:
BodyInside:
SpriteV:
SpriteH:
    LDY.b #!SpriteActAs>>8
    LDA.b #!SpriteActAs
    STA $1693|!addr
Return:
	RTL

print "Two-tile wide invisible kaizo block, right tile."