; With a little editing, you could add a short freeze too
; (If you use nomal powerup. the animation will be weird)

!Palette = A ; See options at bottom
!Trigger = $0E1C ; set whatever FreeRAM trigger you want, to be used with block, etc.

; You probably won't need to edit anything after this
!SmallFireballFreeRAM = $0DF3 ; enables fireball when small, and disables forced big Mario pose 
!FreeRAMToSetAndRevert = $0E57 ; revert pose
!FreeRAM2 = $0E58 ; revert pose
!Timer = #$06 ; how long to show new fireball pose
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
	BEQ BackToNormalMario     ; Don't change to new palette unless RAM set
	LDA #$01
    STA !SmallFireballFreeRAM
	LDA #$01			
	STA !RAM_PalUpdateFlag
	STA $15E8 ; used as flag in GM0F, to keep palette through fades
FireballStuff:
	LDA $18 ; L/R pose 
	AND #$30
	BEQ Alt
	BRA Stuff
Alt:
    LDA $16
    AND #$40 ; check Y/X press
    BEQ +	
Stuff:
    LDA #$01
    STA !FreeRAMToSetAndRevert
+
    LDA !FreeRAMToSetAndRevert ; if set 
    BEQ Return ; check
    LDA #$30 ; set pose.
    STA $13E0
    LDA !FreeRAM2
	CMP !Timer
    BEQ BackToNormalMarioPalette
    INC !FreeRAM2
	BRA Return
BackToNormalMario:
    STZ !SmallFireballFreeRAM
    LDA #$00			; can't STZ long; back to original if trigger flipped back
	STA !RAM_PalUpdateFlag
	STA $15E8 ; used as flag in GM0F, to keep palette through fades
BackToNormalMarioPalette:  
    STZ !FreeRAM2
    STZ !FreeRAMToSetAndRevert
Return:
	RTL

; Palettes:

A:
    dw $635F,$581D,$2529,$7FFF,$0008,$0017,$001F,$577B,$0DDF,$03FF ; Fire Mario
B:
    dw $3B1F,$581D,$2529,$7FFF,$1140,$01E0,$02E0,$577B,$0DDF,$03FF ; Fire Luigi