;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
; Custom Falling Spike - by dtothefourth
;
; Falling spike that can go in all 4 directions and interact
; with objects
;
; Uses 4 Extra Bytes, set in Extension Box in LM as follows
;
;   SD SH TT SP
;       SD
;           S = Size - 1 (1-8 tiles)
;           D = Direction - 0 Down, 1 Right, 2 Up, 3 Left
;       SH = Shake Time (Vanilla 40)
;       TT = Trigger Distance (Vanilla 40)
;       SP = Max Speed (Vanilla 40)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!ShakeTime   = !extra_byte_2,x ; How long to shake before falling 
!TriggerDist = !extra_byte_3,x ; How close Mario has to be to trigger (0-7F)
!MaxSpeed    = !extra_byte_4,x ; Maximum speed spike can fall (0-7F)
!Accel       = $03 ; How quickly spike accelerates while falling

!Collide     = 0 ; If 1, will hit objects instead of falling through them
!Activate    = 1 ; If 1 and collide is set will activate blocks like hitting them with a shell

!FarDespawn  = 1 ; If 1 don't despawn unless far off screen, mostly if you want to use really wide spikes
!WideTrigger = 1 ; If 1 for multi tile spikes check both ends for trigger distance

;Tile to draw, vertical and horizontal
Tiles:
    db $E0, $8A  ; SJC changed from 80




Dir:
    db $04,$01,$08,$02

XOff:
    dw $0000,$0010,$0000,$0000

YOff:
    dw $0010,$0000,$0000,$0000

print "INIT ",pc
    if !Collide
    LDA !1686,x
    AND #$7F
    STA !1686,x
    endif

    LDA !TriggerDist
    ASL
    STA !1510,x

    LDA !MaxSpeed
    EOR #$FF
    INC
    STA !151C,x

    LDA !extra_byte_1,x
    AND #$7F
    STA !extra_byte_1,x

    LDA !extra_byte_1,x
    AND #$F0
    LSR #4
    STA !1534,x

    LDA !extra_byte_1,x
    AND #$0F
    PHX
    TAX
    LDA.L Dir,x
    PLX
    STA !1528,x

    LDA !extra_byte_1,x
    AND #$02
    BEQ NoFlip
    LDA !15F6,x
    ORA #$C0
    STA !15F6,x
    NoFlip:

    LDA !extra_byte_1,x
    AND #$01
    BNE +
    LDA !D8,x
    SEC
    SBC #$01
    STA !D8,x
    LDA !14D4,x
    SBC #$00
    STA !14D4,x
    +

    RTL


print "MAIN ",pc
    PHB                       
    PHK                       
    PLB                                 
    JSR SprMain        
    PLB                       
    RTL


SprMain:       
    JSR Graphics
    
        
    LDA $9D     
    BEQ +
    RTS 
    +


    if !FarDespawn
    LDA !14E0,x
    XBA
    LDA !E4,x
    REP #$20
    SEC
    SBC $1A
    CLC
    ADC #$0100
    CMP #$0300
    SEP #$20
    BCC +
    STZ !14C8,x
    PHX
    LDA !161A,x
    TAX
    LDA #$00
    STA !1938,x
    PLX
    +
    LDA !14D4,x
    XBA
    LDA !D8,x
    REP #$20
    SEC
    SBC $1C
    CLC
    ADC #$0100
    CMP #$0300
    SEP #$20
    BCC +
    STZ !14C8,x
    PHX
    LDA !161A,x
    TAX
    LDA #$00
    STA !1938,x
    PLX
    +
    else
    LDA #$04
    %SubOffScreen() 
    endif

    JSL $01801A
    JSL $018022      
    LDA !C2,x     
    BNE Falling       
print "waiting ",pc
Waiting:
    STZ !B6,x
    STZ !AA,x

    STZ $00
    STZ $01
    JSR DistCheck

    if !WideTrigger
    LDA !C2,x
    BNE +

    LDA !extra_byte_1,x
    AND #$F0
    BEQ +
    STA $00
    STZ $01
    JSR DistCheck
    +
    endif
    RTS

DistCheck:
    LDA !extra_byte_1,x
    AND #$01
    BNE VertCheck

    %SubHorzPos()
    REP #$20
    LDA $0E
    SEC
    SBC $00
    STA $0E
    SEP #$20
    -
    LDA $0F
    INC
    CMP #$02
    BCS +   
    REP #$20
    LDA $0E
    BPL ++
    EOR #$FFFF
    INC
    ++
    SEP #$20                 
    CMP !TriggerDist
    BCS +          
    BRA Fall

VertCheck:
    LDA !14D4,x
    XBA
    LDA !D8,x
    REP #$20
    SEC
    SBC $96
    CLC
    ADC $00
    STA $0E
    BPL ++
    EOR #$FFFF
    INC
    ++
    SEP #$20
    BRA -

Fall:
    INC !C2,x     
    LDA !ShakeTime           
    STA !1540,x   
    RTS          
    +



    RTS

Falling:          					
    LDA !1540,x             
    BEQ +
    STZ !B6,x
    STZ !AA,x
    RTS
    +

    LDA !extra_byte_1,x
    AND #$F0
    BNE +
    JSL $01A7DC|!BankB
    BRA ++
    +
    JSR WideHit
    ++

    if !Collide


    JSL $019138|!BankB
     
    
    LDA !1588,x
    AND !1528,x
    BEQ +
    LDA #$0A
    STA !14C8,x

    if !Activate
    JSR HitBlock
    endif

    STZ !14C8,x

    LDA !186C,x
    ORA !15A0,x
    BNE ++

    STZ $00 : STZ $01
    LDA #$0C : STA $02
    LDA #$02
    %SpawnSmoke() 

    ++
    RTS
    +
    endif
    
    LDA !extra_byte_1,x
    AND #$0F
    JSL $0086DF|!BankB       

    dw FallDown         
    dw FallRight 
    dw FallUp
    dw FallLeft

FallDown:
    LDA !AA,x
    CMP !MaxSpeed
    BCC +
    LDA !MaxSpeed
    STA !AA,x
    RTS
    +

    CLC
    ADC #!Accel
    STA !AA,x				
    RTS

FallUp:
    LDA !AA,x
    CMP !151C,x
    BCS +
    LDA !151C,x
    STA !AA,x
    RTS
    +

    SEC
    SBC #!Accel
    STA !AA,x				
    RTS

FallRight:
    LDA !B6,x
    CMP !MaxSpeed
    BCC +
    LDA !MaxSpeed
    STA !B6,x
    RTS
    +

    CLC
    ADC #!Accel
    STA !B6,x		
    RTS

FallLeft:
    LDA !B6,x
    CMP !151C,x
    BCS +
    LDA !151C,x
    STA !B6,x
    RTS
    +

    SEC
    SBC #!Accel
    STA !B6,x				
    RTS
print "graphics ",pc
Graphics:

    LDA !14E0,x
    XBA
    LDA !E4,x
    REP #$20
    SEC
    SBC $1A
    CMP #$0100
    SEP #$20
    BMI +
    BCC +
    RTS
    +
    LDA !14D4,x
    XBA
    LDA !D8,x
    REP #$20
    SEC
    SBC $1C
    CMP #$00E0
    SEP #$20
    BMI +
    BCC +
    RTS
    + 

    JSR GetDrawInfo

    LDA !15A0,x
    STA $02
    LDA !186C,X
    STA $03



    LDA #$FF
    STA $0F

    PHX
    LDA !1534,x
    TAX

    -

	LDA $00
	STA $0300|!addr,y
	LDA $01
	STA $0301|!addr,y

	PHX
    LDX $15E9|!Base2
    LDA !extra_byte_1,x
    AND #$01
    TAX
	LDA Tiles,x
	STA $0302|!addr,y

    LDX $15E9|!Base2
	LDA !15F6,x
	ORA $64
	STA $0303|!addr,y

    LDA !extra_byte_1,x
    AND #$01
    BEQ +
    INY
    +

    LDA !1540,x             
    BEQ +           
    LSR                       
    LSR                       
    AND #$01                
    CLC                       
    ADC $0300|!Base2,y         
    STA $0300|!Base2,y     
    +

    LDA !extra_byte_1,x
    AND #$01
    BEQ +
    DEY
    +

    INC $0F
    INY #4

    LDA !extra_byte_1,x
    AND #$01
    BEQ +
    PLX
    LDA $01
    CLC
    ADC #$10
    STA $01
    LDA $03
    BNE ++

    BCS +++
    BRA ++
    +
    PLX
    LDA $00
    CLC
    ADC #$10
    STA $00
    LDA $02
    BNE ++ 
    BCS +++
    ++
    DEX
    BPL -

    +++
    PLX

	LDA $0F
	LDY #$02
	JSL $01B7B3|!BankB
    RTS

HitBlock:

    PHX
    LDA !extra_byte_1,x
    AND #$0F
    ASL
    TAX
    REP #$20
    LDA XOff,x
    STA $00
    LDA YOff,x
    STA $02
    SEP #$20
    PLX

    LDA !E4,X                  
    AND #$F0                   
    STA $9A                    
    LDA !14E0,X                             
    STA $9B                    
    LDA !D8,X                  
    AND #$F0                 
    STA $98                    
    LDA $14D4,X              
    STA $99     

    REP #$20
    LDA $9A
    CLC
    ADC $00
    AND #$FFF0
    STA $9A   
    LDA $98
    CLC
    ADC $02 
    AND #$FFF0 
    STA $98
    SEP #$20

    LDA !1588,x          
    AND #$40             
    ASL                  
    ASL                  
    ROL                  
    AND #$01             
    STA $1933|!Base2     

    LDY #$00             
    LDA $1693|!Base2      
    JSL $00F160|!BankB    
    RTS

WideHit:



    JSL $03B664|!BankB
    JSL $03B69F|!BankB
    
    LDA !extra_byte_1,x
    AND #$01
    BEQ +

    LDA !extra_byte_1,x
    AND #$F0
    CLC
    ADC $07
    STA $07

    BRA ++
    +

    LDA !extra_byte_1,x
    AND #$F0
    CLC
    ADC $06
    STA $06

    ++


    JSL $03B72B|!BankB
    BCC NoContact

    LDA $7D
    BMI ++

    LDA $140D|!Base2
    BNE +
    ++
    JSL $00F5B7|!BankB
    BRA NoContact
    +

    LDA $15		
    AND #$80	
    BEQ BounceLow
    LDA #$A8	
    STA $7D		
    BRA Sound	
BounceLow:
    LDA #$C0	
    STA $7D		
Sound:
    LDA #$02	
    STA $1DF9|!Base2
    JSL $01AB99|!BankB
NoContact:
    RTS

GetDrawInfo:
STZ !186C,x
   LDA !14E0,x
   XBA
   LDA !E4,x
   REP #$20
   SEC : SBC $1A
   STA $00
   CLC
   ADC.w #$0040
   CMP.w #$0180
   SEP #$20
   LDA $01
   BEQ +
     LDA #$01
   +
   STA !15A0,x
   ; in sa-1, this isn't #$000
   ; this actually doesn't matter
   ; because we change A and B to different stuff
   TDC
   ROL A
   STA !15C4,x

   LDA !14D4,x
   XBA
   LDA !190F,x
   AND #$20
   BEQ .CheckOnce
.CheckTwice
   LDA !D8,x
   REP #$21
   ADC.w #$001C
   SEC : SBC $1C
   SEP #$20
   LDA !14D4,x
   XBA
   BEQ .CheckOnce
   LDA #$02
.CheckOnce
   STA !186C,x
   LDA !D8,x
   REP #$21
   ADC.w #$000C
   SEC : SBC $1C
   SEP #$21
   SBC #$0C
   STA $01
   XBA
   BEQ .OnScreenY
   INC !186C,x
.OnScreenY
   LDY !15EA,x
   RTS