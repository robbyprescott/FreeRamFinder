; Sin/Cos routine by Puniry Ping
;
; Routine that gets the x and y distance when given an angle and a radius.
; It doesn't conflict with mode 7. Not SA-1 compatible.
;
; Input:  $04 = angle (16 bit)
;         $06 = radius (8 bit)
;
; Output: $07 = X displacement (16 bit)
;         $09 = Y displacement (16 bit)

__SIN:
        PHP
        PHX

        REP #$30
        LDA $04
        AND #$00FF
        ASL A
        TAX             
        LDA $07F7DB,x
        STA $02        

        SEP #$30 
        LDA $05
        PHA
        LDA $02
        STA $4202
        LDA $06
        LDX $03
        BNE .IF1_SIN
        STA $4203
        ASL $4216
        LDA $4217
        ADC #$00
.IF1_SIN
        LSR $05
        BCC .IF_SIN_PLUS

        EOR #$FF
        INC A
        STA $09
        BEQ .IF0_SIN
        LDA #$FF
        STA $0A
        BRA .END_SIN

.IF_SIN_PLUS
        STA $09
.IF0_SIN
        STZ $0A

.END_SIN
        PLA
        STA $05
 
__COS:    
        REP #$30
        LDA $04
        CLC
        ADC #$0080
        AND #$01FF      
        STA $07   
         
        AND #$00FF
        ASL A
        TAX
        LDA $07F7DB,x
        STA $00

        SEP #$30
        LDA $00
        STA $4202
        LDA $06
        LDX $01
        BNE .IF1_COS
        STA $4203
        ASL $4216
        LDA $4217       
        ADC #$00
.IF1_COS
        LSR $08
        BCC .IF_COS_PLUS
        EOR #$FF
        INC A
        STA $07
        BEQ .IF0_COS
        LDA #$FF
        STA $08
        BRA .END_COS

.IF_COS_PLUS
        STA $07
.IF0_COS
        STZ $08

.END_COS
        PLX
        PLP
        RTL
