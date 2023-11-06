;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sprite Invincibility Fix by Davros.
;;
;; Fixes a glitch in which the Dry Bones, Bony Beetles and Mega Moles can't be defeated
;; while the player is invincible.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
	!bank = $000000
else
	lorom
	!addr = $0000
	!bank = $800000
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Dry Bones and Bony Beetle code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $01E604|!bank

          autoclean JSL SprInvFix           ; go to new routine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mega Mole code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $038826|!bank

          autoclean JSL SprInvFix           ; go to new routine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Dry Bones, Bony Beetle and Mega Mole invincibility fix code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


                    freecode
                    reset bytes

                    print "Code is located at: $", pc

SprInvFix:          LDA $1490|!addr         ; \ if Mario star timer > 0, go to Has_Star
                    BNE Has_Star            ; /
                    JSL $00F5B7|!bank       ; hurt Mario
                    RTL                     ; return

Has_Star:           PHB		            ; preserve bank
		    LDA #$03		    ; bank 03
		    PHA		            ; preserve
		    PLB		            ; new data bank 
		    PEA $839D		    ; push return address containing PLB + RTL
		    JML $0395F2|!bank       ; kill sprite routine


print "Freespace used: ",bytes," bytes."
