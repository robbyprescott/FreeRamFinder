; Must enable other optional global UberASM code first.
; May cause very slight delay on level load, and slight delay when actually changing GFX.

; You can also use this with SwitchBetweenMarioAndLuigiWithLR.asm,
; if you want the player to actually change into Luigi (e.g. in status bar too), and not just GFX.
; Just change that other trigger to match this one. 

!Trigger = $14AF ; Set whatever FreeRAM trigger you want, to be used with block, etc.
!CustomExGFXNumber = $0C32 ; actual GFX file itself
!Palette = B ; See options at bottom.
!ChangeToLuigi = 0 ; You can set this to 1 if you use the other Luigi Uber mentioned above

!VanillaExGFXNumber = $0A32 ; you shouldn't need to change this
!RAM_PlayerPalPtr = $7FA034		; Only change these if you 
!RAM_PalUpdateFlag = $7FA00B    ; change them in imamelia's patch

init:
    ;if !ChangetoLuigi = 0
	LDA.b #!Palette			; set up pointer
	STA !RAM_PlayerPalPtr
	LDA.b #!Palette>>8
	STA !RAM_PlayerPalPtr+1
	LDA.b #!Palette>>16
	STA !RAM_PlayerPalPtr+2
	;endif
	RTL
	
; !ChangeToLuigi = 0	
	
main:
    ;if !ChangeToLuigi = 1
	;LDX $0DB3 ; actually change player to Luigi
	;TXA
	;BEQ ToLuigi
	;STZ $0DB3
	;BRA PaletteMain
;ToLuigi:
	;INC $0DB3
	;endif
;PaletteMain:
    ;if !ChangetoLuigi = 0
    LDA !Trigger
	BEQ PaletteFlip     ; Don't change to new palette unless RAM set
	LDA #$01			
	STA !RAM_PalUpdateFlag
	STA $15E8
	BRA Gfx
PaletteFlip:
	LDA #$00			; ; can't STZ long address, back to original if trigger flipped back
	STA !RAM_PalUpdateFlag
	STA $15E8
	;endif
Gfx:	
    lda !Trigger 
	beq BackToMario
    rep #$30
    lda.w #!CustomExGFXNumber
    jsl mario_exgfx_upload_player
    sep #$30
    RTL
BackToMario:
	rep #$30
    lda.w #!VanillaExGFXNumber
    jsl mario_exgfx_upload_player
    sep #$30
;if !ChangeToLuigi = 1
	;stz $0DB3
;endif
    RTL

; Palettes:

A:
     dw $635F,$581D,$2529,$7FFF,$0008,$0017,$001F,$577B,$0DDF,$03FF ; Fire Mario
B:   
     dw $5B3D,$18DC,$09D4,$0DE5,$12A7,$7FB4,$7FFF,$1769,$2F8E,$03FF ; Yoshi
C:
     dw $4F3F,$581D,$1140,$3FE0,$3C07,$7CAE,$7DB3,$2F00,$165F,$03FF ; Luigi, starts at color 6