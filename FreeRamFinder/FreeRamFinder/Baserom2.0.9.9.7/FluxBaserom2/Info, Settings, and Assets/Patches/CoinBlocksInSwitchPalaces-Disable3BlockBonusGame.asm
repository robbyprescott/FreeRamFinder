; Fixes switch palace block jank when hit thing
; Also frees up 5 bytes of RAM at $13F4

;$008F67 - [8D 25 14] Change to EA EA EA to disable entering bonus game when player has 100 bonus stars.


org $00F1EA
db $EA,$EA     ;   vanilla $F0,0D 

; Change from F0 0D to EA EA to disable the 3-block 1up bonus game, allowing you to use coin question blocks in levels with the switch palace tileset (4), and freeing up the 5 bytes at RAM address $13F4 for custom use.

; $00:F1E9 - FG/BG Tileset in which coin question blocks' behavior are changed for the 3-block 1up bonus game.



;CODE_00F1E5:        AC 31 19      LDY.W $1931, Tileset setting from level header.             
;CODE_00F1E8:        C0 04         CPY.B #$04                
;CODE_00F1EA:        F0 0D         BEQ CODE_00F1F9           
;CODE_00F1EC:        8B            PHB 