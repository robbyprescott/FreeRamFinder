; Instead of checking for another controller in the other port,
; you control Luigi with the same controller.



	   
org $0086A0
db $9C,$A0,$0D,$AD,$A0,$0D,$A2,$00 ; vanilla $AE,$A0,$0D,$10,$03,$AE,$B3,$0D, 
                                   ; a.k.a. LDX.W $0DA0 : BPL CODE_0086A8 : LDX.W $0DB3 
								   
;org $0086A0
       ;STZ $0DA0
       ;LDA $0DA0
       ;LDX #$00								