;self explanatory
!hurt_routine = $00F5B7|!BankB

;also self explanatory
!update_X_spd_no_gravity = $018022|!BankB
!update_Y_spd_no_gravity = $01801A|!BankB

;allows sprite to interact with foreground
!obj_interaction_routine = $019138|!BankB

;allows sprite to interact with player
!player_interaction_routine = $01A7DC|!BankB

;makes player bounce upward depending on A/B button holding (not spinjump)
!player_bounce_routine = $01AA33|!BankB

;shows hit effect, places it at sprite's position
!hit_effect_to_sprite = $01AB6F|!BankB

;same as above, except it places effect at player's position depending on his/her movement
!hit_effect_to_player = $01AB99|!BankB

;draws OAM based on OAM addresses set.
;A and Y are used to determine number of tiles to be displayed and their sizes respectively
!finish_drawing = $01B7B3|!BankB

;Get and match sprites collisions, if they overlap - contact was made.
;Collision A is bullet sprite, Collision B is checked sprite's collsion.
!get_collision_A = $03B69F|!BankB
!get_collision_B = $03B6E5|!BankB
!check_AB_collisions = $03B72B|!BankB

;resets tables before changing into another sprite
!reset_spr_tables = $07F7D2|!BankB

;routine that summons 4 spinjump stars that show up when player kills sprite with spinjump
!spinjmp_stars_routine = $07FC3B|!BankB