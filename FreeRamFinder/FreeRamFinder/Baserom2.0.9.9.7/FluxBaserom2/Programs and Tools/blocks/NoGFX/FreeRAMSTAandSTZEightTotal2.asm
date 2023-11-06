print "See SpecialBlocks.jpg chart for what all these blocks do."

; Starts at tile 640, ends at 671
;Uses 49-57, bush tiles act as 25

; Format goes STA then STZ

!FreeRAM1 = $0EC0
!FreeRAM2 = $0E00
!FreeRAM3 = $0EAC ; pause buffer
!FreeRAM4 = $0DFC
!FreeRAM5 = $0DED
!FreeRAM6 = $0DF9 ; select won't activate item box
!FreeRAM7 = $0DF8 ; item reserve item won't automatically drop if you take damage
; 8th is  $5B, disable layer 2 interaction

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
     BNE Next8
     STZ !FreeRAM4
     BRA Return2	 
Next8:
     LDA $1693
     CPY #$00	
     CMP #$51
     BNE Next9	 
	 LDA #$01
     STA !FreeRAM5
     BRA Return2 
Next9:
     LDA $1693
     CPY #$00 	
     CMP #$52 
     BNE Next10
     STZ !FreeRAM5
     BRA Return2	 
Next10:
     LDA $1693
     CPY #$00	
     CMP #$53
     BNE Next11	 
	 LDA #$01
     STA !FreeRAM6
     BRA Return2 
Next11:
     LDA $1693
     CPY #$00 	
     CMP #$54 
     BNE Next12
     STZ !FreeRAM6
     BRA Return2	 
Next12:
     LDA $1693
     CPY #$00	
     CMP #$55
     BNE Next13	 
	 LDA #$01
     STA !FreeRAM7
     BRA Return2 
Next13:
     LDA $1693
     CPY #$00 	
     CMP #$56
     BNE Next14
     STZ !FreeRAM7
     BRA Return2	 
Next14:
     LDA $1693
     CPY #$00	
     CMP #$57
     BNE Next15 
	 LDA #$80
	 TRB $5B
     BRA Return2 
Next15:
     LDA $1693
     CPY #$00 	
     CMP #$58
     BNE Return2
	 LDA #$80
	 TSB $5B 	 
SpriteV:
SpriteH:
Fireball:
Return2:
     RTL