; 6+!NumOptions bytes are used
!FreeRAM        = $0E59|!addr

; Which button(s) bring up/close the menu
!ButtonRAM      = $16
!ButtonValue    = %00100000

; If 1, a counter of how many warp points have been unlocked will be drawn.
!ShowCounter    = 1

; If 0, "Exit" won't be shown.
!ShowExitOption = 1

; Graphical properties
; Remember the cursor is in the second layer 3 page, while the letters are on the first.
!CursorTile     = $2E
!CursorPalette  = $02
!TextPalette    = $07
!SlashTile      = $46
!CounterPalette = $02

; Where the menu is placed on the screen.
; Remember that the position and length is counted in amount of 8x8 tiles.
!CursorXPos     = $04
!FirstLineYPos  = $07
!LinesDistance  = $02
!TextXPos       = $06
!TextLength     = 18    ; Can be up to 24 to fit into the OW border (also need to move the cursor and text one tile left).
!CounterXPos    = $16
!CounterYPos    = $18

; Number of max options in the menu (without counting the exit option)
; Make sure all the tables below have this number of entries! (+1 for the names table)
!NumOptions     = 9

; How many options are shown at once in the menu.
!ShownOptions   = 8

; Color for backdrop during menu (to darken the OW under it).
!BGColor        = $2D6B

; SFX when opening the menu
!OpenSFX        = $15
!OpenSFXAddr    = $1DFC|!addr

; SFX when closing the menu
!CloseSFX       = $29
!CloseSFXAddr   = $1DFC|!addr

; SFX when moving the cursor
!CursorSFX      = $06
!CursorSFXAddr  = $1DFC|!addr

; SFX when selecting an option
!SelectSFX      = $01
!SelectSFXAddr  = $1DFC|!addr

; SFX when warping
!WarpSFX        = $0D
!WarpSFXAddr    = $1DF9|!addr

; How many frames to spin on the ground before rising during a warp
!GroundTime     = $31

; Max Y speed while rising during a warp
!MaxYSpeed      = $04

; If 1, the first map in DestinationSubmap will always be unlocked when starting the game.
; Otherwise, it'll require an event like the others.
!StartMapAlwaysUnlocked = 1

; Destination submap ID for each menu option. IDs can be repeated to have multiple warp points in the same map.
; $00 = Main map; $01 = Yoshi's Island; $02 = Vanilla Dome; $03 = Forest of Illusion;
; $04 = Valley of Bowser; $05 = Special World; $06 = Star World
DestinationSubmap:
    db $01
    db $00
    db $02
    db $00
    db $03
    db $00
    db $04
    db $06
    db $05

; Position to warp to for each menu option. In OW editor, bottom left numbers are X,Y (when in layer 1 editing mode).
; Put here those numbers * $10.
; For the Y position, also add $08 after the multiplication.
; For the X position, add $08 if the destination is on the main OW, or subtract $08 if it's in one of the submaps.
DestinationXPosition:
    dw $0068
    dw $0058
    dw $0058
    dw $0148
    dw $0088
    dw $0188
    dw $01B8
    dw $0128
    dw $0118

DestinationYPosition:
    dw $0278
    dw $0118
    dw $0328
    dw $0038
    dw $0378
    dw $0168
    dw $0278
    dw $03D8
    dw $0338

; This determines whether the destination tile is ground or water,
; needed because of a vanilla bug where the animation is not updated after warping.
; $02 = ground, $0A = water.
DestinationType:
    db $02
    db $02
    db $02
    db $02
    db $02
    db $02
    db $02
    db $02
    db $02

; Event required in order to teleport to the different maps.
; If !StartMapAlwaysUnlocked = 1, the value for the starting map doesn't matter here.
RequiredEvent:
    db $00
    db $06
    db $0F
    db $21
    db $24
    db $61
    db $4E
    db $13
    db $5E

; Name for each warp point (+ option to close the menu if !ShowExitOption = 1).
; Each entry must be !TextLength characters long (add spaces if necessary).
; Note: if all names end with a bunch of spaces, trim them down and reduce !TextLength,
;       since drawing too many characters on screen may cause some flickering (more probable on SA-1).
;       Alternatively you can also reduce the number of options shown at once.
SubmapNames:
    db "Yoshi's Island    "
    db "Donut Plains      "
    db "Vanilla Dome      "
    db "Butter Bridge     "
    db "Forest of Illusion"
    db "Chocolate Island  "
    db "Valley of Bowser  "
    db "Star Road         "
    db "Special World     "
    db "Exit              "
