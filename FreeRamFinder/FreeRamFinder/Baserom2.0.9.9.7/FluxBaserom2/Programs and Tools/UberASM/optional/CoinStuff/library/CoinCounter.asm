; Includes coin functionality too

!CoinFunctionality = 0 ; already restored

; This UberASM will show a coin counter using layer 3 tiles
; Useful if you nuked the status bar but still need it displayed for specific levels
; (make sure that you didn't nuke the coin count functionality though)

!FreeRAMKillVanillaFunction = $0DEC

; Position of the counter on the screen (measured in amount of 8x8 tiles)
!XPos     = $19
!YPos     = $02

; Tiles that precede the actual counter
!CoinTile  = $3C2E
!XTile     = $3826
!EmptyTile = $38FC

!Counter = $0DBF|!addr  ; Counter to display. 
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
    ;LDA #$01 
	;STA !FreeRAMKillVanillaFunction
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
    lda.w #!CoinTile    ;|
    sta $00             ;|
    lda.w #!XTile       ;| Store the static tiles.
    sta $02             ;|
    lda.w #!EmptyTile   ;|
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
	
	 if !CoinFunctionality
	    LDA $13CC   ; add up coins
        BEQ .return
        DEC $13CC
        INC $0DBF
        LDA $0DBF
        CMP #$64        ; only give a reward with 100 coins
        BCC .return
        
        INC $18E4   ; REWARD (1UP)
        
        STZ $0DBF
	endif
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
