; By MarioFanGamer, big modifications by SJC
; SFX handled by bounce sprite

!FireballActivate = 1

!bounce_num			= $09	; See RAM $1699 for more details. If set to 0, the block changes into the Map16 tile directly
!bounce_block		= $FF	; See RAM $9C for more details. Can be set to $FF to change the tile manually
!bounce_properties	= $00	; YXPPCCCT properties. 06 default

db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP HeadInside : JMP BodyInside
JMP WallRun : JMP WallFeet

Shared:
	lda $14AF|!addr				;checking the on off state
	bne Return
	;lda #$0B					;sound effect
	;sta $1DF9|!addr
	lda #$01					;load 01 to on off state
	sta $14AF|!addr
	
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
if !FireballActivate = 1
    STZ $170B,x
	%fireball_smoke()
    BRA Shared
endif	

WallRun:
WallFeet:

BodyInside:			;>fireballs should go through coins!

MarioAbove:
TopCorner:

HeadInside:
MarioSide:

Return:
RTL

print "This is one half of a pair of custom on/off switches. Unlike normal switches, after you hit this one, it'll become a brick block and you'll be unable to flip it again, UNTIL the OTHER switch is flipped (and vice versa). Is also set to be activated by Mario fireballs, too, but you can change this."