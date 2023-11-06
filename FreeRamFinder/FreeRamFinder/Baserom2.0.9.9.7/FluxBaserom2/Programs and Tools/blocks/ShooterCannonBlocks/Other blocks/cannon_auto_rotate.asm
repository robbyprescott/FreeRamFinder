;this cannon block will launch mario automatically in different directions
;based on the exanimation frame, thus the player has to time his movement
;BEFORE jumping into it, to change the direction for each frame, scroll to
;the very bottom.
;behaves $025
db $42
JMP ret : JMP ret : JMP ret : JMP ret : JMP ret : JMP ret
JMP ret : JMP ret : JMP main : JMP main

incsrc cannon_defs.txt

main:
	%Collision12x16()	;\If too far, don't trigger block
	BCC ret				;/
	LDA $187A|!addr	;\if mario carrying something/on yoshi
	ORA $1470|!addr	;|
	ORA $148F|!addr	;|
	BNE ret			;/return
	LDA !freeram_interact	;\if mario prior launched
	BNE ret			;/then return
	LDA #!cannon_sfx_num		;\sfx (bullet bill shoot)
	STA !cannon_bank	;/
	LDA #$06		;\so mario cannot be stuck in cannon
	STA !freeram_interact	;/
	PHX						;>protect Y from being used as behavor
	LDA $7FC080+!Global_Or_Level0+!Which_Slot0	;>load exanimation RAM
	TAX						;>transfer to Y (because its a long address for table)
	LDA direction_table,x				;>use different directions depending on frame
	STA !freeram_dir				;>and set his direction
	PLX						;>end the preservation so it won't stack endlessly
	LDA #$FF		;\so he looks like he's in the cannon
	STA $78			;/
	LDA $9A			;\center player horizontally
	AND #$F0		;|
	STA $94			;|
	LDA $9B			;|
	STA $95			;/

	LDA $19			;\if mario is small
	BEQ small_mario		;/then center vertically differently

	LDA $98			;\center player vertically
	AND #$F0		;|
	SEC : SBC #$0A		;|
	STA $96			;|
	LDA $99			;|
	SBC #$00		;|
	STA $97			;|
	RTL			;|
small_mario:			;|
	LDA $98			;|
	AND #$F0		;|
	SEC : SBC #$10		;|
	STA $96			;|
	LDA $99			;|
	SBC #$00		;|
	STA $97			;/	
ret:
	RTL
;This is the table that list of directions based on the exanimation frame.
;each Individual number correspond to each exanimation frame (1st number
;means 1st frame, 2nd number means 2nd frame, etc), the values represent
;the direction based on the frames. Here are the valid values:
;$01 = up
;$02 = up-right
;$03 = right
;$04 = down-right
;$05 = down
;$06 = down-left
;$07 = left
;$08 = up-left

direction_table:
	db $01,$02,$03,$04,$05,$06,$07,$08

;Be careful that if the number of frames of LM is more than the number
;of frames in the table will causes glitches because the frames exceed
;the block's table.

print "A rotating cannon that launches the player automatically."