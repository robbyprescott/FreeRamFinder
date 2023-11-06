print "See SpecialBlocks.jpg chart for what all these blocks do."

; Starts at tile 662
;Uses 49-57, bush tiles act as 25

; Format goes STA then STZ

!FreeRAM1 = $85
!FreeRAM2 = $0E07
!FreeRAM3 = $0DFE
!FreeRAM4 = $0EBF


db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

Cape:
Return:
     RTL
MarioCorner:
MarioBody:
MarioHead:
WallFeet:
WallBody:
MarioBelow:
MarioAbove:
MarioSide:
     LDA $1693
     CPY #$00 	
     CMP #$49 
     BNE Next
     LDA #$01
     STA !FreeRAM1
	 BRA Return
Next:
     LDA $1693
     CPY #$00 	
     CMP #$4A 
     BNE Next2
     STZ !FreeRAM1
	 BRA Return
Next2:
     LDA $1693
     CPY #$00	
     CMP #$4B
     BNE Next3	 
	 LDA #$01
     STA !FreeRAM2
	 BRA Return
Next3:
     LDA $1693
     CPY #$00 	
     CMP #$4C 
     BNE Next4
     STZ !FreeRAM2
	 BRA Return
Next4:
     LDA $1693
     CPY #$00	
     CMP #$4D
     BNE Next5	 
	 LDA #$01
     STA !FreeRAM3
     BRA Return
Next5:
     LDA $1693
     CPY #$00 	
     CMP #$4E 
     BNE Next6
     STZ !FreeRAM3
     BRA Return	 
Next6:
     LDA $1693
     CPY #$00	
     CMP #$4F
     BNE Next7	 
	 LDA #$01
     STA !FreeRAM4
     BRA Return 
Next7:
     LDA $1693
     CPY #$00 	
     CMP #$50 
     BNE Return2
     STZ !FreeRAM4 	 
SpriteV:
SpriteH:
Fireball:
Return2:
     RTL