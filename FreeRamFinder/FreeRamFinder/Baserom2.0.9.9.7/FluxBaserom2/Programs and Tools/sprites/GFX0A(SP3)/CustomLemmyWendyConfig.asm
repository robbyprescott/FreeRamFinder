;---------------------------------------
; Customization, etc:
;---------------------------------------

;--------------------------------------------
; Basic settings:

; Use either LemmyGfx.asm or WendyGfx.asm for the basic graphics.  See there for more information about making custom graphics.
incsrc "WendyGfx.asm"

!BossHP = 3             ; hits required to kill the boss
!MaxDummySlot = 6       ; highest sprite slot to attempt to spawn dummies into.  What's safe to use will depend on the sprite memory settings and any patches like SA-1, No more sprite tile limits, etc.  For the default fight, a setting of 6 is safe to avoid glitched graphics.
!IsWendy = 1            ; set to 1 for wendy, 0 for lemmy (probably doesn't matter, but it will set the koopa kid type in case something else wants to check it)

;------------------------------------------------------------------------------
; Spawn settings:

; The following tables describe the possible spawn positions for the boss.  The default Lemmy/Wendy fights use 7 each, but you can ha.ve up to 127 max
; Each spawn point has an X coordinate, Y coordinate, and direction (rightside up or upside down).

; The 16-bit X coordinates of each spawn point -- one entry for each
; In the normal Lemmy and Wendy fights, these are each 8 pixels to the right of the leftmost pixel of the pipe to spawn in
SpawnPointX:
  dw $0018,$0038,$0058,$0078,$0098,$00B8,$00D8  ; default for Lemmy/Wendy

; The 16-bit Y coordinates of each spawn point -- one entry for each
; In the normal Lemmy/Wendy fights, the Y coordinates are 16 pixels below the top pixel of a pipe.
;   For upside down spawns, they should be 18 pixels above the bottom pixel of the pipe in order to match.
;   (These can also be 17 and 17 due to the SMW's 1-pixel layer rendering offset)
SpawnPointY:
  dw $0150,$0150,$0150,$0150,$0150,$0150,$0150  ; default for Wendy
;  dw $0140,$0150,$0150,$0140,$0130,$0140,$0150  ; default for Lemmy

; The directions for each spawn point -- 0 for regular, 1 for an upside down point -- one entry for each
SpawnPointDir:
  db 0,0,0,0,0,0,0

;------

; Fights are divided into a number of cycles (where the boss will emerge from their pipe, make a funny face, and then retreat back into it)
; Each cycle consists of one or more patterns (each cycle has the same number of patterns).
; For each cycle, a random pattern from that cycle is chosen, and that pattern is used to determine where the boss and the dummies will appear.
;   (So note that if each cycle only has 1 pattern, then there's no randomness to the fight at all)
; And for each pattern, the spawn location for the boss and any dummies must be given
; 
; For example, the default Lemmy/Wendy fight can be thought of as having 1 cycle (which repeats), with 7 patterns.
; If you instead gave it 7 (repeating) cycles with 1 pattern each, then you'd get a fight which goes through each pattern once, then repeats
;
; As another example, an autoscroll fight might have 5 (non-repeating) cycles and 2 patterns per cycle.  You'd then have 5 chances to
;   hit the boss enough times, but still retain a little randomness in where the boss will appear.  And here, the patterns for each cycle
;   will be using different spawn points (since the ones for previous cycles would have scrolled away by then).
;
; Warning: Due to the way this data is accessed, (!NumCycles * !PatternsPerCycle * !MaxDummies) can be no larger than 256

!NumCycles = 1          ; total number of cycles
!RepeatCycles = 1       ; after all cycles have run, keep repeating this many of them (0 to just stop and despawn)
!PatternsPerCycle = 7   ; number of patterns any given cycle will randomly choose from
!MaxDummies = 2         ; maximum number of dummies that will appear in any pattern

; don't change these
!NumPatterns #= !NumCycles*!PatternsPerCycle
!RepeatOffset #= !PatternsPerCycle*(!NumCycles-!RepeatCycles)

; The spawn locations for the boss -- each entry refers to a spawn point defined above (use -1 or $ff if the boss shouldn't appear)
; First give the locations for each pattern in cycle 0, then each pattern in cycle 1, etc.
; So for example, if you have 3 cycles with 2 patterns each, you'll give something like:
;   db <spawn point for cycle 0, pattern 0>, <spawn point for cycle 0, pattern 1>
;   db <spawn point for cycle 1, pattern 0>, <spawn point for cycle 1, pattern 1>
;   db <spawn point for cycle 2, pattern 0>, <spawn point for cycle 2, pattern 1>
BossSpawnLocations:
  db 0,1,2,3,4,5,6    ; default for Wendy/Lemmy

; The spawn locations for the dummies
; Use the same format as for the boss, but give each dummy separately.  So give all the values for the first dummy, then all the values for the second dummy, etc.
DummySpawnLocations:
  db 2,3,4,5,6,0,1   ; default for Wendy/Lemmy
  db 4,5,6,0,1,2,3

;------------------------------------------------------------------------------
; Timing settings:
; Unless otherwise specified, times are given in frames

; Set to 0 for normal spawn cycle timing, or 1 to manually specify a set of times to emerge (particularly useful for autoscroll fights)
!ManualCycles = 0

; If not using manual cycle timing, the following two defines are used

; Time to stay hiding in the pipe (phase 0) before starting to emerge (phase 1)
!TimeHiding = $30
; Like the previous, but only the first time as the fight is starting
!TimeStart = $80

; If using manual cycle timing, specify a list of (16-bit) times to begin phase 1 (emerging) for each cycle
; If also using repeating cycles, the timer will be reset to a sane (but possibly undesired) value at the end of the last cycle
; Warning: if these are too close together, the frame counter may pass the value it's checking for and never trigger the next cycle
if !ManualCycles
  EmergeTimes:
    dw 120, 300, 700
endif

!TimeVulnerable = $40   ; time boss/dummy is vulnerable while out of the pipe
!TimeRetreat = $24      ; time spent retreating back into the pipe
!TimeStompedBoss = $50  ; time to stay stomped for the boss
!TimeStompedDummy = $20 ; time to stay stomped for the dummies
!EmergeSpeed = 8        ; speed to emerge from the pipe
!RetreatSpeed = 16      ; speed to retreat back into the pipe

;------------------------------------------------------------------------------
; Interaction settings:

; Set to 0 to bypass boss or dummy interaction with mario, 1 to enable
!BossMarioInteract = 1
!DummyMarioInteract = 1

; These describe how to behave if (normal) jumped on or spin jumped on for the boss and dummy.
; They're ignored if there's no interaction.  Otherwise:
; 0 = nothing (just bounce off), 1 = normal hit, 2 = stun but no damage, 3 = hurt mario
; For dummies, "normal hit" is a kill, either a spin kill or sending it immediately back into the retreat phase depnding on jump type
; Note that these are ignored for an upside down spawn point -- Mario always gets hurt in this case (assuming interaction is enabled)
!JumpBoss = 1
!JumpDummy = 2
!SpinBoss = 1
!SpinDummy = 2

; Set to 0 to bypass boss or dummy interactions with carryable/kickable sprites (shell, key, throw block, etc), or 1 to enable
!BossSpriteInteract = 0
!DummySpriteInteract = 0

; These describe how to behave when the boss or dummy is hit by a throwable sprite.
; They're ignored if there's no interaction.  Otherwise:
; 0 = nothing (but item still breaks), 1 = normal hit, 2 = stun but no damage
; A "normal hit" for a dummy is a kill, like via jumping
!SpriteBoss = 1
!SpriteDummy = 2

; Set to 0 to bypass boss or dummy interactions with player fireballs, or 1 to enable
!BossFireballInteract = 0
!DummyFireballInteract = 0
; If set to 1, any fireball interactions will also check for Yoshi fireballs in addition to player fireballs
!YoshiFireballs = 1

; These describe how to behave when the boss or dummy is hit by a throwable sprite.
; They're ignored if there's no interaction.  Otherwise:
; 0 = nothing happens, 1 = normal hit, 2 = stun but no damage
; A "normal hit" for a dummy is a kill, like via jumping
!FireballBoss = 1
!FireballDummy = 1

;------------------------------------------------------------------------------
; End-of-fight settings:

; set to 1 to kill (most) sprites on screen upon the final hit on the boss, and 0 to skip doing so
!KillSprites = 1
; set to 1 to also kill the dummies, 0 to not
!KillDummies = 0

; If killing sprites, set this to the number of sprites you want to spare (0 not to spare any)
!DontKillSpritesNum = 1

; If killing sprites, this should be a list of sprites to spare
if !KillSprites && !DontKillSpritesNum
  DontKillSprites:
    db $35                  ; Yoshi (even though he probably doesn't deserve it)
endif

; The number of map16 tiles to change upon the final hit on the boss (0 to not change any, max 127)
!TilesToChange = 0
; If 0, the tile coordinates below are absolute positions in the level; if 1, they're relative to Mario's position when they're created
!TilesRelativeMario = 0
; The layer to change tiles on: 0 for layer 1, or 1 for layer 2/3
!TileChangeLayer = 0

; This is a list of tiles to change: first a table of the (16-bit) X coordinates (in tiles, not pixels -- easy to find in LM),
;   then a table of the (16-bit) Y coordinates, then a table of the (16-bit) Map16 tile numbers to change to
if !TilesToChange
  TileChangeDataX:
    dw $0007, $0008
  TileChangeDataY:
    dw $0018, $0018
  TileChangeDataNum:
    dw $0130, $0130
endif

; What to do after the last hit on the boss: 1 = Fall and sink in lava, 2 = fall offscreen
!EndingPhase = 1

; Time to spend in phase 6 (either sinking in lava or just waiting invisible after falling offscreen) before ending the fight
!TimeEnding = 128

; If sinking, this is the Y position (in pixels) that the boss will fall to before beginning to sink
!SinkHeight = $185
; If the spawn point was upside down, this value will be used instead
!SinkHeightUD = $19d

; What to do after the fight is over:
; 0 = Nothing, 1 = End level
!DefeatAction = 1
