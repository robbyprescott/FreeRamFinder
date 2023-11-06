!MarioActAs = $0130
!SpriteIsntStopped = 1 ; Sprite will move right through without being stopped
                       ; Set to 0 to make its motion stop
!OnlyDestroyMovingUpward = 1 ; only destroyed if sprite has upward movement

;Behaves $130
;This is the left block of the 2x1 block gate.

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP BodyInside : JMP HeadInside

incsrc KeyBlkDef.txt


;-------------------------------------------------
;This checks what sprite number and deletes key.
;-------------------------------------------------

SpriteV:
SpriteH:
%sprite_block_position()
if !custom_type == 0 || !custom_type == 1
	PHX
	LDX.b #!NumbOfSa1Slots-1
-
	LDA !14C8,x		;\If sprite status = not alive then next slot
	CMP #$08		;|
	BNE NextSlot		;/

	LDA !7FAB10,x		;\Check if its a custom sprite
	AND #$08		;|
	if !custom_type = 0	;|
		BNE ReturnPull	;|
	else			;|
		BEQ ReturnPull	;|
	endif			;/
	LDA !SpriteTyp,x	;\If sprite number doesn't match, then next slot
	CMP #!SpriteNum		;|
	BNE NextSlot		;/
if !OnlyDestroyMovingUpward
	LDA $AA,x   ; sprite y-speed. (B6 is x-speed)
	BPL ReturnPull
else
    LDA $AA,x   ; sprite y-speed. (B6 is x-speed)
	BMI ReturnPull
endif
	JMP match_sprite	;>if match, then proceed.
NextSlot:
	DEX
	BPL -
ReturnPull:
	PLX
	RTL			;>if all slots checked and still didn't find, return.
match_sprite:
	;STZ !14C8,x		;>erase key.
	PLX			;>done with slots.
	;LDA #$40		;\Fix a bug that if you unlock the block and kick it
	;TSB $15			;/at the same frame makes deleting the key not function.

endif
;---------------------------------
;Erase block.
;---------------------------------
Erase:
    if !SpriteIsntStopped
	LDY #$00		;\Right when it disappears, shouldn't stop the player's
	LDA #$25		;|movement.
	STA $1693|!addr		;/
	endif

	%create_smoke()			;>smoke
	%erase_block()			;>Delete self.
	LDA $5B				;\Check if vertical level = true
	AND #$01			;|
	BEQ +				;|
	PHY				;|
	LDA $99				;|Fix the $99 and $9B from glitching up if placed
	LDY $9B				;|other than top-left subscreen boundaries of vertical
	STY $99				;|levels!!!!! (barrowed from the map16 change routine of GPS).
	STA $9B				;|(this switch values $99 <-> $9B, since the subscreen boundaries are sideways).
	PLY				;|
+					;/
	REP #$20			;\Move 1 block right.
	LDA $9A				;|
	CLC : ADC #$0010		;|
	STA $9A				;|
	SEP #$20			;/
	%create_smoke()			;
	%erase_block()	

	LDA #!sfx_open			;\Play sfx.
	STA !RAM_port_open		;/
	RTL

	;LDA !14C8,x		;\If sprite status = not carried then next slot
	;CMP #$08		;|
	;BNE Return		;/

	;LDA !7FAB10,x		;\Check if its a custom sprite
	;AND #$08		;|
	;if !custom_type = 0	;|
		;BNE Return	;|
	;else			;|
		;BEQ Return	;|
	;endif			;/
	;LDA !SpriteTyp,x	;\If sprite number doesn't match, then next slot
	;CMP #!SpriteNum		;|
	;BNE Return		;/
	
	;LDA $AA,x   ; sprite y-speed. (B6 is x-speed)
	;CMP #$80
	;BMI Return  ; BMI for downward

	;STZ !14C8,x		;>erase key.

	

	;BRA Erase

	;RTL
TopCorner:
MarioAbove:
MarioBelow:
MarioSide:
HeadInside:
MarioCape:
MarioFireBall:
BodyInside:
    LDY.b #!MarioActAs>>8
    LDA.b #!MarioActAs
    STA $1693|!addr
Return:
	RTL

print "Solid for Mario, but will be crushed be block-interactable sprites that move vertically through it. By default, it won't make the sprite stop when it goes through it (though this can be changed). Also, the blocks are currently only crushed when a sprite moves UP through it, but this can be changed too."