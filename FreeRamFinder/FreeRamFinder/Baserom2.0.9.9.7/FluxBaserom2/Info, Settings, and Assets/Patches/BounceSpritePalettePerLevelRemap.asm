; This patch remaps the palette used by the turn block and ? block bounce sprites in each level

if read1($00FFD5) == $23
    sa1rom
    !sa1 = 1
    !dp = $3000
    !addr = $6000
    !bank = $000000
else
    lorom
    !sa1 = 0
    !dp = $0000
    !addr = $0000
    !bank = $800000
endif

!Pal8 = $00
!Pal9 = $02
!PalA = $04
!PalB = $06
!PalC = $08
!PalD = $0A
!PalE = $0C
!PalF = $0E

org $028824
    autoclean jml Main

freecode

Main:
    cpx #$00
    beq +
    cpx #$02
    beq +
    cpx #$03
    beq +
    cpx #$06
    bne .normal
+   rep #$10
    ldx $010B|!addr
    lda.l Palette,x
    sep #$10
    bra .return
.normal
    lda.w $028789,x
.return
    sta $1901|!addr,y
    jml $02882A|!bank

; Change the palette here. Possible values are !PalA-F
Palette:
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 000-00F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 010-01F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 020-02F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 030-03F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 040-04F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 050-05F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 060-06F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 070-07F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 080-08F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 090-09F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 0A0-0AF
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 0B0-0BF
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 0C0-0CF
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 0D0-0DF
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 0E0-0EF
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 0F0-0FF
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 100-10F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 110-11F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 120-12F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 130-13F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 140-14F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 150-15F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 160-16F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 170-17F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 180-18F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 190-19F
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 1A0-1AF
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 1B0-1BF
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 1C0-1CF
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 1D0-1DF
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 1E0-1EF
db !PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA,!PalA  ;Sublevels 1F0-1FF