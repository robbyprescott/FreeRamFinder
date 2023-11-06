;current layer 1 (camera?)'s Y position
!current_y_pos = $1C

;current sprite's priority from YXPPCCCT
!spr_priority = $64

;self-explanatory
!player_y_speed = $7D

;common flag that prevents sprite from functioning if it's set
!freeze_flag = $9D

;OAM - related addresses
;0300 - sprite's X-position relative to screen border
;0301 - sprite's Y-position relative to screen border
;0302 - sprite tile
;0303 - sprite tile props

!OAM_Tile_X_Pos = $0300|!Base2,y
!OAM_Tile_Y_Pos = $0301|!Base2,y
!OAM_Tile_Display = $0302|!Base2,y
!OAM_Tile_Props = $0303|!Base2,y

;Flag for player's sliding
!Sliding_Flag = $13ED|!Base2

;0 - standing/jumping, anything else - spinjumping
!Player_Jump_status = $140D|!Base2

;timer for player's star power
!Star_Timer = $1490|!Base2

;player's invulnerability timer
!Blink_Timer = $1497|!Base2

;currently processing sprite's slot
!current_spr_slot = $15E9|!Base2

;flag if player's riding yoshi
!On_Yoshi_Flag = $187A|!Base2

;How long player faces screen, unable to move
!Player_Stun_Timer = $18BD|!Base2

;sound banks
;https://www.smwcentral.net/?p=viewthread&t=6665 is your friend

!sound_bank_1DF9 = $1DF9|!Base2
!sound_bank_1DFC = $1DFC|!Base2