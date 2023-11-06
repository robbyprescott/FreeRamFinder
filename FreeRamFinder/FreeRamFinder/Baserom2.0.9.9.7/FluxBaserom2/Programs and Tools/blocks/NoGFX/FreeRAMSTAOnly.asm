print "See SpecialBlocks.jpg chart for what all these blocks do."

; Tiles 388-38E (38F not used, even though still appears here)
;Uses 49-50, bush tiles act as 25

!FreeRAM1 = $0EC4
!FreeRAM2 = $0EEB
!FreeRAM3 = $0E09
!FreeRAM4 = $0DF2
!FreeRAM5 = $0E0B
!FreeRAM6 = $22 ; plus next 3), STZ only
!FreeRAM7 = $18B9 ; generator, STZ, #$01-#$0F = generators CB-D9. See also INC $18BF (lakitu, magikoopa etc.)
; !FreeRAM8 = $0ECE

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
	 BRA Return2
Next:
     LDA $1693
     CPY #$00 	
     CMP #$4A 
     BNE Next2
     LDA #$01
     STA !FreeRAM2
	 BRA Return2
Next2:
     LDA $1693
     CPY #$00	
     CMP #$4B
     BNE Next3	 
	 LDA #$01
     STA !FreeRAM3
	 BRA Return2
Next3:
     LDA $1693
     CPY #$00 	
     CMP #$4C 
     BNE Next4
     LDA #$01
     STA !FreeRAM4
	 BRA Return2
Next4:
     LDA $1693
     CPY #$00	
     CMP #$4D
     BNE Next5	 
	 LDA #$01
     STA !FreeRAM5
     BRA Return2
Next5:
     LDA $1693
     CPY #$00 	
     CMP #$4E 
     BNE Next6
     STZ !FreeRAM6
	 STZ !FreeRAM6+1
	 STZ !FreeRAM6+2
	 STZ !FreeRAM6+3
     BRA Return2	 
Next6:
     LDA $1693
     CPY #$00	
     CMP #$4F
     BNE Return2	 
     STZ !FreeRAM7 
SpriteV:
SpriteH:
Fireball:
Return2:
     RTL