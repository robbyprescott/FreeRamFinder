;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Turn Block Bridge Horizontal (and vertical) Disassembly
;By RealLink, edits by RussianMan and SJandCharlieTheCat
;USES FIRST EXTRA BIT: OPTIONAL

; By default will expand vertically first instead of horizontally
; If you set the extra bit (3), it will ONLY expand vertically
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Palette = $04 ; palette A. Palette 9 would be $02, etc.
!OnOffConditionality = 0 ; If enabled, will be toggled by on/off switch.
!TileFlipFix = 1		 ;Change this to 1 to fix last bridge turn block which is x-fliped.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Defines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BlkBridgeLength:                  db $20,$00	;Length - I don't recommend changing this. At least not to a bigger value than 20
TurnBlkBridgeSpeed:               db $01,$FF	;Folding speed - This can be changed, but be careful with big values
BlkBridgeTiming:                  db $40,$40	;Timer - This can be changed to any value
			!TurnblockGFX		= $40	;Tile to use (40 = Turnblock)

			!RAM_MarioYPosHi	= $97
			!RAM_MarioYPos		= $96
			!RAM_MarioSpeedY	= $7D
			!RAM_MarioAnimation	= $71
			!RAM_MarioXPos		= $94
			!RAM_MarioXPosHi	= $95
			!RAM_SpritesLocked	= $9D
			!RAM_SpriteState	= !C2
			!RAM_SpriteYLo		= !D8
			!RAM_SpriteXLo		= !E4
			!OAM_DispX		= $0300|!Base2
			!OAM_DispY		= $0301|!Base2
			!OAM_Tile		= $0302|!Base2
			!OAM_Prop		= $0303|!Base2
			!OAM_TileSize		= $0460|!Base2
			!RAM_SpriteYHi		= !14D4
			!RAM_SpriteXHi		= !14E0
			!RAM_SpriteDir		= !157C
			!RAM_SprOAMIndex	= !15EA
			!RAM_ScreenBndryYLo	= $1C
			!OAM_Tile3DispY		= $0309|!Base2
			!OAM_Tile4DispY		= $030D|!Base2
			!OAM_Tile2DispY		= $0305|!Base2
			!RAM_ScreenBndryXLo	= $1A
			!OAM_Tile3DispX		= $0308|!Base2
			!OAM_Tile4DispX		= $030C|!Base2
			!OAM_Tile2DispX		= $0304|!Base2
			!OAM_Tile2		= $0306|!Base2
			!OAM_Tile3		= $030A|!Base2
			!OAM_Tile4		= $030E|!Base2
			!OAM_Tile4Prop		= $030F|!Base2
			!OAM_Tile2Prop		= $0307|!Base2
			!OAM_Tile3Prop		= $030B|!Base2
			!RAM_OnYoshi		= $187A|!Base2
			!EXTRA_BITS 		= !7FAB10 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
LDA !7FAB28,x
BNE MoreChecks
Return:
RTL
MoreChecks:
LDA !EXTRA_BITS,x
AND #$04
BNE Return          ; changed from BEQ, by SJC
LDA #$02			;Start expanding vertically by setting sprite state to
STA !RAM_SpriteState,x		;02
RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR TurnBlkBridge       ;  |
                    PLB                     ;  |
                    RTL                     ; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sprite Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TurnBlkBridge:                    LDA #$00
				  %SubOffScreen()	   	;Off screen processing
CODE_01B6DD:                      JSR CODE_01B710         	;GFX Routine
CODE_01B6E0:                      JSR CODE_01B852         	;Mario interaction stuff
				  if !OnOffConditionality
				  LDA $14AF|!Base2
				  BNE Return01B702
				  endif
;CODE_01B6E3:                     JSR CODE_01B6E7         	;Timer
;Return01B6E6:                    RTS                       	; Return 
;RussianMan: Uncommented those 2 lines, for optimization sakes.

				  LDA !EXTRA_BITS,x
				  AND #$04
				  BEQ CODE_01B6B2      ; changed from BNE, by SJC
CODE_01B6E7:			  LDY !RAM_SpriteState,X     	;Go out/in state
				  BRA CODE_01B6E9
CODE_01B6B2:			  LDA !RAM_SpriteState,X
CODE_01B6B4:                      AND #$01                  	;00->00 01->01 02->00 03->01 usw.
CODE_01B6B6:                      TAY                       	;into Y
CODE_01B6E9:                      LDA !151C,x             	;\Length reached?
CODE_01B6EC:                      CMP BlkBridgeLength,Y   	; |go set time
CODE_01B6EF:                      BEQ CODE_01B703           	;/
CODE_01B6F1:                      LDA !1540,X             	;Timer
CODE_01B6F4:                      ORA !RAM_SpritesLocked     	;Sprites Locked
CODE_01B6F6:                      BNE Return01B702          	;not zero? Return
CODE_01B6F8:                      LDA !151C,x             	;\?
CODE_01B6FB:                      CLC                       	; |Add
CODE_01B6FC:                      ADC TurnBlkBridgeSpeed,Y 	; |speed to
CODE_01B6FF:                      STA !151C,X             	;/length
Return01B702:                     RTS                       	; Return 

CODE_01B703:                      LDA BlkBridgeTiming,Y   	;\Set timer
CODE_01B706:                      STA !1540,X             	;/
				  LDA !EXTRA_BITS,x
				  AND #$04
				  BEQ CODE_01B6D7   ; changed from BNE, by SJC
SkipCheck2:
CODE_01B709:                      LDA !RAM_SpriteState,X     	;\Change state around
CODE_01B70B:                      EOR #$01                	; |
CODE_01B70D:                      STA !RAM_SpriteState,X     	;/
				  BRA Return01B70F
CODE_01B6D7:                      INC !RAM_SpriteState,X    	;Increase State
Return01B70F:                     RTS                       	; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Mario interaction code below
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CODE_01B852:                      LDA !15C4,X             	;Sprite off screen
CODE_01B855:                      BNE Return01B8B1          	;Return
CODE_01B857:                      LDA !RAM_MarioAnimation    	;Mario doing a special action?
CODE_01B859:                      CMP #$01                	;
CODE_01B85B:                      BCS Return01B8B1          	;Return
CODE_01B85D:                      JSR CODE_01B8FF         	;
CODE_01B860:                      BCC Return01B8B1          	;No contact, return
CODE_01B862:                      LDA !RAM_SpriteYLo,X          ;
CODE_01B864:                      SEC                       	;
CODE_01B865:                      SBC !RAM_ScreenBndryYLo    	;
CODE_01B867:                      STA $02                       ;
CODE_01B869:                      SEC                           ;
CODE_01B86A:                      SBC $0D                       ;
CODE_01B86C:                      STA $09                       ;
CODE_01B86E:                      LDA $80                       ;
CODE_01B870:                      CLC                       	;
CODE_01B871:                      ADC #$18                	;
CODE_01B873:                      CMP $09                   	;
CODE_01B875:                      BCS ADDR_01B8B2		;
CODE_01B877:                      LDA !RAM_MarioSpeedY          ;
CODE_01B879:                      BMI Return01B8B1              ;
CODE_01B87B:                      STZ !RAM_MarioSpeedY          ;Mario is on top of the sprite interaction(?)
CODE_01B87D:                      LDA #$01                	;platform type
CODE_01B87F:                      STA $1471|!Base2              ;
CODE_01B882:                      LDA $0D                       ;
CODE_01B884:                      CLC                       	;
CODE_01B885:                      ADC #$1F                	;
CODE_01B887:                      LDY !RAM_OnYoshi         	;
CODE_01B88A:                      BEQ CODE_01B88F           	;
CODE_01B88C:                      CLC                       	;
CODE_01B88D:                      ADC #$10                	;
CODE_01B88F:                      STA $00                   	;
CODE_01B891:                      LDA !RAM_SpriteYLo,X       	;
CODE_01B893:                      SEC                       	;
CODE_01B894:                      SBC $00                   	;
CODE_01B896:                      STA !RAM_MarioYPos         	;
CODE_01B898:                      LDA !RAM_SpriteYHi,X     	;
CODE_01B89B:                      SBC #$00                	;
CODE_01B89D:                      STA !RAM_MarioYPosHi       	;
CODE_01B89F:                      LDY #$00                	;
CODE_01B8A1:                      LDA $1491|!Base2              ;
CODE_01B8A4:                      BPL CODE_01B8A7           	;
ADDR_01B8A6:                      DEY                       	;
CODE_01B8A7:                      CLC                       	;
CODE_01B8A8:                      ADC !RAM_MarioXPos         	;
CODE_01B8AA:                      STA !RAM_MarioXPos         	;
CODE_01B8AC:                      TYA                       	;
CODE_01B8AD:                      ADC !RAM_MarioXPosHi       	;
CODE_01B8AF:                      STA !RAM_MarioXPosHi       	;
Return01B8B1:                     RTS                       ; Return 

ADDR_01B8B2:                      LDA $02                       ;
ADDR_01B8B4:                      CLC                       	;
ADDR_01B8B5:                      ADC $0D                   	;
ADDR_01B8B7:                      STA $02                   	;
ADDR_01B8B9:                      LDA #$FF                	;
ADDR_01B8BB:                      LDY $73         		;
ADDR_01B8BD:                      BNE ADDR_01B8C3           	;
ADDR_01B8BF:                      LDY $19      			;
ADDR_01B8C1:                      BNE ADDR_01B8C5           	;
ADDR_01B8C3:                      LDA #$08                	;
ADDR_01B8C5:                      CLC                       	;
ADDR_01B8C6:                      ADC $80                   	;
ADDR_01B8C8:                      CMP $02                   	;
ADDR_01B8CA:                      BCC ADDR_01B8D5           	;
ADDR_01B8CC:                      LDA !RAM_MarioSpeedY       	;
ADDR_01B8CE:                      BPL Return01B8D4          	;
ADDR_01B8D0:                      LDA #$10                	;
ADDR_01B8D2:                      STA !RAM_MarioSpeedY       	;
Return01B8D4:                     RTS                       ; Return 

ADDR_01B8D5:                      LDA $0E                   	;
ADDR_01B8D7:                      CLC                       	;
ADDR_01B8D8:                      ADC #$10                	;
ADDR_01B8DA:                      STA $00                   	;
ADDR_01B8DC:                      LDY #$00                	;
ADDR_01B8DE:                      LDA !RAM_SpriteXLo,X       	;
ADDR_01B8E0:                      SEC                       	;
ADDR_01B8E1:                      SBC !RAM_ScreenBndryXLo    	;
ADDR_01B8E3:                      CMP $7E                   	;
ADDR_01B8E5:                      BCC ADDR_01B8EF           	;
ADDR_01B8E7:                      LDA $00                   	;
ADDR_01B8E9:                      EOR #$FF                	;
ADDR_01B8EB:                      INC A                     	;
ADDR_01B8EC:                      STA $00                   	;
ADDR_01B8EE:                      DEY                       	;
ADDR_01B8EF:                      LDA !RAM_SpriteXLo,X       	;
ADDR_01B8F1:                      CLC                       	;
ADDR_01B8F2:                      ADC $00                   	;
ADDR_01B8F4:                      STA !RAM_MarioXPos         	;
ADDR_01B8F6:                      TYA                       	;
ADDR_01B8F7:                      ADC !RAM_SpriteXHi,X     	;
ADDR_01B8FA:                      STA !RAM_MarioXPosHi       	;
ADDR_01B8FC:                      STZ $7B       		;
Return01B8FE:                     RTS                       ; Return 

CODE_01B8FF:                      LDA $00                  ;
CODE_01B901:                      STA $0E                  ;
CODE_01B903:                      LDA $02                  ;
CODE_01B905:                      STA $0D                  ;
CODE_01B907:                      LDA !RAM_SpriteXLo,X     ;
CODE_01B909:                      SEC                      ;
CODE_01B90A:                      SBC $00                  ;
CODE_01B90C:                      STA $04                  ;
CODE_01B90E:                      LDA !RAM_SpriteXHi,X     ;
CODE_01B911:                      SBC #$00                 ;
CODE_01B913:                      STA $0A                  ;
CODE_01B915:                      LDA $00                  ;
CODE_01B917:                      ASL                      ;
CODE_01B918:                      CLC                      ;
CODE_01B919:                      ADC #$10                 ;
CODE_01B91B:                      STA $06                  ;
CODE_01B91D:                      LDA !RAM_SpriteYLo,X     ;
CODE_01B91F:                      SEC                      ;
CODE_01B920:                      SBC $02                  ;
CODE_01B922:                      STA $05                  ;
CODE_01B924:                      LDA !RAM_SpriteYHi,X     ;
CODE_01B927:                      SBC #$00                 ;
CODE_01B929:                      STA $0B                  ;
CODE_01B92B:                      LDA $02                  ;
CODE_01B92D:                      ASL                      ;
CODE_01B92E:                      CLC                      ;
CODE_01B92F:                      ADC #$10                 ;
CODE_01B931:                      STA $07                  ;
CODE_01B933:                      JSL $03B664|!BankB       ;Mario clipping
CODE_01B937:                      JSL $03B72B|!BankB       ;check contact
Return01B93B:                     RTS                      ; Return 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GFX Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CODE_01B710:                      %GetDrawInfo()    
CODE_01B713:                      STZ $00                   
CODE_01B715:                      STZ $01                   
CODE_01B717:                      STZ $02                   
CODE_01B719:                      STZ $03                   
CODE_01B71B:                      LDA !RAM_SpriteState,X   
CODE_01B71D:                      AND #$02                 
CODE_01B71F:                      TAY     
				  LDA !7FAB28,x	   	   ;Extra Property		  
		    		  BEQ CODE_01B720	   ;clear go to CODE_01B720
				  LDA !EXTRA_BITS,x
				  AND #$04
				  BEQ CODE_01B720  ; changed from BNE, by SJC
				  LDY #$02		   ;There is probably a more elegant way to do it, but this works so...                  
CODE_01B720:                      LDA !151C,X             
CODE_01B723:                      STA $0000,Y              ;$0000 holds current length? Indexed by Y. If Y=02, $0002 is used, which is the length in vertical direction
CODE_01B726:                      LSR                      ;divide by 2
CODE_01B727:                      STA $0001,Y              ;Store into $0001, also indexed by Y. Same as above
CODE_01B72A:                      LDY !RAM_SprOAMIndex,X   ; Y = Index into sprite OAM 
CODE_01B72D:                      LDA !RAM_SpriteYLo,X       
CODE_01B72F:                      SEC                       
CODE_01B730:                      SBC !RAM_ScreenBndryYLo    
CODE_01B732:                      STA $0311|!Base2,Y             
CODE_01B735:                      PHA                       
CODE_01B736:                      PHA                       
CODE_01B737:                      PHA                       
CODE_01B738:                      SEC                       
CODE_01B739:                      SBC $02                   
CODE_01B73B:                      STA !OAM_Tile3DispY,Y    
CODE_01B73E:                      PLA                       
CODE_01B73F:                      SEC                       
CODE_01B740:                      SBC $03                   
CODE_01B742:                      STA !OAM_Tile4DispY,Y    
CODE_01B745:                      PLA                       
CODE_01B746:                      CLC                       
CODE_01B747:                      ADC $02                   
CODE_01B749:                      STA !OAM_DispY,Y         
CODE_01B74C:                      PLA                       
CODE_01B74D:                      CLC                       
CODE_01B74E:                      ADC $03                   
CODE_01B750:                      STA !OAM_Tile2DispY,Y    
CODE_01B753:                      LDA !RAM_SpriteXLo,X       
CODE_01B755:                      SEC                       
CODE_01B756:                      SBC !RAM_ScreenBndryXLo    
CODE_01B758:                      STA $0310|!Base2,Y             
CODE_01B75B:                      PHA                       
CODE_01B75C:                      PHA                       
CODE_01B75D:                      PHA                       
CODE_01B75E:                      SEC                       
CODE_01B75F:                      SBC $00                   
CODE_01B761:                      STA !OAM_Tile3DispX,Y     ;leftmost tile
CODE_01B764:                      PLA                       
CODE_01B765:                      SEC                       
CODE_01B766:                      SBC $01                   
CODE_01B768:                      STA !OAM_Tile4DispX,Y     ;second tile from the left
CODE_01B76B:                      PLA                       
CODE_01B76C:                      CLC                       
CODE_01B76D:                      ADC $00                   
CODE_01B76F:                      STA !OAM_DispX,Y          ;rightmost tile
CODE_01B772:                      PLA                       
CODE_01B773:                      CLC                       
CODE_01B774:                      ADC $01                   
CODE_01B776:                      STA !OAM_Tile2DispX,Y     ;second tile from the right
CODE_01B779:                      LDA !RAM_SpriteState,X    ;
CODE_01B77B:                      LSR                       ;
CODE_01B77C:                      LSR                       ;
CODE_01B77D:                      LDA #!TurnblockGFX                
CODE_01B77F:                      STA !OAM_Tile2,Y          ;second tile from the right
CODE_01B782:                      STA !OAM_Tile4,Y          ;second tile from the left
CODE_01B785:                      STA $0312|!Base2,Y               ;Middle tile
CODE_01B788:                      STA !OAM_Tile3,Y          ;leftmost tile
CODE_01B78B:                      STA !OAM_Tile,Y           ;rightmost tile
                                  LDA #!Palette
CODE_01B78E:                      ORA $64                   
CODE_01B790:                      STA !OAM_Tile4Prop,Y      ;OXOOO
CODE_01B793:                      STA !OAM_Tile2Prop,Y      ;OOOXO
CODE_01B796:                      STA !OAM_Tile3Prop,Y      ;XOOOO
CODE_01B799:                      STA $0313|!Base2,Y               ;OOXOO
				  If !TileFlipFix == 0
CODE_01B79C:                      ORA #$60                  
				  endif
CODE_01B79E:                      STA !OAM_Prop,Y           ;OOOOX
CODE_01B7A1:                      LDA $00                   
CODE_01B7A3:                      PHA                       
CODE_01B7A4:                      LDA $02                   
CODE_01B7A6:                      PHA                       
CODE_01B7A7:                      LDA #$04                
CODE_01B7A9:                      JSR CODE_01B37E         
CODE_01B7AC:                      PLA                       
CODE_01B7AD:                      STA $02                   
CODE_01B7AF:                      PLA                       
CODE_01B7B0:                      STA $00                   
Return01B7B2:                     RTS                       ; Return 

CODE_01B37E:                      LDY #$02                
CODE_01B380:                      JMP FinishOAMWriteRt 

FinishOAMWriteRt:                 STY $0B                   
CODE_01B7BD:                      STA $08                   
CODE_01B7BF:                      LDY !RAM_SprOAMIndex,X   ; Y = Index into sprite OAM 
CODE_01B7C2:                      LDA !RAM_SpriteYLo,X       
CODE_01B7C4:                      STA $00                   
CODE_01B7C6:                      SEC                       
CODE_01B7C7:                      SBC !RAM_ScreenBndryYLo    
CODE_01B7C9:                      STA $06                   
CODE_01B7CB:                      LDA !RAM_SpriteYHi,X     
CODE_01B7CE:                      STA $01                   
CODE_01B7D0:                      LDA !RAM_SpriteXLo,X       
CODE_01B7D2:                      STA $02                   
CODE_01B7D4:                      SEC                       
CODE_01B7D5:                      SBC !RAM_ScreenBndryXLo    
CODE_01B7D7:                      STA $07                   
CODE_01B7D9:                      LDA !RAM_SpriteXHi,X     
CODE_01B7DC:                      STA $03                   
CODE_01B7DE:                      TYA                       
CODE_01B7DF:                      LSR                       
CODE_01B7E0:                      LSR                       
CODE_01B7E1:                      TAX                       
CODE_01B7E2:                      LDA $0B                   
CODE_01B7E4:                      BPL CODE_01B7F0           
CODE_01B7E6:                      LDA !OAM_TileSize,X      
CODE_01B7E9:                      AND #$02                
CODE_01B7EB:                      STA !OAM_TileSize,X      
CODE_01B7EE:                      BRA CODE_01B7F3           

CODE_01B7F0:                      STA !OAM_TileSize,X      
CODE_01B7F3:                      LDX #$00                
CODE_01B7F5:                      LDA !OAM_DispX,Y         
CODE_01B7F8:                      SEC                       
CODE_01B7F9:                      SBC $07                   
CODE_01B7FB:                      BPL CODE_01B7FE           
CODE_01B7FD:                      DEX                       
CODE_01B7FE:                      CLC                       
CODE_01B7FF:                      ADC $02                   
CODE_01B801:                      STA $04                   
CODE_01B803:                      TXA                       
CODE_01B804:                      ADC $03                   
CODE_01B806:                      STA $05                   
CODE_01B808:                      JSR CODE_01B844         
CODE_01B80B:                      BCC CODE_01B819           
CODE_01B80D:                      TYA                       
CODE_01B80E:                      LSR                       
CODE_01B80F:                      LSR                       
CODE_01B810:                      TAX                       
CODE_01B811:                      LDA !OAM_TileSize,X      
CODE_01B814:                      ORA #$01                
CODE_01B816:                      STA !OAM_TileSize,X      
CODE_01B819:                      LDX #$00                
CODE_01B81B:                      LDA !OAM_DispY,Y         
CODE_01B81E:                      SEC                       
CODE_01B81F:                      SBC $06                   
CODE_01B821:                      BPL CODE_01B824           
CODE_01B823:                      DEX                       
CODE_01B824:                      CLC                       
CODE_01B825:                      ADC $00                   
CODE_01B827:                      STA $09                   
CODE_01B829:                      TXA                       
CODE_01B82A:                      ADC $01                   
CODE_01B82C:                      STA $0A                   
CODE_01B82E:                      JSR CODE_01C9BF         
CODE_01B831:                      BCC CODE_01B838           
CODE_01B833:                      LDA #$F0                
CODE_01B835:                      STA !OAM_DispY,Y         
CODE_01B838:                      INY                       
CODE_01B839:                      INY                       
CODE_01B83A:                      INY                       
CODE_01B83B:                      INY                       
CODE_01B83C:                      DEC $08                   
CODE_01B83E:                      BPL CODE_01B7DE           
CODE_01B840:                      LDX $15E9|!Base2               ; X = Sprite index 
Return01B843:                     RTS                       ; Return 

CODE_01B844:                      REP #$20                  ; Accum (16 bit) 
CODE_01B846:                      LDA $04                   
CODE_01B848:                      SEC                       
CODE_01B849:                      SBC !RAM_ScreenBndryXLo    
CODE_01B84B:                      CMP #$0100              
CODE_01B84E:                      SEP #$20                  ; Accum (8 bit) 
Return01B850:                     RTS                       ; Return 

;Return01B851:                     RTS             	             
;RussianMan: Why is this even needed ^ ?

CODE_01C9BF:                      REP #$20                  ; Accum (16 bit) 
CODE_01C9C1:                      LDA $09                   
CODE_01C9C3:                      PHA                       
CODE_01C9C4:                      CLC                       
CODE_01C9C5:                      ADC #$0010              
CODE_01C9C8:                      STA $09                   
CODE_01C9CA:                      SEC                       
CODE_01C9CB:                      SBC !RAM_ScreenBndryYLo    
CODE_01C9CD:                      CMP #$0100              
CODE_01C9D0:                      PLA                       
CODE_01C9D1:                      STA $09                   
CODE_01C9D3:                      SEP #$20                  ; Accum (8 bit) 
Return01C9D5:                     RTS                       ; Return 