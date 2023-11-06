; Works with conditional Map16.

; Put this block in your level, then click on it (in the level),
; and go to Edit > Conditional Map16..., 
; type 1 for the Flag Number, and check "Always show..." 
; This will make it so that after hitting it (turns into used brown block), 
; after you die and respawn, it will no longer be there - or, rather, it'll become whatever tile is 100 tiles below it (in Map16).
; (It will also display this other tile in LM no matter what.)

db $42 ; enable corner and inside offsets
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall : JMP MarioCorner : JMP BodyInside : JMP HeadInside


MarioBelow:
   LDA $7FC060
   ORA #%00000010 ; 2 in hex, 1 in Conditional
   STA $7FC060
MarioSide:
MarioCorner:
HeadInside:
BodyInside:
MarioAbove:
MarioFireBall:
SpriteV:
SpriteH:
MarioCape:
Return:
	RTL
	
print "InvisibleKaizoBlockNeverReappearsAfterDeath.asm. Use ConditionalMap16 flag 1. See instructions for more."