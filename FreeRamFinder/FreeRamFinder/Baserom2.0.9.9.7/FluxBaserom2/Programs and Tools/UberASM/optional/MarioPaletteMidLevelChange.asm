; By Thomas, mods by SJC
; Define your palette at the bottom and un-comment

!Palette = A ; See options at bottom
!Trigger = $14AF ; set whatever FreeRAM trigger you want, to be used with block, etc.
; !ChangetoLuigi = 0 ; If set, will actually change player to Luigi (e.g. in status bar too)

!RAM_PlayerPalPtr = $7FA034		; Only change these if you 
!RAM_PalUpdateFlag = $7FA00B    ; change them in imamelia's patch

init:
	LDA.b #!Palette			; set up pointer
	STA !RAM_PlayerPalPtr
	LDA.b #!Palette>>8
	STA !RAM_PlayerPalPtr+1
	LDA.b #!Palette>>16
	STA !RAM_PlayerPalPtr+2
	RTL
main:
    LDA !Trigger
	BEQ BackToNormalMarioPalette     ; Don't change to new palette unless RAM set
	LDA #$01			
	STA !RAM_PalUpdateFlag
	STA $15E8 ; used as flag in GM0F, to keep palette through fades
	RTL
	
	BackToNormalMarioPalette:
	LDA #$00			; back to original if trigger flipped back
	STA !RAM_PalUpdateFlag
	STA $15E8
	RTL

; Palettes:

A:
     dw $4F3F,$581D,$1140,$3FE0,$3C07,$7CAE,$7DB3,$2F00,$165F,$03FF ; Luigi, starts at color 6
B:
     dw $635F,$581D,$2529,$7FFF,$0008,$0017,$001F,$577B,$0DDF,$03FF ; Fire Mario
C:   
     dw $5B3D,$18DC,$09D4,$0DE5,$12A7,$7FB4,$7FFF,$1769,$2F8E,$03FF ; Yoshi
