; By SJandCharlieTheCat

!AddressToRevert = $0ECF ; CF, D0, D1, D2. shell
!Timer = #$18 ; 24 frames?
!FreeRAM = $0ED6

init:
  STZ !FreeRAM
  STZ !AddressToRevert
  STZ !AddressToRevert+1
  STZ !AddressToRevert+2
  STZ !AddressToRevert+3
  RTL

main:
  LDA !AddressToRevert
  ORA !AddressToRevert+1
  ORA !AddressToRevert+2
  ORA !AddressToRevert+3
  BEQ End	
  LDA !FreeRAM
  CMP !Timer
  BEQ Revert
  INC !FreeRAM
End:
  RTL
Revert:
  BRA init