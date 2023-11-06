;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pipe Generator, based on mikeyk's and Magus' code, further changed by Davros and SJC.
;;
;; Description: This sprite will turn into upper pipe tiles or a lower pipe tiles when all 
;; the defined trigger is toggled on.
;;
;; Uses extra bit: YES
;; When using pipe_generator_up_down.json, when the extra bit is clear, the sprite will turn into an upper pipe. 
;; When the first extra bit is set, it will turn into a lower pipe.
;; When using pipe_generator_right_left.json, with the extra bit clear, will presumably be right pipe.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            
!Trigger = $14AF ; on/off
							
!EXTRA_BITS = $7FAB10

PipeTiles:
	dw $0137,$0138,$0135,$0136	; Up facing pipe
	dw $0135,$0136,$0137,$0138	; Down facing pipe
	dw $013D,$013B,$013E,$013F	; Right facing pipe
	dw $013B,$013D,$013F,$013E	; Left facing pipe
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

					print "MAIN ",pc
                    LDA $1493               ; \ if the goal is set...
                    BNE RETURN              ; /
					
                    LDA !Trigger           
                    BEQ RETURN					

SOUND:              LDA #$15                ; \ play sound effect
                    STA $1DFC               ; /

					LDA !EXTRA_BITS,x        ; \ generate lower pipe if the extra bit is set...
                    AND #$04                ;
					ASL
					CLC : ADC !extra_prop_1,x
					TAY
					
					PHB : PHK : PLB
                    JSR GENERATE_PIPES      ; generate pipe routine
					PLB
print "INIT ",pc
RETURN:             RTL                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; generate Map16 pipes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OffsetTable:
.x	dw $0000,$0010,$0000,$0010
.y	dw $0000,$0000,$0010,$0010

GENERATE_PIPES:     LDA $AA,x               ; \ if the y speed is set...
                    BNE RETURN67            ; /
                    STZ $14C8,x             ; destroy the sprite
                    
					LDA #$04
					STA $02
-					TYA : STA $03 : AND #$07 : TAY
					LDA $E4,x
					CLC : ADC OffsetTable_x,y
					STA $9A
					LDA $14E0,x
					ADC #$00
					STA $9B
					LDA $D8,x
					CLC : ADC OffsetTable_y,y
					STA $98
					LDA $14D4,x
					ADC #$00
					STA $99
					
					LDY $03
					PHY
					REP #$30
						LDA PipeTiles,y
						%ChangeMap16()
					SEP #$30
					PLY
					INY
					INY
					DEC $02
					BNE -
RETURN67:           RTS                     ; return