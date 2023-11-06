; By SJandCharlieTheCat, with Thomas
; Several patches were required to get this to work (FireballWhenSmallAndOtherChecks.asm and palette patch).

; By default this will spawn you as small fire Mario. 
; With modifications, you could change this to only be set on a trigger, too.
; Need to add L/R pose check, LDA $18 : AND #$30

!EnableLRFiring = 0

; You won't need to edit anything after this
!SmallFireballFreeRAM = $0DF3 ; enables fireball when small, and disables forced big Mario pose 
!FreeRAMToSetAndRevert = $0E57 ; revert pose
!FreeRAM2 = $0E58 ; revert pose
!Timer = #$06 ; how long to show new fireball pose

!RAM_PlayerPalPtr = $7FA034		; if you change these in imamelia's patch, change here too
!RAM_PalUpdateFlag = $7FA00B

init:
    LDA #$01
    STA !SmallFireballFreeRAM ; 
    LDA.b #Palette			; set up pointer
	STA !RAM_PlayerPalPtr
	LDA.b #Palette>>8
	STA !RAM_PlayerPalPtr+1
	LDA.b #Palette>>16
	STA !RAM_PlayerPalPtr+2
    RTL
	
main:
	LDA #$01			
	STA !RAM_PalUpdateFlag
	STA $15E8 ; used as flag in GM0F, to keep palette through fades
		
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
    BEQ Revert
    INC !FreeRAM2
	BRA Return
Revert:
    STZ !FreeRAM2
    STZ !FreeRAMToSetAndRevert
Return:
    RTL


Palette:
    dw $635F,$581D,$2529,$7FFF,$0008,$0017,$001F,$577B,$0DDF,$03FF ; Fire Mario