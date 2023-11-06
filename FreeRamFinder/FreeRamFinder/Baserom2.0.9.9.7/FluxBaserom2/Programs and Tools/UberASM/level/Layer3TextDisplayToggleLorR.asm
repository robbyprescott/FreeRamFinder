; This is obsolete in light of other L3 toggle Uber

; L/R toggleable layer 3 text message
; By KevinM, modified by SJandCharlieTheCat

; Scroll all the way down to DisplayText: to enter your message.
; You can specify the color after the letter.
; Count the total number of tiles in your message (including spaces and punctuation),
; then come back and enter it at !NumberOfTiles.

; Note that this will kill any layer 3 you have in your level
; Also message boxes, unless you have the inline message box patch.


!NumberOfTiles = 30 ; In decimal, not hex. 
                    ; Looks like if the number exceeds entries, jank

; Position of the counter on the screen (measured in amount of 8x8 tiles)
!XPos     = $01 ; Far left. The higher the number, the further right it is. 22 is near far right. 
!YPos     = $01 ; Top. The higher the number, the lower down it is. 12 is about 2/3 of the way toward bottom.


;Letter equivalences. You don't need to touch this.
!0 = $00 : !1 = $01 : !2 = $02 : !3 = $03 : !4 = $04 : !5 = $05 : !6 = $06 : !7 = $07 : !8 = $08 : !9 = $09
!A = $0A : !B = $0B : !C = $0C : !D = $0D : !E = $0E : !F = $0F : !G = $10 : !H = $11 : !I = $12 : !J = $13
!K = $14 : !L = $15 : !M = $16 : !N = $17 : !O = $18 : !P = $19 : !Q = $1A : !R = $1B : !S = $1C : !T = $1D
!U = $1E : !V = $1F : !W = $20 : !X = $21 : !Y = $22 : !Z = $23 : !Period = $24 : !Comma = $25 : !Underscore = $27
!Exclamation = $28 : !EqualSign = $77 : !Space = $FC

;Color equivalencess. You don't need to touch this.
!White = $38 : !Yellow = $3C : !Red = $2C


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
    inx #2 ;
?-  lda.w <Table>,y
    sta $7F837D,x
    inx #2 ;
    iny #2 ;
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

main:
    lda #$09            ;\ Set layer 3 absolute priority.
    sta $3E             ;/
    stz $22             ;\
    stz $23             ;| Reset layer 3 position.
    stz $24             ;|
    stz $25             ;/
    jsr DrawStaticTiles ; Draw the static tiles.
	return:
	rtl

DisplayText:
db !L         :     db !Red
db !EqualSign :     db !White
db !1         :     db !Yellow 
db !0         :     db !Yellow 
db !4         :     db !Yellow
db !Space     :     db !White
db !Space     :     db !White
db !Space     :     db !White
db !Space     :     db !White
db !S         :     db !Red 
db !E         :     db !Red
db !L         :     db !Red
db !EqualSign :     db !White
db !M         :     db !Yellow
db !A         :     db !Yellow
db !I         :     db !Yellow
db !N         :     db !Yellow
db !Space     :     db !White
db !H         :     db !Yellow
db !U         :     db !Yellow
db !B         :     db !Yellow
db !Space     :     db !White
db !Space     :     db !White
db !Space     :     db !White
db !Space     :     db !White
db !R         :     db !Red
db !EqualSign :     db !White
db !1         :     db !Yellow 
db !0         :  db !Yellow 
db !6         :  db !Yellow ; 30th tile

DrawStaticTiles:
    ; Copy the tiles in the stripe image table.
	LDA $17
	AND #$30 ; either L or R
	BEQ NotHeld
    %BeginStripe()
    %WriteLine(3,!XPos,!YPos,DisplayText,!NumberOfTiles*2) ; removed ,$00|!dp,
    %EndStripe()
    rts
	
	BlankTable:
db $FC : db $38 : db $FC : db $38 : db $FC : db $38 : db $FC : db $38 : db $FC : db $38
db $FC : db $38 : db $FC : db $38 : db $FC : db $38 : db $FC : db $38 : db $FC : db $38
db $FC : db $38 : db $FC : db $38 : db $FC : db $38 : db $FC : db $38 : db $FC : db $38
db $FC : db $38 : db $FC : db $38 : db $FC : db $38 : db $FC : db $38 : db $FC : db $38
db $FC : db $38 : db $FC : db $38 : db $FC : db $38 : db $FC : db $38 : db $FC : db $38
db $FC : db $38 : db $FC : db $38 : db $FC : db $38 : db $FC : db $38 : db $FC : db $38
	
	NotHeld:
	%BeginStripe()
    %WriteLine(3,!XPos,!YPos,BlankTable,!NumberOfTiles*2) ; removed ,$00|!dp,
    %EndStripe()
	rts
	