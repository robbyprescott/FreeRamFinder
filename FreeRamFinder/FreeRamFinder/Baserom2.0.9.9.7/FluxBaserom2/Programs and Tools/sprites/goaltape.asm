
;=============;
; Goal Tape   ;
;=============;

;Normal bit = normal exit goal.
;Extra bit set = secret exit.

;==========
;Configurables
;==========

!Sfx = $09			; Sound. Bank = $1DFB of course.
!Tile = $D4			; Tile to draw.
!Timer = $7C			; Duration timer until it goes back down and vice versa.
!Music = $0C			; Goal tape music.
!BonusTimer = $40		; Amount of time to draw bonus stars number.

DATA_01C0A5: db $10,$F0		; Maximum height, up/down.

;=============

print "INIT ",pc
	LDA !E4,x	;\
	SEC		; | Sprite X position - #$08
	SBC #$08	; | = Sprite state.
	STA !C2,x	;/
	LDA !14E0,x	;\
	SBC #$00	; | Store X high into $151C?
	STA !151C,x	;/
	LDA !D8,x	;\
	STA !1528,x	;/ Preserve Y position into $1528,x.
	LDA !14D4,x	;\
	;STA $187B,x	;/ Uncommented, because I use extra bit for goal type.
	AND #$01	;\
	STA !14D4,x	; | I think these are preserved to check if Mario touches the sprite in the same X range.
	STA !1534,x	;/
	RTL

print "MAIN ",pc
	PHB		;\
	PHK		; | Make data bank running from here.
	PLB		; | Call local subroutine.
	JSR Spr		; |
	PLB		; | Restore it when we're done.
	RTL		;/

;=========
;Main
;=========           
Spr:
	JSR SprGfx		; Branch to draw tilemaps of sprite.
	LDA $9D			;\
	BNE Locked		;/ If locked, return.
	LDA !1602,x		;\ If goal already touched, return.
	BEQ Code0A7		;/ (#$01).
Locked: RTS


Code0A7:
CODE_01C0A7:                      LDA.w !1540,X 	;\ If timer duration is set, don't set again.           
CODE_01C0AA:                      BNE CODE_01C0B4       ;/ (Obviously..)
CODE_01C0AC:                      LDA.b #!Timer 	;\              
CODE_01C0AE:                      STA.w !1540,X         ;/ Set timer for Y movement.  
CODE_01C0B1:                      INC.w !1588,X 	; Increase object status?? 
CODE_01C0B4:                      LDA.w !1588,X  	;\
CODE_01C0B7:                      AND.b #$01            ; |  
CODE_01C0B9:                      TAY                   ; | Get two bits (0,1) of it. 
CODE_01C0BA:                      LDA.w DATA_01C0A5,Y   ; |      
CODE_01C0BD:                      STA !AA,X    		;/ Use it to store up/down movement to Y speed.
CODE_01C0BF:                      JSL $01801A		; Update Y Pos, no gravity.   
CODE_01C0C2:                      LDA !C2,X 		;\    
CODE_01C0C4:                      STA $00               ;/ Preserve $C2,x to $00.  
CODE_01C0C6:                      LDA.w !151C,X		;\ Store sprite X position high into $01.       
CODE_01C0C9:                      STA $01               ;/
CODE_01C0CB:                      REP #$20              ; Accum (16 bit) 
CODE_01C0CD:                      LDA $94		;\         
CODE_01C0CF:                      SEC			; | Subtract $00 from Mario's X position.                      
CODE_01C0D0:                      SBC $00               ; |    
CODE_01C0D2:                      CMP.w #$0010 		; | If it's over 10 ..            
CODE_01C0D5:                      SEP #$20		; | I think it could be the X range to end the goal.
CODE_01C0D7:                      BCS Return01C12C      ;/  
CODE_01C0D9:                      LDA.w !1528,X 	;\           
CODE_01C0DC:                      CMP $96         	; |
CODE_01C0DE:                      LDA.w !1534,X		; |            
CODE_01C0E1:                      AND.b #$01            ; | If Mario is not in the vertical range of sprite, return.
CODE_01C0E3:                      SBC $97       	; |
CODE_01C0E5:                      BCC Return01C12C      ;/   
CODE_01C0E7:                     ; LDA.w $187B,X             ; \ $141C = #01 if Goal Tape triggers secret exit 
CODE_01C0EA:                     ; LSR                       ;  | 
CODE_01C0EB:                     ; LSR                       ;  | 
CODE_01C0EC:                     ; STA.w $141C               ; / 

LDA !7FAB10,x		;\
AND #$04		; |
BEQ +			; | Branch if extra bit clear.
INC $141C|!Base2		; | Otherwise, $141C = 01 (set secret goal flag).
+			; | I think this is why doesn't work in vertical levels.
			;/ $141C is ignored in vertical levels.
			; Too lazy to fix it though.
			; However, you can try LDA #$FF : STA $0DD5.
			; ..wait, I'm entirely wrong.
			; Nothing shows up on a vertical level!
			; Maybe the routine overall is crap?

CODE_01C0EF:                      LDA.b #!Music		; Play goal music.              
CODE_01C0F1:                      STA.w $1DFB|!Base2
CODE_01C0F4:                      LDA.b #$FF    	;\            
CODE_01C0F6:                      STA.w $0DDA|!Base2           ;/ Still have no idea what this does. Maybe it preserves old music?  
CODE_01C0F9:                      ;LDA.b #$FF  		; It's already loaded!              
CODE_01C0FB:                      STA.w $1493|!Base2 		; Set goal timer to FF.              
CODE_01C0FE:                      STZ.w $1490|!Base2		; Clear star timer.
CODE_01C101:                      INC.w !1602,X 	; Indicate that goal is on?            
CODE_01C104:                      JSL $01A7DC   	;\         
CODE_01C107:                      BCC CODE_01C125       ;/ If Mario touches sprite ..  
CODE_01C109:                      LDA.b #!Sfx		; .. execute all this code.
CODE_01C10B:                      STA.w $1DFC|!Base2		; Play sound.
CODE_01C10E:                      INC.w !160E,X		; This one is used as a flag to not draw the tape Gfx I believe.           
CODE_01C111:                      LDA.w !1528,X		;\ 	            
CODE_01C114:                      SEC                   ; | Subtract current Y position from initial one..  
CODE_01C115:                      SBC !D8,X       	; | And store into $1594,x. Probably used by below routine.
CODE_01C117:                      STA.w !1594,X         ;/    
CODE_01C11A:                      LDA.b #!BonusTimer	;\ Duration to draw bonus star #.             
CODE_01C11C:                      STA.w !1540,X         ;/     
CODE_01C11F:                      JSL.l $07F252
CODE_01C123:                      BRA CODE_01C128           

CODE_01C125:			  STZ !1686,x 		; Clear all tweaker bits.
CODE_01C128:			  JSL $00FA80 		; Trigger goal tape routine.
Return01C12C:			  RTS	
;====================

SprGfx:
CODE_01C12D:                      LDA.w !160E,X  	;\           
CODE_01C130:                      BNE CODE_01C175       ;/ If the goal tape has been touched, skip Gfx routine.  
CODE_01C132:                      %GetDrawInfo()   
CODE_01C135:                      LDA $00   		;\                
CODE_01C137:                      SEC                   ; | Apply X displacement.  
CODE_01C138:                      SBC.b #$08            ; | 
CODE_01C13A:                      STA.w $0300|!Base2,Y         ;/
CODE_01C13D:                      CLC         		;\              
CODE_01C13E:                      ADC.b #$08            ; | 
CODE_01C140:                      STA.w $0304|!Base2,Y    	;/ OAM Tile (X) #2
CODE_01C143:                      CLC      		;\                 
CODE_01C144:                      ADC.b #$08            ; |  
CODE_01C146:                      STA.w $0308|!Base2,Y    	;/ OAM tile (X) #3.
CODE_01C149:                      LDA $01  		;\ Get Y pos ..                 
CODE_01C14B:                      CLC                   ; |
CODE_01C14C:                      ADC.b #$08            ; | 
CODE_01C14E:                      STA.w $0301|!Base2,Y         ;/ Apply displacement and store.
CODE_01C151:                      STA.w $0305|!Base2,Y         ;\ There isn't any other tile to displace, so directly store.
CODE_01C154:                      STA.w $0309|!Base2,Y 	;/   
CODE_01C157:                      LDA.b #!Tile          ;\ Tile of sprite.  
CODE_01C159:                      STA.w $0302|!Base2,Y  	;/ Is stored to OAM tile.        
CODE_01C15C:                      INC A			;\                     
CODE_01C15D:                      STA.w $0306|!Base2,Y        	;/ The next ones are stored to the next OAM tiles.
CODE_01C160:                      STA.w $030A|!Base2,Y     	;\    
CODE_01C163:                      LDA.b #$32            ;\  
CODE_01C165:                      STA.w $0303|!Base2,Y         ; | Property byte for all tiles.
CODE_01C168:                      STA.w $0307|!Base2,Y         ; |
CODE_01C16B:                      STA.w $030B|!Base2,Y     	;/
CODE_01C16E:                      LDY.b #$00    	;\ We drew 8x8 tiles, so 00 instead of the normal 02.           
CODE_01C170:                      LDA.b #$02            ;/ # of tiles drawn = 3.
CODE_01C172:                      JSL $01B7B3		; Finish OAM write.
				  RTS 			;JMP.W FinishOAMWriteRt    

CODE_01C175:                      LDA.w !1540,X		    ;\   If bonus star number timer duration is over ..           
CODE_01C178:                      BEQ CODE_01C17F 	    ;/   Clear sprite.        
CODE_01C17A:                      JSL.l $07F1CA 	    ; This routine draws bonus star numbers after hitting the goal tape. Uncomment if you don't want any.         
Return01C17E:                     RTS                       ; Return 

CODE_01C17F:                      STZ.w !14C8,X   	    ; Erase sprite.          
Return01C182:                     RTS                       ; Return 
