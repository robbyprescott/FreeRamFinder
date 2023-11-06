; By SJandCharlieTheCat, based on MFG and lx5
; Activated from the side or below by sprites

print "Invisible kaizo block, only activated by kicked sprites."

!FireballActivation = 0
!Map16TileToGenerate = $0132

db $42

		
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioInside : JMP MarioHead

Return:
MarioAbove:
MarioSide:
MarioCorner:
MarioInside:
MarioHead:
MarioBelow:
Cape:
    RTL
Fireball:
if !FireballActivation = 1
; STZ?
    BRA Kaizod
endif
    RTL
SpriteH:
	%check_sprite_kicked_horiz_alt() ; alt handles dropped from above jank better than %check_sprite_kicked_horizontal()
	BCS Kaizod
    RTL
SpriteV:
	LDA $14C8,x
	CMP #$08 ; 9
	BCC Return
	LDA $AA,x
	BPL Return
	LDA #$10 ; handles weird below clipping
	STA $AA,x
Kaizod:
    %sprite_block_position()
	
    PHX				
	REP #$10				
	LDX #!Map16TileToGenerate	
	%change_map16()				
	SEP #$10			
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
	 
	PHX
	PHY
	LDA #$03
	LDX #$0D
	LDY #$00
	%spawn_bounce_sprite()
	LDA #$00
	STA $1901,y

	LDA #$01 ; coin sound
	STA $1DFC

	PLY
	PLX	
Return2:
    RTL
