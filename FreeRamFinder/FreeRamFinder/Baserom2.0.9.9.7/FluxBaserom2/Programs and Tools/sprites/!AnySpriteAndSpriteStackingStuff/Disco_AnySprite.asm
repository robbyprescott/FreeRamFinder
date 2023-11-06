;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Disco Any Sprite by dtothefourth
;
; Acts as a wrapper for any normal or custom sprite, allowing
; it to easily be made to move like a disco shell vertically
; and/or horizontally
;
; Extra bit: if set, the spawned sprite is custom.
;
; Options are set using the extension box in LM using 4 bytes
;
; SS XX YY CC
; 
; SS = Sprite number
; XX = Horizontal disco speed (00 = not applied)
; YY = Vertical disco speed (00 = not applied)
; CC = Custom settings.
;  - EXYOSSSS - The 8 bits of the number are broken into different settings
;  - The last 4 bits (S) are the state the sprite will spawn in ($14C8 format)
;    (0 acts as 1 because state 0 doesn't make sense here)
;    State 1 (set with either 0 or 1) is init, which is what you usually want
;    State 9 is carryable, useful for sprites like shells or throwblocks
;  - The highest bit (E), if set (i.e. add 80 to the number), 
;       will set the extra bit for the spawned sprite
;
;  - The remaining 3 bits (XYO) set the bounce settings
;       If X is 0, the disco bounce will not happen horizontally
;       If X is 1 and the spawned sprite has object interaction set,
;           it will bounce off walls horizontally like a disco shell
;
;       If Y is 0, the disco bounce will not happen vertically
;       If Y is 1 and the spawned sprite has object interaction set,
;           it will bounce off walls vertically
;
;       If O is 1, the X or Y bounces that are set will occur even if
;           the sprite doesn't have object interaction enabled
;      
;
; Note:
;  - To spawn a Shell, don't use numbers DA-DF. Use instead 04-09,
;    and set the state as carryable (extra byte 4 = 09)
;  - To spawn a throw block, use sprite number 53 and spawn it in
;    carryable state (or it won't appear)
;  - To spawn a P-Switch, use 0 or 1 for extra byte 4 or its color will be wrong
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
    STZ !151C,x

    STZ $05
    PHX
    DEX
    -
    LDA !14C8,x
    BNE +
    INC $05
    BRA ++
    +
    DEX
    BPL -
    ++
    PLX

    ;try to force sprite into a lower slot
    LDA $05
    BEQ +

    CPX #!SprSize-1
    BEQ +
    PHX
    INX
    -
    LDA !14C8,x
    BNE ++
    LDA #$FF
    STA !14C8,x
    ++
    INX
    CPX #!SprSize
    BNE -
    PLX

    +


    LDA !extra_byte_1,x
    STA $04

    stz $00
    stz $01
    stz $02
    stz $03
    lda !extra_bits,x       ;\
    and #$04                ;| Extra bit set = custom
    lsr #3                  ;/

    LDA $04
    %SpawnSprite()
    bcc +                   ;\
    stz !14C8,x             ;| If spawn failed, kill the sprite.
    rtl                     ;/
+   
    tya
    sta !1504,x
    
    LDA !extra_byte_4,x
    and #$0F                ;| Set the sprite state
    beq +                   ;|
    sta !14C8,y             ;/
+
    LDA !extra_byte_4,x
    bpl +                   ;|
    tyx                     ;|
    lda !extra_bits,x       ;| Set the extra bit
    ora #$04                ;|
    sta !extra_bits,x       ;|
    ldx $15E9|!Base2        ;/
+

    LDA !1656,y
    AND #$0F
    STA $00

    LDA !1656,x
    AND #$F0
    ORA $00
    STA !1656,x

    LDA !167A,y
    AND #$04
    STA $00

    LDA !167A,x
    AND #$FB
    ORA $00
    STA !167A,x


    ;restore sprite slots
    LDA $05
    BEQ +

    CPX #!SprSize-1
    BEQ +

    PHX
    INX
    -
    LDA !14C8,x
    CMP #$FF
    BNE ++
    STZ !14C8,x
    ++
    INX
    CPX #!SprSize
    BNE -
    PLX

    +
    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


print "MAIN ",pc
    phb : phk : plb : jsr Main : plb
    rtl


Main:
    lda $9D
    beq +
    rts
    +

    lda !1504,x
    tay
    
    lda !14C8,y
    bne CheckState

    JSR GetDraw
    LDA !15A0,x
    ORA !186C,x
    BEQ Kill

    LDY !161A,x          
    CPY #$FF             
    BEQ Kill             

    PHX
    TYX
    LDA #$00
if !Disable255SpritesPerLevel
    STA !1938,x
else
    STA.L !7FAF00,x
endif			
    PLX
    stz !14C8,x
    rts

GetDraw:
    %GetDrawInfo()
    rts

Kill:
    stz !14C8,x
    lda #$FF            ;\ Make it not respawn.
    sta !161A,x         ;/
    rts

CheckState:
    cmp #$02            ;\
    bcc Alive           ;| If the sprite is dead, kill this one too.
    cmp #$07            ;|
    bcc Kill            ;/

    cmp #$0B            ;\
    beq Kill           ;| If Mario or Yoshi grabbed the sprite,
    cmp #$07            ;|  kill this sprite.
    beq Kill           ;/

    lda !15D0,y         ;\ If on Yoshi's tongue, kill.
    bne Kill           ;/

    ldx #!SprSize-1     ;\
-   lda !14C8,x         ;|
    cmp #$08            ;|
    bcc +               ;|
    lda !9E,x           ;|
    cmp #$2D            ;|
    bne +               ;| If the sprite is being eaten by Baby Yoshi, kill.
    tya                 ;|
    cmp !160E,x         ;|
    bne +               ;|
    ldx $15E9|!Base2    ;|
    bra Kill            ;|
+   dex                 ;|
    bpl -               ;|
    ldx $15E9|!Base2    ;/

Alive:
    lda.w !9E,y         ;\
    cmp #$35            ;| If it's Yoshi and he's not idle anymore,
    bne +               ;| kill this sprite
    lda.w !C2,y         ;|
    bne Kill           ;/
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
+

    LDA !1686,x
    AND #$7F
    STA $00

    LDA !extra_byte_4,x
    BIT #$10
    BNE +

    LDA !1686,y
    AND #$80
    ORA $00
    STA !1686,x
    +


    LDA !1504,x
    TAY



    ;Run X routines
    LDA !extra_byte_2,x
    BEQ +

    STA $00
    EOR #$FF
    INC
    STA $01

    %SubHorzPos()			;face player. always.
    TYA				;
    STA !157C,x

    JSR DiscoX
    
    +

    
    ;Run Y routines
    LDA !extra_byte_3,x
    BEQ +

    STA $00
    EOR #$FF
    INC
    STA $01

    %SubVertPos()
    TYA				
    STA !1602,x    

    JSR DiscoY
    
    +

    ;Move wrapper with sprite
    lda.w !E4,y
    sta !E4,x
    lda !14E0,y
    sta !14E0,x

    lda.w !D8,y
    sta !D8,x
    lda !14D4,y
    sta !14D4,x


    rts


DiscoX:

    LDA !B6,x			;disassembled some code from disco shell
    LDY !157C,x			;
    BNE .NoRightSpeed		;
    CMP $00		;if hit maximum right speed
    BPL .NoMoreSpeed		;don't increase speed.

    INC !B6,x			;increase X-speed
    INC !B6,x			;twice
    BRA .NoMoreSpeed		;jump over some code

    .NoRightSpeed
    CMP $01		;if hit max left speed
    BMI .NoMoreSpeed		;don't decrease
    DEC !B6,x			;decrease X-speed
    DEC !B6,x			;twice

    .NoMoreSpeed

    REP #$20
    LDA $00
    PHA
    SEP #$20

    JSL $018022|!BankB

    REP #$20
    PLA
    STA $00
    SEP #$20

    LDA !extra_byte_4,x
    BIT #$40
    BEQ +
    BIT #$10
    BNE ++

    LDA !1686,x
    BMI +

    ++

    REP #$20
    LDA $00
    PHA
    SEP #$20

    JSL $019138|!BankB

    REP #$20
    PLA
    STA $00
    SEP #$20

    LDA !1588,x
    AND #$03
    BEQ +


    LDA #$01			;hit sound effect
    STA $1DF9|!Base2		;


    LDA !1588,x
    AND #$03
    LSR
    EOR #$01
    TAY
    LDA $00,y
    STA !B6,x

    LDA !1504,x
    TAY

    LDA !15A0,y			;if offscreen, don't trigger bounce sprite
    BNE .NoBlockHit			

    LDA !E4,x			
    SEC : SBC $1A			
    CLC : ADC #$14			
    CMP #$1C			
    BCC .NoBlockHit			

    LDA !1588,x			
    AND #$40			
    ASL #2				
    ROL				
    AND #$01			
    STA $1933|!Base2		

    LDY #$00			
    LDA $18A7|!Base2		
    JSL $00F160|!BankB		

    LDA #$05			
    STA !1FE2,x			

    .NoBlockHit

    +

    LDA !1504,x
    TAY

    lda !E4,x
    sta.w !E4,y
    lda !14E0,x
    sta !14E0,y

    LDA #$00
    STA !B6,y

    LDA !B6,x
    BPL ++
    LDA #$01
    STA !157C,y
    BRA +++
    ++
    LDA #$00
    STA !157C,y
    +++


    RTS

DiscoY:


    LDA !AA,x			;disassembled some code from disco shell
    LDY !1602,x			;
    BNE .NoRightSpeed		;
    CMP $00		;if hit maximum right speed
    BPL .NoMoreSpeed		;don't increase speed.

    INC !AA,x			;increase X-speed
    INC !AA,x			;twice
    BRA .NoMoreSpeed		;jump over some code

    .NoRightSpeed
    CMP $01		;if hit max left speed
    BMI .NoMoreSpeed		;don't decrease
    DEC !AA,x			;decrease X-speed
    DEC !AA,x			;twice

    .NoMoreSpeed

    REP #$20
    LDA $00
    PHA
    SEP #$20

    JSL $01801A|!BankB

    REP #$20
    PLA
    STA $00
    SEP #$20

    LDA !extra_byte_4,x
    BIT #$20
    BEQ +
    BIT #$10
    BNE ++

    LDA !1686,x
    BMI +

    ++


    REP #$20
    LDA $00
    PHA
    SEP #$20

    JSL $019138|!BankB

    REP #$20
    PLA
    STA $00
    SEP #$20

    LDA !1588,x
    AND #$0C
    BEQ +


    LDA #$01			;hit sound effect
    STA $1DF9|!Base2		;


    LDA !1588,x
    AND #$0C
    LSR #3
    EOR #$01
    TAY
    LDA $00,y
    STA !AA,x
    
    LDA !1504,x
    TAY

    LDA !15A0,y			;if offscreen, don't trigger bounce sprite
    BNE .NoBlockHit			

    LDA !E4,x			
    SEC : SBC $1A			
    CLC : ADC #$14			
    CMP #$1C			
    BCC .NoBlockHit			

    LDA !1588,x			
    AND #$40			
    ASL #2				
    ROL				
    AND #$01			
    STA $1933|!Base2		

    LDY #$00			
    LDA $18A7|!Base2		
    JSL $00F160|!BankB		

    LDA #$05			
    STA !1FE2,x			

    .NoBlockHit

    +

    LDA !1504,x
    TAY

    lda !D8,x
    sta.w !D8,y
    lda !14D4,x
    sta !14D4,y

    LDA #$00
    STA !AA,y

    RTS 
