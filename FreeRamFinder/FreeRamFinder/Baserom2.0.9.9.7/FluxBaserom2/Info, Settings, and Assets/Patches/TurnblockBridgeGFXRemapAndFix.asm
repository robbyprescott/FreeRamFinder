; The direction that one of the tiles in the tileblock bridge
; is oriented is reversed from the other 4 blocks.
; Hard to notice, but it's there.



!Palette = $0A	; Not the YXPPCCCT format
!Page = 0

; I recommend you to NOT change the rest
if read1($00FFD5) == $23
	sa1rom
	!Base = $6000
else
	lorom
	!Base = $0000
endif

; Unless you know what to do
!YXPPCCCT = ((!Palette&7)<<1)|(!Page&1)

org $01B78E
LDA $64
ORA #!YXPPCCCT
STA $0303|!Base,y	; Changes x-flipped tile?
STA $0307|!Base,y
STA $030B|!Base,y
STA $030F|!Base,y
STA $0313|!Base,y
LDA $00 : PHA	; Code I accidentally overwrote >_<