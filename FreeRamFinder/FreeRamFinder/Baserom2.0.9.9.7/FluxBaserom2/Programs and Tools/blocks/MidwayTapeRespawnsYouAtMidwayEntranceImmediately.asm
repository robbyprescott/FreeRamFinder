; by SJC with KevinM

; This midway teleports you to where current screen exit is set to take you.
; There are a couple things you need to do to get this to work. 
; First, you need to use TeleportDelay UberASM with this.

; (If you want to teleport to the midway in the SAME level, 
; go to the Modify Screen Exit menu, put the level number as itself, 
; and check the "Go to midway entrance" option. 
; Make sure you have the correct settings in the Modify Main and Midway Entrance menu, too.)

; Second, to prevent this midway from reappearing when you respawn,
; you can use conditional Map16.
; After you this block in your level, click on it,
; go to Edit > Conditional Map16..., 
; type 3 for the Flag Number (others are used), and check "Always show..." 
; It will subsequently use the blank tile 100 tiles below this in Map16.
; (It will also display this other tile in LM no matter what.)



!TeleportFreeRAM = $0E7C ; match in Uber
!retry_freeram = $7FB400
!retry_freeram_checkpoint = $7FB40C


db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

MarioCorner:
WallFeet:
WallBody:
MarioBelow:
MarioAbove:
MarioSide:
MarioBody:
MarioHead:

    LDA $7FC060
    ORA #%00001000 ; 8 in hex, 3 in Conditional
    STA $7FC060

    LDA #$01
	STA !TeleportFreeRAM 

    LDA #$05 ; midway sound
	STA $1DF9
	
    lda $13BF|!addr
    cmp #$25 : bcc +
    clc : adc #$DC
+   sta !retry_freeram+3
    lda #$08 : adc #$00 : sta !retry_freeram+4

    ldx $13BF|!addr
    lda $1EA2|!addr,x : ora #$40 : sta $1EA2|!addr,x
    txa : asl : tax
    rep #$20
    lda !retry_freeram+3 : sta !retry_freeram_checkpoint,x
    sep #$20
    %erase_block()
SpriteV:
SpriteH:
Fireball:
Cape:
    rtl    		;do nothing on sprite/fireball/cape contact 
	
print "This midway teleports you to where the current screen exit is set to take you. There are a couple things you need to do to get this to work. You need to use the TeleportDelay UberASM with this, and ConditionalMap16 flag 3. See instructions."