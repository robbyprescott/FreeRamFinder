; https://www.smwcentral.net/?p=tweaks&a=details&id=69

; This tweak fixes some issues that happen with sprites occupying slots 10 and 11 (20 and 21 on SA-1), which originally are only used by reserve items and berries but are more commonly used with custom codes that spawn sprites.

!SprSize = $0C          ; Number of sprite slots (12 - FastROM, 22 - SA-1 ROM)

; Lakitu spawn check
org $01846C
    db !SprSize-1

; Yellow Koopa jump check
org $0188A0
    db !SprSize-1

; Magikoopa spawn check
org $01BDB9
    db !SprSize-1

; Cloud's Lakitu check
org $01E7DC
    db !SprSize-1

; Explosion sprite interaction
org $02813A
    db !SprSize-1

; Cape ground pound
org $0294CD
    db !SprSize-1

; Mario/Yoshi fireballs sprite interaction
org $02A0B9  ; Sometimes sprites spawned from question blocks are immune to Mario fire, Yoshi fireball, etc.
    db !SprSize-1 ; vanilla 09

; Pokey sprite interaction
org $02B7AD
    db !SprSize-1

; Silver P-Switch effect
org $02B9C3
    db !SprSize-1

; Flying Hammer Bro platform check
org $02DB65
    db !SprSize-1

; Skull Raft despawn check
org $02EDE5
    db !SprSize-1

; Unused Skull Raft check
org $02EE20
    db !SprSize-1

; Flying Grey Turnblocks check
org $03865F
    db !SprSize-1

; Boss end sprite kill
org $03A6C9
    db !SprSize-1

; Light switch spotlight check
org $03C210
    db !SprSize-1

; Spotlight spawn check
org $03C4E2
    db !SprSize-1