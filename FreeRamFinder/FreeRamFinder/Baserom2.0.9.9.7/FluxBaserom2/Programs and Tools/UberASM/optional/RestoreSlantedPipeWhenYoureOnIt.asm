; Need to add support for sprites, too

; Add 1EF and maybe 15C (technically uses all 159-15C and 1EC-1EF, but won't need those)
; This could be siimplified just by checking range. Leaving it for template, though.

; The problem is that because ActAs are same for upside-down slope and slanted pipe,
; you'll have to check for the Map16 # instead, forcing you to use vanilla slanted pipe tile Map16 locations.

; jsl GetMap16_Main to get the map16 ActAs number
; jsl GetMap16_ActAs to get the map16 ActAs act as number

!ActAsNumber = $01C4
!ActAsNumber2 = $01C5
!ActAsNumber3 = $01C6
!ActAsNumber4 = $01C7

load:
    ; LDA #$01
	; STA $0E00
    RTL

main:
    JSL GetMap16_Main
    CMP.b #!ActAsNumber
	BNE NextCheck
	CPY.b #!ActAsNumber>>8
	BNE NextCheck	
	BRA RestorePipe
NextCheck:
	CMP.b #!ActAsNumber2
	BNE NextCheck2
	CPY.b #!ActAsNumber2>>8
	BNE NextCheck2
	BRA RestorePipe
NextCheck2:
	CMP.b #!ActAsNumber3
	BNE NextCheck3
	CPY.b #!ActAsNumber3>>8
	BNE NextCheck3
	BRA RestorePipe
NextCheck3:
	CMP.b #!ActAsNumber4
	BNE UpsideDownSlopeFix
	CPY.b #!ActAsNumber4>>8
	BNE UpsideDownSlopeFix
RestorePipe:
    LDA #$C8 ; restore
	STA $82
	LDA #$E5
	STA $83	
	BRA End
UpsideDownSlopeFix:
    LDA #$5E ; Allows upside down slopes in other tilesets (0 and 7)
	STA $82
	LDA #$E5
	STA $83
End:
	RTL

