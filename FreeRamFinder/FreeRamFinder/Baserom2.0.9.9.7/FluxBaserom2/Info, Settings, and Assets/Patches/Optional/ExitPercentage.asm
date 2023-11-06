;===========================================;
; Show exit percentage on file select v1.1  ;
; by KevinM                                 ;
;===========================================;

; Total number of exits in your game (decimal)
!TotalExits = 96

; Tile used for the percent sign (LG1/2)
!PercentTile = $87

; 0 = round percentage down, 1 = round it up
!RoundUp = 1

; 0 = only integer value, 1 = also a decimal digit
!ShowDecimalDigit = 1

; What tile to use for the decimal separator
; (only relevant if !ShowDecimalDigit = 1)
!DotTile = $24

if read1($00FFD5) == $23
    sa1rom
    !sa1 = 1
    !addr = $6000
    !bank = $000000
else
    lorom
    !sa1 = 0
    !addr = $0000
    !bank = $800000
endif

org $009D6C
    autoclean jml ComputePercentage

if !ShowDecimalDigit
    org $009D7C
        sta $7F8381,x
else
    org $009D7C
        sta $7F8383,x
endif

if !ShowDecimalDigit
    org $009D96
        bra $0C
else
    org $009D96
        ldy #$01
endif

org $009D9B
    sta $7F8387,x

org $009D85
    autoclean jml DrawPercentage

freecode

; Even on SA-1 roms we're running on the SNES here.
ComputePercentage:
    sta $4202       ;\
    lda.b #100      ;|
    sta $4203       ;| Percent = Exits * 100 / TotalExits.
    jsr .sub        ;|
    lda $4214       ;/
if !ShowDecimalDigit == 0
if !RoundUp
    ldy $4216       ;\ If there's a remainder
    beq +           ;|
    cmp.b #99       ;| and the result is not 99%
    beq +           ;|
    inc             ;/ increase by 1.
+
endif   
else
    pha             ; Save percentage for later.
    lda $4216       ;\ If remainder is 0, decimal digit is 0.
    beq +           ;/
    sta $4202       ;\
    lda.b #10       ;|
    sta $4203       ;| DecimalUnit = Remainder * 10 / TotalExits.
    jsr .sub        ;|
    lda $4214       ;/
if !RoundUp
    ldy $4216       ;\ If the remainder is 0, don't round up.
    beq +           ;/
    cmp.b #9        ;\
    bne ++          ;|
    pla             ;| If we have to round up 9, increase the
    inc             ;| integer units by 1 and set decimal digit to 0.
    pha             ;|
    lda #$00        ;|
    bra +           ;/
++  inc             ; Otherwise, just increase the decimal unit by 1.
endif
+   sta $0F         ; Save decimal unit for later.
    pla             ; Retrieve percetage.
endif
    jml $009D76|!bank

; Input: $4202-3 multiplicands
; Output: $4214 result, $4216 remainder
.sub
    nop             ; JSR takes 6 cycles so we only need 2 more.
    lda $4216
    sta $4204
    lda $4217
    sta $4205
    lda.b #!TotalExits
    sta $4206
    ora ($00)       ;\ Waste 10 cycles
    ora ($00)       ;/
    rts             ; (+6 cycles)

DrawPercentage:
if !ShowDecimalDigit
    cmp #$00
    beq +
    cmp #$0A
    bcc ++
; Here it's 100+%, so we skip the dot and decimal digit
    sec
    sbc #$0A
    sta $7F8383,x
    lda #$38
    sta $7F8384,x
    lda $7F8381,x   ;\ The units are two tiles to the right in this case.
    sta $7F8385,x   ;/
    rep #$20
    lda #$3801
    sta $7F8381,x
    lda #$38FC
    sta $7F837F,x
    bra +++
; Here it's <100%
+   lda #$FC
++  sta $7F837F,x
    lda $0F
    sta $7F8385,x
    rep #$20
    lda.w #$3800+!DotTile
    sta $7F8383,x
; Here the two cases converge
+++ lda.w #$3800+!PercentTile
    sta $7F8387,x
    sep #$20
    lda #$38
    sta $7F8386,x
else
    tay
    beq +
    cpy #$0A
    bcc ++
    sec
    sbc #$0A
    bra ++
+   lda #$FC
++  sta $7F8381,x
    lda #$FC
    cpy #$0A
    bcc +
    lda #$01
+   sta $7F837F,x
    lda.b #!PercentTile
    sta $7F8385,x
    lda #$38
    sta $7F8384,x
    sta $7F8386,x
endif
    jml $009D8C|!bank
