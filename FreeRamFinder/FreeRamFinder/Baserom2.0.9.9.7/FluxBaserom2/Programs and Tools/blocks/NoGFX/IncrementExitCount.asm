print "Increments exit counts +1 when touched. See file for more info."

; If you set things up so that you have to get this block PRIOR to the goal tape, 
; what you can do is make an Uber where FreeRAM is set during the goal sequence (and save this to SRAM, or use $1F2B?).
; Then you can use this FreeRAM as a check in this block itself, to prevent 
; the exit count incrementing again if people replay the level. 

!FreeRAM = $14AF ; match Uber

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioInside : JMP MarioHead
JMP WallRun : JMP WallSide

MarioInside:
MarioSide:
MarioBelow:
MarioAbove:
MarioCorner:
MarioHead:
WallRun:
WallSide:
   LDA !FreeRAM
   BNE Return
   INC $1F2E
   LDA #$05 ; midway sound
   STA $1DF9
   %erase_block() ; prevent double increment
SpriteV:
SpriteH:
Cape:
Fireball:
Return:
    RTL