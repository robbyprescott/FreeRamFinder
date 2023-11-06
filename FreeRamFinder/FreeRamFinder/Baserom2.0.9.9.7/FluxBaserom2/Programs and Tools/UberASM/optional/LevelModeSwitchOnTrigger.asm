; Some of this unnecessary I think

; Example starts in level mode 1E, no matter what the LM setting.
; Flips between modes on trigger
; Can't imagine what sort of jank this could create

!StartingMode = $1E
!InitialTS = $16
!InitialTM = $01
!InitialCGADSUB = $21

!ToggleToMode = $00 
!SecondTS = $02
!SecondTM = $15
!SecondCGADSUB = $20 ; or 24?


!FreeRAM = $14AF

nmi:
LDA !FreeRAM
BNE Toggle
LDA #!StartingMode
STA $1925 ; level mode
LDA #!InitialTM
STA $0D9D ; Main Screen and Window logic mask setting of current level mode (000abcde - a = Object layer; b = Layer 4; c = Layer 3; d = Layer 2; e = Layer 1). 
          ; Value appears as TM in Lunar Magic (Header properties). Mirror of SNES registers $212C and $212E; transfer only occurs on level load.
LDA #!InitialTS
STA $0D9E ; Appears as TS & TSW in Lunar Magic?
LDA #!InitialCGADSUB
STA $40 ; CGADSUB, shbo4321.
STZ $41 ; (mirror of W12SEL $2123) controls BG1 and BG2
STZ $42 ; (mirror of W34SEL $2124) controls BG3 and BG4
STZ $43 ; (mirror of WOBJSEL $2125) controls OBJ and COL
LDA #$02 
STA $44 ; Initial settings for color addition
RTL

Toggle:

LDA #!ToggleToMode
STA $1925 ; takes back to mode 00
LDA #!SecondTM
STA $0D9D ; TM
LDA #!SecondTS 
STA $0D9E ; TS
LDA #!SecondCGADSUB
STA $40
STZ $41
STZ $42
STZ $43
LDA #$02
STA $44
RTL