Print "MAIN ",pc
	Baseball:           LDA $9D  
	CODE_02A256:        BNE GFX         
	
	%SpeedNoGrav()
	        
	CODE_02A25B:        INC.W $1765|!Base2,X             
	CODE_02A25E:        LDA $13     
	CODE_02A260:        AND.B #$01                
	CODE_02A262:        BNE +           
	CODE_02A264:        INC.W $1765|!Base2,X             
	+

	LDA $171F|!Base2,x
	CLC
	ADC #$03
	STA $04
	LDA $1733|!Base2,x
	ADC #$00
	STA $0A
	LDA #$04
	STA $06
	STA $07
	LDA $1715|!Base2,x
	CLC
	ADC #$03
	STA $05
	LDA $1729|!Base2,x
	ADC #$00
	STA $0B
	JSL $03B664|!BankB
	JSL $03B72B|!BankB
	BCC GFX
	PHB
	LDA.b #($02|!BankB>>16)
	PHA
	PLB
	PHK
	PEA.w .return-1
	PEA.w $B889-1
	JML $02A469|!BankB
.return
	PLB 

    
	GFX:
    %ExtendedGetDrawInfo()

	LDA $01
	STA $0200|!Base2,y

	LDA $02
	STA $0201|!Base2,y

	CODE_02A2A3:        LDA.B #$AD                
	CODE_02A2A5:        STA.W $0202|!Base2,Y  

	CODE_02A2A8:        LDA $14     
	CODE_02A2AA:        ASL                       
	CODE_02A2AB:        ASL                       
	CODE_02A2AC:        ASL                       
	CODE_02A2AD:        ASL                       
	CODE_02A2AE:        AND.B #$C0                
	CODE_02A2B0:        ORA.B #$39                
	CODE_02A2B2:        STA.W $0203|!Base2,Y  
	CODE_02A2B5:        TYA                       
	CODE_02A2B6:        LSR                       
	CODE_02A2B7:        LSR                       
	CODE_02A2B8:        TAY                       
	CODE_02A2B9:        LDA.B #$00                
	CODE_02A2BB:        STA.W $0420|!Base2,Y             
	Return02A2BE:       RTL
