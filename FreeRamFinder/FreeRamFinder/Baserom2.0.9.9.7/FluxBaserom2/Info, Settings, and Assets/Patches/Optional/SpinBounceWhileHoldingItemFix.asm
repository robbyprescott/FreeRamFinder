; https://www.smwcentral.net/?p=section&a=details&id=23017
; While this is a nice fix, some people may think the actual graphical modification is pretty weird (item held above head).
; And others may prefer to force an item upthrow + re-catch after the spin-bounce


if read1($00FFD5) == $23    ; SA-1 detection code
    sa1rom
    !sa1 = 1
    !dp = $3000
    !addr = $6000
    !bank = $000000
    !E4 = $322C
    !14E0 = $326E
else
    lorom
    !sa1 = 0
    !dp = $0000
    !addr = $0000
    !bank = $800000
    !E4 = $E4
    !14E0 = $14E0
endif

org $01A0F6
autoclean JML new_carry_code

freedata
mario_spinning:
    LDA $00
    STA !E4,X
    LDA $01
    STA.W !14E0,X
    LDA.B #$06    ;item y offset, lower value to move the item higher
    JML $01A11A|!bank

new_carry_code:
    PLY
    LDA.W $140D|!addr
    BNE mario_spinning
    LDA $00
    CLC
    JML $01A0FA|!bank