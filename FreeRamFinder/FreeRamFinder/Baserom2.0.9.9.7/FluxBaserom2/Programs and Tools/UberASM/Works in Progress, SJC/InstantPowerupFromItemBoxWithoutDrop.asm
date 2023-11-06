; given instant powerup from item reserve instead of it dropping, upon pressing select
; Also, if set, items in item reserve will never auto-drop

; Actual powerup:

;$00 = small
;$01 = big
;$02 = cape
;$03 = fire

; Item box stuff:

;00 - Empty.
;01 - Mushroom.
;02 - Fire Flower.
;03 - Star.
;04 - Feather.

!InstantPowerupOnDamage = 1

main:
if !InstantPowerupOnDamage
     LDA #$01
     STA $0DF8 ; item won't fall when you take damage
endif
     LDA #$01
     STA $0DF9 ; disables select from activating vanilla item box drop
	 
     LDA $16  ; if
     AND #$20 ; press select
     BEQ Return
GivePowerup:
     LDA $0DC2
	 CMP #$01 ; see if item in reserve is mushroom
	 BNE Fire
	 LDA $19 ; see if small Mario
	 CMP #$01 ; (if below #$01)
	 BCS Return ; otherwise branch (don't give mushroom if fire, for example)
     LDA #$01 ; make big
     STA $19
     LDA #$0A
     STA $1DF9 ; sound mushroom powerup
     STZ $0DC2 ; remove item box item
	 BRA Return	 
Fire:
     LDA $0DC2
	 CMP #$02 ; see if item in reserve is flower
	 BNE Cape
     LDA #$03 ; give fire
     STA $19
     LDA #$0A
     STA $1DF9 ; sound mushroom powerup
	 LDA $19 ; see if small Mario
	 CMP #$01 ; (if below #$01)
	 BCS CapeItem
     STZ $0DC2 ; remove item box item
	 BRA Return
CapeItem:
     LDA $19 ; see if cape Mario
	 CMP #$02 ; (if below #$01)	 
	 BNE Return
	 LDA #$04 ; give feather
	 STA $0DC2
	 BRA Return
Cape:
     LDA $0DC2
	 CMP #$04 ; see if item in reserve is feather
	 BNE Return
     LDA #$02 ; give cape
     STA $19
     LDA #$0D
     STA $1DF9 ; sound powerup
     LDA $19 ; see if small Mario
	 CMP #$01 ; (if below #$01)
	 BCS FireItem
     STZ $0DC2 ; remove item box item
	 BRA Return
FireItem:
     LDA $19 ; see if fire Mario
	 CMP #$03 ;
	 BNE Return
	 LDA #$02 ; give feather in tem
	 STA $0DC2
Return:	 
     RTL

					
					
;LDA $71             ; Animation?
;CMP #$01
;BNE GivePowerup