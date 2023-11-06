!FreezeWhenGet = 0 ; If 1, will freeze Mario briefly when you get it.
               ; Note, however, that UNlike the normal powerup,
               ; Mario will	turn invisible for a second
!FreeRAM = $0E1C

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

     LDA #$01
     STA !FreeRAM
     LDA #$0A
     STA $1DF9 ; sound
if !FreezeWhenGet
     LDA #$04				;\Fire flower animation
	 STA $71				;|
	 LDA #$20				;|
	 STA $149B|!addr		;|
	 STA $9D				;|
endif	 
     LDA #$09					;\Spawn score sprite
	 %SpawnScoreSprite()				;/
	 %PositionScoreSprite()				;>Position the score sprite.     
	 %erase_block()

;WallFeet:	; when using db $37
;WallBody:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
RTL

print "Powerup for SMALL fire Mario. Use with small fire Mario UberASM, if you want this to only activate when you get it."