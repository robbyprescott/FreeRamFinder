;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Custom Bullet Bill
;; By RussianMan
;;
;; It's a bullet bill that includes new custom behavor, details below
;;
;; Extra Byte determines it's initial direction:
;; 00 - right
;; 01 - left
;; 02 - up
;; 03 - down
;; 04 - up-right
;; 05 - down-right
;; 06 - down-left
;; 07 - up-left	
;; FF - vanilla (face player)
;;
;; Extra Byte 2 determines it's behavor:
;; Bit 0 - Can Hit Enemies
;; Bit 1 - Die if it hits solid object (enables object interaction)
;; Bit 2 - Die if it hits player
;; Bit 3 - Explodes on hit (requires either of above bits to be set, overwrites normal death)
;; Bit 4 - Freeze player on hit (incompatible with yoshi, it still makes player lose him)
;; Bit 5 - Can be reflected with cape (similar to SM3DL)
;; Bit 6 - Die if it hits enemy (bit 0 must be enabled, ignored if bit 3 is enabled)
;; Bit 7 - Spawn diagonal fireballs on death (any of bits 1, 2 or 6 must be enabled)
;;
;; Extra byte 3 determines behavor part 2:
;; Any non-zero value - Explode on stomp (from above)
;; (will change to bits once I have more features for this byte)
;;
;; Note on Extra Byte 2 Bit 5 (Cape Reflect)
;; It can be reflected to ONLY go left or right, but any of it's states can be reflected (as in if it goes straight upwards, it can be hit to go left/right)
;; Direction is determined by player's position relative to sprite's. 
;;
;; Credit is appreciated.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Tilemap:
;-Horizontal right
;-Horizontal left
;-vertical up
;-vertical down
;-diagonal up-right
;-diagonal down-right
;-diagonal down-left
;-diagonal up-left 

Tilemap:
db $A6,$A6,$A4,$A4,$A6,$A8,$A8,$A6	

;Graphical properties:
;Apply flips and SP3/4 GFX when necessary
;-Horizontal flip (face right), No Vertical Flip, SP1/2
;-No Horizontal flip, No Vertical Flip, SP1/2
;-No Horizontal flip, No Vertical Flip, SP3/4
;-No Horizontal flip, Vertical Flip (face upward), SP3/4
;-No Horizontal flip, No Vertical Flip, SP3/4
;-Horizontal flip (face right), No Vertical Flip, SP3/4
;-No Horizontal flip, No Vertical Flip, SP3/4
;-Horizontal flip (face right), No Vertical Flip, SP3/4

TileProperties:
db $40,$00,$01,$81,$01,$41,$01,$41

;X/Y Speed
;-Go right
;-Go left
;-Go up
;-Go down
;-Go up-right
;-Go down-right
;-Go down-left
;-Go up-left

XSpeed:
db $20,$E0,$00,$00,$18,$18,$E8,$E8

YSpeed:
db $00,$00,$E0,$20,$E8,$18,$18,$E8

;this makes Bit 4 of behavor props to both hurt and freeze, instead of just freezing player.

!HitANDFreeze = 1			

;Sprite contact flags enable to allow bullet to kill:
;!SprContactCape - If it can be hit/killed with cape attack
;!SprContactFire - If it can be hit/killed with fireball
;!SprContactStarBlks - If it can be hit/killed by star power and bounce sprites.
;
;Note that sprite checks those from CFG settings, specifically $166E's Bits 4 and 5 and $167A's bit 1.
;Glitchy death sprites may occure for some killed sprites, so watch out for that!
;Also those options don't include "Don't interact with other sprites" bit, check for it already included

!SprContactCape = 0
!SprContactFire = 0
!SprContactStarETC = 0

;Death type:
;0 - Smoke - disappear on puff of smoke
;1 - Classic Fire/5 Fireballs kill - Makes it die like if it was either killed by 5 fireballs or killed with fireball with classic fireball patch

!DeathType = 1

;Original SMW bullet bill disappears forever if it goes offscreen vertically. If you want to disable that, set this to zero.

!VerticallyDisappear = 1

;used when bullet kills sprite to kill it some X speed
KillXSpeed:
db $F0,$10

;same as above, but for y speed
!KillYSpeed = $D0

;Diagonal Fireballs Speed
;(change what's substracted for negative speeds)

DiagFireXSpd:
db $11,$11,$00-$11,$00-$11

DiagFireYSpd:
db $11,$00-$11,$0F,$00-$11

;defines you don't need to edit (unless you know what you're doing)
incsrc BulletSrc/SpriteTables.asm	;make asm look cool, sorta?
incsrc BulletSrc/RAMAddresses.asm	;but doesn't make it portable
incsrc BulletSrc/ROMAddresses.asm	;I mean you have to replace every address from define to actual address if you copy-paste it somewhere else (unless you include them in here as well)
incsrc BulletSrc/Misc.asm		;I'm experimenting with coding styles again

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
DEC !spr_y_pos,x		; slightly raise it's position 1 pixel upward to prevent straight left/right bullets from dying by touching ground when it shouldn't (only if foreground collision is set)

;LDA !spr_y_pos_hi,x		; prevents bullets from appearing?
;SBC #$00			;
;STA !spr_y_pos_hi,x		;

LDA !extra_byte_1,x		; set direction based on Extra Byte 1
STA !sprite_direction,x		;
INC				;
BNE NotVanilla			; unless you want it to act like vanilla bullet

%SubHorzPos()			; face player
TYA				;
STA !sprite_direction,x		; (only left/right is possible with this)

NotVanilla:
LDA #$10			;
STA !behind_scene_timer,x	; set the "behind screen" timer
STA !no_obj_col_timer,x		; no collision for a little bit

LDA !extra_byte_2,x		; store behavor properties
STA !behavor_props,x		;
AND #$20			; if it can be cape-reflected
BEQ .NoCapeReflect		; it can be cape reflected

LDA !cfg_166E,x			; enable "Disable Cape Killing" bit to make custom cape interaction work
ORA #$20			;
STA !cfg_166E,x			;

.NoCapeReflect
LDA !extra_byte_3,x		;more props - more features
STA !behavor_props_sequel,x	;
RTL				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR BulletBillMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BulletBillMain:
LDA #$00			;
%SubOffScreen()			;

LDY !sprite_direction,x		;
LDA !freeze_flag		; if sprites are locked...
ORA !sprite_status,x		; or dead...
EOR #$08			;
BNE Skip1			; skip this next part of code

LDA XSpeed,y			;
STA !X_speed,x			; set the X speed

LDA YSpeed,y			;
STA !Y_speed,x			; set the Y speed

PHY				; save y we loaded from overwriting
JSL !update_X_spd_no_gravity	; update sprite X position without gravity
JSL !update_Y_spd_no_gravity	; update sprite Y position without gravity

JSR Interactions		; interact with player and objects (maybe)
PLY				;

Skip1:
If !VerticallyDisappear
  LDA !spr_y_pos,x		; sprite Y position
  SEC				;
  SBC !current_y_pos		; minus vertical screen boundary
  CMP #$F0			; if the sprite has gone too far offscreen...
  BCC NoErase			;
  STZ !sprite_status,x		; erase it (yeah, it won't reappear... I guess?)
endif

NoErase:
LDA !behind_scene_timer,x	; if the behind-screen timer is set...
BEQ BulletBillGFX		; put the sprite behind the foreground

LDA !spr_priority		;
PHA				; preserve the current priority settings
LDA #$10			;
STA !spr_priority		; and set the priority lower

JSR BulletBillGFX		; draw the sprite

PLA				;
STA !spr_priority		; restore the old priority settings
RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BulletBillGFX:
LDA Tilemap,y			; sprite tile to $02
STA $02				;

LDA TileProperties,y		; set flips 'n stuff
STA $03				; to $03

%GetDrawInfo()			;

LDA $00				;
STA !OAM_Tile_X_Pos		; no X displacement

LDA $01				;
STA !OAM_Tile_Y_Pos		; no Y displacement

LDA $02
STA !OAM_Tile_Display		;

LDA !sprite_status,x		;
EOR #$08			;
BEQ .Mhm			;

LDA #$80			; if dead, it should be Y-flipped (with a few exceptions)

.Mhm
ORA $03				;
ORA !spr_priority		;
ORA !gfx_prop_settings,x
STA !OAM_Tile_Props		;

LDY #$02			; tile size = 16x16
LDA #$00			; tiles to display = 1
JSL !finish_drawing		;
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; various interactions
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Interactions:
LDA !behavor_props,x		; check if it should have contact with cape
AND #$20			;
BEQ .NoCape			;

%CapeContact()				; check cape contact
BCC .NoCape			;

%SubHorzPos()			; make bullet face away from player (only horizontally)
TYA				;
EOR #$01			;
CMP !sprite_direction,x		; if player hits bullet with cape that goes away from player
BEQ .NoCape			; no effect (only for straight horizontal bullets, diagonal bullets that supposendly go away still become straight horizontal ones)
STA !sprite_direction,x		;

JSL !hit_effect_to_sprite	;

LDA #$13			; sound effect for hitting bullet with cape
STA !sound_bank_1DF9		;

.NoCape
LDA !behavor_props,x		; if it can hit sprite, it should
AND #$01			;
BEQ .NoSprCheck			;

JSR ProcessSprInteraction	; sprite interaction

.NoSprCheck
LDA !behavor_props,x		; if bullet can interact with foreground, it can be dead
AND #$02			;
BEQ .NoObjInteraction		;

LDA !no_obj_col_timer,x		; if timer to disable object interaction is set
BNE .NoObjInteraction		; don't interact with objects

JSL !obj_interaction_routine	; now interaction with objects makes more sense (if you know what I mean)

LDA !blocked_status,x		; if it's blocked by anything
BEQ .NoObjInteraction		;

LDA #$09			; hit sound effect
STA !sound_bank_1DFC		;

JMP Dead			; boom, dead

.NoObjInteraction
JSL !player_interaction_routine	; interact with the player
BCC .Re				;

LDA !Star_Timer			; if player has star, kill sprite in any case
BEQ .NotStar			;

-
JSL !hit_effect_to_sprite	; hit effect
%Star()				; kill sprite with star power

.Re
RTS				;

;common sprite stomp code (well, almost)

.NotStar
LDA !no_player_col_timer,x	; this prevents player from stomping sprite if it goes under player when he/she is frozen (like vertical bullet)
BNE .Re				; possible only with "can freeze on contact" behavor. it also prevents sprite from constantly setting freeze timer when in contact with player.

%SubVertPos()			; check if wether player or sprite takes a hit
LDA $0E
CMP #$E6			;
BPL .Sprite_Hurts		; if player's below or on the same level, sprite hurts

.Mario_Hurts
JSL !hit_effect_to_player	; show hit graphics

LDA !Player_Jump_status		; if player's jumping, do a normal bounce height
BEQ .NormalBounce		;

LDA !On_Yoshi_Flag		; if player's on yoshi, also normal bounce
BNE .NormalBounce		;

LDA #$F8			; a small little "bounce"
STA !player_y_speed		;
BRA .SpinKillOrNot		;

.NormalBounce
JSL !player_bounce_routine 	; make player bounce like normal (with jump buttons pressed and all)

.SpinKillOrNot
LDA !Player_Jump_status		; if player's either spinjumping
ORA !On_Yoshi_Flag		; or on yoshi
BNE .SpinKill			; make sprite die in four stars of life force that last 23 frames.

%Stomp()			; perform le 'ol stomp action

LDA !behavor_props_sequel,x	; if it must explode on stomp, explode
;AND #$01			; will uncomment after assigning more features to third extra byte
BEQ .NormalDeath		; if not, oh well

JMP Dead_KABOOM			;

.NormalDeath
LDA #$02			; sprite status = falling
STA !sprite_status,x		;

STZ !X_speed,x			; stop sprite from moving, jeez.
STZ !Y_speed,x			;
RTS

;sprite hurt player code

.Sprite_Hurts
LDA !Sliding_Flag		; if player's sliding
BNE -				; kill sprite like if player had star power

LDA !Blink_Timer		; don't make sprite accidently hurt mario if he's in blinking state
ORA !On_Yoshi_Flag		; don't hurt when on yoshi, instead make player lose him
BNE .Re2			; (oversight of SMW is that even if player's blinking yoshi takes damage. yoshi always takes damage for some reason)

LDA !behavor_props,x		;
AND #$04			;
BEQ .NoDisappear		;

JSR Dead			;

.NoDisappear
LDA !behavor_props,x		; check if it can freeze player
AND #$10			;
BEQ .Hurt			;

LDA #$1C			;
STA !sound_bank_1DFC		; sound effect

LDA #$30			; frozen
STA !Player_Stun_Timer		;
STA !no_player_col_timer,x	; can't contact anymore

If not(!HitANDFreeze)
  BRA .Re2			; freeze only
endif
  
.Hurt
JSL !hurt_routine		; a simple hurt routine

.Re2
RTS				;

.SpinKill
%Stomp()			; yes, this also runs stomp code. some adresses get overwritten afterwards

LDA #$04			; status = spin-killed
STA !sprite_status,x		;

LDA #$08			;
STA !sound_bank_1DF9		; spin-killed sound effect

JSL !spinjmp_stars_routine	; show spinjump stars
RTS				; finish our business

;custom death effect, includes "fireball hit", smoke and explosion

Dead:	
JSL !hit_effect_to_sprite	; said "smoke" appears in any case if you didn't know

LDA !behavor_props,x		; if it can spawn diagonal fireballs, do it
AND #$80			;
BEQ .NoFire			;

JSR DiagonalFire		; spawn fire

.NoFire
LDA !behavor_props,x		; if it explodes on hit, explode
AND #$08			;
BNE .KABOOM			;

If not(!DeathType)
  STZ !sprite_status,x		; a simple death
else
  LDY #$D0
  LDA !Y_speed,x		; if sprite was already going upward
  BPL .Reset			; no need to make it bounce upward on hit

  LDY #$10

.Reset
  STY !Y_speed,x		;

  LDY #$00
  LDA !X_speed,x		; if it didn't have any X-speed
  BEQ .ResetNO2			; no need to add it

  PHA				; don't make Y overwrite check value
  LDY #$F0			;
  PLA				;
  BPL .ResetNO2			;

  LDY #$10			;

.ResetNO2
  STY !X_speed,x		;

  LDA #$02			;
  STA !sprite_status,x		;
endif
RTS				

.KABOOM
LDA #$0D			;turn into bob-omb
STA !spr_num,x		     	;

;LDA #$08		     	; i mean, sprite is already in normal state, right?
;STA !sprite_status		;

JSL !reset_spr_tables		; Reset sprite tables

LDA #$01			; make it explode
STA !explosion_flag,x		;

LDA #$40		      	; explosion timer
STA !explosion_timer,x		;

LDA #$09		      	; explosion sound effect
STA !sound_bank_1DFC	      	;

;LDA #$1B			; this changes sprite props. not sure why
;STA !167A,x			;

LDA !cfg_166E,x			; most important thing is to disable cape killing
ORA #$20			; (because y'know, it looks weird when you can kill explosion)
STA !cfg_166E,x			;
RTS				;

ProcessSprInteraction:
LDY #!SprSize			; standart sprite check loop, load all sprite slots

.Loop
CPY !current_spr_slot		; don't check contact with itself
BEQ .Next			; (note: doesn't prevent interaction with other bullets, bullet in higher slot wins)

LDA !sprite_status,y		; sprite we're checkin' should be alive
CMP #$08			;
BCS .Alive			;

.Next
DEY				; check other sprites
BPL .Loop			;

.Re
RTS				; either no contact was made, can't contact or no other sprite avaiable. (actually, if contact was made it also returns here, unless bullet is supposed to die)

.Alive
LDA !cfg_1686,y			; check if sprite we're about to hit can interact with others at all
AND #$08			;
BNE .Next			; if not, next sprite

If !ConfCheck
  LDA !cfg_166E,y		; this checks if sprite we're about to hit can be killed by cape, fire or both
  AND #!ConfCheck		;
  BEQ .Next			; if not, NEEEEEEEXT!!!
endif

If !SprContactStarETC
  LDA !cfg_167A,y		; if checked sprite can't be killed with star and bouncing blocks, well...
  AND #$02			;
  BNE .Next			; ...
endif

PHX				; get enemy's clipping first...
TYX				;
JSL !get_collision_B		;
PLX				;
JSL !get_collision_A     	; then bullet's...

JSL !check_AB_collisions 	; check if their clippings overlap
BCC .Next			; if not, ok.

LDA #$02			; make sprite we hit die by falling offscreen
STA !sprite_status,y		;

LDA #$09			; hit sound effect
STA !sound_bank_1DFC		;

LDA #!KillYSpeed		; this makes killed sprite bounce slightly upward
STA !Y_speed,y			;

PHX				;
LDA !157C,y			;
TAX				;
LDA KillXSpeed,x		; X-speed based on it's facing...
STA !B6,y			; it goes away from where it was facing
PLX				;

LDA !behavor_props,x		; if it should disappear on enemy contact, rip
AND #$48			;
BEQ .Re				;

JMP Dead			;

DiagonalFire:
LDY #$03			; 4 fireballs to spawn

.FireLoop
PHY

LDA #$08			; fireballs appear from center (more or less)
STA $00				;
STA $01				;

LDA DiagFireXSpd,y		;
STA $02				;

LDA DiagFireYSpd,y		;
STA $03				;

LDA #$02			;
%SpawnExtended()		;
PLY				;
DEY				;
BPL .FireLoop			;
RTS				;