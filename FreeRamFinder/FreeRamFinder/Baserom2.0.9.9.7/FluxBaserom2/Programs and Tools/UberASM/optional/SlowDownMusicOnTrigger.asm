; This is the address that controls the effect, by default the P-Balloon flag. You can change this to another address to have the effect happen for something else (like $14AF for the ON/OFF switch, etc.).
!flag = $14AF|!addr

; 1 byte of freeram
!freeram = $0E2C

; Number and port used by the custom SFX
; Same as what you insert them as in AddmusicK
!slow_tempo_sfx         = $39
!slow_tempo_sfx_addr    = $1DFC|!addr
!normal_tempo_sfx       = $3A
!normal_tempo_sfx_addr  = $1DFC|!addr

init:
    lda !flag : sta !freeram
    rtl

main:
    lda !flag : beq +
    lda #$01
+   cmp !freeram : beq .return
    sta !freeram
    cmp #$00 : beq .reset
.slowdown:
    lda.b #!slow_tempo_sfx
    sta !slow_tempo_sfx_addr
    rtl
.reset:
    lda.b #!normal_tempo_sfx
    sta !normal_tempo_sfx_addr
.return:
    rtl
