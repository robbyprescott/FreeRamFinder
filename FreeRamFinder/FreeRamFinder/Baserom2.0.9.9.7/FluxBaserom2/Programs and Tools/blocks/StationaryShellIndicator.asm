db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

MarioBelow:
MarioAbove:
MarioSide:

TopCorner:
BodyInside:
HeadInside:
    
	LDA $0ECF ; $0ECF set by shell itself; this checks. 
	BEQ Return
	LDA $7D
	BPL Return ; must be ascending
    REP #$10				;   16-bit XY
    LDX $03					; \ 
    INX						; / Load next Map16 number
    %change_map16()			;   Change the block
    SEP #$10				;   8-bit XY
	STZ $0ECF

;WallFeet:	; when using db $37
;WallBody:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
Return:
RTL

print "Simple number indicator, though can also be used with Uber in conjunction with statonary shell blocks."