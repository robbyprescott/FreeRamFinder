; This will skip drawing the circular item reserve box GFX
; whenever you have an item in there.
; Necessary if you need the GFX space (tiles CC,CD,DC,DD in SP2) for other purposes,
; but will still be using the itme reserve, so there's not GFX jank

load:
LDA #$01
STA $0E0A
RTL