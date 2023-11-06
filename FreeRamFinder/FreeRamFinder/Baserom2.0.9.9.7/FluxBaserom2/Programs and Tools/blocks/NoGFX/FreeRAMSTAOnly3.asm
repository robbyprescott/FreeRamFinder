print "See SpecialBlocks.jpg chart for what all these blocks do."

; Starts at tile 600
;Uses 49-50, bush tiles act as 25

!FreeRAM1 = $0DFD
!FreeRAM2 = $0E01
!FreeRAM3 = $0E08
!FreeRAM4 = $0DFB
!FreeRAM5 = $60 ; currently unused from here on
!FreeRAM6 = $61
!FreeRAM7 = $62
!FreeRAM8 = $63

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
	 STA $0DFC
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
     LDA #$01
     STA !FreeRAM6
     BRA Return2	 
Next6:
     LDA $1693
     CPY #$00	
     CMP #$4F
     BNE Next7	 
	 LDA #$01
     STA !FreeRAM7
     BRA Return2 
Next7:
     LDA $1693
     CPY #$00 	
     CMP #$50 
     BNE Return2
     LDA #$01
     STA !FreeRAM8 	 
SpriteV:
SpriteH:
Fireball:
Return2:
     RTL