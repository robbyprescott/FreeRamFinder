; This UberASM will show a counter using layer 3 tiles.
; If you're not using this for the HP counter, but for an actual life counter with two-digit lives,
; you can switch around !FirstTile and stuff to bring the heart symbol and X mark further away from the number.
; (Make 1st tile = $2C86, 2nd = $3826, 2nd  and 3rd = $38FC). May need to move position over one, too.)


; Position of the counter on the screen (measured in amount of 8x8 tiles)
!XPos     = $01 
!YPos     = $01

; Tiles that precede the actual counter
!FirstTile  = $38FC ; Empty (so that will be closer to actual counter)
!SecondTile = $2C86 ; Last two digits of this value are tile # (page 1C in Tile Editor). 86 is heart. 88 is mushroom.
!ThirdTile = $3826 ; X mark. 2C is palette 2. 36 is palette 03, or 4th on right

!Counter = $0DBE|!addr  ; $0DBF, coin. Counter to display
!Backup  = $7FBFFF      ; 1 byte of freeram

; Stripe image utilities
macro BeginStripe()
    rep #$30
    lda $7F837B
    tax
endmacro

macro WriteLine(Layer, XPos, YPos, Table, Length)
    ldy #$0000
    lda.w #(($800*<Layer>*(<Layer>-1))+$2000)|((<YPos>)<<5)|(<XPos>)
    xba
    sta $7F837D,x
    inx #2
    lda.w #(<Length>)-1
    xba
    sta $7F837D,x
    inx #2
?-  lda.w <Table>,y
    sta $7F837D,x
    inx #2
    iny #2
    cpy.w #<Length>
    bne ?-
endmacro

macro EndStripe()
    txa
    sta $7F837B
    lda #$FFFF
    sta $7F837D,x
    sep #$30
endmacro

init:
    lda #$09            ;\ Set layer 3 absolute priority.
    sta $3E             ;/
    stz $22             ;\
    stz $23             ;| Reset layer 3 position.
    stz $24             ;|
    stz $25             ;/
    lda !Counter        ;\ Init the counter backup.
    sta !Backup         ;/
    jsr DrawStaticTiles ; Draw the static tiles.
    jmp main_write      ; Draw the counter.

DrawStaticTiles:
    rep #$20            ;\
    lda.w #!FirstTile    ;|
    sta $00             ;|
    lda.w #!SecondTile  ;| Store the static tiles.
    sta $02             ;|
    lda.w #!ThirdTile   ;|
    sta $04             ;|
    sep #$20            ;/

    ; Copy the tiles in the stripe image table.
    %BeginStripe()
    %WriteLine(3,!XPos,!YPos,$00|!dp,3*2)
    %EndStripe()
    rts

main:
    lda !Counter        ;\ Only update the counter when it changes.
    cmp !Backup         ;| (2 8x8 tiles shouldn't cause overflows but better safe than sorry).
    beq .return         ;/
    sta !Backup         ; and update the counter backup.
.write:
    jsr SetupTable      ; Setup stripe table in $00.

    ; Copy the tiles in the stripe image table.
    %BeginStripe()
    %WriteLine(3,!XPos+3,!YPos,$00|!dp,2*2)
    %EndStripe()
.return
    rtl

SetupTable:
    lda !Counter        ;\
    sta $4204           ;|
    stz $4205           ;| Divide counter by 10 to find the digits.
    lda #10             ;|
    sta $4206           ;/
    
    lda #$38            ;\
    sta $01             ;| Store properties for the digits.
    sta $03             ;/

    nop #4              ; Need to waste 8 more cycles...

    lda $4214           ;\
    bne +               ;|
    lda #$FC            ;| Store digits in the table.
+   sta $00             ;| (if tens are 0, store the empty tile).
    lda $4216           ;|
    sta $02             ;/
    rts
