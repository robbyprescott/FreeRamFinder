; SFX handled by bounce sprite

!FireballActivate = 1

!bounce_num			= $09			;>The bounce block sprite number
!bounce_properties	= $00			;> Palette B, 06. $04 is palette A (%00000100). $00 is palette 8, Mario. 
                                    ; The properties of bounce blocks (palette, tile number high byte)


db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP HeadInside : JMP BodyInside
JMP WallRun : JMP WallFeet

Shared:
	lda $14AF|!addr				;checkin on off state
	beq Return
	;lda #$0B
	;sta $1DF9|!addr				;load sound effect and on off state
	stz $14AF|!addr
	
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