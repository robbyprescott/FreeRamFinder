;; SMM2 Rotten Mushroom by Abdu
;; C3 Release.
;; If the Extra Bit is set then the poison mushroom will have a parachute
;;
;; Extra Byte 1:
;; 00 Normal
;; 01 Wings
;; any other values will result in a crash.
;; 
;; Extra Byte 2: (Only used when Extra Byte 1 is 1)
;; 00 Fly Horizontally
;; 01 Fly vertically
;; any other values will result in a crash.
;; 
;; Extra Byte 3: (Only used when Extra Byte 1 is 1)
;; For Horizontal Movement:
;; 00 Fly towards the player when spawned.
;; 01 Fly towards the left.
;; 02 Fly towards the left then right.
;; 03 Fly towards the right.
;; 04 Fly towards the right then left.
;; 05 Fly back and forth first it flies towards the player then goes back to the opposite direction.
;; weird stuff will happen if you have any other values

;; For Vertical Movement:
;; 00 Will Fly up if the player is on the left of the sprite when the sprite is spawned, and will fly down the player is on the right when the sprite is spawned. 
;; 01 Fly Up.
;; 02 Fly towards the Up then Down.
;; 03 Fly towards the Down.
;; 04 Fly towards the Down then Up.
;; 05 Fly if the player is on the left of the sprite when the sprite is spawned, the sprite will go up then down if the player is on the right when spawned it will go down then up.
;; weird stuff will happen if you have any other values

;; Coming next Update: 
;; Note Block interaction
;; And purple smoke with the purple skull when it hurts the player, 
;; this will be done using the new version of pixi when its fully released on the site.



;=======Misc sprite tables defines=======
; Don't Change these unless you know what you are doing.
!Stop                   = !1528     ; Flag when set that means the sprite has stopped, used so after the sprite has been stopped we can make the sprite move again after the player has moved away from it !Dist amount of pixels
!SpriteDir              = !157C     ; Contains the current facing direction of the sprite
!Hop                    = !1504     ; 0 = don't hop at all, 1 = sprite needs to hop, 2 = sprite has hopped but make sure it doesn't move horizontally while it is in the air.
; !PauseTimer             = !154C   ; unused timer used to make the sprite move again so whenever the sprite drops off from a ledge and it and lands on the ground this is set and it moves after !PauseTime frames.
!SpawnedinAir           = !160E     ; 
!Type                   = !C2       ; 0 = Normal, 1 = Wings, 2(?) = Parachute  
!MovementType           = !extra_byte_2 ; check (extra byte 2 info)
!FlyType                = !1510     ; check Extra Byte 3 settings.
!Wave                   = !1534
!Timer                  = !1540
!WingAnimation          = !1570

;========================================

;=======Changeable values defines=======
!Dist                   = $10           ; how far away should the player be so the sprite could chace the player again, currently set to be around a tile away
!MaxXSpeed              = $10
!XAcceleration          = $01
!HopSpeed               = $E0           ; Y Speed used when the sprite needs to do a little hop whenever a star is gotten and before the sprite runs away from the player.
!JumpSpeed              = $C9           ; Y Speed when trying to jump over a wall. 
; !YSpeedFromNoteBlock    = $B0         ; will be used
; !PauseTime              = $08         ; not used rn
!HitWithStarPowerSFX    = $13
!Port                   = $1DF9|!Base2
!ExtraBit               = $04

;; When the sprite has wings
!XAccelerationWings     = $01
!MaxXSpeedWings         = $10

;; Y speed for horizontal movement (when Extra Byte 2 = 00).
!HorzYAcceleration      = $01   ; Y Acceleration while the sprite is moving horizontally 
!HorzMaxYSpeed          = $0C   ; Max Y speed while the sprite is moving horizontally 

!XSpeedFreq             = $03   ;\ Frequency for updating X speed and Y speed, must be (powers of 2)-1, $00, $01, $03, etc.
!HorzYSpeedFreq         = $01   ;/

; X speed for vertical movement (when Extra Byte 2 = 01).
!VertXAccelerationWings = $01
!VertMaxXSpeedWings     = $0C

!YAcceleration          = $01   ; Y Acceleration while the sprite is moving horizontally 
!MaxYSpeed              = $10   ; Max Y speed while the sprite is moving horizontally

!VertXSpeedFreq         = $01   ;\ Frequency for updating X speed and Y speed, must be (powers of 2)-1, $00, $01, $03, etc.
!YSpeedFreq             = $03   ;/
!StayAtMaxSpeed         = $20

!PoisonMushroomTile     = $E0     ; Poison Mushroom sprite tile

;; When the sprite has a parachute.
!ParachuteTile          = $E2
!ParachuteTileTilted    = $E6
!ParachutePal           = $06
;=======================================


print "INIT ",pc
    LDA !7FAB10,x       ;\ See if the extra bit is set
    AND #!ExtraBit      ;|
    BEQ +               ;| if not then set the type based on the extra byte
    LDA #$02            ;/ if it is then set the type to be parachute
    BRA ++
    +
    LDA !extra_byte_1,x     ;\
    ++
    STA !Type,x             ;| if there is no wings just face the player
                            ;/
    BEQ +

    LDA !extra_byte_3,x     ;\ Store the fly type
    STA !FlyType,x          ;/
    BEQ +                   ;\ if its 0 then that means it will face the player when spawned
    CMP #$05                ;| same applies with 5
    BEQ  +                  ;/
    LDY #$01                ; Set Y = 1 which means face left
    CMP #$03                ; since we already check for 0 that means anything less than 3 means that we should face left
    BCC ++                  
    DEY                     ; Decrement so now Y = 0 which means face right
    BRA ++
    +
    %SubHorzPos()
    ++
    TYA
    STA !SpriteDir,x
    
    PHB : PHK : PLB
    JSL $01802A|!BankB
    LDA !1588,x                 ;\ check if the sprite is in the air or not
    AND #$04                    ;|
    BNE +
    LDA #$01 : STA !SpawnedinAir,x     ; set flag that we are in the air
    +
    PLB

RTL


print "MAIN ",pc
    PHB : PHK : PLB
    JSR PoisonMushroom
    PLB
RTL

PoisonMushroom:
    JSR Graphics
    LDA !14C8,x
    CMP #$08
    BCC .Ret

    
    LDA !Type,x
	ASL
	TAX
	JSR.w (.Ptrs,x)
    
    .Ret 
RTS
    .Ptrs:
        dw Normal
        dw Wings
        dw Parachute


Normal:
    LDX $15E9|!Base2
    LDA $9D
    BNE .Ret
    LDA !166E,x
    AND #$DF
    STA !166E,x
    JSR NormalMovement
    JSR PlayerInteraction
    ; INC !WingAnimation,x        ; need to increment this so the wings can flap if the wings are set.        ; need to increment this so the wings can flap if the wings are set
    .Ret 
RTS




MaxXSpeed:  db !MaxXSpeed, -!MaxXSpeed
XAcce:      db !XAcceleration, -!XAcceleration

; Don't change these table unless you know what you are doing
Offset:     db $08, -$08
OV:         db $00, $FF, $00                ; Table for overflow (don't change these values at all.)
DirFix:     db $FF,$00
Shift:      db $00,$FE,$02					; how much to push the sprite outside of the wall.

NormalMovement:

    LDA $1490|!Base2                    ;\ check if the player has a star
    BEQ .noStar                        ;/

    LDA !1588,x                         ;\ If sprite is in the air
    AND #$04                            ;|
    BEQ +                               ;/ if we are in the air then just update position, apply gravity and object interaction
    STZ !SpawnedinAir,x
    LDA !Hop,x
    CMP #$01
    BCS ++

    STZ !Hop,x                          ; if on ground then set the hop flag to 0
    +
    %SubHorzPos()
    LDA !SpriteDir,x : STA $00          ; store direction before it got flipped
    TYA : EOR #$01 : STA !SpriteDir,x   ; flip direction so it doesn't go towards the player.
    LDA !SpriteDir,x    ;
    CMP $00
    BEQ ++     

    .Hop
    LDA #$01 : STA !Hop,x
    ++
    JMP .move


    .noStar
    LDA !1588,x                 ;\ check if the sprite is in the air or not
    AND #$04                    ;|
    BNE .onGround               ;/ if we are on the ground then no need to set a flag to know we are in the air.
    LDA !1588,x
    AND #$03
    BEQ .move
    JMP .updatePos              ; dont move and just update position

    .onGround
    STZ !SpawnedinAir,x
    STZ !Hop,x

    LDA !Stop,x                 ;\ check if the sprite is currently stopped
    BNE .checkMove              ;/ if we stopped then check if we can move or not
    
    LDY !SpriteDir,x 
    LDA $94
    PHA
    CLC : ADC Offset,y : STA $94        ;\ set the player position to be 8 pixels more to the left or right depending on the teh sprite facing direction
    LDA $95                             ;/ this is done so the sprite stops aprox 8 pixels ahead of the player depedning on the the direction the sprite is going towards
    PHA
    ADC OV,y : STA $95                  ; add the overflow
    %SubHorzPos()                       ; Now $0E = 16 bit difference beween (Mario X Pos + 8 pixels) - Sprite X Pos.
    PLA : STA $95                       ;\ restore player position
    PLA : STA $94                       ;/

    ; %SubHorzPos()
    ; TYA
    ; STA !SpriteDir,x


    LDA !SpriteDir,x                    ;\ Check the direction the sprite is facing.
    BNE .fromRight                      ;/ if it is approaching the player from the right then branch.

    REP #$20                            ; Need to do this in 16 bit to take into account the high byte.
    LDA $0E                             ;\ If we are approaching from the left
    SEP #$20                            ;|
    BPL .move                           ;| then see if the distance is positive which means we are are still to the left of the player, so keep moving
    BRA .stop                           ;/ else that means we are to the right of the player meaning we need to stop the sprite.

    .fromRight 
    REP #$20
    LDA $0E                             ;\ If we are approaching from the right
    SEP #$20                            ;| then see if the distance is negative which means we are are still to the right of the player, so keep moving
    BMI .move                           ;/ that means we are to the left of the player meaning we need to stop the sprite.
    .stop
    LDA #$01                            ;\ Set sprite is stopped flag 
    STA !Stop,x                         ;/
    STZ !B6,x                           ; straight up zero out the speed. (p.s I could just decelerate the sprite speed but it seems in SMM2 they just stop it)
    BRA .updatePos                      ; jump to the gravity routine

    .checkMove
	LDA !E4,x			    ;\
	SEC					    ;|
	SBC $94				    ;|
	PHA					    ;|
	%SubHorzPos()		    ;| Proxmity check
    TYA                     ;|
    STA !SpriteDir,x        ;| store direction the sprite should have.
	PLA					    ;|
	EOR DirFix,y		    ;|
	CMP #!Dist	            ;| (this should be a little less)
	BMI .updatePos		    ;| if we aren't a 16 pixels away then just keep speed the same
    STZ !Stop,x             ;/ if we are then set the sprite flag stopped to 0 and move the sprite 

    .move        
    JSR movement

    .updatePos
    JSR ShiftSpriteFromWall
    LDA !1588,x
    AND #$08
    BEQ +
    STZ !AA,x
    +
    JSL $01802A|!BankB      ; Apply Gravity and object interaction
    

RTS
movement:
    LDA !SpawnedinAir,x
    BEQ +
    RTS
    +

    LDA !Hop,x
    CMP #$01
    BNE .skip

    LDA !1588,x                         ;\ If sprite is in the air
    AND #$04
    BEQ +    
    LDA #!HopSpeed : STA !AA,x
    LDA #$02 : STA !Hop,x          ; clear hop flag since we just hopped
    +
   - STZ !B6,x
    RTS


    .skip
    LDA !1588,x                         ;\ If sprite is in the air
    AND #$04
    BNE + 

    LDA !Hop,x
    CMP #$02
    BEQ -

    +
    STZ !Hop,x
    LDY !SpriteDir,x        ;\ get sprite facing direction
    BNE .leftSpeed          ;/ if facing left then branch
    
    LDA !1588,x
    BIT #$01
    BEQ .moveRight
    STZ !B6,x
    
    BIT #$04
    BEQ .Ret
    
    LDA #!JumpSpeed
    STA !AA,x
    BRA .Ret
    
    .moveRight
    LDA !B6,x               ;\ Get current speed
    CLC : ADC XAcce,y       ;| add acceleration
    CMP MaxXSpeed,y         ;| check if max speed has been reached
    BPL .keepSpeed          ;| if it has then don't add any more speed and just update X/Y position and apply gravity and block interaction 
    STA !B6,x               ;/ if not update X speed
    BRA .keepSpeed          ; jump over some code

    .leftSpeed

    LDA !1588,x
    BIT #$02
    BEQ .moveLeft

    STZ !B6,x
    BIT #$04
    BEQ .Ret

    LDA #!JumpSpeed
    STA !AA,x
    BRA .Ret
    
    .moveLeft
    LDA !B6,x
    CLC : ADC XAcce,y
    CMP MaxXSpeed,y
    BMI .keepSpeed
    STA !B6,x
    
    .keepSpeed
    LDA !1588,x
    bit #$04
    BEQ .Ret

    LDA !1588,x                 ;\ See if the sprite on layer 2 
	BMI .onLayer2				;/ if it is then branch


	LDA #$00					; if not then set the Y speed to be 0
	LDY !15B8,x				    ; Check if we are on a slope
	BEQ .setYspeed				; if we are not then just set the speed
    .onLayer2
	LDA #$18
    .setYspeed	
	STA !AA,x
	
    .Ret
RTS

; Routine that shifts the sprite out if the wall if it is stuck.
ShiftSpriteFromWall:
    LDA !1588,x     ;\ check direction the sprite is blocked from
	AND #$03        ;| AND that to get an index
    TAY             ;/ store index into Y

	LDA !E4,x       ;\ Get Sprite X position and put that into the high byte
	CLC             ;|
	ADC Shift,y     ;| add the shift to the sprite position
	STA !E4,x       ;/ update x position

	LDA !14E0,x     ;\ Account for any overflow
	ADC OV,y        ;| for the high byte
	STA !14E0,x     ;/
RTS

; noteBlockTable: dw $0111, $0113, $0115, $0116
; .ends
; !noteBlockTableSize = (noteBlockTable_ends-noteBlockTable)-1
; Routine that sets the carry if the sprite is touching a note block from above, clears the carry if not touching.
; not used for now but will be used in the future.
; CheckNoteBlock:

;     LDA !D8,x : CLC : ADC #$10 : STA $98
;     LDA !14D4,x : ADC #$00 : STA $99
;     LDA !E4,x : STA $9A : LDA !14E0,x : STA $9B
;     STZ $1933|!Base2
;     %GetMap16() ; A will have the map16 number both high byte and low byte
;     REP #$20
;     LDY #$07
;     .loop
;     CMP noteBlockTable,y
;     BNE .next
;     SEC
;     BRA .done
;     .next
;     DEY #2 ; two bytes for each entry so decrease by two each time
;     BPL .loop
;     CLC
;     .done
;     SEP #$20
; RTS

Wings:
    LDX $15E9|!Base2
    
    LDA #$00
	%SubOffScreen()

    LDA $9D
    BNE .Ret
    %CapeContact()
    BCC +
    JSR CapeInteraction
    RTS
    +
    JSR WingsMovement
    JSR PlayerInteraction
    INC !WingAnimation,x        ; need to increment this so the wings can flap if the wings are set.        ; need to increment this so the wings can flap if the wings are set
.Ret
RTS

CapeSpinXSpeed:					; X speeds to give sprites hit by quake sprites, capespins, cape smashes, or net punches.
	db $F8,$08

; This routine is needed for whenever the sprite has wings because the vanilla routine makes the sprite get yeeted up in the sky.
; This routine is also called when the sprite has a parachute.
; Routine modified from $0294A2 
CapeInteraction:
	STZ !Type,x			        ; Set the sprite to have no wings or parachute.
	LDA #$C0					;\ Set Y speed				
	STA !AA,X					;/
	%SubHorzPos()			    ;\ 
	LDA CapeSpinXSpeed,y	    ;/ give X speed
	STA !B6,X					;
	TYA							;\ 
	EOR #$01					;| Flip direction the sprite is facing
	STA !SpriteDir,x		    ;/
	RTS							

MaxXSpeedWings:     db !MaxXSpeedWings, -!MaxXSpeedWings
XAcceWings:         db !XAccelerationWings, -!XAccelerationWings

HorzMaxYSpeed:      db -!HorzMaxYSpeed, !HorzMaxYSpeed 
HorzYAcce:          db -!HorzYAcceleration, !HorzYAcceleration 

WingsMovement:
    LDA !MovementType,x
    ASL
	TAX
	JMP.w (.Ptrs,x)
    RTS
    .Ptrs

    dw Horizontal
    dw Vertical


RTS
Horizontal:
    LDX $15E9|!Base2
    LDA $14
    AND #!HorzYSpeedFreq
    BNE +
    LDA !Wave,x
    AND #$01
    TAY
    LDA !AA,x
    CLC : ADC HorzYAcce,y
    CMP HorzMaxYSpeed,y
    STA !AA,x
    BNE +
    INC !Wave,x
    +

    LDY !SpriteDir,x
    LDA !FlyType,x          ;\ I could have done a setup to do this better but its 4AM and I aint feeling it rn 
    BEQ .noTurn             ;|
    CMP #$01                ;|
    BEQ .noTurn             ;|
    CMP #$03                ;|
    BEQ .noTurn             ;/

    LDA $14
    AND #!VertXSpeedFreq
    BNE .skip
    LDA !Timer,x
    BNE .skip
    
    LDA !B6,x
    CLC : ADC XAcceWings,y
    STA !B6,x
    CMP MaxXSpeedWings,y
    BNE .skip
    .switchDir
    TYA : EOR #$01 : STA !SpriteDir,x
    LDA #!StayAtMaxSpeed 
    STA !Timer,x
    BRA .skip

    .noTurn
    LDA MaxXSpeedWings,y
    STA !B6,x
    .skip
    JSL $01801A|!BankB
    JSL $018022|!BankB
RTS

VertMaxXSpeedWings: db !VertMaxXSpeedWings, -!VertMaxXSpeedWings
VertXAcceWings:     db !VertXAccelerationWings, -!VertXAccelerationWings

MaxYSpeed:          db -!MaxYSpeed, !MaxYSpeed 
YAcce:              db -!YAcceleration, !YAcceleration 
Vertical:
    LDX $15E9|!Base2

    LDA $14
    AND #!YSpeedFreq
    BNE +
    LDA !Wave,x
    AND #$01
    TAY
    LDA !B6,x
    CLC : ADC VertXAcceWings,y
    CMP VertMaxXSpeedWings,y
    STA !B6,x
    BNE +
    INC !Wave,x
    +

    LDY !SpriteDir,x
    LDA !FlyType,x          ;\ I could have done a setup to do this better but its 4AM and I aint feeling it rn 
    BEQ .noTurn             ;|
    CMP #$01                ;|
    BEQ .noTurn             ;|
    CMP #$03                ;|
    BEQ .noTurn             ;/

    LDA $14
    AND #!XSpeedFreq
    BNE .skip
    LDA !Timer,x
    BNE .skip
    
    LDA !AA,x
    CLC : ADC XAcceWings,y
    STA !AA,x
    CMP MaxXSpeedWings,y
    BNE .skip
    .switchDir
    TYA : EOR #$01 : STA !SpriteDir,x
    LDA #!StayAtMaxSpeed 
    STA !Timer,x
    BRA .skip

    .noTurn
    LDA MaxXSpeedWings,y
    STA !AA,x
    .skip
    JSL $01801A|!BankB
    JSL $018022|!BankB
RTS

PlayerInteraction:
    JSL $01A7DC|!BankB		    ;\ interaction route
	BCC .Ret                    ;/ if not touching the player then return


	LDA $1490|!Base2
	ORA $1493|!Base2
	ORA $1497|!Base2
	BNE .killSprite
    

    LDA $187A|!Base2
    BEQ .notOnYoshi
    %LoseYoshi()

    .notOnYoshi
    LDA #$1B : STA $02
    LDA #$01
    %SpawnSmoke()
    LDA $94 : STA $17C8|!Base2,y
    LDA $96 : STA $17C4|!Base2,y
    ; do something here to add that little skull.

	JSL $00F5B7|!BankB		    ; hurt the player.
    ; when the new pixi update drops will add custom smoke sprite here and the little skull icon.

    .killSprite
    LDA $1490|!Base2            ;\ Check if we have star power
    BEQ +                       ;| if we don't just kill the sprite
    LDA #$04                    ;| if we do then give 1000 points
    JSL $02ACE5                 ;|
    LDA #!HitWithStarPowerSFX   ;| play sfx
    STA !Port                   ;/
    +
	STZ !14C8,x
    .Ret
RTS

; You are too far in this file run away before your brain hurts.

!SwingDir           = !1534     ; direction for swinging, it is left when odd and right when even.
!HitSide            = !151C     ; When set it will make the sprite go down and the sprite animation will be locked.
!ParaDescentTimer   = !1540		; Timer which is used to make the parachute go down when the sprite hits the ground.
!Angle              = !1528     ; Will contain the current angle value for the sprite.
!DirParachute       = !1504     ; Sprite facing direction, Would use 157C but its already used for direction for when its flying.
!AnimationFrame     = !1602     ; 0 = regular, 1 = tilted left, 2 = tilted right, in the GFX routine C = Normal and D = tilted.

; Tables taken from all.log
IncAngleSpeed:					            ; Increment/decrement values, used for the parachute sprite's angles and Ludwig's shell speed. IncAngleSpeed
	db $01,$FF

MaxMinAngleSpeed:					        ; Max/min angle values for the parachute sprite. MaxMinAngleSpeed
	db $0F,$00

AngleDependentXSpeed:					    ; X speeds for each angular value (00-0F). Inverted when moving left. AngleDependentXSpeed
	db $00,$02,$04,$06,$08,$0A,$0C,$0E
	db $0E,$0C,$0A,$08,$06,$04,$02,$00

ParachuteAnimation:						    ; Animation frames for the parachute, indexed by the sprite's angle ($1570).
	db $0D,$0D,$0D,$0D,$0C,$0C,$0C,$0C
	db $0C,$0C,$0C,$0C,$0D,$0D,$0D,$0D

DirectionTable:							    ; Horizontal directions for the frames designated above.
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $01,$01,$01,$01,$01,$01,$01,$01
	
SpriteXOffsetLow:						    ; X offsets (low) for the Poison Mushroom.
	db $F8,$F8,$FA,$FA,$FC,$FC,$FE,$FE
	db $02,$02,$04,$04,$06,$06,$08,$08
SpriteXOffsetHigh:						    ; X offsets (high) for the Poison Mushroom.
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $00,$00,$00,$00,$00,$00,$00,$00

SpriteYOffset:							    ; Y offsets for the Poison Mushroom from the parachute.
	db $0E,$0E,$0F,$0F,$10,$10,$10,$10
	db $10,$10,$10,$10,$0F,$0F,$0E,$0E

; this table isnt from the all.log I added this, because the the parachute tile is accessed is very interesting, it uses two large tables depedning on the sprite number.
ParachuteTiles: db !ParachuteTileTilted, !ParachuteTile 
; Parachute code from the disassembly I am working on.
; I am here to tell you right now, don't bother modifying anything here unless you know what you are doing.
; You also might see a few dumb things because ya know its SMW.

Parachute:
    LDX $15E9|!Base2
	LDA $9D						;\ 
	BNE drawGraphics			;| Skip movement if game frozen or landing on the ground.
    
    %CapeContact()              ;\ Check if hit by cape
    BCC +                       ;| if not just branch
    JSR CapeInteraction         ;/
    RTS
    +
    INC !WingAnimation,x        ; need to increment this so the wings can flap if the wings are set.
	
    LDA !ParaDescentTimer,x		
	BNE drawGraphics			
	LDA $13						;\ 
	LSR							;|
	BCC noDownMovement		    ;| Move downwards one pixel every two frames.
	INC !D8,x					;|
	BNE noDownMovement			;|
	INC !14D4,x					;/
    
noDownMovement:
	LDA !HitSide,x				;\ Skip horizontal movement if the sprite hit a wall.
	BNE drawGraphics			;/

	LDA $13						;\ 
	LSR							;|
	BCC noAngleChange			;|
	LDA !SwingDir,x				;|
	AND #$01					;|
	TAY							;| Every two frames, increase/decrease the current angle.
	LDA !Angle,x				;| If at the maximum, invert direction of movement.
	CLC							;|
	ADC IncAngleSpeed,Y			;|
	STA !Angle,x				;|
	CMP MaxMinAngleSpeed,Y		;|
	BNE noAngleChange			;|
	INC !SwingDir,x				;/

noAngleChange:
	LDA !B6,x					;\ 
	PHA							;|
	LDY !Angle,x				;|
	LDA !SwingDir,x				;|
	LSR							;|
	LDA AngleDependentXSpeed,Y 	;|
	BCC donInvertXSpeed			;|
	EOR #$FF					;| Update X position, using the angle and current direction to find the X speed.
	INC A						;|
donInvertXSpeed:				;|
	CLC							;|
	ADC !B6,x					;|
	STA !B6,x					;|
	JSL $018022|!BankB			;|
	PLA							;|
	STA !B6,x					;/

drawGraphics:
    LDA #$00
	%SubOffScreen()

ParachuteGraphics:
	STZ $185E|!Base2
	LDY #$F0					; Position for the Parachute
	LDA !ParaDescentTimer,x		;\
	BEQ ParachuteNotDescending	;|
	LSR							;| divide the Parachute Decent timer by 2
	EOR #$0F					;| flip nibble bits
	STA $185E|!Base2			;/ Store here which will be used later so we can subtract what we added for parachute as an offset, then add some Y offset.
	CLC					
	ADC #$F0			
	TAY					 
    ParachuteNotDescending:	
	STY $00						; Store Parachute Y offset to scratch RAM 
	LDA !D8,x					;\
	PHA							;| save sprite Low Byte Y position to get back later
	CLC							;|
	ADC $00						;| Add Y offset for to the sprite Y position for parachute
	STA !D8,x					;/

	LDA !14D4,x					;\ Same thing as what we did with the low byte but with the high byte
	PHA							;|
	ADC #$FF					;| add the overflow
	STA !14D4,x					;/

	LDA !15F6,x					;\ Get sprite properties
	PHA							;| Save YXPPCCCT
	AND #$F1					;| zero out CCC so the parachute palette would be different than what we have set in CFG
	ORA #!ParachutePal			;|
	STA !15F6,x					;/ Store them here

	LDY !Angle,x				;\ Get the current angle 
	LDA ParachuteAnimation,Y	;| Using the angle we get the parachute animation
	STA !AnimationFrame,x		;/ remember C is normal and D is titlted parachute

	LDA DirectionTable,Y		;\ Based on the angle get the Sprite direction
	STA !DirParachute,x			;| update Sprite direction
    JSR DrawParachute           ; Draw the 16x16 parachute.
	PLA							;\ Restore YXPPCCCT
	STA !15F6,x					;/

	LDA !15EA,x					;\ get sprite OAM index
	CLC							;|
	ADC #$04					;| Add 4 to it for the next OAM slot
	STA !15EA,x					;/ 

	LDY !Angle,x				;\ Get angle
	LDA !E4,x					;| 
	PHA							;| save sprite's X Position low byte
	CLC							;|
	ADC SpriteXOffsetLow,Y		;| Add the X offset to the sprite's X position low byte
	STA !E4,x					;/
	LDA !14E0,x					;\ Same thing as what we did with the low byte but with the high byte this time
	PHA							;|
	ADC SpriteXOffsetHigh,Y		;|
	STA !14E0,x					;/

	STZ $00						;\ Zero out the offset that was set for the parachute 
	LDA SpriteYOffset,Y			;| get offset for Y position
	SEC							;|
	SBC $185E|!Base2			;| subtract the parachute offset
	BPL noOverflow				;|
	DEC $00						;| if its negative then decrease for the overflow
    noOverflow:						;|
	CLC							;|
	ADC !D8,x					;| (SpriteYOffset-Parachute offset) + Sprite's Y position Low byte.
	STA !D8,x					;| 
	LDA !14D4,x					;|
	ADC $00						;| add the overflow to the high byte
	STA !14D4,x					;/

	LDA !AnimationFrame,x		;\  check animation 
	SEC							;|
	SBC #$0C					;|
	CMP #$01					;| 
	BNE +						;| 
	CLC							;| 
	ADC !DirParachute,x			;| add the direction 
	+							;|
	STA !AnimationFrame,x		;/ store that to the animation

	LDA !ParaDescentTimer,x		;\ If descent timer is set that means we landed
	BEQ notLanded				;| 
	STZ !AnimationFrame,x		;/ so clear animation frame
	
	notLanded:
    JSR Graphics                ;\ draw poison mushroom tile
	JSR PlayerInteraction       ;| Interact with the player and other sprites
	LDA !ParaDescentTimer,x		 ;| see if descent timer has been set
	BEQ checkLanding		    ;/  if not then branch and interact with object
	DEC A						 ;\ decrease timer
	BNE landed					 ;/ if after decreasing and its still not 0 then wait for parachute to fall.
	STZ !AA,x					 ; if we are here then we have already landed and the timer ran out so set Y speed to 0
	PLA							
	PLA
	PLA
								;\ restore Y position high byte 
	STA !14D4,x					;/

	PLA							;\ Restore Y position low byte
	STA !D8,x					;/

    JSR ResetSpriteTables       ; Reset the sprite tables since they will be used for other things.
    LDA !extra_byte_1,x         ;\ Set the type
    STA !Type,x                 ;/
    RTS

    landed:
	JSL $019138|!BankB			; Interact with objects
	LDA !1588,x
	AND #$04
	BEQ notOnGround
    
    LDA !1588,x                 ;\ See if the sprite on layer 2 
	BMI .onLayer2				;/ if it is then branch
	LDA #$00					; if not then set the Y speed to be 0
	LDY !15B8,x				    ; Check if we are on a slope
	BEQ .setYspeed				; if we are not then just set the speed
    .onLayer2
	LDA #$18
    .setYspeed	
	STA !AA,x

    notOnGround:					
	JSL $01801A|!BankB			
	INC !AA,x					
	BRA RestorePositions

    checkLanding:
	TXA							;\ 
	EOR $13						;| Object interaction happens every other frame
	LSR							;|
	BCC RestorePositions		;| if not that frame then restore position
	JSL $019138|!BankB			;/ interact with objects
	LDA !1588,x
	AND #$03		            ;\ check if touching sides
	BEQ notTouchingSide			;/ if not tocuching side then branch
	LDA #$01					;\ set flag that a side has been touched
	STA !HitSide,x				;/ 
	LDA #$07					;\ And set the angle to 7
	STA !Angle,x				;/
    notTouchingSide:
	LDA !1588,x
	AND #$04				    ;\ 
	BEQ RestorePositions		;| if not touching ground just restore position
	LDA #$20					;\ Set the timer if the ground has been touched
	STA !ParaDescentTimer,x		;/
    RestorePositions:
	PLA							;\ 
	STA !14E0,x					;|
	PLA							;|
	STA !E4,x					;| Restore X and Y positions
	PLA							;|
	STA !14D4,x					;|
	PLA							;|
	STA !D8,x					;/
	RTS    




 ; Modified $019F0D routine taken from all.log
DrawParachute:
	STZ $04
	%GetDrawInfo()
	LDA !DirParachute,x             
	STA $02
	LDA !AnimationFrame,x
    SEC : SBC #$0C
	TAX	
	LDA ParachuteTiles,x
	STA $0302|!Base2,y 
	LDX $15E9|!Base2
	LDA $00						    ;\ 
	STA $0300|!Base2,y 				;| Set X/Y offsets.
	LDA $01						    ;|
	STA $0301|!Base2,y 				;/

	LDA !DirParachute,x
	LSR
	LDA #$00
	ORA !15F6,x
	BCS noFlip
	EOR #$40					    ; sprite is facing left so flip X 

    noFlip:
	ORA $04						
	ORA $64						
	STA $0303|!Base2,y
	TYA							    
	LSR							    
	LSR							    
	TAY							    
	LDA #$02					     
	ORA !15A0,x				        ;	| Draw a 16x16 tile.
	STA $0460|!Base2,y				;	/
    PHK
    PEA.w .jslrtsreturn-1
    PEA.w $0180CA-1
    JML $01A3DF
    .jslrtsreturn
	RTS



ResetSpriteTables:
    STZ !SwingDir,X
    STZ !HitSide,x
    STZ !ParaDescentTimer,x
    STZ !Angle,x
    STZ !AnimationFrame,x
    STZ !DirParachute,x
RTS


Graphics:
    LDA !Type,x
    CMP #$01
    BCC +
    LDA !extra_byte_1,x
    BEQ +
	PEA ($01)|(done>>16<<8)
	PLB
	PHK
	PEA done-1
	PEA $80CA-1
	JML $019E95|!BankB
    done:
	PLB
    
    +

    %GetDrawInfo()
    LDA $00                     ;\ Store Tile X position
    STA $0300|!Base2,y          ;/

    LDA $01                     ;\ Store Tile Y position
    STA $0301|!Base2,y          ;/

    LDA #!PoisonMushroomTile    ;\ Store Tile number
    STA $0302|!Base2,y          ;/
    
    LDA !15F6,x                 ;\ Store Tile properties
    ORA $64                     ;|
    STA $0303|!Base2,y          ;/
    
    LDA #$00 				    ; A = (number of tiles drawn - 1)
    LDY #$02 				    ; 16x16 tiles
    JSL $01B7B3|!BankB

RTS