print "Complicated block. See instructions."

; Independent of UberASM retry settings, this block acts like a silent secondary checkpoint (no SFX, and invisible if you want), 
; making you respawn at the secondary entrance associated with it when you die after touching it. (See further below for the secondary entrance #s you should use.)
; It works in conjunction with the secondary entrance settings/menu,
; where you create secondary entrances and assign them level destinations, etc. 
; You don't need to bother with the screen exit menu here.

; HOW TO USE:
; I've designed this block kind of like a silent counterpart of custom object 2D.
; If you go to Map16 page 2D, starting at tile 2D49 you'll see a lot of copies of this block.
; The last two numbers of each block number, as well as their act-as #, both range from 49 to 69. 
; This corresponds to this same range of secondary entrance numbers.
; So if you want to respawn at the destination assigned to
; secondary entrance number 4B upon death, use block 2D4B (act-as is 4B). 
; Or for secondary entrance 61, use block 61.

; (If you've never used the secondary entrance menu, it's the door icon with a 2 on it.
; On the left side of that menu, you see a pull-down prompt with all the secondary entrances numbers.
; You can assign these secondary entrance numbers a level destination — including the current level — ,
; and then set the exact spawn screen and position with the generated Mario sprite. If you
; can't find the Mario sprite it generates, check the top of the screen, or far-left.)

!ram_set_checkpoint = $7FB413

db $42 ; enable corner and inside offsets
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall : JMP MarioCorner : JMP BodyInside : JMP HeadInside


MarioBelow:
MarioSide:
MarioCorner:
HeadInside:
BodyInside:
MarioAbove:
	TYA
    XBA
    LDA $1693     ; Find secondary number corresponding to block act-as
    REP #$20
    ORA #$0200    ; Set the "secondary entrance/exit" bit in the high byte (like $19D8)?
    STA !ram_set_checkpoint ; https://www.smwcentral.net/?p=memorymap&game=smw&region=ram&address=7E19D8&context=
    SEP #$20
    RTL
MarioFireBall:
SpriteV:
SpriteH:
MarioCape:
    RTL
	
	

 
;REP #$20
;LDA #$0011    ; Secondary number.
;ORA #$0200 