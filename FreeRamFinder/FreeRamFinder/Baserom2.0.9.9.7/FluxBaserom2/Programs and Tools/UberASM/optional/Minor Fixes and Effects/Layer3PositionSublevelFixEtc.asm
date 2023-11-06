; Sometimes if you transition to a sublevel from a main level
; that (both) has layer 3, the position will be messed up in the sublevel one

init:
    stz $22             ;\
    stz $23             ;| Reset layer 3 position.
    stz $24             ;|
    stz $25             ;/
RTL