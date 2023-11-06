; When Yoshi has wings, e.g. from eating blue shell,
; you can fly upward infinitely just by holding B,
; instead of repeated pressing.

main:
    LDA $15 : AND #$80 : BEQ +
    LDA #$08 : STA $14A5            
    +
    RTL


