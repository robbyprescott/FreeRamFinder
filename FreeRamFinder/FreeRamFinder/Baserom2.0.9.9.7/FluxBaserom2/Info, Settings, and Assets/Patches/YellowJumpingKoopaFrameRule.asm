;In vanilla SMW, yellow koopas can jump over tossed shells or throwblocks, 
;but they will only check for whether one is approaching once every 4 frames (depending on the sprite slot). 
;This can easily cause janky behavior when the koopa jumps too late and gets hit by the tossed item. 
;The hex edit below fixes this by having the koopa do this check every single frame:

org $018898
NOP #7 ; BRA $05