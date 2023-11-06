;===============================================
; Upwards Grey Platform
; By Erik
;
; Description: This is a sprite like the grey
; falling platform (C4) but instead of falling
; it'll rise up. Gamers rise up
;===============================================

!initial_speed  = $FD
!terminal_speed = $C0
tilemap:
        db $60,$61,$61,$62    

;---

print "MAIN ",pc
        PHB
        PHK
        PLB
        JSR grey_rising_platform
        PLB
print "INIT ",pc
        RTL

grey_rising_platform:
        JSR draw_sprite
        LDA $9D
        BNE return
        %SubOffScreen()
        LDA !AA,x
        BEQ .no_speed_update
        LDA !1540,x
        BNE .update_speed
        LDA !AA,x
        CMP.b #!terminal_speed
        BMI .update_speed
        SEC                       
        SBC #$02
        STA !AA,x
.update_speed
        JSL $01801A|!BankB
.no_speed_update
        JSL $01B44F|!BankB
        BCC return
        LDA !AA,x
        BNE return
        LDA.b #!initial_speed
        STA !AA,x
        LDA #$18
        STA !1540,x
return:
        RTS

;---

x_disp:
        db $00,$10,$20,$30

draw_sprite:
        %GetDrawInfo()
        LDA !15F6,x
        STA $03
        LDX #$03
.loop
        LDA $00
        CLC
        ADC x_disp,x
        STA $0300|!Base2,y
        LDA $01
        STA $0301|!Base2,y
        LDA tilemap,x
        STA $0302|!Base2,y
        LDA $03
        ORA $64
        STA $0303|!Base2,y
        INY #4
        DEX
        BPL .loop
        LDX $15E9|!Base2
        LDY #$02
        LDA #$03
        JSL $01B7B3|!BankB
        RTS

