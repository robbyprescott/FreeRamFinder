; Mario never dies or takes damage if small,
; at least not from vanilla resources. Including pits.
; Also toggleable by blocks

!NoPitDeath = 1

load:
LDA #$01
STA $0EB7
if !NoPitDeath
LDA #$01
STA $0EB8
endif
RTL