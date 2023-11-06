;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Sprite Buoyancy Blocks - by dtothefourth
;
; Acts like water for sprites even if sprite
; buoyancy is disabled in the sprite header
;
; Use act as 25 to be water for sprites only
; Or act as 2 to also be water for Mario
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

SpriteV:
SpriteH:
	LDA #$01
	STA !164A,x
MarioBelow:
MarioAbove:
MarioSide:
Cape:
Fireball:
MarioCorner:
MarioBody:
MarioHead:
WallFeet:
WallBody:
RTL


print "This is like normal water, except it automatically has buoyancy for sprites, without having to enable this in Lunar Magic. Note that some sprites, like the floating spike ball (A4), apparently still require buoyancy to be enabled in Lunar Magic itself."