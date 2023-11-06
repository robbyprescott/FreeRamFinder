; Which cutscene to trigger
; 1 = Iggy, 2 = Morton, 3 = Lemmy, 4 = Ludwig
; 5 = Roy, 6 = Wendy, 7 = Larry, 8 = Credits
!cutscene = 1

; If you disabled the end level circle closing, or if
; the level is a vanilla vertical level, set this to 1
!end_circle_disable = 0

main:
if !end_circle_disable
    lda $1493|!addr : cmp #$01 : bne .return
else
    lda $1B99|!addr : beq .return
    lda $1433|!addr : cmp #$04 : bne .return
    phk
    pea.w (+)-1
    pea.w $0084CF-1
    jml $00CA44|!bank
+   
endif
    stz $0DDA|!addr
    lda.b #!cutscene : sta $13C6|!addr
    lda #$01 : sta $0DD5|!addr : sta $1DE9|!addr : sta $13CE|!addr
    lda #$18 : sta $0100|!addr
.return:
    rtl
