!KillFromAboveIfYoureNotBig = 1
!BounceHeightWhenShatter = $DA ; lower hex number = higher

!bounce_num			= $08			;>The bounce block sprite number
!bounce_properties	= $08			;> Palette B, 06. $04 is palette A (%00000100). $00 is palette 8, Mario. 
                                    ; The properties of bounce blocks (palette, tile number high byte)

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

BounceBlock:
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
     LDA $19
     CMP #$01
     BCC BounceBlock
     %shatter_block()
     BRA BounceBlock
MarioAbove:
TopCorner:
     LDA $19
     CMP #$01
     BCC Return
     LDA $140D
     BEQ Return
LDA #!BounceHeightWhenShatter
STA $7D
;LDA #$07 
;STA $1DFC
%shatter_block()
MarioSide:

BodyInside:
HeadInside:

;WallFeet:	; when using db $37
;WallBody:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
     BRA Final
Return:
     if !KillFromAboveIfYoureNotBig
     JSL $00F606
     endif
Final:
     RTL

print "This shatter block can't be broken by small Mario, but only big Mario. Further, by default, it's set to actually instantly KILL small Mario if he touches it from above (though you can change this). This is to prevent cheese in the common kaizo setup where you have to spin-jump off of turnblocks as big Mario."