
org $008650
autoclean JSL Control1
NOP

org $008678
autoclean JSL Control2
NOP

freecode

Control1:
LDX #$00
BRA Main
Control2:
LDX #$02

Main:
LDA $4219,x
AND #$F0
LSR #4
ORA $4218,x
RTL
