; I think it may be the $0296B4 edit that causes a crash when you spin-jump with capespin

; Capespin Hitbox Consistency + Net Punching Hitbox Correction - patch by Katun24
;
; Capespinning in vanilla SMW has the following properties:
;	- The capespin hitbox is active either only on the left side of Mario or on the right side - the side changes every 4 frames (unpredictable for RTA as it depends on a global timer).
;	- It checks for interaction with sprites only every other frame.
;	- It checks for interaction with tiles in two different pixel positions (within the hitbox that could be left or right of Mario) based on whether the frame is even or odd.
; This patch changes this behavior in the following ways for the sake of RTA consistency:
;	- The capespin hitbox is always active on both sides of Mario.
;	- It checks for interaction with sprites only every single frame.
;	- It checks for interaction with tiles either on the left side of Mario or on the right side, based on whether the frame is even or odd.
;
; The net punching hitbox (which shares part of its hitbox checking routine with the capespin) is also changed to interact with sprites every frame and is offset to the left and right of Mario equally.
; In vanilla SMW, punching checks for sprite interaction only every other frame and is offset to the left or right of Mario depending on whether you're in front of the net or behind it.


org $0294FF						; have capespin interact with sprites every frame
NOP #2

org $00D034						; set capespin hitbox x to Mario's x minus 12 pixels (always left side)
dw $FFF4						; vanilla value = &000C
org $00D038						; set net punching hitbox x to Mario's x minus 8 pixels (always left side)
dw $FFF8						; vanilla value = &0008

org $02953E						; set capespin layer1/2 interaction points so that it checks for interaction left or right depending on a framerule (x offset from $00D034)
db $02,$25						; vanilla:	db $02,$0E

org $0296A5
autoclean JML HitboxWidth

org $0296B4						; set capespin hitbox height to xx pixels (vanilla = 16 pixels) to account for spin-killing sprites more readily when spin-gliding into them at an angle (side-effect of the patch)
db $0D

freecode


HitboxWidth:
	LDA $74						; if climbing (net punching hitbox), set the hitbox width to 36 pixels (= hitbox of left punch + right punch + in between)
	BEQ +
	LDA #$24
	BRA .return
	+
	LDA #$2C					; otherwise (capespin hitbox), set the hitbox width to 44 pixels (= hitbox of left spin + right spin + in between)

.return
	STA $02
	JML $0296A9