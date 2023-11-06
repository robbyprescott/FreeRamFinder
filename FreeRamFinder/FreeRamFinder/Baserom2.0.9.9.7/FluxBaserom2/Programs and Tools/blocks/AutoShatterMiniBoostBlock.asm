; By SJC
; Shatters and bounces you up a bit when you touch from above.

!EraseBlock = 0   ; if enabled, this will cause less sprite lag in sprite-heavy sections
!power = $CA ; $Dx or Ex for shorter bounce

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37


MarioAbove:
TopCorner:
    LDA #!power
    STA $7D
if !EraseBlock
    %erase_block()
	LDA #$38 
    STA $1DFC
else 
    %shatter_block()
endif
MarioSide:
MarioBelow:
BodyInside:
HeadInside:

;WallFeet:	; when using db $37
;WallBody:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
RTL

print "Automatically shatters and bounces you up a bit when you touch it from above."
