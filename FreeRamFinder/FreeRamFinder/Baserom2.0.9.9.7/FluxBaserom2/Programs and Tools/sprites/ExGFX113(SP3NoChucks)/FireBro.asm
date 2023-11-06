; Use with ExGFX103 in SP3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fire Bros.
;; By Sonikku
;;
;; Description: Walks back and forth, frequently throwing two fireballs.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!FireballNumber = $0A               ; Extended sprite number from list.txt of fireball.asm.

!FireballSFX = $06                  ; Sound effect to play when shooting fire.
!FireballBank = $1DFC

TILEMAP:            db $04,$66,$7F
                    db $04,$76,$3F
                    db $2B,$66,$7F
                    db $2B,$76,$3F

PROPERTIES:	db $40,$00			;actually only contains horizontal flip data, properties are set through CFG/json

TILE_SIZE:	db $02,$00,$00

HORZ_DISP:	db $00,$00,$08
		db $00,$08,$00

VERT_DISP:	db $F8,$08,$08

print "INIT ",pc
    JSR FaceMario
    RTL

print "MAIN ",pc
    PHB : PHK : PLB
    JSR SpriteCode
    PLB
    RTL

Return:
    RTS

; Workaround for sublabels; wastes 4 bytes, but ensures the sprite assembles.
%SubOffScreen()

SpriteCode:
    JSR Graphics

    LDA !14C8,x                     ; If sprite dead of sprites locked, return.
    CMP #$08
    BNE Return
    LDA $9D
    BNE Return

    %SubOffScreen()

    JSL $01A7DC|!BankB              ; Sprite interacts with Mario
    JSR FaceMario                   ; Sprite always faces Mario
    JSL $01802A|!BankB              ; Sprite has gravity

    INC !1570,x

    LDA !1570,x
    CMP #$A0
    BNE .noReset                    ; if timer isn't maximum, branch.

    STZ !1570,x

    LDY #$50                        ; Random option 1
    JSL $01ACF9|!BankB
    AND #$01
    BEQ +
        LDY #$30                    ; Random option 2
+   TYA
    STA !1540,x                     ; Set timer

    STZ !B6,x
.noReset
    LDY #$00                        ; Y = $00

    LDA !151C,x
    AND #$08
    BEQ +                           ; 8 ticks on, 8 ticks off; branch
        INY                         ; Y = $01
+   LDA !1540,x
    BEQ ++                          ; if timer = #$00, branch
    CMP #$20
    BNE +                           ; if timer != #$20, branch
    JSL $01ACF9|!BankB
    AND #$01
    BEQ +                           ; 50% chance to branch.
    LDA !1588,x
    AND #$04
    BEQ +
    LDA #$C8
    STA !AA,x
+   LDY #$02                        ; Y = $02
++  TYA
    STA !1602,x                     ; set frame based on Y
    LDA !1540,x
    CMP #$40
    BCS +                           ; if timer is above #$40, branch
    AND #$1F
    CMP #$0F
    BNE +                           ; if not time to spawn, branch
    JSR GenerateFireball
+   LDA !1540,x
    BNE +
    LDA !1528,x
    BEQ .onGround                   ; if flag is already #$00, branch
+   LDA !1588,x
    AND #$04
    BEQ +                           ; if sprite is in the air, return
    STZ !1528,x                     ; clear flag
    LDA !AA,x
    BMI +
        STZ !AA,x                   ; no speed if positive
+   RTS

.onGround
    LDA !160E,x
    BEQ +
        DEC !160E,x
+   INC !1534,x
    LDA !1534,x
    AND #$1F
    BNE +                           ; only run once every #$20 frames
    JSL $01ACF9|!BankB
    AND #$01
    BNE +                           ; 50% chance to branch
    LDA !1588,x
    AND #$04
    BEQ +                           ; branch if in the air
    INC !1528,x                     ; increment flag
    LDA #$D8
    STA !AA,x                       ; jump
    STZ !B6,x                       ; no x-speed
    RTS

+   LDA !C2,x
    AND #$03                        ; one of 4 possibilities
    ASL A
    TAX
    JMP.w (.pointers,x)

.pointers
    dw .walkLeft
    dw .stopWalk
    dw .walkRight
    dw .stopWalk

.stopWalk
    LDX $15E9|!Base2
    LDA !160E,x
    BNE +
    INC !C2,x                       ; increment state (to walking left or right)
    LDA #$20
    STA !160E,x                     ; set walk timer
+   BRA .finish

.walkLeft
    LDX $15E9|!Base2
    LDY #$F8
    BRA +

.walkRight
    LDX $15E9|!Base2
    LDY #$08
+   LDA !160E,x
    BNE +
    INC !C2,x                       ; increment state (to waiting)
    LDA #$10
    STA !160E,x                     ; set wait timer
+   TYA
    STA !B6,x

    LDA !160E,x
    AND #$3F
    BNE .finish                     ; every so often we let the sprite hop

    LDA !160E,x
    AND #$40
    ASL #2
    LDY #$E0                        ; possibility 1
    BCC +
        LDY #$D8                    ; possibility 2
+   TYA
    STA !AA,x                       ; set y speed
.finish
    LDA !1588,x
    AND #$04
    BEQ +
    INC !151C,x
    LDA !AA,x
    BMI +
    STZ !AA,x
+   RTS

Graphics:
    %GetDrawInfo()

    		LDA !1602,x
                ASL
		CLC			;multiply by 3
		ADC !1602,x
		STA $03                 ; /

                LDA !157C,x             ; \ $02 = sprite direction
                STA $02                 ; /

		LDA !15F6,x
		STA $05

                LDX #$02                ;3 tiles

After_Pre_LOOP_START:
		STX $04			;amount of tiles to store

LOOP_START:
		STX $06

		LDA $02
		BNE NO_ADJ
		TXA
		CLC : ADC #$03		;whoops, i kinda forgot how this works, this should be about right
	        TAX

NO_ADJ:
                LDA $00                 ; \ tile x position = sprite x location ($00)
                CLC
                ADC HORZ_DISP,x
                STA $0300|!Base2,y      ; /
                 
		LDX $06			;restore OAM slot
                                        
		LDA $01                 ; \ tile y position = sprite y location ($01) + tile displacement
		CLC                     ;  |
		ADC VERT_DISP,x         ;  |
		STA $0301|!Base2,y      ; /
                    
		LDA TILE_SIZE,x
		PHA
		TYA                     ; \ get index to sprite property map ($460)...
		LSR A                   ; |    ...we use the sprite OAM index...
		LSR A                   ; |    ...and divide by 4 because a 16x16 tile is 4 8x8 tiles
		TAX                     ; | 
		PLA
		STA $0460|!Base2,x      ; /  

		LDX $06
		TXA                     ; \ X = index to horizontal displacement
		;ORA $03                 ; / get index of tile (index to first tile of frame + current tile number)
		;TAX          
CLC : ADC $03
TAX
		LDA TILEMAP,x           ; \ store tile
		STA $0302|!Base2,y      ; / 

		LDA $05            	; get palette info
.ItsHammer
		LDX $02                 ; \
		ORA PROPERTIES,x        ;  | get tile PROPERTIES using sprite direction
		ORA $64                 ;  | ?? what is in 64, level PROPERTIES... disable layer priority??
		STA $0303|!Base2,y      ; / store tile PROPERTIES

		LDX $06			;and restore OAM slot also

		INY                     ;  | increase index to sprite tile map ($300)...
		INY                     ;  |    ...we wrote 1 16x16 tile...
		INY                     ;  |    ...sprite OAM is 8x8...
		INY                     ;  |    ...so increment 4 times
		;DEC $06                 ;  | go to next tile of frame and loop
		DEX
		BPL LOOP_START          ; / 

		LDX $15E9|!Base2	;
                    
		LDY #$FF                ; \
		LDA $04			;  | A = number of tiles drawn - 1
		JSL $01B7B3|!BankB	; / don't draw if offscreen
		RTS                     ; RETURN


GenerateFireball:
    LDA !15A0,x
    ORA !186C,x
    BNE ++
    LDY #$07
-   LDA !extended_num,y
    BEQ +
    DEY
    BPL -
++  RTS

+   LDA.b #!FireballSFX
    STA.w !FireballBank|!Base2
    LDA.b #!FireballNumber+!ExtendedOffset
    STA !extended_num,y
    LDA #$20                        ; extended sprite Y speed
    STA $173D|!Base2,y
    LDA !E4,x                       ; extended sprite X position = 4 pixels to the left
    CLC : ADC #$04
    STA !extended_x_low,y
    LDA !14E0,x                     ; extended sprite Y position (high)
    ADC #$00
    STA !extended_x_high,y
    LDA !D8,x
    CLC : ADC #$F8                  ; extended sprite Y position = 8 pixels above sprite
    STA !extended_y_low,y
    LDA !14D4,x
    ADC #$FF                        ; extended sprite Y position (high)
    STA !extended_y_high,y

    LDA !157C,x                     ; set up extended sprite direction
    TAX
    LDA .xspd,x                     ; set up extended sprite speed
    STA $1747|!Base2,y
    LDX $15E9|!Base2
    RTS

.xspd
    db $02,$FE

FaceMario:
    LDY #$00
    LDA $94
    SEC : SBC !E4,x
    LDA $95
    SBC !14E0,x
    BPL +
        INY
+   TYA
    STA !157C,x
    RTS
