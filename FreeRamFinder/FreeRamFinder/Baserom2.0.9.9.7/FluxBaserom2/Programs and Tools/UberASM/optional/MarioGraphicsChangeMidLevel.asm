; Before using, requires you to set up the stuff included in Optional Features

; This Uber lets you make a player (or animation) GFX change — and, optionally, a palette change too — MID-level, 
; instead of just a single change at the beginning of the level like the other Uber.

; You can set what you want to trigger this change. By default it's $14AF, the on/off switch

; Note, however, that for the mid-level GFX change, there's a brief freeze when doing this.
; If you want an instant transformation, you should probably instead use the other patch which I've included and modified. 
; The other patch doesn't allow you to change the other animation GFX (see GFX33), though.

; The GFX change and palette change are separare here. 


!Trigger = $14AF
!CustomExGFXNumber = $0C32 ; actual GFX themselves
!ChangeToLuigi = 0 ; Actually makes player Luigi
!VanillaExGFXNumber = $0A32 ; you shouldn't need to change this

main:
    lda !Trigger ; on/off switch
	beq BackToMario
    rep #$30
    lda.w #!CustomExGFXNumber
    jsl mario_exgfx_upload_player
    sep #$30
if !ChangeToLuigi
	LDX $0DB3 ; actually change player to Luigi
	TXA
	BEQ ToLuigi
	STZ $0DB3
ToLuigi:
	INC $0DB3
endif	
	RTL
	
BackToMario:
	rep #$30
    lda.w #!VanillaExGFXNumber
    jsl mario_exgfx_upload_player
    sep #$30
if !ChangeToLuigi
	stz $0DB3
endif
	rtl