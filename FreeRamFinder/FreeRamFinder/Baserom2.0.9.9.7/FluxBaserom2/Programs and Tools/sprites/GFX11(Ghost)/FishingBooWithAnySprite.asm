; Tiles CC and CE in SP4 are normal sprite GFX, flame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Any Sprite Fishin' Boo by dtothefourth
;;
;; Based on the disassembly by Davros
;;
;; Instead of having a fire, can have any sprite
;; at the end of its line and have the sprite respawn.
;;
;; You can also remap the fishin' boo to only use SP3
;; 
;;
;; If desired the original mapping can be uncommented
;; below to use the normal graphics.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


!Sprite = #$0E	; Sprite to spawn with initially. Keyhole for example. Will spawn in its normal tile slot.
!State  = #$01  ; Generally 1,8,9 (9 for carryable stuff like keys, 1 for stuff that needs to run its init routine)
!Custom = 0		; 1 to spawn a custom sprite
!Extra  = 0		; 1 to set extra bit on sprite

X_OFFSET:	    db $1A,$12,$F0,$F8 ;X position of carried sprite in each turn position
;X_OFFSET:	    db $14,$0C,$EA,$F2 ;X position of carried sprite in each turn position
!Y_Offset = #$3E; Y distance below boo to swing sprite

!Respawn       = 1     ; If 1, respawn the sprite if it dies or is taken
!RespawnTime   = #$40  ; Number of frames to wait before respawning
!RespawnSFX	   = #$10  ; Sound to play when spawning
!RespawnBank   = $1DF9 ; Sound to play when spawning
!RespawnSprite = #$21  ; Sprite to respawn 
!RespawnState  = #$01  ; Generally 1,8,9 (9 for carryable stuff like keys, 1 for stuff that needs to run its init routine)
!RespawnCustom = 0	   ; 1 to spawn a custom sprite
!RespawnExtra  = 0	   ; 1 to set extra bit on sprite

X_OFFSET_RE:	 db $14,$0C,$EA,$F2 ;X position of carried sprite in each turn position after respawn
!Y_Offset_Re = #$3E ; Y distance below boo to swing sprite after respawn


X_ACCEL:
db $01,$FF	;acceleration per frame (right, left)

X_SPEED:
db $20,$E0	;max X speeds (right, left)

Y_ACCEL:
db $01,$FF	;acceleration per frame (down, up)

Y_SPEED:
db $10,$F0	;max Y speeds (down, up)



TILEMAP:	    db $60,$60,$64,$8A,$60,$60,$AC,$AC,$AC ; 

;Alt tilemap, use this one if you want to use the new SP3 mapping
;TILEMAP:	    db $60,$60,$43,$00,$60,$60,$02,$02,$02


PROPERTIES:     db $04,$04,$0D,$09,$04,$04,$0D,$0D,$0D,$07

HORZ_DISP:	    db $FB,$05,$00,$F2,$FD,$03,$EA,$EA,$EA,$EA
		    db $FB,$05,$00,$FA,$FD,$03,$F2,$F2,$F2,$F2
		    db $FB,$05,$00,$0E,$03,$FD,$16,$16,$16,$16			
		    db $FB,$05,$00,$06,$03,$FD,$0E,$0E,$0E,$0E

VERT_DISP:          db $0B,$0B,$00,$03,$0F,$0F,$13,$23,$33,$43			
		

CLOUD_PROPERTIES:   db $00,$40,$C0,$80			

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "MAIN ",pc
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR START_SPRITE_CODE   ;  |
                    PLB    
					RTL                 ;  |

                    print "INIT ",pc

					JSL $02A9DE|!BankB
					BMI EndSpawn

					TYA
					STA !160E,x


					LDA !Sprite
					if !Custom
					PHX
					TYX
					STA !7FAB9E,x
					PLX
					else
					STA !9E,y
					endif
	
					LDA !E4,x
					STA !E4,y
					LDA !14E0,x
					STA !14E0,y
					LDA !D8,x
					STA !D8,y	
					LDA !14D4,x
					STA !14D4,y	
					PHX
					TYX
					JSL $07F7D2|!BankB

					if !Custom

						LDA #$08|(!Extra*4)
						STA !7FAB10,x
						JSL $0187A7|!BankB

					endif

					PLX

					LDA !State
					STA !14C8,y

					LDA #$01
					STA !15DC,y
					LDA #$00
					STA !1504,x
					RTL
				EndSpawn:
					STZ !14C8,x
                    RTL                     ; /
                   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

START_SPRITE_CODE:  JSR SUB_GFX             ; sprite graphics routine

                    LDA $9D                 ; \ if sprites locked, return
                    BNE RETURN              ; /

		    JSL $01A7DC|!BankB      ; check for Mario/sprite contact

		    %SubHorzPos()	    ; horizontal Mario/sprite check routine
		    STZ !1602,x             ; restore image
		    LDA !15AC,x             ; \ if the turn timer is set...
		    BEQ NO_DIRECTION        ; /
		    INC !1602,x             ; increase image
		    CMP #$10                ; \ if the image is set...
		    BNE NO_DIRECTION        ; /
		    TYA                     ; transfer to...
		    STA !157C,x             ; direction

NO_DIRECTION:	    TXA
		    ASL #4
		    ADC $13                 ; \ if the frame is set...
		    AND #$3F                ; /
		    ORA !15AC,x             ; \ or the turn timer is set...
		    BNE NO_TIMER            ; /
		    LDA #$20                ; \ set time to turn
		    STA !15AC,x             ; /

NO_TIMER:	    LDA $18BF|!Base2
		    BEQ SET_X_SPEED
		    TYA
		    EOR #$01
		    TAY

SET_X_SPEED:	    LDA !B6,x               ; \ compare x speed     
		    CMP X_SPEED,y           ;  |
		    BEQ CALC_FRAME          ;  |
		    CLC                     ;  |
		    ADC X_ACCEL,y           ;  | set up acceleration
		    STA !B6,x               ; /

CALC_FRAME:	    LDA $13                 ; \ if the frame is set...
		    AND #$01                ;  |
		    BNE HORZ_SPEED          ; /

		    LDA !C2,x               ; \ set state
		    AND #$01                ;  |
		    TAY                     ; /
		    LDA !AA,x               ; \
		    CLC                     ;  |
		    ADC Y_ACCEL,y           ;  | set up acceleration
		    STA !AA,x               ;  |
		    CMP Y_SPEED,y           ;  | compare x speed
		    BNE HORZ_SPEED          ; /
		    INC !C2,x               ; increase sprite state

HORZ_SPEED:	    LDA !B6,x
		    PHA
		    LDY $18BF|!Base2
		    BNE UPDATE_POSITION
		    LDA $17BD|!Base2
		    ASL #3
		    CLC
		    ADC !B6,x
		    STA !B6,x
UPDATE_POSITION:    JSL $018022|!BankB      ; update x speed without y gravity
		    PLA
		    STA !B6,x

UPDATE_SPEED:       JSL $01801A|!BankB      ; update speed based on position

		    JSR FLAME_INTERACT      ; flame interaction routine
RETURN:		    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; flame interaction routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


FLAME_INTERACT:    

			LDA !160E,x
			BPL +

			if !Respawn
					LDA !1540,x
					BNE ++
					JSL $02A9DE|!BankB
					BMI EndSpawn2

					TYA
					STA !160E,x

					LDA #$01
					STA !1504,x

					LDA !RespawnSprite
					if !RespawnCustom
					PHX
					TYX
					STA !7FAB9E,x
					PLX
					else
					STA !9E,y
					endif
	
					LDA !E4,x
					STA !E4,y
					LDA !14E0,x
					STA !14E0,y
					LDA !D8,x
					STA !D8,y	
					LDA !14D4,x
					STA !14D4,y	
					PHX
					TYX
					JSL $07F7D2|!BankB
					if !RespawnCustom
						JSL $0187A7|!BankB
						LDA #$08|(!RespawnExtra*4)
						STA !7FAB10,x
					endif
					PLX

					LDA !RespawnState
					STA !14C8,y

					LDA #$01
					STA !15DC,y
					STA !1626,x

					LDA !RespawnSFX
					STA !RespawnBank



					BRA Done
				EndSpawn2:
					LDA #$08
					STA !1540,x
					Done:
			endif
			++
			RTS
			+


			PHX
			LDA !160E,x
			TAX
			LDA !14C8,x
			BEQ Dead
			CMP #$0B
			BEQ Dead
			BRA +
		Dead:
			LDA #$00
			STA !15DC,x
			PLX
			LDA #$FF
			STA !160E,x
			if !Respawn
			LDA !RespawnTime
			STA !1540,x
			endif
			RTS
			+
			LDA #$00
			STA !AA,x
			STA !B6,x
			PLX
			
			LDA !157C,x             ; \ set direction...
		    ASL A                   ;  |
		    ADC !1602,x             ;  | set frames...
		    TAY                     ; / transfer to...

			LDA !1504,x
			BNE +

		    LDA !E4,x               ; \ store x position (Low Byte)
		    CLC                     ;  |
		    ADC X_OFFSET,y          ;  |
			BRA ++
			+
		    LDA !E4,x               ; \ store x position (Low Byte)
		    CLC                     ;  |
		    ADC X_OFFSET_RE,y          ;  |
			++


			PHX
			PHA
			LDA !160E,x
			TAX
			PLA
			STA !E4,x
			PLX
			
			LDA !1504,x
			BNE +
			
			LDA  X_OFFSET,y
			BRA ++
			+
			LDA  X_OFFSET_RE,y
			++


			BMI +

		    LDA !14E0,x             ; \ store x position (High Byte)
		    ADC #$00		    ;  | add carry
			BRA ++
			+

			LDA !14E0,x
			BCS ++
			SEC
			SBC #$01



			++
			PHX
			PHA
			LDA !160E,x
			TAX
			PLA
			STA !14E0,x
			PLX

			LDA !1504,x
			BNE +

		    LDA !D8,x               ; \ store y position (Low Byte)
		    CLC                     ;  |
		    ADC !Y_Offset                ;  |
		    BRA ++
			+
		    LDA !D8,x               ; \ store y position (Low Byte)
		    CLC                     ;  |
		    ADC !Y_Offset_Re                ;  |
			++

			PHX
			PHA
			LDA !160E,x
			TAX
			PLA
			STA !D8,x
			PLX

		    LDA !14D4,x             ; \ store y position (High Byte)
		    ADC #$00                ;  |

			PHX
			PHA
			LDA !1626,x
			STA $00
			LDA !160E,x
			TAX
			PLA
			STA !14D4,x

			LDA $00
			BEQ +
			STZ $00 : STZ $01
			LDA #$1B : STA $02
			LDA #$01
			PHY
			%SpawnSmoke()
			PLY
			+

			PLX
            LDA #$00
			STA !1626,x
RETURN2:	    RTS                     ; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:	    %GetDrawInfo()	    ; after: Y = index to sprite tile map ($300)
                                            ; $00 = sprite x position relative to screen boarder 
                                            ; $01 = sprite y position relative to screen boarder 
		    LDA !1602,x             ; \ $04 = index to frame start (0 or 1)
		    STA $04                 ; /
                    LDA !157C,x             ; \ $02 = sprite direction
                    STA $02                 ; /
		    PHX                     ; push sprite index

		    PHY                     ; push sprite index
		    LDX #$08               ; loop counter = (number of tiles per frame) - 1

LOOP_START:	    LDA $01                 ; \ tile y position = sprite y location ($01) + tile displacement
		    CLC                     ;  |
		    ADC VERT_DISP,x         ;  |
		    STA $0301|!Base2,y      ; /

		    STZ $03                 ; restore tilemap direction

		    LDA TILEMAP,x           ; set tilemap
		    STA $0302|!Base2,y      ; / store tilemap

		    LDA $02                 ; \ if the direction is set...
		    CMP #$01                ; /
		    LDA PROPERTIES,x        ; \ get tile properties
		    EOR $03                 ;  |
		    ORA $64                 ;  | add in tile priority of level
		    BCS STORE_PROPERTIES    ;  |
		    EOR #$40                ;  | flip tile
STORE_PROPERTIES:   STA $0303|!Base2,y      ; / store tile properties

		    PHX                     ; push x
		    LDA $04                 ; \ if the image is set...
		    BEQ DIRECTION_IS_SET    ; /
		    TXA
		    CLC
		    ADC #$0A
		    TAX

DIRECTION_IS_SET:   LDA $02                 ; \ if the direction is set...
		    BNE SET_HORZ_DISP       ; /
		    TXA
		    CLC
		    ADC #$14
		    TAX

SET_HORZ_DISP:	    LDA $00                 ; \ tile x position = sprite x location ($00) + tile displacement
		    CLC                     ;  |
		    ADC HORZ_DISP,x         ;  |
		    STA $0300|!Base2,y      ; /

		    PLX                     ; \ pull, X = current tile of the frame we're drawing
                    INY                     ;  | increase index to sprite tile map ($300)...
                    INY                     ;  |    ...we wrote 1 16x16 tile...
                    INY                     ;  |    ...sprite OAM is 8x8...
                    INY                     ;  |    ...so increment 4 times
                    DEX                     ;  | go to next tile of frame and loop
                    BPL LOOP_START          ; / 

		    LDA $14                 ; \ make cloud tilemap animated
		    LSR #3                  ;  |
		    AND #$03                ;  |
		    TAX                     ; /
		    PLY                     ; pull y

		    LDA CLOUD_PROPERTIES,x  ; \ set cloud properties
		    EOR $030F|!Base2,y      ;  |
		    STA $030F|!Base2,y      ;  |
		    STA $0323|!Base2,y      ;  |
		    EOR #$C0                ;  |
		    STA $0313|!Base2,y      ;  |
		    STA $031F|!Base2,y      ; /

		    PLX                     ; pull, X = sprite index
		    LDY #$02                ; \ 460 = 2 (all 16x16 tiles)
		    LDA #$08                ;  | A = (number of tiles drawn - 1)
		    JSL $01B7B3|!BankB      ; / don't draw if offscreen
		    RTS