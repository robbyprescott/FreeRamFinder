; by SJandCharlieTheCat     

; Somehow prevent jank if Yoshi already present?        

;!Yellow     = $04
;!Blue       = $06
;!Red        = $08 ; note that I couldn't make a corresponding block color for red Yoshi
;!Green      = $0A

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
     LDA $187A 
	 BNE Return ; Prevents multiple spawning jank by checking if already on Yoshi
	 LDA $1693
     CPY #$00 	
     CMP #$49 
	 BNE Next
     LDA #$0A    ; green
     STA $13C7   ; Yoshi color
	 BRA Shared
Next:
     LDA $187A 
	 BNE Return ; Prevents multiple spawning jank by checking if already on Yoshi
	 LDA $1693
     CPY #$00 	
     CMP #$4A 
	 BNE Next2
     LDA #$06    ; blue
     STA $13C7   ; Yoshi color
	 BRA Shared
Next2:
     LDA $187A 
	 BNE Return ; Prevents multiple spawning jank by checking if already on Yoshi
	 LDA $1693
     CPY #$00 	
     CMP #$4B 
	 BNE Return
     LDA #$04    ; yellow
     STA $13C7   ; Yoshi color
	 BRA Shared
Shared:
    PHY	
    JSL $00FC7A
    PLY
	LDA #$1F
	STA $1DFC
SpriteV:
SpriteH:
Fireball:
Cape:
Return:
RTL

print "Spawns you on Yoshi when touched."