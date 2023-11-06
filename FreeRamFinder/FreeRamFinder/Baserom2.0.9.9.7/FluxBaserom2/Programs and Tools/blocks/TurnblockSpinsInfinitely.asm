print "A turnblock that spins forever after being activated."

; By MarioFanGamer, big modifications by SJC

;!map16_tile         = $0048 

;!bounce_num			= $08			;>The bounce block sprite number
;!bounce_properties	= $04			;> $04 is palette A (%00000100). $00 is palette 8, Mario. 
                                    ; The properties of bounce blocks (palette, tile number high byte)
!YXPPCCCT = $04 ; 04 is Palette A

db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP HeadInside : JMP BodyInside
JMP WallRun : JMP WallFeet

SharedBounce:

    PHX
	PHY
	LDA #$01 ; $1699, bounce sprite. 01 normal turnblock. 07 is turning turnblock
	LDX #$05 ; $9C, Map16 tile. 02 is tile 25. 05 is always turning.
	LDY #$00
	%spawn_bounce_sprite()
	LDA #!YXPPCCCT 
	STA $1901,y
	PLY
	PLX
	
    ;;PHX 
	;;PHY 
    ;LDA.b #!map16_tile
    ;STA $03
    ;LDA.b #!map16_tile>>8
    ;STA $04
    ;LDA #!bounce_num
    ;LDX #$FF
    ;LDY #$00
    ;%spawn_bounce_sprite()
    ;LDA #!bounce_properties
    ;STA $1901|!addr,y
	;;PLY 
	;;PLX 
	RTL
	
MarioBelow:
    LDA $7D			;\Must be going up.
	BPL Return		;/ Necessary to prevent weird side activation
	
	;add other stuff?
	
    BRA SharedBounce
	RTL
	
SpriteH:
	%check_sprite_kicked_horiz_alt() ; changed from %check_sprite_kicked_horizontal()
	BCS SpriteShared
    RTL

SpriteV:
	LDA $14C8,x
	CMP #$09
	BCC Return
	LDA $AA,x
	BPL Return
	LDA #$10
	STA $AA,x

SpriteShared:
	%sprite_block_position()
MarioCape:	
	BRA SharedBounce

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