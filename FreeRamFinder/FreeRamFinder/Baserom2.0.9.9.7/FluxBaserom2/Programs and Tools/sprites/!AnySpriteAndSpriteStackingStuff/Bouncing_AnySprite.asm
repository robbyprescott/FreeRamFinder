;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Any Sprite, Football Movement
;
; Extra bit: if set, the spawned sprite is custom.
;
; Options are set using the extension box in LM using 6 or 10 (depending on extra bit, if not set it'll be 6) bytes
;
; SS XX YY CC SX SY E1 E2 E3 E4
; 
; SS = Sprite number
; XX = X offset for position sprite ($80-$FF = negative offset)
; YY = Y offset for position sprite ($80-$FF = negative offset)
; CC = Custom settings. Format: epP-SSSS
;  - SSSS: the state the sprite will be spawned in (using the $14C8 format).
;    (0 acts as 1 because state 0 doesn't make sense here).
;    State 1 (set with either 0 or 1) is init, which is what you usually want.
;    State 9 is carryable, useful for sprites like shells or throwblocks.
;  - e: if 1 (i.e. add 80 to the number), will set the extra bit for the spawned sprite.
;  - p: to be used with platforms: if set (i.e. add 40 to the number)
;    Mario will move with the platform instead of sliding on it.
;    Note: it doesn't work with Carrot Lifts, Keys and Boo Blocks.
;  - P: second platform option, which does the same thing as the p option
;    but it's recommended for sprites that use custom solid sprite code
;    (for example, MarioFanGamer's Numbered Platform sprite).
;    Note: this option doesn't work for sprites that naturally move horizontally.
;    Also, this option is overriden by the p option: don't use them together.
; SX = X speed of the spawned sprite
; SY = Bounce speed override. If left at zero, the sprite will use default random bounce speeds.
; E1-E4 - extra bytes for rotating custom sprite (those aren't present if extra bit isn't set)
;
; Note:
;  - To spawn a Shell, don't use numbers DA-DF. Use instead 04-09,
;    and set the state as carryable (extra byte 6 = 09).
;  - To spawn a throw block, use sprite number 53 and spawn it in
;    carryable state (or it won't appear).
;  - To spawn a P-Switch, use 0 or 1 for extra byte 6, or its color will be wrong.
;  - When inserting the sprite through the custom collection menu in LM, the last 4 bytes
;    will have random values in them (because the list only supports up to 4).
;    If the sprite you need is vanilla or it's custom but doesn't use the extra bytes, you
;    can ignore them and leave them random. Otherwise, you'll have to change them manually
;    (but in this case you'd have to change them anyway most of the time).
;    NOTE: this problem is fixed in PIXI v1.3.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

YSpeeds:		db $A0,$D0,$C0,$D0			;DATA_03800E

;depending on slope (this is added each time the sprite lands on a slope)
XSpeeds:		db -$10,-$08,-$04,$00,$04,$08,$10

!MaxRightwardSpeed = $20
!MaxLeftwardSpeed = -$20

			!RAM_SpritesLocked	= $9D
			!RAM_SpriteSpeedY	= !AA
			!RAM_SpriteSpeedX	= !B6
			!OAM_DispX		= $0300|!Base2
			!OAM_DispY		= $0301|!Base2
			!OAM_Tile		= $0302|!Base2
			!OAM_Prop		= $0303|!Base2
			!OAM_TileSize		= $0460|!Base2
			!RAM_SpriteDir		= !157C
			!RAM_SprObjStatus	= !1588
			!RAM_OffscreenHorz	= !15A0
			!RAM_SpritePal		= !15F6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
macro StoreExtraByte(addr)
    lda [$00],y
    sta <addr>
    iny
endmacro

macro StoreExtraByteX(addr)
    lda [$00],y
    sta <addr>,x
    iny
endmacro

!XOffset   = !1602
!YOffset   = !1594
!Slot      = !1504
!Settings  = !1570

;!XSpeed = !187B
!XSpeed = !B6
!YSpeed = !160E

!ProcessOffScreenBit = !1510

print "INIT ",pc
ExtraBytesSetup:
    lda !extra_byte_1,x		;setup pointers for extra bytes stored in ROM
    sta $00
    lda !extra_byte_2,x
    sta $01
    lda !extra_byte_3,x
    sta $02

    ldy #$00
    %StoreExtraByte($04)        ; extra 1 - $04 = sprite number.
    %StoreExtraByteX(!XOffset)  ; $1602,x = X offset.
    %StoreExtraByteX(!YOffset)  ; $1594,x = Y offset.
    %StoreExtraByteX(!Settings)
    %StoreExtraByteX(!XSpeed)
    %StoreExtraByteX(!YSpeed)

LDA !YSpeed,x			;don't make the sprite bounce downward (doesnt really make sense)
BMI .NoNeed			;but if already bouncing upward, no need for invertion
EOR #$FF
INC
STA !YSpeed,x

.NoNeed

;check for wether is is a custom sprite, to make it use less extra bytes (not needed for vanilla sprites)
    lda !extra_bits,x           ;\
    and #$04                    ;| Extra bit set = custom
    BEQ Spawn

    %StoreExtraByte($05)        ; extra 7 $06 = extra byte 1
    %StoreExtraByte($06)        ; extra 8 $07 = extra byte 2
    %StoreExtraByte($07)        ; extra 9 $08 = extra byte 3
    %StoreExtraByte($08)        ; extra 10 $09 = extra byte 4

Spawn:
    stz $00
    stz $01
    stz $02
    stz $03
    lda !extra_bits,x           ;\
    and #$04                    ;| Extra bit set = custom
    lsr #3                      ;/
    lda $04
    %SpawnSprite()
    bcc +                       ;\ If spawn failed, kill the sprite
    jmp AllowRespawn            ;/ but allow it to respawn.
+   
    tya                         ;\ Save slot in RAM.
    sta !Slot,x                 ;/
    
    lda !Settings,x             ;\
    and #$0F                    ;| Set the sprite state
    beq +                       ;|
    sta !14C8,y                 ;/

+
;make attached sprite not disappear offscreen (unless there's some hard code, idk)
LDA !167A,y			;need to save the bit in case it's intended to disappear offscreen after we grab it/destroy it or w/e (e.g. koopa shells should disappear)
AND #$04
STA !ProcessOffScreenBit,x

LDA !167A,y			;ignore offscreen
ORA #$04
STA !167A,y

    lda !Settings,x             ;\
    bpl +                       ;|
    tyx                         ;|
    lda !extra_bits,x           ;| Set the extra bit
    ora #$04                    ;|
    sta !extra_bits,x           ;|
    ldx $15E9|!Base2            ;/
+
    lda #$01                    ;\ Disable object interaction
    sta !15DC,y                 ;/

    %BEC(+)                     ;\
    tyx                         ;|
    lda $05                     ;|
    sta !extra_byte_1,x         ;|
    lda $06                     ;|
    sta !extra_byte_2,x         ;| If the sprite is custom, set the extra bytes.
    lda $07                     ;|
    sta !extra_byte_3,x         ;|
    lda $08                     ;|
    sta !extra_byte_4,x         ;|
    ldx $15E9|!Base2            ;/
+

JMP Offset

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
Main:
;Don't want to check if attached sprite is offscreen, need to check if this rotating sprite is offscreen despawn center olny)
LDA #$01
%SubOffScreen()

LDA !14C8,x				;center of rotation despawned offscreeen - remove attached sprite
CMP #$08
BNE RemoveAttach

PHB
PHK
PLB
		LDA $9D				;freeze flag = return
		BNE NoFlipDir

			JSL $01802A|!BankB     		; update sprite position
CODE_038031:
			LDA !RAM_SprObjStatus,x		;\ If no horizontal contact, branch
			AND #$03			; | 
			BEQ CODE_03803F			;/ 
			LDA !RAM_SpriteSpeedX,x		;\ else, invert horizontal speed
			EOR #$FF			; |
			INC A				; |
			STA !RAM_SpriteSpeedX,x		;/ 
CODE_03803F:
			LDA !RAM_SprObjStatus,x		;\ if sprite not touching ceiling, branch
			AND #$08			; |
			BEQ CODE_038048			;/
			STZ !RAM_SpriteSpeedY,x		; else, set y speed to zero
CODE_038048:
			LDA !RAM_SprObjStatus,x		;\ if sprite not on ground, branch
			AND #$04			; |
			BEQ NoFlipDir			;/ 
			;LDA !RAM_SpriteDir,x		;\ flip sprite graphics
			;EOR #$01			; |
			;STA !RAM_SpriteDir,x		;/
			LDA !YSpeed,x			;\override y-speed (consistent bounce)
			BNE .Store			;/
			JSL $01ACF9|!BankB		;\ use random number generator to
			AND #$03			; | determine new y speed
			TAY				; |
			LDA YSpeeds,y			; |
							; |
.Store							; |
			STA !RAM_SpriteSpeedY,x		;/
			LDY !15B8,X			;\ change x speed depending on what type of slope sprite is on (?)
			INY #3				; |
			LDA XSpeeds,y			; |
			CLC				; |
			ADC !RAM_SpriteSpeedX,x		;/
			BPL CODE_03807E			; if sprite going to the left, branch
			CMP #!MaxLeftwardSpeed		;\ if sprite x speed slower than #$E0,
			BCS CODE_038084			; |
			LDA #!MaxLeftwardSpeed		; | load #$E0,
			BRA CODE_038084			;/ 
CODE_03807E:
			CMP #!MaxRightwardSpeed		;\ if sprite x speed slower than #$20,
			BCC CODE_038084			; |
			LDA #!MaxRightwardSpeed		;/ load #$20,
CODE_038084:
			STA !RAM_SpriteSpeedX,X		; and set new sprite x speed (to prevent sprite from going slower than #$20 or #$E0)

NoFlipDir:			;

;.Mathmatics

;JSL OtherStuff			;kinda on't want to mess with RTS/RTL, there are JMLs so i'm a little worried
PLB
BRA OtherStuff
;RTL

RemoveAttach:
    LDY !Slot,x             ;maybe LDA : TAY is for long adresses, but this isn't long, so yeah
    LDA #$00
    STA !14C8,y
    RTL

OtherStuff:
    LDY !Slot,x             ;\ Retrieve slot of the other sprite.
    ;tay                     ;/
    
    lda !14C8,y             ;\ If the sprite died, kill this one too.
    BNE CheckState          ;/

;here's a catch - even though it's set to not despawn offscreen, it can still despawn if it's too low offscreen (in the pit basically), so we still want to check for offscreen. in case the sprite is supposed to slowly rotate towards bottom and despawn but still able to respawn afterwards.
    lda !15A0,y             ;\ If it's offscreen, assume it was killed by SubOffScreen().
    ora !186C,y             ;| (This still allows powerups to respawn if grabbed offscreen, for example, but still better than nothing).
    beq Kill                ;/

;only way to kill this specific sprite is despawning offscreen (okay, there's also killing attached sprite/grabbing it, however this sprite doesn't need to respawn), so this is unecessary (as offscreen already sets sprite to respawn)
AllowRespawn:
    lda !161A,x             ;\
    tax                     ;|
    lda #$00                ;| Kill the sprite but allow it to respawn.
    sta !1938,x             ;|
    ldx $15E9|!Base2        ;|
    stz !14C8,x             ;/
    RTL

Kill2:
    lda #$00                ;\ Re-enable object interaction.
    sta !15DC,y             ;/

    LDA !ProcessOffScreenBit,x		;if the sprite is originally supposed to not despawn offscreen
    BNE Kill				;don't reset the bit

    LDA !167A,y				;allow to despawn offscreen
    EOR #$04				;(since we set this bit EOR clears it)
    STA !167A,y				;

Kill:
    stz !14C8,x
    lda #$FF                ;\ Make it not respawn.
    sta !161A,x             ;/
    rTL

CheckState:
    cmp #$02                ;\
    bcc Alive               ;| If the sprite is dead, kill this one too.
    cmp #$07                ;|
    bcc Kill                ;/

    cmp #$0B                ;\
    beq Kill2               ;| If Mario or Yoshi grabbed the sprite,
    cmp #$07                ;| make it interact with objects and kill this sprite.
    beq Kill2               ;/

    lda !15D0,y             ;\ If on Yoshi's tongue, kill
    bne Kill2               ;/ (but make it interact with objects again).

    ldx #!SprSize-1         ;\
-   lda !14C8,x             ;|
    cmp #$08                ;|
    bcc +                   ;|
    lda !9E,x               ;|
    cmp #$2D                ;|
    bne +                   ;| If the sprite is being eaten by Baby Yoshi, kill.
    tya                     ;|
    cmp !160E,x             ;|
    bne +                   ;|
    ldx $15E9|!Base2        ;|
    bra Kill                ;|
+   dex                     ;|
    bpl -                   ;|
    ldx $15E9|!Base2        ;/

Alive:
    lda.w !9E,y             ;\
    cmp #$35                ;| If it's Yoshi and he's not idle anymore,
    bne +                   ;| kill this sprite and enable object interaction for Yoshi.
    lda.w !C2,y             ;|
    bne Kill2               ;/
+
    lda $14AE|!Base2        ;\
    beq +                   ;|
    lda !190F,y             ;|
    and #$40                ;|
    bne +                   ;|
    lda.w !9E,y             ;| If the silver switch is active and the sprite is not a silver coin,
    cmp.b #read1($02B9DA)   ;| turn it into a silver coin (if the tweaker is not set).
    bne ++                  ;| This both fixes the issue where sprites spawned in the
    lda !15F6,y             ;| 2 highest slots don't turn into silver coins, and
    and #$02                ;| the issue where spawning after hitting the switch
    bne +                   ;| wouldn't make it spawn as a silver coin.
++  phk                     ;|
    pea.w .jslrtsreturn-1   ;|
    pea.w $02B889-1         ;|
    jml $02B9D9|!BankB      ;|
.jslrtsreturn               ;/

+   lda !Settings,x         ;\ If sprite not set to move Mario with it, skip.
    and #$60                ;|
    beq ++                  ;/
    lda $1491|!Base2        ;\ Store how much the sprite moved horizontally
    sta !1528,y             ;/ in the other sprite's table.
    bit !Settings,x         ;\ If not using the p option, skip running vanilla solid sprite routine.
    bvc ++                  ;/
    phy                     ; Backup Y.
    tyx                     ; Switch to other sprite.
    jsl $01B44F|!BankB      ; Run "Solid sprite" routine.
    stz !1528,x             ; Make sure Mario's position isn't updated twice.
    stz !sprite_speed_x,x   ;\ Reset other sprite's speeds.
    stz !sprite_speed_y,x   ;/ This reduced the jank with some horizontal moving platforms.
    stz !sprite_speed_x_frac,x  ;\ Also reset the fraction bits for good measure.
    stz !sprite_speed_y_frac,x  ;/
    lda !9E,x               ;\
    cmp #$BB                ;| Dumb fix for the grey castle block.
    bne +                   ;|
    stz !C2,x               ;/
+   ply                     ; Restore Y.
    ldx $15E9|!Base2        ; Restore X.
    stz $1491|!Base2
++
Offset:
    stz $00                 ;\
    lda !XOffset,x          ;|
    bpl +                   ;|
    dec $00                 ;|
+   clc                     ;| Offset the sprite horizontally.
    adc !E4,x               ;|
    sta.w !E4,y             ;|
    lda !14E0,x             ;|
    adc $00                 ;|
    sta !14E0,y             ;/

    stz $00                 ;\
    lda !YOffset,x          ;|
    bpl +                   ;|
    dec $00                 ;|
+   clc                     ;| Offset the sprite vertically.
    adc !D8,x               ;|
    sta.w !D8,y             ;|
    lda !14D4,x             ;|
    adc $00                 ;|
    sta !14D4,y             ;/
    rtl