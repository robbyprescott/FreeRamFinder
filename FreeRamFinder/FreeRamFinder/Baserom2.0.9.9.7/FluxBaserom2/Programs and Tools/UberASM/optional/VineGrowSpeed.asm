; You can set a custom speed for all vanilla growing vines in your level
; Faster by default.

!Speed = $E0 ; Fast than vanilla, which is $F0. Something like $F8 would be slower.
!Toggle = 0 ; If set, can flip back and forth between original custom speed and another custom one. 
!SecondarySpeed = $FF ; Still moves, but only barely
!SecondaryTrigger = $14AF
!DummyRAM = $0DFE 


main:
if !Toggle
     LDA !SecondaryTrigger
     BNE Return
endif
     LDA #!Speed
     STA !DummyRAM
     BRA End
Return:
     LDA #!SecondarySpeed ; If you replace these two lines with STZ !DummyRAM,
     STA !DummyRAM        ; the secondary speed will actually just be vanilla.
End:
     RTL