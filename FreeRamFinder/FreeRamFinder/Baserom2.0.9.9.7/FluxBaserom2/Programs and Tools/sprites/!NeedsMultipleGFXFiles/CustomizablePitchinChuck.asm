;Pitchin' Chuck disassembly with added features and SA-1 support
;Created by dtothefourth
;Disassembly notes thanks to Kaizoman

!Baseball      = #$1A  ;extended sprite to throw $0D for vanilla baseball
					   ;to use aiming need to use the included custom extended baseball (note that you have to add hex $13 to the extended insert number from the pixi list)
					   ;example list.txt
					   ;EXTENDED:
					   ;02 Baseball.asm
					   ;Then set !Baseball to #$15

!BaseballSpeed = #$18  ;Speed for thrown baseballs
!ShotFrequency = #$1F  ;Throwing frequency in frames. ANDed with frame counter so use $07,$0F,$1F,$3F,$7F etc. Lower than 7 will not work	
!TimerExtend   = #$07  ;Timer extension - used to make the throwing phase last longer. ANDed with frame counter so use $01,$03,$07,$0F,$1F,$3F,$7F etc.
					   ;Smaller values mean longer shooting phase and more baseballs
!DownTime	   = #$40  ;How many frames to not throw baseballs
!ThrowOffset   = #$40  ;Timing offset for throw animation, may need to be tweaked when changing shot frequency and phase lengths to line up the animation
					   ;If the phase length differences in DATA_02C3B3 below aren't multiples of the shot frequency (+1), the animations won't line up between different X positions

!jump		   = 1	   ;1 to enable jumping
!JumpSpeed	   = #$C8  ;Y Speed when jumping
!JumpDist	   = #$D0  ;Distance to trigger jumping

!aim		   = 0	   ;1 to have baseballs aimed at mario instead of horizontal

!ChargeOnHurt  = 1	   ;1 to become a charging chuck after being jumped on, 0 will remain pitching
!Health		   = #$03  ;Number of bounces to kill the chuck

!Direction	   = 2	   ;0 - right only, 1 - left only, 2 - normal turning

DATA_02C79B:                    ;$02C79B    | X speeds to give Mario when bouncing off of a Chuck.
    db $20,$E0

DATA_02C3B3:                    ;$02C3B3    | Length of the Baseball Chuck's throwing "sets", indexed by its X position mod 4.
    db $7F,$BF,$FF,$DF                      ; Effectively equates to 2, 4, 6, and 5 baseballs respectively with default shot frequency

DATA_02C3B7:                    ;$02C3B7    | Animation frames for the Baseball Chuck's throwing animation.
    db $18,$19,$14,$14

DATA_02C3BB:                    ;$02C3BB    | Animation frames for the Baseball Chuck's throwing animation during a jump.
    db $18,$18,$18,$18,$17,$17,$17,$17
    db $17,$17,$16,$15,$15,$16,$16,$16

BaseballTileDispX:              ;$02C460    | X offsets (lo) for the baseballs spawned by the Pitchin' Chuck.
    db $10,$F8

DATA_02C462:                    ;$02C462    | X offsets (hi) for the baseballs spawned by the Pitchin' Chuck.
    db $00,$FF



Print "INIT ",pc
					PHB
					PHK
					PLB
InitPitchinChuck:   LDA !E4,X       
CODE_0184EF:        AND.B #$30                
CODE_0184F1:        LSR                       
CODE_0184F2:        LSR                       
CODE_0184F3:        LSR                       
CODE_0184F4:        LSR                       
CODE_0184F5:        STA !187B,X             
CODE_0184F8:        LDA.B #$04                            
CODE_01851A:        STA !C2,X     

					if !Direction = 2
					%SubHorzPos()
					TYA
					else
					LDA #$!Direction
					TAY

					endif
					STA !157C,x       
CODE_01851F:        LDA.W DATA_018526,Y       
CODE_018522:        STA !151C,X    
					PLB         
Return018525:       RTL   

DATA_018526: 
	db $00,$04

Print "MAIN ",pc	
ChucksMain:                     ;-----------| Chuck MAIN.
    PHB                         ;$02C1F5    |
    PHK                         ;$02C1F6    |
    PLB                         ;$02C1F7    |
    LDA !187B,X               ;$02C1F8    |
    PHA                         ;$02C1FB    |
    JSR CODE_02C22C             ;$02C1FC    | Run main Chuck routine.
    PLA                         ;$02C1FF    |
    BNE CODE_02C211             ;$02C200    |\ 
    CMP !187B,X               ;$02C202    ||
    BEQ CODE_02C211             ;$02C205    ||
    LDA !163E,X               ;$02C207    || If Mario was just spotted, set an unused timer.
    BNE CODE_02C211             ;$02C20A    ||  Related to the unused code at $02C6B5.
    LDA.b #$28                  ;$02C20C    ||
    STA !163E,X               ;$02C20E    |/
CODE_02C211:                    ;           |
    PLB                         ;$02C211    |
    RTL                         ;$02C212    |



DATA_02C1F3:                    ;           |
    db $01,$03

DATA_02C213:                    ;$02C213    | Animation frames to give the Chuck's head when dying.
    db $01,$02,$03,$02

CODE_02C217:                    ;-----------| Animation for the Chuck dying.
    LDA $14                     ;$02C217    |\ 
    LSR                         ;$02C219    ||
    LSR                         ;$02C21A    ||
    AND.b #$03                  ;$02C21B    || Handle the death animation (shaking the Chuck's head).
    TAY                         ;$02C21D    ||
    LDA.w DATA_02C213,Y         ;$02C21E    ||
    STA !151C,X               ;$02C221    |/
    JSR CODE_02C81A             ;$02C224    | Draw GFX.
	
	LDA $9D
	BNE +
	JSL $1802A
	+
    RTS                         ;$02C227    |



DATA_02C228:                    ;$02C228    | Max falling speeds for Chucks. First value is out of water, second is in.
    db $40,$10

DATA_02C22A:                    ;$02C22A    | Gravity for Chucks. First value is out of water, second is in.
    db $03,$01

CODE_02C22C:                    ;-----------| Actual main routine for the Chucks.
    LDA !14C8,X               ;$02C22C    |\ 
    CMP.b #$08                  ;$02C22F    || Branch to just handle graphics if dying.
    BNE CODE_02C217             ;$02C231    |/
    LDA !15AC,X               ;$02C233    |\ 
    BEQ CODE_02C23D             ;$02C236    || If just starting to charge, set an "inbetween" animation frame for the Chuck (5).
    LDA.b #$05                  ;$02C238    ||
    STA !1602,X               ;$02C23A    |/
CODE_02C23D:                    ;           |
    LDA !1588,X               ;$02C23D    |\ 
    AND.b #$04                  ;$02C240    ||
    BNE CODE_02C253             ;$02C242    ||
    LDA !AA,X                   ;$02C244    ||
    BPL CODE_02C253             ;$02C246    || Handle the animation frame for when the Chuck is jumping (6).
    LDA !C2,X                   ;$02C248    ||
    CMP.b #$03                  ;$02C24A    ||
    BCS CODE_02C253             ;$02C24C    ||
    LDA.b #$06                  ;$02C24E    ||
    STA !1602,X               ;$02C250    |/
CODE_02C253:                    ;           |
    JSR CODE_02C81A             ;$02C253    | Draw GFX.
    LDA $9D                     ;$02C256    |\ Branch if game isn't frozen.
    BEQ CODE_02C25B             ;$02C258    |/
    RTS                         ;$02C25A    |

CODE_02C25B:                    ;```````````| Game isn't frozen.
	LDA #$00
	%SubOffScreen()
    JSR CODE_02C79D             ;$02C25E    | Process interaction with Mario.
    JSL $018032|!BankB		    ;$02C261    | Process interaction with sprites.
    JSL $019138|!BankB          ;$02C265    | Process interaction with blocks.
    LDA !1588,X               ;$02C269    |\ 
    AND.b #$08                  ;$02C26C    ||
    BEQ CODE_02C274             ;$02C26E    ||
    LDA.b #$10                  ;$02C270    ||| Y speed to give the Chuck when it hits a ceiling.
    STA !AA,X                   ;$02C272    |/
CODE_02C274:                    ;           |
    LDA !1588,X               ;$02C274    |\ 
    AND.b #$03                  ;$02C277    || Branch if not blocked on the left/right.
    BEQ CODE_02C2F4             ;$02C279    |/
    LDA !15A0,X               ;$02C27B    |\ 
    ORA !186C,X               ;$02C27E    ||
    BNE CODE_02C2E4             ;$02C281    ||
    LDA !187B,X               ;$02C283    || Branch to make the Chuck jump if:
    BEQ CODE_02C2E4             ;$02C286    ||  - Offscreen
    LDA !E4,x                   ;$02C288    ||  - Not chasing after Mario
    SEC                         ;$02C28A    ||  - Not far enough onscreen (about 1 tile)
    SBC $1A                     ;$02C28B    ||  - Touching the side of Layer 2
    CLC                         ;$02C28D    ||  - Not touching a turnblock/throwblock
    ADC.b #$14                  ;$02C28E    ||
    CMP.b #$1C                  ;$02C290    ||
    BCC CODE_02C2E4             ;$02C292    ||
    LDA !1588,X               ;$02C294    ||
    AND.b #$40                  ;$02C297    ||
    BNE CODE_02C2E4             ;$02C299    ||
    LDA.w $18A7|!Base2          ;$02C29B    ||
    CMP.b #$2E                  ;$02C29E    ||
    BEQ CODE_02C2A6             ;$02C2A0    ||
    CMP.b #$1E                  ;$02C2A2    ||
    BNE CODE_02C2E4             ;$02C2A4    |/
CODE_02C2A6:                    ;```````````| Chuck is breaking a block.
    LDA !1588,X               ;$02C2A6    |\ 
    AND.b #$04                  ;$02C2A9    || Branch if not on the ground.
    BEQ CODE_02C2F7             ;$02C2AB    |/
    LDA $9B                     ;$02C2AD    |
    PHA                         ;$02C2AF    |
    LDA $9A                     ;$02C2B0    |
    PHA                         ;$02C2B2    |
    LDA $99                     ;$02C2B3    |
    PHA                         ;$02C2B5    |
    LDA $98                     ;$02C2B6    |
    PHA                         ;$02C2B8    |
    JSL $028663|!BankB	        ;$02C2B9    |\ 
    LDA.b #$02                  ;$02C2BD    || Shatter the lower block.
    STA $9C                     ;$02C2BF    || 
    JSL $00BEB0|!BankB		    ;$02C2C1    |/
    PLA                         ;$02C2C5    |\ 
    SEC                         ;$02C2C6    ||
    SBC.b #$10                  ;$02C2C7    ||
    STA $98                     ;$02C2C9    ||
    PLA                         ;$02C2CB    ||
    SBC.b #$00                  ;$02C2CC    || Shift the block position up one tile.
    STA $99                     ;$02C2CE    ||
    PLA                         ;$02C2D0    ||
    STA $9A                     ;$02C2D1    ||
    PLA                         ;$02C2D3    ||
    STA $9B                     ;$02C2D4    |/
    JSL $028663|!BankB			;$02C2D6    |\ 
    LDA.b #$02                  ;$02C2DA    || Shatter the upper block.
    STA $9C                     ;$02C2DC    ||
    JSL $00BEB0|!BankB			;$02C2DE    |/
    BRA CODE_02C2F4             ;$02C2E2    |

CODE_02C2E4:                    ;```````````| Chuck is not blocked but not able to break; make him jump instead.
    LDA !1588,X               ;$02C2E4    |\ 
    AND.b #$04                  ;$02C2E7    || Branch if not on the ground.
    BEQ CODE_02C2F7             ;$02C2E9    |/
    LDA.b #$C0                  ;$02C2EB    |\ Y speed for the Chuck's jumps after running into a block
    STA !AA,X                   ;$02C2ED    |/
    JSL $01801A|!BankB			;$02C2EF    | Update Y position.
    BRA CODE_02C301             ;$02C2F2    |

CODE_02C2F4:                    ;```````````| Chuck is not blocked on the side.
    JSL $018022|!BankB		    ;$02C2F4    | Update X position.
CODE_02C2F7:                    ;```````````| Chuck is blocked on the side but not on the ground.
    LDA !1588,X               ;$02C2F7    |\ 
    AND.b #$04                  ;$02C2FA    || If on the ground, clear X/Y speed. 
    BEQ CODE_02C301             ;$02C2FC    ||
    JSR CODE_02C579             ;$02C2FE    |/
CODE_02C301:                    ;```````````| Done with routine for being blocked on the side.
    JSL $01801A|!BankB			;$02C301    | Update Y position.
    LDY !164A,X               ;$02C304    |\ 
    CPY.b #$01                  ;$02C307    ||
    LDY.b #$00                  ;$02C309    ||
    LDA !AA,X                   ;$02C30B    || Handle gravity.
    BCC CODE_02C31A             ;$02C30D    ||
    INY                         ;$02C30F    ||
    CMP.b #$00                  ;$02C310    ||\ 
    BPL CODE_02C31A             ;$02C312    |||
    CMP.b #$E0                  ;$02C314    ||| Limit rising speed in water to E0 (-32).
    BCS CODE_02C31A             ;$02C316    |||
    LDA.b #$E0                  ;$02C318    ||/
CODE_02C31A:                    ;           ||
    CLC                         ;$02C31A    ||\ Apply appropriate gravity based on whether the Chuck is in water.
    ADC.w DATA_02C22A,Y         ;$02C31B    ||/
    BMI CODE_02C328             ;$02C31E    ||\ 
    CMP.w DATA_02C228,Y         ;$02C320    ||| Limit falling speed for the water, too.
    BCC CODE_02C328             ;$02C323    |||
    LDA.w DATA_02C228,Y         ;$02C325    ||/
CODE_02C328:                    ;           ||
    TAY                         ;$02C328    ||\ 
    BMI CODE_02C334             ;$02C329    |||
    LDY !C2,X                   ;$02C32B    |||
    CPY.b #$07                  ;$02C32D    ||| If the Chuck just landed, increase his Y speed slightly more, for some reason.
    BNE CODE_02C334             ;$02C32F    |||
    CLC                         ;$02C331    |||
    ADC.b #$03                  ;$02C332    ||/
CODE_02C334:                    ;           ||
    STA !AA,X                   ;$02C334    |/
    LDA !C2,X                   ;$02C336    |
    JSL $0086DF|!BankB          ;$02C338    |

ChuckPtrs:                      ;$02C33C    | Chuck routine pointers.
    dw CODE_02C63B                          ; 0 - Looking from side to side (Chargin')
    dw CODE_02C6A7                          ; 1 - Chargin'
    dw CODE_02C726                          ; 2 - Preparing to charge
    dw CODE_02C74A                          ; 3 - Hurt
    dw CODE_02C3CB                          ; 4 - Pitchin'





	   
CODE_02C3CB:                    ;-----------| Chuck routine A - Pitchin'
	if !jump = 1
    LDA !1534,X               ;$02C3CB    |\ Branch if the Chuck is already jumping.
    BNE CODE_02C43A             ;$02C3CE    |/
    %SubVertPos()				;$02C3D0    |\ 
    LDA $0F                     ;$02C3D3    ||
    BPL CODE_02C3E7             ;$02C3D5    || If Mario is at least 2 tiles above the Chuck, make him jump.
    CMP.b !JumpDist                  ;$02C3D7    ||
    BCS CODE_02C3E7             ;$02C3D9    ||
    LDA !JumpSpeed                  ;$02C3DB    ||| Y speed the Pitchin' Chuck jumps with.
    STA !AA,X                   ;$02C3DD    ||
    LDA.b #$3E                  ;$02C3DF    ||
    STA !1540,x               ;$02C3E1    ||
    INC !1534,x               ;$02C3E4    |/
	endif
CODE_02C3E7:                    ;           |
    LDA $13                     ;$02C3E7    |\ 
    AND !TimerExtend                  ;$02C3E9    ||
    BNE CODE_02C3F5             ;$02C3EB    || Extend the timer for throwing slightly.
    LDA !1540,x               ;$02C3ED    ||  (adds 1/8th the time, or between 15 and 30 frames depending on the initial timer)
    BEQ CODE_02C3F5             ;$02C3F0    ||
    INC !1540,x               ;$02C3F2    |/
CODE_02C3F5:                    ;           |
    if !Direction = 2

	if !aim = 0					; no frame delay on turnaround when aiming otherwise looks weird throwing backwards
	LDA $14                     ;$02C3F5    |\ 
    AND.b #$3F                  ;$02C3F7    || Face the Chuck towards Mario every 64 frames.
    BNE CODE_02C3FE             ;$02C3F9    ||  (note that this doesn't apply when jumping)
	endif
    JSR CODE_02C556             ;$02C3FB    |/
	endif
CODE_02C3FE:                    ;           |
    LDA !1540,x               ;$02C3FE    |\ 
    BNE CODE_02C40C             ;$02C401    ||
    LDY !187B,x               ;$02C403    || If done with the current set of baseballs, start the next one.
    LDA.w DATA_02C3B3,Y         ;$02C406    ||
    STA !1540,x               ;$02C409    |/
CODE_02C40C:                    ;           |
    LDA !1540,x               ;$02C40C    |\ 
    CMP !DownTime                  ;$02C40F    || Branch if still throwing baseballs for the current set.
    BCS CODE_02C419             ;$02C411    |/
    LDA.b #$00                  ;$02C413    |\ Animation for the Chuck inbetween sets of baseballs.
    STA !1602,x               ;$02C415    |/
    RTS                         ;$02C418    |

CODE_02C419:                    ;```````````| Baseball Chuck is in the process of throwing a set of baseballs.
    SEC                         ;$02C419    |\ 
    SBC !ThrowOffset             ;$02C41A    ||

	;make throw animation match altered shot frequency
	STA $00
	LDY !ShotFrequency
	-
	LDA $00
    LSR                         ;$02C41C    ||
    STA $00
	TYA
	LSR
	TAY
	CMP #$04
	BPL -
	LDA $00

    AND.b #$03                  ;$02C41F    ||
    TAY                         ;$02C421    ||
    LDA.w DATA_02C3B7,Y         ;$02C422    ||
    STA !1602,x               ;$02C425    |/
    LDA !1540,x               ;$02C428    |\ 
    AND !ShotFrequency        ;$02C42B    ||| How often the Baseball Chuck throws a baseball
    CMP.b #$06                  ;$02C42D    ||
    BNE Return02C439            ;$02C42F    || Spawn a baseball when time to do so.
    JSR CODE_02C466             ;$02C431    ||
    LDA.b #$08                  ;$02C434    ||
    STA !1558,x               ;$02C436    |/
Return02C439:                   ;           |
    RTS                         ;$02C439    |

CODE_02C43A:                    ;```````````| Baseball Chuck is jumping.
    LDA !1540,x               ;$02C43A    |\ Branch if done with the jump.
    BEQ CODE_02C45C             ;$02C43D    |/
    PHA                         ;$02C43F    |
    CMP.b #$20                  ;$02C440    |\ 
    BCC CODE_02C44A             ;$02C442    ||
    CMP.b #$30                  ;$02C444    || Clear the Chuck's Y speed if at the height of its jump (timer between 20 and 30).
    BCS CODE_02C44A             ;$02C446    ||
    STZ !AA,X                   ;$02C448    |/
CODE_02C44A:                    ;           |
    LSR                         ;$02C44A    |\ 
    LSR                         ;$02C44B    ||
    TAY                         ;$02C44C    || Set the animation frame for the throwing animation.
    LDA.w DATA_02C3BB,Y         ;$02C44D    ||
    STA !1602,x               ;$02C450    |/
    PLA                         ;$02C453    |
    CMP.b #$26                  ;$02C454    |\ 
    BNE Return02C45B            ;$02C456    || Actually spawn the baseball when time to do so.
    JSR CODE_02C466             ;$02C458    |/
Return02C45B:                   ;           |
    RTS                         ;$02C45B    |

CODE_02C45C:                    ;```````````| Done the jump.
    STZ !1534,x               ;$02C45C    | Clear the jumping flag.
    RTS                         ;$02C45F    |


CODE_02C466:                    ;-----------| Subroutine to spawn a baseball for the Pitchin' Chuck.
    LDA !1558,x               ;$02C466    |\ 
    ORA !186C,x               ;$02C469    || Return if the Chuck is offscreen, or has already spawned a baseball.
    BNE Return02C439            ;$02C46C    |/
    LDY.b #$07                  ;$02C46E    |\ 
CODE_02C470:                    ;           ||
    LDA.w $170B|!Base2,Y               ;$02C470    || Find an empty extended sprite slot.
    BEQ CODE_02C479             ;$02C473    ||
    DEY                         ;$02C475    ||
    BPL CODE_02C470             ;$02C476    |/
    RTS                         ;$02C478    |

CODE_02C479:
    LDA !Baseball             ;$02C479    |\\ Extended sprite to spawn (baseball)
    STA.w $170B|!Base2,Y        ;$02C47B    |/
    LDA !E4,x                   ;$02C47E    |
    STA $00                     ;$02C480    |
    LDA !14E0,x               ;$02C482    |
    STA $01                     ;$02C485    |
    LDA !D8,x                   ;$02C487    |\ 
    CLC                         ;$02C489    ||
    ADC.b #$00                  ;$02C48A    ||
    STA.w $1715|!Base2,Y        ;$02C48C    || Spawn at the Chuck's Y position.
    LDA !14D4,x               ;$02C48F    ||
    ADC.b #$00                  ;$02C492    ||
    STA.w $1729|!Base2,Y        ;$02C494    |/
    PHX                         ;$02C497    |
    LDA !157C,x               ;$02C498    |\ 
    TAX                         ;$02C49B    ||
    LDA $00                     ;$02C49C    ||
    CLC                         ;$02C49E    ||
    ADC.w BaseballTileDispX,X   ;$02C49F    || Spawn at the Chuck's X position, offset in front of it.
    STA.w $171F|!Base2,Y        ;$02C4A2    ||

    LDA $01                     ;$02C4A5    ||
    ADC.w DATA_02C462,X         ;$02C4A7    ||
    STA.w $1733|!Base2,Y               ;$02C4AA    |/

	LDA $1715|!Base2,y
	STA $02
	LDA $1729|!Base2,y
	STA $03

	LDA $171F|!Base2,y
	STA $00
	LDA $1733|!Base2,y
	STA $01



	REP #$20                    ;\ Setup parameters for the aiming routine.
	LDA $00                     ;|
	SEC : SBC $94		        ;|
	STA $00                     ;|
	LDA $02                     ;|
	SEC : SBC $96		        ;|
	SBC #$0010                  ;|
	STA $02                     ;|
	SEP #$20                    ;|


    PLX                         ;$02C4B3    |

	if !aim = 1
	LDA !BaseballSpeed			;$02C4AD  
    %Aiming()

	if !Direction != 2
	PHY
	%SubHorzPos()
	TYA
	CMP !157C,x
	BEQ +
	LDA $00
	EOR #$FF
	INC
	STA $00
	+
	PLY
	endif

    LDA $00                     ;\ set new extended sprite x speed
    STA $1747|!Base2,y      ;/
    LDA $02                     ;\ set new extended sprite y speed
    STA $173D|!Base2,y      ;/



	else

	LDA !157C,x               ;$02C498    |\ 
    BEQ +

	LDA !BaseballSpeed	
	EOR #$FF
	INC
	BRA ++
	+
	LDA !BaseballSpeed	

	++
    STA $1747|!Base2,y      ;\ set new extended sprite x speed


	endif


    RTS                         ;$02C4B4    |


CODE_02C556:                    ;```````````| Routine to make the Chuck face Mario.
    %SubHorzPos()				;$02C556    |\ 
    TYA                         ;$02C559    ||
    STA !157C,x               ;$02C55A    || Face Mario.
    LDA.w DATA_02C639,Y         ;$02C55D    ||
    STA !151C,x               ;$02C560    |/
    RTS                         ;$02C563    |

CODE_02C579:                    ;           |
    STZ !B6,X                   ;$02C579    |\ Clear X/Y speed.
    STZ !AA,X                   ;$02C57B    |/
Return02C57D:                   ;           |
    RTS                         ;$02C57D    |


CODE_02C628:                    ;-----------| Chuck subroutine to set a timer for the "inbetween" animation frame when starting to charge.
    LDA.b #$08                  ;$02C628    |\\ How long the animation frame lasts.
    STA !15AC,x               ;$02C62A    |/
    RTS                         ;$02C62D    |



DATA_02C62E:                    ;$02C62E    | Animation frames for the head-turning animation the Chuck uses when waiting to charge.
    db $00,$00,$00,$00,$01,$02,$03,$04
    db $04,$04,$04

DATA_02C639:                    ;$02C639    | Head animation frames for the Chuck when facing towards Mario.
    db $00,$04

CODE_02C63B:                    ;-----------| Chuck routine 0 - Looking from side to side.
    LDA.b #$03                  ;$02C63B    |\ Animation frame for the Chuck while waiting to charge (3).
    STA !1602,x               ;$02C63D    |/
    STZ !187B,x               ;$02C640    | Clear flag for whether Mario has been found.
    LDA !1540,x               ;$02C643    |\ 
    AND.b #$0F                  ;$02C646    || Branch if not a frame to check whether to run towards Mario.
    BNE CODE_02C668             ;$02C648    |/
    %SubVertPos()          ;$02C64A    |\ 
    LDA $0F                     ;$02C64D    ||
    CLC                         ;$02C64F    ||
    ADC.b #$28                  ;$02C650    || If Mario is within 2 tiles vertically, face him and mark him in the Chuck's line of sight.
    CMP.b #$50                  ;$02C652    ||
    BCS CODE_02C668             ;$02C654    ||
    JSR CODE_02C556             ;$02C656    ||
    INC !187B,x               ;$02C659    |/
CODE_02C65C:                    ;           |
    LDA.b #$02                  ;$02C65C    |\ Switch to the phase 2 (preparing to charge).
    STA !C2,x                   ;$02C65E    |/
    LDA.b #$18                  ;$02C660    |\ How long the Chuck waits before actually charging.
    STA !1540,x               ;$02C662    |/
    RTS                         ;$02C665    |


DATA_02C666:                    ;$02C666    | Increment/decrement values for handling the Chargin' Chuck's head-turning animation prior to a charge.
    db $01,$FF

CODE_02C668:                    ;```````````| Not a frame to actually check for Mario.
    LDA !1540,x               ;$02C668    |\ Branch if not yet time to force an auto-run.
    BNE CODE_02C677             ;$02C66B    |/
    LDA !157C,x               ;$02C66D    |\ 
    EOR.b #$01                  ;$02C670    || Turn to the opposite direction the Chuck is currently facing.
    STA !157C,x               ;$02C672    |/
    BRA CODE_02C65C             ;$02C675    | Switch to preparing to charge.

CODE_02C677:                    ;```````````| Not forcing an auto-run either.
    LDA $14                     ;$02C677    |\ 
    AND.b #$03                  ;$02C679    ||
    BNE CODE_02C691             ;$02C67B    ||
    LDA !1534,x               ;$02C67D    ||
    AND.b #$01                  ;$02C680    ||
    TAY                         ;$02C682    ||
    LDA !1594,x               ;$02C683    ||
    CLC                         ;$02C686    || Handle the animation for the Chuck's head.
    ADC.w DATA_02C666,Y         ;$02C687    ||  Use !1534 as the direction to currently turn;
    CMP.b #$0B                  ;$02C68A    ||  then use !1594 as a counter for determining the actual frame for the Chuck's head (in !151C).
    BCS CODE_02C69B             ;$02C68C    ||
    STA !1594,x               ;$02C68E    ||
CODE_02C691:                    ;           ||
    LDY !1594,x               ;$02C691    ||
    LDA.w DATA_02C62E,Y         ;$02C694    ||
    STA !151C,x               ;$02C697    |/
    RTS                         ;$02C69A    |

CODE_02C69B:                    ;```````````| Chuck has completed a turn to either side, so set him to start turning the other way next time.
    INC !1534,x               ;$02C69B    |
    RTS                         ;$02C69E    |



DATA_02C69F:                    ;$02C69F    | Running X speeds for the Chargin' Chuck. Seperate speeds are used depending on whether it's running towards Mario.
    db $10,$F0                              ; Auto-running
    db $18,$E8                              ; Running towards Mario

DATA_02C6A3:                    ;$02C6A3    | Animation frames for the Chargin' Chuck's run animation.
    db $12,$13                              ; Auto-running
    db $12,$13                              ; Running towards Mario

CODE_02C6A7:                    ;-----------| Chuck routine 1 - Charging.
    LDA !1588,x               ;$02C6A7    |\ 
    AND.b #$04                  ;$02C6AA    ||
    BEQ CODE_02C6BA             ;$02C6AC    || Always branches.
    LDA !163E,x               ;$02C6AE    ||  Would have played the below sound effect when the Chuck is on the ground and Mario has just been spotted.
    CMP.b #$01                  ;$02C6B1    ||
    BRA CODE_02C6BA             ;$02C6B3    |/

    LDA.b #$24                  ;$02C6B5    |\ Unused SFX for the Chuck spotting Mario.
    STA.w $1DF9|!Base2          ;$02C6B7    |/

CODE_02C6BA:
    %SubVertPos()				;$02C6BA    |\ 
    LDA $0F                     ;$02C6BD    ||
    CLC                         ;$02C6BF    ||
    ADC.b #$30                  ;$02C6C0    ||
    CMP.b #$60                  ;$02C6C2    ||
    BCS CODE_02C6D7             ;$02C6C4    || If Mario is vertically within 3 tiles of the Chuck and in front of him,
    %SubHorzPos()				;$02C6C6    ||  reset the Chuck's run timer and indicate that Mario is in his line of sight.
    TYA                         ;$02C6C9    ||
    CMP !157C,x               ;$02C6CA    ||
    BNE CODE_02C6D7             ;$02C6CD    ||
    LDA.b #$20                  ;$02C6CF    ||
    STA !1540,x               ;$02C6D1    ||
    STA !187B,x               ;$02C6D4    |/
CODE_02C6D7:                    ;           |
    LDA !1540,x               ;$02C6D7    |\ 
    BNE CODE_02C6EC             ;$02C6DA    ||
    STZ !C2,x                   ;$02C6DC    ||
    JSR CODE_02C628             ;$02C6DE    || If finished running, switch to phase 0 (looking side-to-side),
    JSL $01ACF9                 ;$02C6E1    ||  and set the timer for the charging phase.
    AND.b #$3F                  ;$02C6E5    ||
    ORA.b #$40                  ;$02C6E7    ||
    STA !1540,x               ;$02C6E9    |/
CODE_02C6EC:                    ;           |
    LDY !157C,x               ;$02C6EC    |\ 
    LDA.w DATA_02C639,Y         ;$02C6EF    || Set the Chuck's head to face the direction it's running in.
    STA !151C,x               ;$02C6F2    |/
    LDA !1588,x               ;$02C6F5    |\ 
    AND.b #$04                  ;$02C6F8    || Branch if the Chuck isn't on the ground.
    BEQ CODE_02C713             ;$02C6FA    |/
    LDA !187B,x               ;$02C6FC    |\ 
    BEQ CODE_02C70E             ;$02C6FF    ||
    LDA $14                     ;$02C701    || Branch if not running towards Mario.
    AND.b #$07                  ;$02C703    ||
    BNE CODE_02C70C             ;$02C705    ||
    LDA.b #$01                  ;$02C707    ||\ SFX for the Chargin' Chuck's run. Only plays when running towards Mario, not auto-running.
    STA.w $1DF9|!Base2          ;$02C709    ||/
CODE_02C70C:                    ;           ||
    INY                         ;$02C70C    ||
    INY                         ;$02C70D    |/
CODE_02C70E:                    ;           |
    LDA.w DATA_02C69F,Y         ;$02C70E    |\ Set X speed for the Chuck. Different X speeds are used when running towards Mario vs. auto-running.
    STA !B6,X                   ;$02C711    |/
CODE_02C713:                    ;           |
    LDA $13                     ;$02C713    |\ 
    LDY !187B,x               ;$02C715    ||
    BNE CODE_02C71B             ;$02C718    ||
    LSR                         ;$02C71A    ||
CODE_02C71B:                    ;           || Set animation frame for the Chuck. Only animate half as fast when auto-running.
    LSR                         ;$02C71B    ||
    AND.b #$03                  ;$02C71C    ||
    TAY                         ;$02C71E    ||
    LDA.w DATA_02C6A3,Y         ;$02C71F    ||
    STA !1602,x               ;$02C722    |/
    RTS                         ;$02C725    |



CODE_02C726:                    ;-----------| Chuck routine 2 - preparing to charge.
    LDA.b #$03                  ;$02C726    |\ Animation frame to use (3).
    STA !1602,x               ;$02C728    |/
    LDA !1540,x               ;$02C72B    |\ Return if not time to actually charge.
    BNE Return02C73C            ;$02C72E    |/
    JSR CODE_02C628             ;$02C730    | Set a timer for the 'starting to run' animation frame.
    LDA.b #$01                  ;$02C733    |\ Switch to phase 1 (charging).
    STA !C2,x                   ;$02C735    |/
    LDA.b #$40                  ;$02C737    |\ Set the auto-run timer for the charging phase.
    STA !1540,x               ;$02C739    |/
Return02C73C:                   ;           |
    RTS                         ;$02C73C    |



DATA_02C73D:                    ;$02C73D    | Animation frames for each phase of the hurt animation.
    db $0A,$0B,$0A,$0C,$0D,$0C

DATA_02C743:                    ;$02C743    | Animation timers for each phase of the hurt animation.
    db $0C,$10,$10,$04,$08,$10,$18

CODE_02C74A:                    ;-----------| Chuck routine 3 - Hurt
    LDY !1570,x               ;$02C74A    |\ 
    LDA !1540,x               ;$02C74D    ||
    BNE CODE_02C760             ;$02C750    ||
    INC !1570,x               ;$02C752    || Set timer for the current phase of the hurt animation.
    INY                         ;$02C755    ||  Branch if done with the hurt animation.
    CPY.b #$07                  ;$02C756    ||
    BEQ CODE_02C777             ;$02C758    ||
    LDA.w DATA_02C743,Y         ;$02C75A    ||
    STA !1540,x               ;$02C75D    |/
CODE_02C760:                    ;           |
    LDA.w DATA_02C73D,Y         ;$02C760    |\ Get the the animation frame for the current phase of the hurt animation.
    STA !1602,x               ;$02C763    |/
    LDA.b #$02                  ;$02C766    |\ 
    CPY.b #$05                  ;$02C768    ||
    BNE CODE_02C773             ;$02C76A    ||
    LDA $14                     ;$02C76C    ||
    LSR                         ;$02C76E    || Get the animation frame for the Chuck's head. Normally, fully forward (3).
    NOP                         ;$02C76F    ||  In phase 5 of the hurt animation though, makes the head shake from side to side (2-4).
    AND.b #$02                  ;$02C770    ||
    INC A                       ;$02C772    ||
CODE_02C773:                    ;           ||
    STA !151C,x               ;$02C773    |/
    RTS                         ;$02C776    |

CODE_02C777:                    ;```````````| Done with the hurt animation.
    if !ChargeOnHurt
    LDA.b #$30                  ;$02C785    |\ Set the timer for the "waiting to charge" phase for the Chuck.
    STA !1540,x               ;$02C787    |/
    LDA.b #$02                  ;$02C78A    |\ Switch to phase 2 (waiting to charge).
    STA !C2,x                   ;$02C78C    |/
    INC !187B,x               ;$02C78E    | Mark Mario in the Chuck's line of sight.
    JMP CODE_02C556             ;$02C791    | Face Mario.
	else

	LDA !157C,x
	TAY
	LDA.w DATA_02C639,Y          
    STA !151C,x               

	LDA.b #$04                  ;$02C794    |\ Switch to phase A (Pitchin').
    STA !C2,x                   ;$02C796    |/
	RTS
	endif


CODE_02C79D:                    ;-----------| Routine to process Mario interaction with Chucks.
    LDA !1564,X               ;$02C79D    |\ Return if contact with Mario is temporarily disabled.
    BNE Return02C80F            ;$02C7A0    |/
    JSL $01A7DC|!BankB			;$02C7A2    |\ Return if not in contact with Mario.
    BCC Return02C80F            ;$02C7A6    |/
    LDA.w $1490|!Base2          ;$02C7A8    |\ 
    BEQ CODE_02C7C4             ;$02C7AB    ||
    LDA.b #$D0                  ;$02C7AD    ||| Y speed to give the Chuck when killed with star power.
    STA !AA,X                   ;$02C7AF    |/
CODE_02C7B1:                    ;```````````| Chuck has been killed by Mario.
    STZ !B6,X                   ;$02C7B1    | Clear its X speed.
    LDA.b #$02                  ;$02C7B3    |\ Set as falling offscreen.
    STA !14C8,x               ;$02C7B5    |/
    LDA.b #$03                  ;$02C7B8    |\ SFX for killing the Chuck.
    STA.w $1DF9|!Base2          ;$02C7BA    |/
    LDA.b #$03                  ;$02C7BD    |\ Give 800 points.
    JSL $02ACE5|!BankB          ;$02C7BF    |/
    RTS                         ;$02C7C3    |

CODE_02C7C4:                    ;```````````| Mario doesn't have star power.
    %SubVertPos()          ;$02C7C4    |\ 
    LDA $0F                     ;$02C7C7    || Branch to hurt Mario if too far below the Chuck.
    CMP.b #$EC                  ;$02C7C9    ||
    BPL CODE_02C810             ;$02C7CB    |/
    LDA.b #$05                  ;$02C7CD    |\ Briefly disable extra contact with the Chuck.
    STA !1564,X               ;$02C7CF    |/
    LDA.b #$02                  ;$02C7D2    |\ SFX for bouncing on a Chuck.
    STA.w $1DF9|!Base2          ;$02C7D4    |/
    JSL $01AB99|!BankB			;$02C7D7    | Display a contact sprite.
    JSL $01AA33|!BankB			;$02C7DB    | Make Mario bounce.
    STZ !163E,x               ;$02C7DF    |] Clear an unused timer.
    LDA !C2,x                   ;$02C7E2    |\ 
    CMP.b #$03                  ;$02C7E4    || Return if already in the Chuck's hurt state (only hurt once).
    BEQ Return02C80F            ;$02C7E6    |/
    INC !1528,X               ;$02C7E8    |\ 
    LDA !1528,X               ;$02C7EB    || Count number of hits, and branch if not yet dead.
    CMP.b !Health                  ;$02C7EE    ||| Number of hits it takes to kill a Chuck.
    BCC CODE_02C7F6             ;$02C7F0    |/
    STZ !AA,X                   ;$02C7F2    | Clear the Chuck's Y speed (in case it was jumping).
    BRA CODE_02C7B1             ;$02C7F4    |

CODE_02C7F6:                    ;```````````| Bounced off Chuck and didn't kill it.
    LDA.b #$28                  ;$02C7F6    |\ SFX for bouncing off a Chargin' Chuck.
    STA.w $1DFC|!Base2          ;$02C7F8    |/
    LDA.b #$03                  ;$02C7FB    |\ Switch Chuck to hurt state.
    STA !C2,x                   ;$02C7FD    |/
    LDA.b #$03                  ;$02C7FF    |\ Set timer for the initial frame of the hurt animation.
    STA !1540,x               ;$02C801    |/
    STZ !1570,x               ;$02C804    | Clear the counter for the hurt animation's phases.
    %SubHorzPos()				;$02C807    |\ 
    LDA.w DATA_02C79B,Y         ;$02C80A    || Give Mario an X speed depending on the side of the Chuck he hit.
    STA $7B                     ;$02C80D    |/
Return02C80F:                   ;           |
    RTS                         ;$02C80F    |

CODE_02C810:                    ;```````````| Mario is too far below the Chuck to hit it.
    LDA.w $187A|!Base2          ;$02C810    |\ 
    BNE Return02C819            ;$02C813    || Hurt Mario, unless riding Yoshi.
    JSL $00F5B7                ;$02C815    |/
Return02C819:                   ;           |
    RTS                         ;$02C819    |



CODE_02C81A:                    ;-----------| Chuck GFX routine.
    %GetDrawInfo()         ;$02C81A    |
    JSR CODE_02C88C             ;$02C81D    | Draw the head.
    JSR CODE_02CA27             ;$02C820    | Draw the body.
    JSR CODE_02CA9D             ;$02C823    | Draw the hands, or Baseball Chuck's baseball.
    LDY.b #$FF                  ;$02C829    |\ 
CODE_02C82B:                    ;           || Upload 5 manually-sized tiles.
    LDA.b #$04                  ;$02C82B    ||
    JSL $01B7B3|!BankB          ;$02C82D    |/
	RTS


DATA_02C830:                    ;$02C830    | X offsets for the Chuck's head in each animation frame.
    db $F8,$F8,$F8,$00,$00,$FE,$00,$00
    db $FA,$00,$00,$00,$00,$00,$00,$FD
    db $FD,$F9,$F6,$F6,$F8,$FE,$FC,$FA
    db $F8,$FA

DATA_02C84A:                    ;$02C84A    | Y offsets for the Chuck's head in each animation frame.
    db $F8,$F9,$F7,$F8,$FC,$F8,$F4,$F5
    db $F5,$FC,$FD,$00,$F9,$F5,$F8,$FA
    db $F6,$F6,$F4,$F4,$F8,$F6,$F6,$F8
    db $F8,$F5

DATA_02C864:                    ;$02C864    | OAM offsets for the head in each animation frame.
    db $08,$08,$08,$00,$00,$00,$08,$08
    db $08,$00,$08,$08,$00,$00,$00,$00
    db $00,$08,$10,$10,$0C,$0C,$0C,$0C
    db $0C,$0C

ChuckHeadTiles:                 ;$02C87E    | Tile numbers for each head animation frame.
    db $06,$0A,$0E,$0A,$06,$4B,$4B

DATA_02C885:                    ;$02C885    | X flips for each head animation frame.
    db $40,$40,$00,$00,$00,$00,$40

CODE_02C88C:                    ;-----------| GFX subroutine for the Chuck's head.
    STZ $07                     ;$02C88C    |\ 
    LDY !1602,x               ;$02C88E    ||
    STY $04                     ;$02C891    ||
    CPY.b #$09                  ;$02C893    ||
    CLC                         ;$02C895    ||
    BNE CODE_02C8AB             ;$02C896    || $00 = X position onscreen
    LDA !1540,x               ;$02C898    || $01 = Y position onscreen
    SEC                         ;$02C89B    || $02 = Animation frame for the head
    SBC.b #$20                  ;$02C89C    || $03 = Horizontal direction the Chuck's body facing
    BCC CODE_02C8AB             ;$02C89E    || $04 = Animation frame for the Chuck
    PHA                         ;$02C8A0    || $05 = Base OAM index of the Chuck
    LSR                         ;$02C8A1    || $07 = Extra Y offset used by animation frame 9 (crouching) to animate the head "ducking"
    LSR                         ;$02C8A2    || $08 = Base YXPPCCCT setting
    LSR                         ;$02C8A3    ||
    LSR                         ;$02C8A4    ||
    LSR                         ;$02C8A5    ||
    STA $07                     ;$02C8A6    ||
    PLA                         ;$02C8A8    ||
    LSR                         ;$02C8A9    ||
    LSR                         ;$02C8AA    ||
CODE_02C8AB:                    ;           ||
    LDA $00                     ;$02C8AB    ||
    ADC.b #$00                  ;$02C8AD    ||
    STA $00                     ;$02C8AF    ||
    LDA !151C,x               ;$02C8B1    ||
    STA $02                     ;$02C8B4    ||
    LDA !157C,x               ;$02C8B6    ||
    STA $03                     ;$02C8B9    ||
    LDA !15F6,X               ;$02C8BB    ||
    ORA $64                     ;$02C8BE    ||
    STA $08                     ;$02C8C0    ||
    LDA !15EA,X               ;$02C8C2    ||
    STA $05                     ;$02C8C5    |/
    CLC                         ;$02C8C7    |\ 
    ADC.w DATA_02C864,Y         ;$02C8C8    || Get OAM index for the head.
    TAY                         ;$02C8CB    |/
    LDX $04                     ;$02C8CC    |\ 
    LDA.w DATA_02C830,X         ;$02C8CE    ||
    LDX $03                     ;$02C8D1    ||
    BNE CODE_02C8D8             ;$02C8D3    ||
    EOR.b #$FF                  ;$02C8D5    || Store X position, accounting for which way the Chuck is turned.
    INC A                       ;$02C8D7    ||
CODE_02C8D8:                    ;           ||
    CLC                         ;$02C8D8    ||
    ADC $00                     ;$02C8D9    ||
    STA.w $0300|!Base2,Y               ;$02C8DB    |/
    LDX $04                     ;$02C8DE    |\ 
    LDA $01                     ;$02C8E0    ||
    CLC                         ;$02C8E2    ||
    ADC.w DATA_02C84A,X         ;$02C8E3    || Store Y position.
    SEC                         ;$02C8E6    ||
    SBC $07                     ;$02C8E7    ||
    STA.w $0301|!Base2,Y               ;$02C8E9    |/
    LDX $02                     ;$02C8EC    |
    LDA.w DATA_02C885,X         ;$02C8EE    |\ 
    ORA $08                     ;$02C8F1    || Store YXPPCCCT.
    STA.w $0303|!Base2,Y               ;$02C8F3    |/
    LDA.w ChuckHeadTiles,X      ;$02C8F6    |\ Store tile number.
    STA.w $0302|!Base2,Y               ;$02C8F9    |/
    TYA                         ;$02C8FC    |
    LSR                         ;$02C8FD    |
    LSR                         ;$02C8FE    |
    TAY                         ;$02C8FF    |
    LDA.b #$02                  ;$02C900    |\ Set size as 16x16.
    STA.w $0460|!Base2,Y               ;$02C902    |/
    LDX.w $15E9|!Base2                 ;$02C905    |
    RTS                         ;$02C908    |



DATA_02C909:                    ;$02C909    | X offsets for the Chuck's first tile. Second set of values are when facing right.
    db $F8,$F8,$F8,$FC,$FC,$FC,$FC,$F8
    db $01,$FC,$FC,$FC,$FC,$FC,$FC,$FC
    db $FC,$F8,$F8,$F8,$F8,$08,$06,$F8
    db $F8,$01,$10,$10,$10,$04,$04,$04
    db $04,$08,$07,$04,$04,$04,$04,$04
    db $04,$04,$04,$10,$08,$08,$10,$00
    db $02,$10,$10,$07

DATA_02C93D:                    ;$02C93D    | X offsets for the Chuck's second tile. Second set of values are when facing right.
    db $00,$00,$00,$04,$04,$04,$04,$08
    db $00,$04,$04,$04,$04,$04,$04,$04
    db $04,$00,$00,$00,$00,$00,$00,$00
    db $00,$00
    db $00,$00,$00,$FC,$FC,$FC,$FC,$F8
    db $00,$FC,$FC,$FC,$FC,$FC,$FC,$FC
    db $FC,$00,$00,$00,$00,$00,$00,$00
    db $00,$00

DATA_02C971:                    ;$02C971    | Y offsets for the Chuck's first tile. Second tile has no offset.
    db $06,$06,$06,$00,$00,$00,$00,$00
    db $F8,$00,$00,$00,$00,$00,$00,$00
    db $00,$03,$00,$00,$06,$F8,$F8,$00
    db $00,$F8

ChuckBody1:                     ;$02C98B    | Tile numbers for the Chuck's first tile.
    db $0D,$34,$35,$26,$2D,$28,$40,$42
    db $5D,$2D,$64,$64,$64,$64,$E7,$28
    db $82,$CB,$23,$20,$0D,$0C,$5D,$BD
    db $BD,$5D

ChuckBody2:                     ;$02C9A5    | Tile numbers for the Chuck's second tile.
    db $4E,$0C,$22,$26,$2D,$29,$40,$42
    db $AE,$2D,$64,$64,$64,$64,$E8,$29
    db $83,$CC,$24,$21,$4E,$A0,$A0,$A2
    db $A4,$AE

DATA_02C9BF:                    ;$02C9BF    | Extra YXPPCCCT values for the Chuck's tiles.
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$40,$00,$00
    db $00,$00

DATA_02C9D9:                    ;$02C9D9    | Extra YXPPCCCT values for the Chuck's second tile. EORed with the first, for X flipping.
    db $00,$00,$00,$40,$40,$00,$40,$40
    db $00,$40,$40,$40,$40,$40,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00

DATA_02C9F3:                    ;$02C9F3    | Sizes for the Chuck's first tile.
    db $00,$00,$00,$02,$02,$02,$02,$02
    db $00,$02,$02,$02,$02,$02,$02,$02
    db $02,$00,$02,$02,$00,$00,$00,$00
    db $00,$00

DATA_02CA0D:                    ;$02CA0D    | OAM offsets for the Chuck's body.
    db $00,$00,$00,$04,$04,$04,$0C,$0C
    db $00,$08,$00,$00,$04,$04,$04,$04
    db $04,$00,$08,$08,$00,$00,$00,$00
    db $00,$00

CODE_02CA27:                    ;-----------| GFX subroutine for the Chuck's body.
    STZ $06                     ;$02CA27    |\ $00 = X position onscreen
    LDA $04                     ;$02CA29    || $01 = Y position onscreen
    LDY $03                     ;$02CA2B    || $03 = Horizontal direction the Chuck's body facing
    BNE CODE_02CA36             ;$02CA2D    || $04 = Animation frame for the Chuck
    CLC                         ;$02CA2F    || $05 = Base OAM index of the Chuck
    ADC.b #$1A                  ;$02CA30    || $06 = X bit of the YXPPCCCT setting
    LDX.b #$40                  ;$02CA32    || $08 = Base YXPPCCCT setting
    STX $06                     ;$02CA34    |/
CODE_02CA36:                    ;           |
    TAX                         ;$02CA36    |
    LDY $04                     ;$02CA37    |\ 
    LDA.w DATA_02CA0D,Y         ;$02CA39    ||
    CLC                         ;$02CA3C    || Get OAM index for the body.
    ADC $05                     ;$02CA3D    ||
    TAY                         ;$02CA3F    |/
    LDA $00                     ;$02CA40    |\ 
    CLC                         ;$02CA42    ||
    ADC.w DATA_02C909,X         ;$02CA43    ||
    STA.w $0300|!Base2,Y               ;$02CA46    || Store X position of both tiles.
    LDA $00                     ;$02CA49    ||
    CLC                         ;$02CA4B    ||
    ADC.w DATA_02C93D,X         ;$02CA4C    ||
    STA.w $0304|!Base2,Y               ;$02CA4F    |/
    LDX $04                     ;$02CA52    |\ 
    LDA $01                     ;$02CA54    ||
    CLC                         ;$02CA56    ||
    ADC.w DATA_02C971,X         ;$02CA57    || Store Y position of both tiles.
    STA.w $0301|!Base2,Y               ;$02CA5A    ||
    LDA $01                     ;$02CA5D    ||
    STA.w $0305|!Base2,Y               ;$02CA5F    |/
    LDA.w ChuckBody1,X          ;$02CA62    |\ 
    STA.w $0302|!Base2,Y               ;$02CA65    || Store tile numbers.
    LDA.w ChuckBody2,X          ;$02CA68    ||
    STA.w $0306|!Base2,Y               ;$02CA6B    |/
    LDA $08                     ;$02CA6E    |\ 
    ORA $06                     ;$02CA70    ||
    PHA                         ;$02CA72    ||
    EOR.w DATA_02C9BF,X         ;$02CA73    || Store YXPPCCCT.
    STA.w $0303|!Base2,Y               ;$02CA76    ||
    PLA                         ;$02CA79    ||
    EOR.w DATA_02C9D9,X         ;$02CA7A    ||
    STA.w $0307|!Base2,Y               ;$02CA7D    |/
    TYA                         ;$02CA80    |
    LSR                         ;$02CA81    |
    LSR                         ;$02CA82    |
    TAY                         ;$02CA83    |
    LDA.w DATA_02C9F3,X         ;$02CA84    |\ 
    STA.w $0460|!Base2,Y               ;$02CA87    || Store size of the tile.
    LDA.b #$02                  ;$02CA8A    ||  Second tile is always 16x16.
    STA.w $0461|!Base2,Y               ;$02CA8C    |/
    LDX.w $15E9|!Base2                 ;$02CA8F    |
    RTS                         ;$02CA92    |



DATA_02CA93:                    ;$02CA93    | X offsets for the first hand tile in frames 6/7.
    db $FA,$00

DATA_02CA95:                    ;$02CA95    | X offsets for the second hand tile in frames 6/7.
    db $0E,$00

ClappinChuckTiles:              ;$02CA97    | Tile numbers for the hand tiles in frames 6/7.
    db $0C,$44

DATA_02CA99:                    ;$02CA99    | Y offsets for both hand tiles in frames 6/7.
    db $F8,$F0

DATA_02CA9B:                    ;$02CA9B    | Tile sizes for the Chuck's hand tiles in frames 6/7.
    db $00,$02

CODE_02CA9D:                    ;-----------| GFX subroutine for the Chuck's hands, or the Baseball Chuck's held baseball.
    LDA $04                     ;$02CA9D    |\ 
    CMP.b #$14                  ;$02CA9F    || $04 = Animation frame for the Chuck
    BCC CODE_02CAA6             ;$02CAA1    ||  If in frame 14+ (Baseball Chuck), jump down to draw his baseball instead.
    JMP CODE_02CB53             ;$02CAA3    |/

CODE_02CAA6:
    CMP.b #$12                  ;$02CAA6    |\ 
    BEQ CODE_02CAFC             ;$02CAA8    || Branch if in frame 12/13 (running).
    CMP.b #$13                  ;$02CAAA    ||
    BEQ CODE_02CAFC             ;$02CAAC    |/
    SEC                         ;$02CAAE    |\ 
    SBC.b #$06                  ;$02CAAF    || Return if not frame 6/7 (jumping/whistling, clapping).
    CMP.b #$02                  ;$02CAB1    ||
    BCS Return02CAF9            ;$02CAB3    |/
    TAX                         ;$02CAB5    |
    LDY $05                     ;$02CAB6    | $05 = Base OAM index of the Chuck
    LDA $00                     ;$02CAB8    |\ 
    CLC                         ;$02CABA    ||
    ADC.w DATA_02CA93,X         ;$02CABB    ||
    STA.w $0300|!Base2,Y               ;$02CABE    || Store X position for both tiles.
    LDA $00                     ;$02CAC1    ||
    CLC                         ;$02CAC3    ||
    ADC.w DATA_02CA95,X         ;$02CAC4    ||
    STA.w $0304|!Base2,Y               ;$02CAC7    |/
    LDA $01                     ;$02CACA    |\ 
    CLC                         ;$02CACC    ||
    ADC.w DATA_02CA99,X         ;$02CACD    || Store Y position for both tiles.
    STA.w $0301|!Base2,Y               ;$02CAD0    ||
    STA.w $0305|!Base2,Y               ;$02CAD3    |/
    LDA.w ClappinChuckTiles,X   ;$02CAD6    |\ 
    STA.w $0302|!Base2,Y               ;$02CAD9    || Store tile numbers.
    STA.w $0306|!Base2,Y               ;$02CADC    |/
    LDA $08                     ;$02CADF    |\ 
    STA.w $0303|!Base2,Y               ;$02CAE1    || Store YXPPCCCT. X flip the second tile.
    ORA.b #$40                  ;$02CAE4    ||
    STA.w $0307|!Base2,Y               ;$02CAE6    |/
    TYA                         ;$02CAE9    |
    LSR                         ;$02CAEA    |
    LSR                         ;$02CAEB    |
    TAY                         ;$02CAEC    |
    LDA.w DATA_02CA9B,X         ;$02CAED    |\ 
    STA.w $0460|!Base2,Y               ;$02CAF0    || Store size of both tiles.
    STA.w $0461|!Base2,Y               ;$02CAF3    |/
    LDX.w $15E9|!Base2                 ;$02CAF6    |
Return02CAF9:                   ;           |
    RTS                         ;$02CAF9    |


ChuckGfxProp:                   ;$02CAFA    | Additional YXPPCCCT bits for the Chuck's hands in frames 12/13.
    db $47,$07

CODE_02CAFC:                    ;```````````| Drawing Chuck's hands for animation frames 12/13 (running).
    LDY $05                     ;$02CAFC    | $05 = Base OAM index of the Chuck
    LDA !157C,x               ;$02CAFE    |\ 
    PHX                         ;$02CB01    ||
    TAX                         ;$02CB02    ||
    ASL                         ;$02CB03    ||
    ASL                         ;$02CB04    ||
    ASL                         ;$02CB05    ||
    PHA                         ;$02CB06    ||
    EOR.b #$08                  ;$02CB07    || Set X position for one tile at the Chuck,
    CLC                         ;$02CB09    ||  and the other tile 8 pixels to the right.
    ADC $00                     ;$02CB0A    ||
    STA.w $0300|!Base2,Y               ;$02CB0C    ||
    PLA                         ;$02CB0F    ||
    CLC                         ;$02CB10    ||
    ADC $00                     ;$02CB11    ||
    STA.w $0304|!Base2,Y               ;$02CB13    |/
    LDA.b #$1C                  ;$02CB16    |\ 
    STA.w $0302|!Base2,Y               ;$02CB18    || Set tile numbers (1C/1D).
    INC A                       ;$02CB1B    ||
    STA.w $0306|!Base2,Y               ;$02CB1C    |/
    LDA $01                     ;$02CB1F    |\ 
    SEC                         ;$02CB21    ||
    SBC.b #$08                  ;$02CB22    || Set Y position.
    STA.w $0301|!Base2,Y               ;$02CB24    ||
    STA.w $0305|!Base2,Y               ;$02CB27    |/
    LDA.w ChuckGfxProp,X        ;$02CB2A    |\ 
    ORA $64                     ;$02CB2D    || Set YXPPCCCT.
    STA.w $0303|!Base2,Y               ;$02CB2F    ||
    STA.w $0307|!Base2,Y               ;$02CB32    |/
    TYA                         ;$02CB35    |
    LSR                         ;$02CB36    |
    LSR                         ;$02CB37    |
    TAX                         ;$02CB38    |
CODE_02CB39:                    ;           |
    STZ.w $0460|!Base2,X               ;$02CB39    |\ Set size as 8x8.
    STZ.w $0461|!Base2,X               ;$02CB3C    |/
    PLX                         ;$02CB3F    |
    RTS                         ;$02CB40    |


DATA_02CB41:                    ;$02CB41    | X offsets for the Baseball Chuck's held baseball in frames 14-19.
    db $FA,$0A,$06,$00,$00,$01              ; Facing left
    db $0E,$FE,$02,$00,$00,$09              ; Facing right

DATA_02CB4D:                    ;$02CB4D    | Y offsets for the Baseball Chuck's held baseball in frames 14-19. An offset of 0 means don't draw.
    db $08,$F4,$F4,$00,$00,$F4

CODE_02CB53:                    ;```````````| Drawing the baseball in the Chuck's hands for animation frames 14-19 (baseball).
    PHX                         ;$02CB53    |
    STA $02                     ;$02CB54    |\ 
    LDY !157C,x               ;$02CB56    ||
    BNE CODE_02CB5E             ;$02CB59    || $02 = base index to the animation frame.
    CLC                         ;$02CB5B    ||
    ADC.b #$06                  ;$02CB5C    || If facing right, increases the index by 6.
CODE_02CB5E:                    ;           ||
    TAX                         ;$02CB5E    |/
    LDA $05                     ;$02CB5F    |\ 
    CLC                         ;$02CB61    || $05 = Base OAM index of the Chuck
    ADC.b #$08                  ;$02CB62    ||  Offset it two tiles in.
    TAY                         ;$02CB64    |/
    LDA $00                     ;$02CB65    |\ 
    CLC                         ;$02CB67    || Set X position.
    ADC.w DATA_02CB41-20,X      ;$02CB68    ||
    STA.w $0300|!Base2,Y               ;$02CB6B    |/
    LDX $02                     ;$02CB6E    |\ 
    LDA.w DATA_02CB4D-20,X      ;$02CB70    || Skip tile if it has a Y offset of 0.
    BEQ CODE_02CB8E             ;$02CB73    |/
    CLC                         ;$02CB75    |\ 
    ADC $01                     ;$02CB76    || Set Y position.
    STA.w $0301|!Base2,Y               ;$02CB78    |/
    LDA.b #$AD                  ;$02CB7B    |\ Set tile number.
    STA.w $0302|!Base2,Y               ;$02CB7D    |/
    LDA.b #$09                  ;$02CB80    |\ 
    ORA $64                     ;$02CB82    || Set YXPPCCCT.
    STA.w $0303|!Base2,Y               ;$02CB84    |/
    TYA                         ;$02CB87    |
    LSR                         ;$02CB88    |
    LSR                         ;$02CB89    |
    TAX                         ;$02CB8A    |
    STZ.w $0460|!Base2,X               ;$02CB8B    | Set size as 8x8.
CODE_02CB8E:                    ;           |
    PLX                         ;$02CB8E    |
    RTS                         ;$02CB8F    |