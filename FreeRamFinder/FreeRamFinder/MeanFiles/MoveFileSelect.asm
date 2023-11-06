; customizable title screen player select by brakkie
; these are the striple image tables used for the title screen
; !! This is for advanced use, make sure you know what you are doing !!

	; each of these individual stripes consists of 4 header bytes
	; they are build like this:

	; |Byte 1| |Byte 2| |Byte 3| |Byte 4|
	; EHHHYXyy yyyxxxxx DRllllll LLLLLLLL
	; E = End of data
	; HHH = Data destination (layer to draw on)
	; Xxxxxx = X coordinate (X/Y is a high byte and will shift x/y pos by 256 pixels if set)
	; Yyyyyy = Y coordinate (adding 1 to x/y will move it one whole 8x8 tile)
	; D = Direction (0 = Horizontal, 1 = Vertical)
	; R = RLE (if set, repeats the same tile based on the amount of bytes in llllllLLLLLLLL)
	; llllllLLLLLLLL = Length (amount of bytes to upload - 1)

	; everything after those 4 header bytes is just tile data while 2 bytes are always 1 tile (I made defines for them for better readability)

	; they are build like this:
	; |Byte 1| : Tile Number
	; |Byte 2| : Properties (YXPCCCTT) <- Priority and graphic page settings are slightly different for layers as they are for sprites!

	; and one $FF at the end to indicate the stripe image has ended

	; for more advanced information on stripe images visit https://www.smwcentral.net/?p=viewthread&t=14531

	; !! If you add more symbols to a stripe image, make sure to update the byte size. !!


; |defines for symbols (tile num, properties)|
; letters or numbers with '!' after them are ones that do not come in the title screen text font but i found replacement in the files
; however, they will appear blue and you have to change color 0,B to white or make custom tiles
!Cursor	= $2E,$3D

!Space	= $FC,$38;
!Dot	= $24,$38
!Comma	= $25,$38
!UScore	= $27,$38
!Exclam	= $28,$38
!Quote	= $85,$38
!Quote2	= $86,$38
!Time	= $76,$38
!Equal	= $77,$38
!Colon	= $78,$38
!Accent	= $62,$39

!A	= $71,$31
!B	= $2C,$31
!C	= $2D,$31
!D	= $7C,$30
!E	= $73,$31
!F	= $0F,$28	;!
!G	= $75,$31
!H	= $84,$30
!I	= $82,$30
!J	= $13,$28	;!
!K	= $14,$28	;!
!L	= $70,$31
!M	= $76,$31
!N	= $79,$30
!O	= $83,$30
!P	= $6F,$31
!Q	= $1A,$28	;!
!R	= $74,$31
!S	= $31,$31
!T	= $2F,$31
!U	= $7B,$30
!V	= $80,$30
!W	= $81,$30
!X	= $21,$28	;!
!Y	= $72,$31
!Z	= $21,$31

!0	= $3E,$31
!1	= $6D,$31
!2	= $6E,$31
!3	= $4E,$30
!4	= $50,$30
!5	= $51,$30
!6	= $52,$30
!7	= $53,$30
!8	= $08,$28	;!
!9	= $09,$28	;!
; feel free to add your own symbols!

; |This is the stuff for the cursor|
; this number is |Byte 1| and |Byte 2| from the stripe image for the cursor (i put it in a dw table for better readablity)
org $009E74
	dw $51CB	; no idea what this one is for but probably also don't want to change this one
	dw $5188	; File select
	dw $51A8	; Player select
	dw $51C4	; Overworld save prompt (don't want to change that one)
	dw $5185	; File erase

; this number is |Byte 3| and |Byte 4| from the stripe image for the cursor (i put it in a dw table for better readablity)
org $009E6A
	dw $0002
	dw $0004
	dw $0002
	dw $0002
	dw $0004

; these are |Properties| and |Tilenumber| for the cursor
org $009EBA
	db !Space	; cursor off (blink)
org $009EC1
	db !Cursor	; cursor itself

; |This is the rest of the text|
org $05B6FE	; Stripe image for the file erase dialogue.
	; empty tiles
	db $51,$85,$40,$2E,!Space
	db $51,$A8,$40,$1C,!Space
	db $51,$C5,$40,$2E,!Space
	db $51,$E8,$40,$1C,!Space
	db $52,$05,$40,$2E,!Space
	db $52,$45,$40,$1C,!Space

	; MARIO A ...EMPTY ($05B722)
	db $51,$8D,$00,$1F
	db !L,!U,!I,!G,!I,!Space,!A,!Space,!Dot,!Dot,!Dot,!E,!M,!P,!T,!Y

	; MARIO B ...EMPTY ($05B746)
	db $51,$CD,$00,$1F
	db !L,!U,!I,!G,!I,!Space,!B,!Space,!Dot,!Dot,!Dot,!E,!M,!P,!T,!Y

	; MARIO C ...EMPTY ($05B76A)
	db $52,$0D,$00,$1F
	db !L,!U,!I,!G,!I,!Space,!C,!Space,!Dot,!Dot,!Dot,!E,!M,!P,!T,!Y

	; ERASE [A] ($05B78E)
	db $51,$87,$00,$0B
	db !E,!R,!A,!S,!E,!Space

	; ERASE [B] ($05B79E)
	db $51,$C7,$00,$0B
	db !E,!R,!A,!S,!E,!Space

	; ERASE [C] ($05B7AE)
	db $52,$07,$00,$0B
	db !E,!R,!A,!S,!E,!Space

	; END ($05B7BE)
	db $52,$47,$00,$05
	db !E,!N,!D

	db $FF	; end table byte

org $05B7C9	; Stripe image for the file select dialogue.
	; empty tiles
	db $51,$85,$40,$2E,!Space
	db $51,$A8,$40,$1C,!Space
	db $51,$C5,$40,$2E,!Space
	db $51,$E8,$40,$1C,!Space
	db $52,$05,$40,$2E,!Space
	db $52,$45,$40,$1C,!Space

	; MARIO A ...EMPTY ($05B7ED)
	db $51,$8A,$00,$1F
	db !L,!U,!I,!G,!I,!Space,!A,!Space,!Dot,!Dot,!Dot,!E,!M,!P,!T,!Y

	; MARIO B ...EMPTY ($05B811)
	db $51,$CA,$00,$1F
	db !L,!U,!I,!G,!I,!Space,!B,!Space,!Dot,!Dot,!Dot,!E,!M,!P,!T,!Y

	; MARIO C ...EMPTY ($05B835)
	db $52,$0A,$00,$1F
	db !L,!U,!I,!G,!I,!Space,!C,!Space,!Dot,!Dot,!Dot,!E,!M,!P,!T,!Y

	; ERASE DATA ($05B859)
	db $52,$4A,$00,$13
	db !E,!R,!A,!S,!E,!Space,!D,!A,!T,!A

	db $FF	; end table byte
 
org $05B872	; Stripe image for the player select dialogue.
	; empty tiles
	db $51,$85,$40,$2F,!Space
	db $51,$C5,$40,$2F,!Space
	db $52,$05,$40,$2F,!Space
	db $52,$45,$40,$1C,!Space

	; 1 PLAYER GAME ($05B88A)
	db $51,$AA,$00,$19
	db !1,!Space,!P,!L,!A,!Y,!E,!R,!Space,!G,!A,!M,!E

	; 2 PLAYER GAME ($05B8A8)
	db $51,$EA,$00,$19
	db !2,!Space,!P,!L,!A,!Y,!E,!R,!Space,!G,!A,!M,!E
	
	db $FF	; end table byte