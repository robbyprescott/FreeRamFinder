; Super simple. See L/R switch code for better


load:
LDA #$01
STA $0DB3 ; switch colors and HUD stuff
RTL

init:
STZ $0DA0 ; only Luigi, controller 2?
RTL