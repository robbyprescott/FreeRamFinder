; Tiny bit of code harvested from AuraDee and Noobish Noobsicle

!CustomExGFXNumber = $0232
!PaletteTransformation = 0

init:
    rep #$30
    lda.w #!CustomExGFXNumber
    jsl mario_exgfx_upload_player
    sep #$30
	rtl