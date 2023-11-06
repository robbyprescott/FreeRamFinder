;vanilla sprite number OR acts like from config setting. used only to turn into bob-omb (or rather to it's explosion)
!spr_num = !9E

;Common speed tables
!Y_speed = !AA
!X_speed = !B6

;self-expalanatory, low byte
!spr_y_pos = !D8

;Direction:
;00 - left
;01 - right
;02 - down
;03 - up
;04 - downright
;05 - upright
;06 - upleft
;07 - downleft
!sprite_direction = !C2

;doesn't need explanation, hopefully
!sprite_status = !14C8

;y position - high byte 
!spr_y_pos_hi = !14D4

;only used when it explodes
!explosion_flag = !1534

;timer that sets bullet behind objects + explosion timer when it's set to explode
!behind_scene_timer = !1540
!explosion_timer = !1540

;if set sprite won't interact with player
!no_player_col_timer = !154C

;timer to disable collision with objects (foreground), set when spawned (to prevent it from dying instantly when shot from cannon)
!no_obj_col_timer = !1558

;mirror of extra byte 2, used for behavor changes
!behavor_props = !157C

;same as above, but extra byte 3
!behavor_props_sequel = !1594

;used in interaction with objects, ceiling, ground and etc.
!blocked_status = !1588

;graphic properties, set from CFG file
!gfx_prop_settings = !15F6

;shows sprite tile loaded from table
!tile_to_display = !1602		

;config settings, values come from cfg.
!cfg_166E = !166E
!cfg_167A = !167A
!cfg_1686 = !1686		