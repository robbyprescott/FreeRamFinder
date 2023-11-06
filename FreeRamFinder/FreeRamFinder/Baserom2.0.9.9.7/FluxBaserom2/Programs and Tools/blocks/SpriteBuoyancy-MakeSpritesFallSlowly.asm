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
; If you want to reenable the splash effect,
; comment out the relevant line.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody


SpriteV:
SpriteH:
    LDA !166E,x : ORA #$40 : STA !166E,x    ; disables splash GFX
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

print "Sprites in this block will behave like they're in water, moving and falling slowly. Splash GFX disabled by default. Note that some sprites, like the floating spike ball (A4), apparently still require buoyancy to be enabled in Lunar Magic itself. (Though certain types of buoyancy may actually counteract the effects of this block, at least with certain patches."