; By SJandCharlieTheCat
; If an address is set / thing activated, e.g. an on/off switch ($14AF), 
; this allows you to automatically reset an address back on/off,
; after a defined amount of time.

!AddressToRevert = $14AF ; on/off
!Timer = $40
!FreeRAM = $0EAF

init:
  STZ !FreeRAM
  STZ !AddressToRevert
  RTL

main:
  LDA !AddressToRevert 
  BEQ End	
  LDA !FreeRAM
  CMP #!Timer
  BEQ Revert
  INC !FreeRAM
End:
  RTL
Revert:
  BRA init