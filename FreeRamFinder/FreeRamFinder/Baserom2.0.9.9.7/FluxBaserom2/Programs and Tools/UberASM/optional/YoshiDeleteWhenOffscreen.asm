; by spoons

; Designed to delete if Yoshi offscreen to the left. 
; Will prob need to rework for right.

main:
    LDX #!sprite_slots-1
.loop

    LDA !sprite_num,x
    CMP #$35
    BEQ .a_yoshi

.next
    DEX
    BPL .loop
    RTL

.a_yoshi
if read4($02FFE2) == $44535453 ; if pixi is installed
    LDA !extra_bits,x ; check if sprite is custom
    AND #$08
    BNE .next
endif

    LDA !sprite_x_high,x
    XBA
    LDA !sprite_x_low,x

    REP #$20
    CLC
    ADC #$0010 ; this despawns when yoshi's body is left of the camera; increase to $0020 to wait for his head to go offscreen
    CMP $1A
    SEP #$20
    BCS .next

    STZ !sprite_status,x
    
    BRA .next