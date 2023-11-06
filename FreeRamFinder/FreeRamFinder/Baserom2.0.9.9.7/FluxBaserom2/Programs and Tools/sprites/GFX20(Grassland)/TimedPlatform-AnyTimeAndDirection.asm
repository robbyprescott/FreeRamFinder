;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Programmable Timed Lift by dtothefourth
;;
;; Based on the disassembly of the timed lift by Iceguy
;;
;; Expands the timer up to 9 and allows it to be set in the extension 
;;      instead of locked to position
;; Allows the platform to move in any direction by setting X and Y speed
;; Adds an option to make it controllable
;; Adds an option for programmed paths
;;
;; Uses three extra bytes - Timer (0-9), X speed, Y speed
;;		Setting the extension to 04 10 00 would recreate vanilla plat with a timer of 4. 
;;              Setting the extension to 09 10 F0 would make it have a timer of 9 and
;;		move diagonally right and up
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



!Control = 0 ; Controlled by directions while riding, uses X speed and Y speed for right/down values. Will not work with UsePath
!UsePath = 0 ; Uses the tables below for changing movement instead of the speed values from the extra bytes
	;How many frames for each phase of movement, use $00 to end and loop back to the beginning
	;The sample entries here move in a triangle in three phases
	TimeInState:
	db $40,$40,$40,$00

	;X and Y speeds for each phase, you need one of these for each time entry except the final $00
	XSpeed:
	db $10,$00,$F0
	YSpeed:
	db $F0,$10,$00


TimedPlatDispX:                   db $00,$10,$0C ; X displacement offset.

TimedPlatDispY:                   db $00,$00,$04 ; Y displacement offset.

TimedPlatTiles:                   db $C4,$C4,$00 ; Tilemaps.

TimedPlatGfxProp:                 db $0B,$4B,$0B ; Property bytes.

TimedPlatTileSize:                db $02,$02,$00 ; Tile size. Last one is 8x8 4321 tile #.

TimedPlatNumTiles:                db $B6,$B5,$B4,$B3,$A7,$A6,$A5,$A4,$A3 ; 1-9 tiles.


print "INIT ",pc
	LDA #$00
	STA !1510,x

	LDA !extra_byte_1,x
	REP #$20
	AND #$00FF
	ASL #6
	DEC
	SEP #$20

	STA !1570,x ; Store into lift timer.
	XBA
	STA !1534,x
	
	if !UsePath = 1
	LDA.L TimeInState	;
	STA !1540,x
	endif
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR TimedLift
	PLB
	RTL

TimedLift:                        JSR.w TimedPlatformGfx   ; Draw graphics. 
CODE_038DBE:                      LDA $9D    
CODE_038DC0:                      BNE Return038DEF ; Return if sprites locked.         
CODE_038DC2:                      LDA #$00
                                  %SubOffScreen()           
CODE_038DCB:                      LDA !C2,x   
CODE_038DCD:                      BEQ CODE_038DD7  
CODE_038DCF:                      LDA.w !1570,X       
CODE_038DD2:                      BEQ CODE_038DD7           
CODE_038DD4:                      DEC.w !1570,X             
CODE_038DD7:                      LDA.w !1570,X  	;\          
								  BNE +
								  LDA !1534,x
CODE_038DDA:                      BEQ CODE_038DF0   
								  DEC
								  STA !1534,x
								  LDA #$FF
								  STA !1570,x
								  +

								  if !UsePath = 1

								  LDA !1540,x
								  BNE NoStateChange	;
								  
								  
								  INC !1510,x	; increment the sprite state
								  -
								  LDA !1510,x	;
								  TAY		;
								  LDA TimeInState,y	;
								  BNE +
								  STZ !1510,x
								  BRA -
								  +
								  STA !1540,x
								  
								  
								  NoStateChange:	;

								  LDA !C2,x
								  BNE +

								  INC !1540,x

		                          JSL.l $01B44F   ; Make the sprite "solid".   
		                          BCC Return038DEF   
								  BRA ++
								  +
CODE_038DE3:                      JSL.l $01B44F   ; Make the sprite "solid".   
								  ++

								  LDA #$01
		                          STA !C2,x 

								  LDA !1510,x	;
								  TAY		;
								  
								  LDA XSpeed,y	;
								  
								  STA !B6,x		; if we're moving horizontally, store the speed value to the X speed table
								  JSL $018022	; and update sprite X position without gravity
								  STA !1528,x	; prevent the player from sliding
								  
								  LDA !1510,x	;
								  TAY		;
								  LDA YSpeed,y	;
								  STA !AA,x	; if we're moving vertically, store the speed value to the Y speed table
								  JSL $01801A	; and update sprite Y position without gravity


								  else


			                      JSL.l $01801A 	; Update the Y position without affecting sprite gravity. 
CODE_038DDC:                      JSL.l $018022 	; Update the X position without affecting sprite gravity. 
CODE_038DE0:                      STA.w !1528,X             
CODE_038DE3:                      JSL.l $01B44F   ; Make the sprite "solid".   
CODE_038DE7:                      BCC Return038DEF          

								 
								  if !Control

								  STZ $7B

								  LDA $15
								  AND #$0F
								  BEQ ++

								  LDA #$00
								  STA !B6,x
								  STA !AA,x

								  LDA $15
								  AND #$01
								  BEQ +
			                      LDA !extra_byte_2,x                
			                      STA !B6,X ; Set the X speed for the sprite here. 
			                      +
								  
								  LDA $15
								  AND #$02
								  BEQ +
			                      LDA !extra_byte_2,x                
			                      EOR #$FF
								  INC
								  STA !B6,X ; Set the X speed for the sprite here. 
			                      +

								  LDA $15
								  AND #$04
								  BEQ +
								  LDA !extra_byte_3,x                
			                      STA !AA,X ; Set the X speed for the sprite here.
								  +

								  LDA $15
								  AND #$08
								  BEQ +
								  LDA !extra_byte_3,x         
								  EOR #$FF
								  INC       
			                      STA !AA,X ; Set the X speed for the sprite here.
								  +

								  ++

								  else

			                      LDA !extra_byte_2,x                
CODE_038DEB:                      STA !B6,X ; Set the X speed for the sprite here. 
			                      LDA !extra_byte_3,x                
			                      STA !AA,X ; Set the X speed for the sprite here.
								   
								  endif

								  endif


								  LDA #$01
CODE_038DED:                      STA !C2,x 
Return038DEF:                     RTS                       ; Return 

CODE_038DF0:                      JSL.l $01802A  ; Update positions based on speed.   
CODE_038DF4:                      LDA.w $1491|!Base2   ;\            
CODE_038DF7:                      STA.w !1528,X          
CODE_038DFA:                      JSL.l $01B44F ; Make the sprite "solid".     
Return038DFE:                     RTS                       ; Return 

;===============
;Graphics Routine
;===============


print "gfx ",pc
TimedPlatformGfx:                 %GetDrawInfo()
								  LDA.w !1534,x
								  XBA
CODE_038E15:                      LDA.w !1570,X  
								  REP #$20           
CODE_038E18:                      PHX ; Push sprite index.                       
CODE_038E19:                      PHA ; And timer for lift.                  
CODE_038E1A:                      LSR                       
CODE_038E1B:                      LSR  ; LSR #6 ..                     
CODE_038E1C:                      LSR                       
CODE_038E1D:                      LSR                       
CODE_038E1E:                      LSR                       
CODE_038E1F:                      LSR                       
CODE_038E20:                      TAX
								  SEP #$20                     
CODE_038E21:                      LDA.w TimedPlatNumTiles,X 
CODE_038E24:                      STA $02 ; Store the numbers into $02 to not mess up the X register.                   
CODE_038E26:                      LDX.b #$02   
								  REP #$20             
CODE_038E28:                      PLA                
CODE_038E29:                      CMP #$0008 ; If timer for lift > 08, branch.  
								  SEP #$20                     
CODE_038E2B:                      BCS CODE_038E2E           
CODE_038E2D:                      DEX ; We don't write the tile number if it's about to fall, so cut off the last tile.                     
CODE_038E2E:                      LDA $00                   
CODE_038E30:                      CLC                       
CODE_038E31:                      ADC.w TimedPlatDispX,X  ; Load X pos and apply x displacement ..  
CODE_038E34:                      STA.w $0300|!Base2,Y     ; To not overwrite them.    
CODE_038E37:                      LDA $01                   
CODE_038E39:                      CLC                       
CODE_038E3A:                      ADC.w TimedPlatDispY,X   ; Apply Y displacement. 
CODE_038E3D:                      STA.w $0301|!Base2,Y         
CODE_038E40:                      LDA.w TimedPlatTiles,X    
CODE_038E43:                      CPX.b #$02                
CODE_038E45:                      BNE CODE_038E49           
CODE_038E47:                      LDA $02		;\                  
CODE_038E49:                      STA.w $0302|!Base2,Y         ;/ Add in the "time" 4321 tiles.
CODE_038E4C:                      LDA.w TimedPlatGfxProp,X  
CODE_038E4F:                      ORA $64         ; Add in property byte along with sprite properties.          
CODE_038E51:                      STA.w $0303|!Base2,Y          
CODE_038E54:                      PHY                       
CODE_038E55:                      TYA                       
CODE_038E56:                      LSR                       
CODE_038E57:                      LSR                       
CODE_038E58:                      TAY                       
CODE_038E59:                      LDA.w TimedPlatTileSize,X 
CODE_038E5C:                      STA.w $0460|!Base2,Y ; Store the tile sizes to $0460..     
CODE_038E5F:                      PLY                       
CODE_038E60:                      INY                       
CODE_038E61:                      INY   ; OAM is 8x8, so write 4 times..                    
CODE_038E62:                      INY                       
CODE_038E63:                      INY                       
CODE_038E64:                      DEX  ; Pull X and loop so all tiles are drawn.                     
CODE_038E65:                      BPL CODE_038E2E           
CODE_038E67:                      PLX                       
CODE_038E68:                      LDY.b #$FF                
CODE_038E6A:                      LDA.b #$02 ; 3 tiles drawn.               
CODE_038E6C:                      JSL.l $01B7B3      
Return038E70:                     RTS                       ; Return 
