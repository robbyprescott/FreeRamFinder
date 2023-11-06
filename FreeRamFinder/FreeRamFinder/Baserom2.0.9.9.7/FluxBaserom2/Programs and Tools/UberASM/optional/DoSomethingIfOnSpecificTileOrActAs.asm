; Does thing when Mario is touching the specified block.
; NOTE, however, that this only really works with blocks that
; have solid interaction by default. (So it'll be weird with, say, a door or moon.)

; jsl GetMap16_Main to get the map16 tile number
; jsl GetMap16_ActAs to get the map16 tile act as number

!TileNumber = $0112
;!TileNumber2 = $0130

main:
    JSL GetMap16_Main
    CMP.b #!TileNumber
	BNE Nope
	CPY.b #!TileNumber>>8
	BNE Nope
	; BRA if more checks, + add new labels
ThingToDo:
    INC $19
	; BRA if not just RTL
Nope:
    RTL