print "See SpecialBlocks.jpg chart for what all these blocks do."

; 2EE, end 2FF

;Uses 49-4C, bush tiles act as 25


!FreeRAM1 = $0DF1 ; horizontal snap fix 
!FreeRAM2 = $13D3 ; note that FF instead of 01


db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody


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
	 LDA #$FF
     STA !FreeRAM2
	 BRA Return
Next3:
     LDA $1693
     CPY #$00 	
     CMP #$4C 
     BNE Return
     STZ !FreeRAM2  	 
SpriteV:
SpriteH:
Fireball:
Cape:
Return:
     RTL