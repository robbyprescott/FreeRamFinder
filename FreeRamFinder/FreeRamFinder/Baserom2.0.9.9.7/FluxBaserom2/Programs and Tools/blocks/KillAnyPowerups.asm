; by SJandCharlieTheCat

!KillItemReserveItemToo = 1

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

MarioBelow:
MarioAbove:
MarioSide:

TopCorner:
BodyInside:
HeadInside:

    LDA $19
    BEQ Star
	LDA #$10        ; Sound effect (default: Magikoopa Magic)
    STA $1DF9       ; SFX Bank
    STZ $19     ; kill powerup
    STZ $1407   ; kill actual flight, viz. floating
	if !KillItemReserveItemToo
	STZ $0DC2
	endif
	%create_smoke()
	RTL
	
Star:	
    LDA $1490    ; first make sure star power was actually active
    BEQ Return            ;  (if you don't, the music will reset every time the block is touched)
	LDA #$10        ; Sound effect (default: Magikoopa Magic)
    STA $1DF9       ; SFX Bank
    STZ $1490     ; clear star power
	%create_smoke()
    LDA $0DDA     ; get the backup music register (this retains the song number for star/p-switches/etc.)
    CMP #$FF            ;  if #$FF, that means 'don't override', so we just return
    BEQ Return
    AND #$7F            ;  clear bit 7 (which indicates star power)
    STA $0DDA     ;   and store this value back.
    STA $1DFB     ;  lastly, restore that value to the song number
Return:	
RTL

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
RTL

print "This will kill any powerups you have, including star power, but without 'hurting' you."
