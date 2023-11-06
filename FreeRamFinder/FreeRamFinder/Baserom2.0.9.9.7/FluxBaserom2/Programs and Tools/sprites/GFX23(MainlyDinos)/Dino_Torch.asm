

!TurnTime = #$3F	; How often to turn around - ANDed with frame counter so use 1,3,7,F,1F,3F,7F etc

!JumpSpeed = #$C0	; Y Speed when jumping
!WallJump  = 1		; If 1, try to jump over blocks instead of turning around

!RandomJump   = 0	  ; If 1, also sometimes jump just when walking around
!JumpChance   = #$10  ; 0-FF frequency of random jumps
!JumpCooldown = #$20  ; How many frames after landing to not check for another jump

!BreatheFire   = 1	  ; If 1, torch breathes fire
!FaceOnFire    = 0    ; If 1, always turn to face mario before firing
!FlameDelay    = #$FF ; How many frames before starting fire breathing after spawn
!FlameCooldown = #$40 ; Minimum frames before breathing fire again
!FlameSpeed    = 8	  ; How quickly the flame animation happens 8 = normal 1-7 = slower/longer, 9-16 = faster / shorter
!FlameDir      = 0    ; Direction to shoot fire 0 = random, 1 = horizontal only, 2 = vertical only, 3 = alternate
!FlameSize	   = 4	  ; How long flame is, 1-6
!FlameInfinite = 0	  ; If 1, flame stays forever once extended

;Sound effect for fire breathing
!FireSFX  = #$17
!FireBank = $1DFC|!Base2

;Walking Speed
;Torch Right, Torch Left, Rhino Right, Rhino Left
DinoSpeed:
	db $08,$F8,$10,$F0

;Turn offset, added to X position when hitting a wall
;No contact, Right, Left, Both
TurnXLo:
	db $00,$FE,$02,$00
TurnXHi:
	db $00,$FF,$00,$00

;Length of flame and torch pose over time
;First half of byte is flame length but inverted so for vanilla 4 is no flame yet and 0 is full length
;Second half of byte is torch pose (1 - normal, 2 - breathing horizontal, 3 - breathing vertical)


if !FlameSize = 4
	DinoFlameTable:
		db $61,$62,$62,$52,$42,$32,$22,$22
		db $22,$22,$22,$22,$22,$22,$22,$22
		db $22,$22,$22,$22,$22,$22,$22,$32
		db $42,$52,$62,$62,$62,$62,$61,$61

		db $61,$63,$63,$53,$43,$33,$23,$23
		db $23,$23,$23,$23,$23,$23,$23,$23
		db $23,$23,$23,$23,$23,$23,$23,$33
		db $43,$53,$63,$63,$63,$63,$61,$61

	;Flame hitbox data - Left, Up (while facing left), Right, Up (while facing right)
	FlameHitXLo:         db $DC,$02,$10,$02
	FlameHitXHi:         db $FF,$00,$00,$00
	FlameHitWidth:       db $24,$0C,$24,$0C
	FlameHitYLo:         db $02,$DC,$02,$DC
	FlameHitYHi:         db $00,$FF,$00,$FF
	FlameHitHeight:      db $0C,$24,$0C,$24
endif
if !FlameSize = 3
	DinoFlameTable:
		db $61,$62,$62,$52,$52,$42,$32,$32
		db $32,$32,$32,$32,$32,$32,$32,$32
		db $32,$32,$32,$32,$32,$32,$32,$42
		db $52,$52,$62,$62,$62,$62,$61,$61

		db $61,$63,$63,$53,$53,$43,$33,$33
		db $33,$33,$33,$33,$33,$33,$33,$33
		db $33,$33,$33,$33,$33,$33,$33,$43
		db $53,$53,$63,$63,$63,$63,$61,$61

	;Flame hitbox data - Left, Up (while facing left), Right, Up (while facing right)
	FlameHitXLo:         db $E8,$02,$10,$02
	FlameHitXHi:         db $FF,$00,$00,$00
	FlameHitWidth:       db $18,$0C,$18,$0C
	FlameHitYLo:         db $02,$E8,$02,$E8
	FlameHitYHi:         db $00,$FF,$00,$FF
	FlameHitHeight:      db $0C,$18,$0C,$18
endif
if !FlameSize = 2
	DinoFlameTable:
		db $61,$62,$62,$62,$62,$52,$42,$42
		db $42,$42,$42,$42,$42,$42,$42,$42
		db $42,$42,$42,$42,$42,$42,$42,$52
		db $52,$52,$62,$62,$62,$62,$61,$61

		db $61,$63,$63,$63,$53,$53,$43,$43
		db $43,$43,$43,$43,$43,$43,$43,$43
		db $43,$43,$43,$43,$43,$43,$43,$53
		db $53,$53,$63,$63,$63,$63,$61,$61

	;Flame hitbox data - Left, Up (while facing left), Right, Up (while facing right)
	FlameHitXLo:         db $F2,$02,$10,$02
	FlameHitXHi:         db $FF,$00,$00,$00
	FlameHitWidth:       db $0E,$0C,$0E,$0C
	FlameHitYLo:         db $02,$F2,$02,$F2
	FlameHitYHi:         db $00,$FF,$00,$FF
	FlameHitHeight:      db $0C,$0E,$0C,$0E
endif
if !FlameSize = 1
	DinoFlameTable:
		db $61,$62,$62,$62,$62,$52,$52,$52
		db $52,$52,$52,$52,$52,$52,$52,$52
		db $52,$52,$52,$52,$52,$52,$52,$52
		db $52,$52,$62,$62,$62,$62,$61,$61

		db $61,$63,$63,$63,$63,$53,$53,$53
		db $53,$53,$53,$53,$53,$53,$53,$53
		db $53,$53,$53,$53,$53,$53,$53,$53
		db $53,$53,$63,$63,$63,$63,$61,$61

	;Flame hitbox data - Left, Up (while facing left), Right, Up (while facing right)
	FlameHitXLo:         db $F8,$02,$10,$02
	FlameHitXHi:         db $FF,$00,$00,$00
	FlameHitWidth:       db $08,$0C,$08,$0C
	FlameHitYLo:         db $02,$F8,$02,$F8
	FlameHitYHi:         db $00,$FF,$00,$FF
	FlameHitHeight:      db $0C,$08,$0C,$08
endif
if !FlameSize = 5
	DinoFlameTable:
		db $61,$62,$52,$42,$32,$22,$12,$12
		db $12,$12,$12,$12,$12,$12,$12,$12
		db $12,$12,$12,$12,$12,$12,$12,$22
		db $32,$42,$52,$62,$62,$62,$61,$61

		db $61,$63,$53,$43,$33,$23,$13,$13
		db $13,$13,$13,$13,$13,$13,$13,$13
		db $13,$13,$13,$13,$13,$13,$13,$23
		db $33,$43,$53,$63,$63,$63,$61,$61

	;Flame hitbox data - Left, Up (while facing left), Right, Up (while facing right)
	FlameHitXLo:         db $D2,$02,$10,$02
	FlameHitXHi:         db $FF,$00,$00,$00
	FlameHitWidth:       db $2E,$0C,$2E,$0C
	FlameHitYLo:         db $02,$D2,$02,$D2
	FlameHitYHi:         db $00,$FF,$00,$FF
	FlameHitHeight:      db $0C,$2E,$0C,$2E
endif
if !FlameSize = 6
	DinoFlameTable:
		db $61,$62,$52,$42,$32,$22,$12,$02
		db $02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$12
		db $22,$32,$42,$52,$62,$62,$61,$61

		db $61,$63,$53,$43,$33,$23,$13,$03
		db $03,$03,$03,$03,$03,$03,$03,$03
		db $03,$03,$03,$03,$03,$03,$03,$13
		db $23,$33,$43,$53,$63,$63,$61,$61

	;Flame hitbox data - Left, Up (while facing left), Right, Up (while facing right)
	FlameHitXLo:         db $C8,$02,$10,$02
	FlameHitXHi:         db $FF,$00,$00,$00
	FlameHitWidth:       db $38,$0C,$38,$0C
	FlameHitYLo:         db $02,$C8,$02,$C8
	FlameHitYHi:         db $00,$FF,$00,$FF
	FlameHitHeight:      db $0C,$38,$0C,$38
endif

;Graphics Properties
TorchTileDispX:
	db $C4,$CE,$D8,$E0,$EC,$F8,$00,$FF,$FF,$FF,$FF,$FF,$FF,$00

TorchTileDispY:               
	db $00,$00,$00,$00,$00,$00,$00,$C4,$CE,$D8,$E0,$EC,$F8,$00

DinoFlameTiles:                   
	db $80,$80,$80,$82,$84,$86,$00,$88,$88,$88,$8A,$8C,$8E,$00

TorchGfxProp:
	db $09,$09,$09,$05,$05,$05,$0F

TorchTiles:
	db $EA,$AA,$C4,$C6,$AC

DinoTilesWritten:                 
	db $06,$05,$04,$03,$02,$01,$00


RhinoTileDispX:
	db $F8,$08,$F8,$08,$08,$F8,$08,$F8
RhinoTileDispY:
	db $F0,$F0,$00,$00
RhinoGfxProp:
	db $2F,$2F,$2F,$2F,$6F,$6F,$6F,$6F

RhinoTiles:
	db $C0,$C2,$E4,$E6,$C0,$C2,$E0,$E2
	db $C8,$CA,$E8,$E2,$CC,$CE,$EC,$EE



Print "INIT ",pc
	LDA #$06                
	STA !151C,X             
	LDA !FlameDelay               
	STA !1540,X             
	
	LDA #$01
	STA !1510,x

	%SubHorzPos()         
	TYA                       
	STA !157C,X     
	RTL   

Print "MAIN ",pc
	PHB                       
	PHK                       
	PLB                       
	JSR DinoMainSubRt       
	PLB                       
	RTL  


DinoMainSubRt:      
	JSR DinoGfxRt           
	LDA $9D					; Check if sprites locked or dead
	BNE Return      
	LDA !14C8,X             
	CMP #$08                
	BEQ +
	LDA #$06				; Prevent drawing flames if dead
	STA !151C,x
	BRA Return     
	+
	LDA #$00
	%SubOffScreen()	   
	JSL $01A7DC|!BankB		; Interact with Mario




	JSL $01802A|!BankB		; Update position
	LDA !C2,X     
	JSL $0086DF|!BankB		; Execute pointer         

RhinoStatePtrs:     
	dw Walking           
    dw FireBreathing        ; Sideways
    dw FireBreathing		; Up
    dw Jumping        

Jumping:

	LDA #$01
	STA !1534,x

    LDA !AA,X				; Don't turn around if rising
	BMI NoTurnAround           
	STZ !C2,X     


	
	LDA !1588,X				; If touching block from side
	AND #$03                
	BEQ NoTurnAround         
	LDA !157C,X				; Turn around
	EOR #$01                
	STA !157C,X     

NoTurnAround:

	STZ !1602,X				; Neutral animation frame        
	LDA !1588,X  
	AND #$03                
	TAY                       
	LDA !E4,X       
	CLC                       
	ADC TurnXLo,Y			; Shift X away from wall if touching
	STA !E4,X       
	LDA !14E0,X     
	ADC TurnXHi,Y       
	STA !14E0,X     
Return:
    RTS




Walking:
	LDA !1588,X			; Don't do anything if in air
	AND #$04 
	BEQ NoTurnAround

	LDA !1534,x
	BEQ +

	STZ !1534,x
	LDA !JumpCooldown
	STA !15AC,x

	+


	if !BreatheFire != 1
		BRA NoFire
	endif


	LDA !1540,X             
	BNE NoFire           
	LDA !9E,X       
	CMP #$6E                
	BEQ NoFire           
	LDA #$FF                ; \ Set fire breathing timer 
	STA !1540,X             ; / 

	if !FaceOnFire     
		%SubHorzPos()    
		TYA              
		STA !157C,X
	endif

	; Choose Flame Direction
	if !FlameDir = 0
	JSL $01ACF9|!BankB             
	AND #$01                
	INC             
	endif        
	if !FlameDir = 1
	LDA #$01
	endif
	if !FlameDir = 2
	LDA #$02
	endif
	if !FlameDir = 3
	LDA !1510,x
	EOR #$01
	STA !1510,x
	INC
	endif
	STA !C2,X
	     
NoFire:
	TXA                       ; Check if time to turn around
	ASL                       
	ASL                       
	ASL                       
	ASL                       
	ADC $14     
	AND !TurnTime                
	BNE NoFace           
	%SubHorzPos()    
	TYA              
	STA !157C,X    
NoFace:
    LDA #$10			       
	STA !AA,X    
	LDY !157C,X				; Set walking speed
	LDA !9E,X       
	CMP #$6E				; Check if rhino or torch
	BEQ +           
	INY             
	INY             
	+
	LDA DinoSpeed,Y 
	STA !B6,X
	JSR DinoSetGfxFrame
    
	LDA !C2,X		; Don't jump if fire breathing
	CMP #$00
	BNE Return2	
	 
	if !RandomJump
		LDA $14
		AND #$07
		BNE +
		LDA !15AC,x
		BNE +
		JSL $01ACF9|!BankB
		CMP !JumpChance
		BCS +

		LDA !JumpSpeed                
		STA !AA,X   
		LDA #$03                
		STA !C2,X
		BRA Return2

		+
	endif

	LDA !1588,X				; If hit a wall, try to jump over it
	AND #$03     
	BEQ Return2
	if !WallJump  
		LDA !JumpSpeed                
		STA !AA,X   
	endif 
	LDA #$03                
	STA !C2,X     
Return2:
	RTS


FireBreathing:       

	if !BreatheFire != 1
		STZ !C2,x
		JMP Walking
	endif

	STZ !B6,X			; Sprite X Speed = 0 

	LDA !1540,X         ; Check for flame ending    
	BEQ NoSpeed

	if !FlameInfinite
		LDA !1528,x
		BEQ +
		LDA !1540,x
		INC
		STA !1540,x
		BRA NoSpeed
		+
	endif


	if !FlameSpeed != 8
		STZ $00
		LDA !1540,x
		CMP #$C0
		BCC +
		INC $00
		+
	endif

	if !FlameSpeed < 8
		LDA $14
		AND #$07
		CMP #$!FlameSpeed
		BCC NoSpeed
		LDA !1540,x
		CMP #$BF
		BEQ NoSpeed
		INC
		STA !1540,x
	endif
	if !FlameSpeed > 8
		
		LDA !1540,x
		CMP #(!FlameSpeed-8)
		BCS +
		LDA #$00
		BRA ++
		+
		SEC
		SBC #(!FlameSpeed-8)
		++
		STA !1540,x

		CMP #$C0
		BCS NoSpeed

		LDA $00
		BEQ NoSpeed

		LDY !FireSFX		;  Play sound effect 
		STY !FireBank  

	endif

NoSpeed:

	LDA !1540,X         ; Check for flame ending    
	BNE FlameTimerSet    
 
	STZ !C2,X     
	LDA !FlameCooldown                 
	STA !1540,X             
	LDA #$00          
	      
FlameTimerSet:
	CMP #$C0                
	BNE NoSFX   
        
	LDY !FireSFX		;  Play sound effect 
	STY !FireBank  
NoSFX:
	LSR                 ; Compute fire frame    
	LSR                       
	LSR                       
	LDY !C2,X     
	CPY #$02                
	BNE NotVertical           
	CLC                       
	ADC #$20                
NotVertical:
	TAY                       
	LDA DinoFlameTable,Y    
	PHA                       
	AND #$0F            ; Set dino pose  
	STA !1602,X             
	PLA                       
	LSR                       
	LSR                       
	LSR                       
	LSR                       
	STA !151C,X         ; Set flame length   

	if !FlameSize < 6
	CMP #(6-!FlameSize)
	endif
	BNE Return3         ; Only damage if fully extended
	LDA !9E,X       
	CMP #$6E                
	BEQ Return3         ; And not the rhino
	TXA                       
	EOR $13				; And only every 4 frames
	AND #$03                
	BNE Return3         

	if !FlameInfinite
	LDA #$01
	STA !1528,x
	endif

	JSR FlameClipping   ; Compute flame hitbox
	JSL $03B664|!BankB    
	JSL $03B72B|!BankB     
	BCC Return3          
	LDA $1490|!Base2  ; Hurt Mario unless star timer is active
	BNE Return3			
	JSL $00F5B7|!BankB           
Return3:
	RTS


;Compute custom hitbox based on direction
FlameClipping:
	LDA !1602,X            ; Sideways or vertical
	SEC                      
	SBC #$02                
	TAY                       
	LDA !157C,X			   ; Left or right
	BNE Right           
	INY                       
	INY      
Right:                 
	LDA !E4,X       
	CLC                       
	ADC FlameHitXLo,Y        
	STA $04                 ; X Low  
	LDA !14E0,X     
	ADC FlameHitXHi,Y        
	STA $0A                 ; X High
	LDA FlameHitWidth,Y        
	STA $06                 ; Width
	LDA $D8,X       
	CLC                       
	ADC FlameHitYLo,Y        
	STA $05                 ; Y Low   
	LDA !14D4,X     
	ADC FlameHitYHi,Y        
	STA $0B                 ; Y High
	LDA FlameHitHeight,Y        
	STA $07                 ; Height
	RTS                      

DinoSetGfxFrame:
	INC !1570,X      ; Alternate walking pose every 8 frames       
	LDA !1570,X             
	AND #$08                
	LSR                       
	LSR                       
	LSR                       
	STA !1602,X             
	RTS

DinoGfxRt:          
	%GetDrawInfo()
	LDA !157C,X		;Store direction and frame for later
	STA $02                   
	LDA !1602,X             
	STA $04                   
	LDA !9E,X		;Check if rhino or torch
	CMP #$6F                
	BEQ TorchGfx
RhinoGfx:           
	PHX                       
	LDX #$03		;Compute table index based on direction     
RhinoLoop:     
	STX $0F                   
	LDA $02                   
	CMP #$01                
	BCS RhinoRight           
	TXA                       
	CLC                       
	ADC #$04                
	TAX                       
RhinoRight:
    LDA RhinoGfxProp,X  ; Loop over 4 rhino tiles
	STA $0303|!Base2,Y          
	LDA RhinoTileDispX,X 
	CLC                       
	ADC $00                   
	STA $0300|!Base2,Y         
	LDA $04                   
	CMP #$01                
	LDX $0F                   
	LDA RhinoTileDispY,X 
	ADC $01                   
	STA $0301|!Base2,Y         
	LDA $04                   
	ASL                       
	ASL                       
	ADC $0F                   
	TAX                       
	LDA RhinoTiles,X    
	STA $0302|!Base2,Y          
	INY                       
	INY                       
	INY                       
	INY                       
	LDX $0F                   
	DEX                       
	BPL RhinoLoop           
	PLX                       
	LDA #$03                
	LDY #$02                
	JSL $01B7B3|!BankB	;Finish graphics 
	RTS


print "gfx ",pc
TorchGfx:
	LDA !151C,X		;Backup flame frame and sprite state for later   
	STA $03						
	LDA !1602,X             
	STA $04            
	LDA !14C8,X             
	STA $07

              
	PHX             ;Make the flame flip every 2 frames
	LDA $14     
	AND #$02                
	ASL                       
	ASL                       
	ASL                       
	ASL                       
	ASL                       
	LDX $04         ;Switch from horizontal to vertical flip based on direction         
	CPX #$03                
	BEQ +           
	ASL  
	+                     
	STA $05     
            
	LDX #$06
              
TorchLoop:
	STX $06			;Loop over torch + all flame tiles
	LDA $04         ;Adjust index into table based on vertical or horizontal flame      
	CMP #$03                
	BNE NotVertical2           
	TXA                       
	CLC                       
	ADC #$07                
	TAX                       
NotVertical2:
	PHX      
                 
	LDA TorchTileDispX,X	;Compute X offset of tile and invert based on direction
	LDX $02                   
	BNE +           
	EOR #$FF                
	INC	
	+                     
	PLX                       
	CLC                       
	ADC $00                   
	STA $0300|!Base2,Y 
        
	LDA TorchTileDispY,X	;Compute Y offset of tile 
	CLC                       
	ADC $01                   
	STA $0301|!Base2,Y  
	       
	LDA $06					;Draw torch or flame depending on if first time through the loop        
	CMP #$06             
	BNE FlameTile           
	LDX $04                


	LDA $07					;Draw squished tile if dead
	CMP #$08
	BEQ +
	LDX #$04
	+
   
	LDA TorchTiles,X    
	BRA SetTile           
FlameTile:	
	LDA DinoFlameTiles,X    
SetTile:
	STA $0302|!Base2,Y   
	       
	LDA #$00		;Apply horizontal flip based on direction            
	LDX $02                   
	BNE +           
	ORA #$40                
	+

	LDX $06                
	CPX #$06        ;If we're drawing the flame, apply the flip calculated earlier  
	BEQ +           
	EOR $05
	+                   
	ORA TorchGfxProp,X  
	ORA $64                   
	STA $0303|!Base2,Y          
	INY                       
	INY                       
	INY                       
	INY                       
	DEX                       
	CPX $03                   
	BPL TorchLoop     
	      
	PLX                       
	LDY !151C,X             
	LDA DinoTilesWritten,Y  
	LDY #$02                
	JSL.L $01B7B3	; Finish graphics
	RTS