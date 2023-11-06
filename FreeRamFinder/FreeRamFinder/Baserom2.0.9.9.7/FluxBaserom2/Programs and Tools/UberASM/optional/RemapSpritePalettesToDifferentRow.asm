; ; football; the wooden spikes/pencils; floating spike ball; ghost house moving hole; the brown chain platform; 
; the rope in the rope machine; and the little exploding fragments when the moles burst out of the ground.




; This UberASM remaps all non-Mario sprites that use palette row 8 to 
; instead use palette row F, on a per-level basis.

; This was made because while colors 6-F in palette row 8 are used exclusively 
; by Mario, the first few colors are used by other other sprites, too. 
; So by remapping these to a different palette row, you can change 
; the color of, say, the key or the turnblock bridge without affecting Mario himself. 
; Palette row F was chosen as the default to remap to, due 
; to the very small number of sprites which actually use this palette row.
; (See the charts in /Info, Settings and Resources/Sprite Info/.)

; Note, however, that a few sprites' palettes are hardcoded, and thus
; can't be changed easily here. This includes 

; Palette 8: the chuck football (1A), spike ball (#$A4), and turnblock bridges (59 and 5A),
; Palette 9: 

; This can have several (minor) trade-offs, too. 
; First, if you're using level mode 0C (dark BG mode), the sprites 
; remapped to row F will now be translucent — whereas this normally 
; doesn't affect sprites whose palettes are in rows 8-B. 
; However, you can use the included SaturateBGWithoutTranslucentSprites.asm 
; UberASM to get the same BG effect without this translucence.

; Further, the Magikoopa is not only colored in palette F directly, but
; its fade routine affects all sprites that use palettes C-F. 
; There's no perfect way around this. I think doing hex edits @ $01BE84 and $01C01A
; reduces the Magikoopa's fade. Maybe it's possible to tweak the Magikoopa's fade
; to not affect other sprites at all — have a look at $01BE through to $01C061.
; So either don't use magikoopas in the same level you use this UberASM,
; or if you don't want the (former) palette 8 sprites to be affected, 
; remap them instead to row B if you must.

; See also PerLevelSpritePaletteRemapTemplate.asm
; to see the structure for other palette remapping.

; Finally, Lakitu's cloud, the keyhole, and the Torpedo Ted bubbles also use palette 8,
; but only black and white — colors available in the same position in all palette rows.
; Feel free to add them to this list if you want to modify them.
; (They're sprite numbers 1E, 0E, and 44, in the order I listed them.)



main:
LDX #!sprite_slots-1
.loop
LDA !14C8,x
BEQ .next
LDA !9E,x
CMP #$1A                ; Chuck football
BEQ ChangeToPaletteF
CMP #$4C                ; Exploding block fragments created by throwblocks (but not all colors).
BEQ ChangeToPaletteF
CMP #$4D                ; Ground-dwelling mole. Not mole fragments though.
BEQ ChangeToPaletteF
CMP #$4E                ; Ledge-dwelling mole
BEQ ChangeToPaletteF
CMP #$52                ; Moving ghost house hole edges
BEQ ChangeToPaletteF
;CMP #$59                Horizontal and vertical turnblock bridge
;BEQ ChangeToPaletteF     
;CMP #$5A                Horizontal turnblock bridge
;BEQ ChangeToPaletteF
CMP #$5B                ; Brown platform floats in water
BEQ ChangeToPaletteF
CMP #$5C                ; Flying checkboard platform
BEQ ChangeToPaletteF
CMP #$5F                ; Brown platform on chain
BEQ ChangeToPaletteF
CMP #$62                ; Brown platform, line-guided
BEQ ChangeToPaletteF
CMP #$63                ; Line-guided checkboard platform
BEQ ChangeToPaletteF
CMP #$65                ; Rope for rope machine, but not the machine itself
BEQ ChangeToPaletteF
CMP #$7D                ; P-balloon
BEQ ChangeToPaletteF
CMP #$7F                ; Flying yellow 1-up, but not the wings
BEQ ChangeToPaletteF
CMP #$80                ; Key
BEQ ChangeToPaletteF
;CMP #$83                ; Flying coin question block, but not the wings
;BEQ ChangeToPaletteF
CMP #$A4                ; Spike floating in water
BEQ ChangeToPaletteF
CMP #$AC                ; Wooden spike/pencil, pointing downward
BEQ ChangeToPaletteF
CMP #$AD                ; Wooden spike/pencil, pointing upward
BEQ ChangeToPaletteF
CMP #$B2                ; Falling spike
BEQ ChangeToPaletteF
CMP #$BC                ; Bowser statue, jumping
BEQ ChangeToPaletteF
CMP #$BF                ; Mega Mole
BEQ ChangeToPaletteF
.next
DEX
BPL .loop
RTL

ChangeToPaletteF:
LDA !15F6,x
AND #$F1
ORA #$0E     ; YXPPCCCT value in hex, but bits only set for CCC, so palette 8 = 00, palette 9 = 02 
             ;                                                   palette A = 04, B = 06; C = 08 
             ;                                                   palette D = 0A, E = 0C, F = 0E

STA !15F6,x
BRA main_next