; How long the P-Balloon rises out of a block
!rise_time = $3E

; How fast the P-Balloon rises out of a block
!rise_speed = $F8

if read1($00FFD5) == $23
    sa1rom
    !1540 = $32C6
    !157C = $3334
else
    lorom
    !1540 = $1540
    !157C = $157C
endif

; Prevent the P-Balloon from moving normally
org $01C206
    beq +

org $01C24F
    +

; Change the "rising out of a block" speed
org $01C216
    db !rise_speed

; Set the "rising out of a block" timer
org $0289C9
    autoclean jml set_1540

freedata

set_1540:
    inc !157C,x
    lda.b #!rise_time : sta !1540,x
    rtl
