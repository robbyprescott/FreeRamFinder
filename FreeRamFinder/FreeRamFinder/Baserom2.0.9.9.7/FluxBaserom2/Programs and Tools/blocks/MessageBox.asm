; Must use in conjunction with MessageBoxTranslevel Uber! Set message number in that.
; By SJC, points to	All Levels Message Block by JamesD28. 

!EraseAfterUse = 0

!bounce_num			= $0C	; See RAM $1699 for more details. If set to 0, the block changes into the Map16 tile directly
!bounce_block		= $FF	; See RAM $9C for more details. Can be set to $FF to change the tile manually
!bounce_properties	= $06	; YXPPCCCT properties

!FreeRAM = $0EAD  ; Must match MessageBoxTranslevel Uber

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP HeadInside : JMP BodyInside
JMP WallRun : JMP WallFeet

Shared:
    PHX
	PHY
	;LDA.b #!bounce_tile
	;STA $02
	;$03 is already set
	LDA #!bounce_num
	LDX #$FF
	LDY #$00
	%spawn_bounce_sprite()
	LDA #!bounce_properties
	STA $1901|!addr,y
	PLY
	PLX
 
    LDA #$01
	STA !FreeRAM
	
	if !EraseAfterUse
	%erase_block()
	endif
	RTL
	
MarioBelow:
    LDA $7D			;\Must be going up.
	BPL Return		;/ Necessary to prevent weird side activation
    BRA Shared
	RTL
	
SpriteH:
    %sprite_block_position()
	%check_sprite_kicked_horiz_alt() ; changed from %check_sprite_kicked_horizontal()
	BCS Shared
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
	
MarioCape:	
	BRA Shared
	
MarioFireBall:			;>fireballs should go through coins!
BodyInside:			;>fireballs should go through coins!
WallFeet:

MarioAbove:
TopCorner:

HeadInside:
MarioSide:
WallRun:
Return:
RTL

print "Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that."