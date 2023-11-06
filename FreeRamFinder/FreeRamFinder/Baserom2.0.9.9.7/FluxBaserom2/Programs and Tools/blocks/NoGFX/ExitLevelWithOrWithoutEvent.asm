print "Exits level without doing anything when touched. You can set it to trigger exits/events, though."

;by KevinM

; What kind of exit to trigger
; - $00 : No event, just returns you to overworld
; - $01 : Normal exit
; - $02 : Secret exit 1
; - $03 : Secret exit 2
; - $04 : Secret exit 3

!ExitType = $00

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

MarioCorner:
WallFeet:
WallBody:
MarioBelow:
MarioAbove:
MarioSide:
MarioBody:
MarioHead:

lda.b #!ExitType
	sta $0DD5|!addr
	lda #$01
	sta $1DE9|!addr
	sta $13CE|!addr
	lda #$0B
	sta $0100|!addr
SpriteV:
SpriteH:
Fireball:
Cape:
RTL    		;do nothing on sprite/fireball/cape contact 