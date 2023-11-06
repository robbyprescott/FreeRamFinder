; By Thomas, mods by SJC

!RAM_PlayerPalPtr = $7FA034		; if you change these in imamelia's patch, change here too
!RAM_PalUpdateFlag = $7FA00B

init:
	LDA.b #Palette			; set up pointer
	STA !RAM_PlayerPalPtr
	LDA.b #Palette>>8
	STA !RAM_PlayerPalPtr+1
	LDA.b #Palette>>16
	STA !RAM_PlayerPalPtr+2
    RTL
main:
	LDA #$01			; can't STZ long address
	STA !RAM_PalUpdateFlag
	STA $15E8 ; used as flag in GM0F, to keep palette through fades
	RTL

Palette:
    dw $4F3F,$581D,$1140,$3FE0,$3C07,$7CAE,$7DB3,$2F00,$165F,$03FF ; Luigi
    ; dw $635F,$581D,$2529,$7FFF,$0008,$0017,$001F,$577B,$0DDF,$03FF ; Fire Mario