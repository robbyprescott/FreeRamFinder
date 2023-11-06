;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Eaten block routines.
;; These decide what the game should do after Yoshi swallows the sprite.
;;
;; To make your own, add rows to the "RoutinePointers" table,
;;  then add your code to this file.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RoutinePointers:
    dw GiveCoin         ; 00 - Just give a coin.
    dw RedBerry         ; 01 - Increment red berry count.
    dw PinkBerry        ; 02 - Increment pink berry count.
    dw GreenBerry       ; 03 - Add 20 seconds to in-game clock.
	dw GiveMushroom     ;
	dw GiveFlower       ; 05
	dw GiveCape         ; 06
    dw GiveStar         ; 07
	dw GiveOneUp        ; 08
	
    ; ...



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Write your routines below.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GiveCoin:               ; 00 - Just give a coin.
    LDA #$06
    STA $1DF9+!Base
    JSL $05B34A|!long
    RTS


RedBerry:               ; 01 - Increase red berry count, give a coin.
    LDA #$06
    STA $1DF9+!Base
    JSL $05B34A|!long
    INC $18D4+!Base
    LDA $18D4+!Base
    CMP #$0A
    BNE .return
    STZ $18D4+!Base
    LDA #$74
    STA $18DA+!Base
    LDY #$20    
    STY $18DE+!Base
  .return
    RTS


PinkBerry:              ; 02 - Increase pink berry count, give a coin.
    LDA #$06
    STA $1DF9+!Base
    JSL $05B34A|!long
    INC $18D5+!Base
    LDA $18D5+!Base
    CMP #$02
    BNE .return
    STZ $18D5+!Base
    LDA #$6A
    STA $18DA+!Base
    LDY #$20
    STY $18DE+!Base
  .return
    RTS


GreenBerry:             ; 03 - Add 20 seconds to in-game timer, give a coin.
    LDA #$06
    STA $1DF9+!Base
    JSL $05B34A|!long
    LDA #$29
    STA $1DFC+!Base
    LDA $0F32+!Base
    CLC
    ADC #$02
    CMP #$0A
    BCC .notHundred
    SBC #$0A
    INC $0F31+!Base
  .notHundred
    STA $0F32+!Base
    RTS

GiveMushroom:	
	LDA $0E2A
	BNE .NoMushroom
	LDA #$01
	STA $19
	LDA #$0A ; 
    STA $1DF9
	BRA .MushroomEnd
.NoMushroom
    LDA #$06
    STA $1DF9
.MushroomEnd	
	RTS
	
GiveFlower:	
	LDA $0E2A
	BNE .NoFlower
	LDA #$03
	STA $19
	LDA #$0A ; 
    STA $1DF9
	BRA .FlowerEnd
.NoFlower
    LDA #$06
    STA $1DF9
.FlowerEnd	
	RTS	
	
GiveCape:	
	LDA $0E2A
	BNE .NoCape
	LDA #$02
	STA $19
	LDA #$0D ; 
    STA $1DF9
	BRA .CapeEnd
.NoCape
    LDA #$06
    STA $1DF9
.CapeEnd	
	RTS	
	
GiveStar:
	LDA $0E2A
	BNE .NoStar
	LDA #$FF
	STA $1490
	BRA .StarEnd
.NoStar
    LDA #$06
    STA $1DF9
.StarEnd	
	RTS	
	
GiveOneUp:	
	LDA $0E2A
	BNE .NoOneUp
	INC $18E4
	BRA .OneUpEnd
.NoOneUp
    LDA #$06
    STA $1DF9
.OneUpEnd	
	RTS	   