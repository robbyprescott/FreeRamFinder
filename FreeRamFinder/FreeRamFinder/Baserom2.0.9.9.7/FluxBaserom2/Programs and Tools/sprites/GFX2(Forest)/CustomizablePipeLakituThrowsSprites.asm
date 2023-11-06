;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pipe Lakitu disassembly
; By nekoh
; Custom version by KevinM v1.1
;
; Extra bit: if set, the sprite thrown is custom.
; Extra byte 1: sprite number of the thrown sprite.
; Extra byte 2: sprite state of the thrown sprite (00 defaults to 01 (init).)
;      Usually you want either 01 or 08, but for carryable sprite you want 09 or 0A.
; Extra byte 3: X speed of the thrown sprite (vanilla = 10)
; Extra byte 4: Y speed of the thrown sprite (vanilla = D8)
;
; Note: to spawn a shell, don't use sprite number DA-DF, but rather 04-09 and use 09 or 0A for the state.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; How many pixels away the sprite can see Mario (and freeze in place), from the left and right respectively.
; Set both at $00 to make it ignore proximity.
!ProximityRangeLeft  = $13
!ProximityRangeRight = $23

; 1 = throw silver coins when the silver P-Switch is active
!ThrowCoinsWhenSilverPActive = 1

; Brief timer set when throwing a carryable/kicked sprite to avoid it killing the Lakitu.
; You can set it to 0 if you want a "one time use shell dispenser" or something, I guess.
!DisableSpriteInteractionTimer = $08

; GFX stuff
!ThrowTile  = $A8   ; Head tile when throwing something
!WatchTile  = $EC   ; Head tile when looking around
!DeathTile  = $CE   ; Head tile when dead and falling down
!BottomTile = $EE   ; Body tile

; Other stuff
!LookAroundPhaseTimer = $90 ; How long the "rise-look around" phase lasts.
!RiseBeforeLookTimer  = $7C ; Lakitu will rise the first time when !LookAroundPhaseTimer reaches this value.
!LookAroundTimer      = $50 ; Lakitu will look around when !LookAroundPhaseTimer reaches this value.
!RiseBeforeThrowTimer = $0C ; How long the rise after looking around lasts.
!ThrowPhaseTimer      = $80 ; How long the "throw" phase lasts.
!ThrowTimer           = $40 ; Lakitu will throw when !ThrowPhaseTimer reaches this value.
!ThrowPoseTimer       = $20 ; How long the throw pose lasts.
!AfterThrowDwellTimer = $50 ; How long Lakitu stays under before rising again.

!LookAroundFrequency  = $20 ; How frequently Lakitu switches directions while looking around.
							; Valid values: $01,$02,$04,$08,$10,$20,$40,$80 (lower = faster).

!RiseSpeed  = $F8
!DwellSpeed = $08

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ",pc
                    LDA !E4,X                 ; \ Center sprite between two tiles 
                    CLC                       ;  | 
                    ADC #$08                  ;  | 
                    STA !E4,X                 ; / 
                    lda !14E0,x    ;\
                    adc #$00       ;| Avoid screen wraps (why wasn't this here before??)
                    sta !14E0,x    ;/
                    DEC !D8,X       
                    LDA !D8,X       
                    CMP #$FF                
                    BNE Return0185C2          
                    DEC !14D4,X     
Return0185C2:       RTL                       


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                           
                    print "MAIN ",pc
                    PHB                       
                    PHK                       
                    PLB                             
                    JSR PipeLakitu         
                    PLB                       
                    RTL                       ; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PipeLakitu:         LDA !14C8,X             
                    CMP #$02                
                    BNE CODE_02E94C           
                    LDA #$02                
                    STA !1602,X             
                    JMP CODE_02E9EC         

CODE_02E94C:        JSR CODE_02E9EC         
                    LDA $9D     
                    BNE Return02E985          
                    STZ !1602,X
                    %SubOffScreen()
                    JSL $01803A|!BankB
                    LDA !C2,X     
                    JSL $0086DF|!BankB          

PipeLakituPtrs:     dw CODE_02E96D           
                    dw CODE_02E986           
                    dw CODE_02E9B4           
                    dw CODE_02E9BD           
                    dw CODE_02E9D5           

CODE_02E96D:        LDA !1540,X             
                    BNE Return02E985  
               if !ProximityRangeLeft || !ProximityRangeRight
                    %SubHorzPos()
                    TYA
                    LDA $0E                   
                    CLC                       
                    ADC.b #!ProximityRangeLeft
                    CMP.b #!ProximityRangeLeft+!ProximityRangeRight
                    BCC Return02E985          
               endif
                    LDA.b #!LookAroundPhaseTimer
CODE_02E980:        STA !1540,X             
                    INC !C2,X     
Return02E985:       RTS                       ; Return 

CODE_02E986:        LDA !1540,X             
                    BNE CODE_02E996           
                    
                    %SubHorzPos()
                    TYA                       
                    STA !157C,X
                    wowie2:
                    LDA.b #!RiseBeforeThrowTimer
                    BRA CODE_02E980

CODE_02E996:        CMP.b #!RiseBeforeLookTimer
                    BCC CODE_02E9A2
CODE_02E99A:
                    %SubHorzPos()
                    TYA
                    STA !157C,X

                    LDA.b #!RiseSpeed               
CODE_02E99C:        STA !AA,X    
                    JSL $01801A|!BankB   
                    RTS                       ; Return 

CODE_02E9A2:        CMP.b #!LookAroundTimer
                    BCS Return02E9B3
                    LDY #$00
                    LDA $13
                    AND.b #!LookAroundFrequency
                    BEQ CODE_02E9AF
                    INY
CODE_02E9AF:        TYA
                    STA !157C,X
Return02E9B3:       RTS                       ; Return 

CODE_02E9B4:        LDA !1540,X
                    BNE CODE_02E99A
                    LDA.b #!ThrowPhaseTimer
                    BRA CODE_02E980

CODE_02E9BD:        LDA !1540,X
                    BNE CODE_02E9C6
                    LDA.b #!ThrowPoseTimer
                    BRA CODE_02E980

CODE_02E9C6:        CMP.b #!ThrowTimer
                    BNE CODE_02E9CF

     stz $00
     stz $01
     %SubHorzPos()
     phy
     lda !extra_byte_3,x
     cpy #$00
     beq +
     eor #$FF
     inc
+    sta $02
     lda !extra_byte_4,x
     sta $03
     lda.b #!SprSize-3
     sta $04
if !ThrowCoinsWhenSilverPActive
     lda $14AE|!addr
     beq +
     lda #$21
     clc
     bra ++
endif
+    lda !extra_bits,x
     lsr #3
     lda !extra_byte_1,x
++   %SpawnSpriteSafe()
     pla
     bcs .return
     sta !157C,y
if !ThrowCoinsWhenSilverPActive
     lda $14AE|!addr
     beq +
     lda #$02
     sta !15F6,y
     lda #$08
     sta !14C8,y
     rts
endif
+    lda !extra_byte_2,x
     bne +
     lda #$01
+    sta !14C8,y
     cmp #$09
     beq +
     cmp #$0A
     bne .return
+    lda #!DisableSpriteInteractionTimer
     sta !1564,x

; You can add code here to do something with the spawned sprite
; (set extra bytes, etc.). Slot in Y.

.return

                    RTS                       ; Return 

CODE_02E9CF:        BCS Return02E9D4          
                    INC !1602,X             
Return02E9D4:       RTS                       ; Return 

CODE_02E9D5:        LDA !1540,X             
                    BNE CODE_02E9E2

                    LDA.b #!AfterThrowDwellTimer
                    JSR CODE_02E980
                    STZ !C2,X
                    RTS                       ; Return 

CODE_02E9E2:        LDA.b #!DwellSpeed               
                    JMP CODE_02E99C           

PipeLakitu1:        db !WatchTile,!ThrowTile,!DeathTile

CODE_02E9EC:        %GetDrawInfo()       
                    LDA $00                   
                    STA $0300|!Base2,Y         
                    STA $0304|!Base2,Y    
                    LDA $01                   
                    STA $0301|!Base2,Y         
                    CLC                       
                    ADC #$10                
                    STA $0305|!Base2,Y    
                    PHX                       
                    LDA !1602,X             
                    TAX                       
                    LDA PipeLakitu1,X       
                    STA $0302|!Base2,Y          
                    LDA #!BottomTile      
                    STA $0306|!Base2,Y         
                    PLX                       
                    LDA !157C,X     
                    LSR                       
                    ROR                       
                    LSR                       
                    EOR #$50
                    ora !15F6,x              
                    STA $0303|!Base2,Y          
                    STA $0307|!Base2,Y     
                    LDA #$01                
                    LDY #$02                
                    JSL $01B7B3|!BankB      
                    RTS                       ; Return
