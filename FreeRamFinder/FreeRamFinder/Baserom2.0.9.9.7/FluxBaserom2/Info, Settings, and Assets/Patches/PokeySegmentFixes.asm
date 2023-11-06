;Pokey's Segment Collision Fix
;This patch fixes a glitch where if you hit pokey's top segment with 4 or less segments slightly higher with a shell or similar object, instead of that top segment going down a non-existant segment will go down instead (segment dupe basically)
;By RussianMan. Credit is optional.
; SJC added SFX fix too

if read1($00FFD5) == $23
	sa1rom
	!C2 = $D8
else
	lorom
	!C2 = $C2
endif

org $02B803
autoclean JSL CheckMan
NOP

freecode

CheckMan:
PHB				;preserve bank and stuff in case things go wrong (with loading tables)
PHK				;
PLB				;

LDA #$13
STA $1DF9 ; added by SJC

LDA !C2,x			;check if current segment we're about to take is actually there
AND PokeySetBit,y		;
BNE .Normal			;if so, proceed as normal

INY				;if not, take lower segment

.Normal
LDA !C2,x			;remove segment
AND PokeyUnsetBit,y		;
PLB				;



RTL				;

;lowest to highest
PokeySetBit:
db $10,$08,$04,$02,$01

PokeyUnsetBit:
db $EF,$F7,$FB,$FD,$FE