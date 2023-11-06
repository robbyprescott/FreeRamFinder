arch spc700-raw

org $000000
incsrc "asm/main.asm"
base $240B

org $008000


    mov a, #$0C 
    clrc
    adc a, $51
    call L_0E14+3
    mov a, #$00
    mov $0387, a
    ret
