; This can be useful to prevent some cheese if you're using certain custom ASM that 
; doesn't account for first-frame jumps.

init:
LDA #$01
STA $0EC0
RTL