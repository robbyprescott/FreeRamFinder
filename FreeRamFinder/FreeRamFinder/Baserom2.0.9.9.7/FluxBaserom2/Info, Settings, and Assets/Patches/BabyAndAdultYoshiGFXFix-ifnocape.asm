;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Baby Yoshi Graphics Fix - by dtothefourth
;
; This patch improves the handling of Yoshi graphics so that
; multiple baby yoshis can exist together and go offscreen without
; glitching and sometimes Yoshi and baby yoshi can be used together
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


!AllowCape = 1   ;If 1, allow a third yoshi to use the extra tile for cape
!ShareSlot = 1   ;If 1, try to make baby yoshis with the same current frame collapse to one slot
			     ;Allows more baby yoshis to work together somewhat, but extra processing
!BigPriority = 1 ;If 1, and would conflict with a big yoshi let the big yoshi get the tiles

if read1($00FFD5) == $23	;sa-1 compatibility
  sa1rom

  !addr  = $6000
  !Bank  = $00
  !BankB = $000000
  !9E    = $3200
  !D8    = $3216
  !E4    = $322C
  !14D4  = $3258
  !14E0  = $326E
  !14C8  = $3242
  !15A0  = $3376
  !15C4  = $7536
  !15EA  = $33A2
  !1602  = $33CE
  !186C  = $7642
  !SprSize = 22
else

  !addr  = $0000
  !Bank  = $80
  !BankB = $800000
  !9E    = $9E
  !D8    = $D8
  !E4    = $E4
  !14D4  = $14D4
  !14E0  = $14E0 
  !14C8  = $14C8
  !15A0  = $15A0
  !15C4  = $15C4  
  !15EA  = $15EA
  !1602  = $1602
  !186C  = $186C
  !SprSize = 12
endif

org $02EA25
	autoclean JML DMA

freecode

DMA:

	LDA !15C4,X
	ORA !186C,X
	BEQ +
	RTL
	+

	STZ $02

	if !AllowCape || !BigPriority
	
	if !BigPriority == 0
	LDA $19
	CMP #$02
	BEQ +++
	endif

	LDY !15EA,x
	PHX
	LDX #!SprSize-1
	-

	LDA !14C8,X
	BEQ ++

	LDA !9E,X
	CMP #$35
	BNE ++

	if !BigPriority
	LDA $19
	CMP #$02
	BNE ++++

	PLX
	LDY !15EA,x
	LDA #$06
	STA $0302|!addr,Y
	RTL

	++++
	endif


	if !AllowCape
	JMP UseCape
	else
	PLX
	LDY !15EA,x
	LDA #$06
	STA $0302|!addr,Y
	RTL
	endif

	++
	DEX
	BPL -
	PLX
	+++
	endif


	if !ShareSlot
	LDA !15EA,X
	STA $00
	
	LDA !1602,X
	STA $01

	PHX
	INX
	CPX #!SprSize
	BEQ +

	-
	LDA !14C8,X
	BEQ ++

	LDA !9E,X
	CMP #$2D
	BNE ++

	LDA !15C4,X
	ORA !186C,X
	BNE ++	

	LDY !15EA,x
	LDA $0302|!addr,Y
	STA $03

	LDA !1602,X
	CMP $01
	BEQ +++

	LDA $03
	CMP #$04
	BNE ++

	INC $02

	BRA ++
	+++
	PLX

	LDY !15EA,x
	LDA $03
	STA $0302|!addr,Y
	RTL

	++
	INX
	CPX #!SprSize
	BNE -
	+
	PLX

	LDY $00
	else
	LDY !15EA,X
	endif



	PHX
	DEX
	BPL +
	JMP NoChange
	+
	-

	LDA !14C8,X
	BEQ ++

	LDA !9E,X
	CMP #$2D
	BNE ++

	LDA !15C4,X
	ORA !186C,X
	BNE ++	

	if !AllowCape

	LDA $19
	CMP #$02
	BEQ PlusOne

	DEX
	BMI PlusOne
	--

	LDA !14C8,X
	BEQ +++

	LDA !9E,X
	CMP #$2D
	BNE +++

	LDA !15C4,X
	ORA !186C,X
	BNE +++	

	if !ShareSlot
	LDA $02
	BNE PlusOne
	endif

UseCape:
	LDA $0302|!addr,Y
	STA $00
	STZ $01
	PLX
	LDA #$04
	STA $0302|!addr,Y
	REP #$20                   
    LDA $00                    
    ASL                        
    ASL                        
    ASL                        
    ASL                        
    ASL                        
    CLC                        
    ADC #$8500               
    STA $0D89|!addr              
    CLC                        
    ADC #$0200               
    STA $0D93|!addr          
    SEP #$20                   
	RTL

	+++
	DEX
	BPL --

	endif

PlusOne:

	LDA $0302|!addr,Y
	STA $00
	STZ $01
	PLX
	LDA #$08
	STA $0302|!addr,Y
	REP #$20                   
    LDA $00                    
    ASL                        
    ASL                        
    ASL                        
    ASL                        
    ASL                        
    CLC                        
    ADC #$8500               
    STA $0D8D|!addr              
    CLC                        
    ADC #$0200               
    STA $0D97|!addr          
    SEP #$20                   
	RTL

	++
	DEX
	BMI NoChange
	JMP -
NoChange:
	LDA $0302|!addr,Y
	STA $00
	STZ $01	
	PLX
	LDA #$06
	STA $0302|!addr,Y

	REP #$20                   
    LDA $00                    
    ASL                        
    ASL                        
    ASL                        
    ASL                        
    ASL                        
    CLC                        
    ADC #$8500               
    STA $0D8B|!addr              
    CLC                        
    ADC #$0200               
    STA $0D95|!addr          
    SEP #$20                   
	RTL
	

