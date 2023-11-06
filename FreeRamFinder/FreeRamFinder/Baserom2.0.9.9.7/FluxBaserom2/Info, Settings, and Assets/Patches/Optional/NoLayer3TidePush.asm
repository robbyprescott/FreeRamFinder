; This will negate the possibility of reversing the layer 3 tide direction, obviously,
; which by default can be triggered by blocks included in the baserom

; If you're not using the screen-scrolling pipes, you can simply do 

;org $00DA6F
;    db $80
	
;org $00DA58
;    db $80

; Otherwise, if you're using the SSPs,

!max_water_walk     =   $08     ; Speed of Mario in water on the ground.
!max_water_swim     =   $10     ; Speed of Mario in water while swimming.
!max_water_walk_i   =   $10     ; Speed of Mario in water on the ground with an item.
!max_water_swim_i   =   $20     ; Speed of Mario in water while swimming with an item.

!tide_spd_walk      =   $FF     ; Speed that tides slow Mario by when walking.
!tide_spd_swim      =   $FF     ; Speed that tides slow Mario by when swimming.

!tide_auto_ground   =   $0000   ; Speed that tides autopush Mario with when on the ground.
!tide_auto_swim     =   $0000   ; Speed that tides autopush Mario with when off the ground.

!left_max_water_walk        =   $100-!max_water_walk
!left_max_water_swim        =   $100-!max_water_swim
!left_max_water_walk_i      =   $100-!max_water_walk_i
!left_max_water_swim_i      =   $100-!max_water_swim_i

!left_tide_spd_walk         =   $100-!tide_spd_walk
!left_tide_spd_swim         =   $100-!tide_spd_swim

org $00D5AD
    WaterMax:       ; Max swim speeds, in the order: on ground, swimming, tide ground, tide swimming. Left then right.
        db !left_max_water_walk,!max_water_walk,!left_max_water_swim,!max_water_swim
        db !left_max_water_walk+!tide_spd_walk,!max_water_walk+!tide_spd_walk,!left_max_water_swim+!tide_spd_swim,!max_water_swim+!tide_spd_swim
    
    WaterItemMax:   ; Max swim speeds with an item, same order as above.
        db !left_max_water_walk_i,!max_water_walk_i,!left_max_water_swim_i,!max_water_swim_i
        db !left_max_water_walk_i+!tide_spd_walk,!max_water_walk_i+!tide_spd_walk,!left_max_water_swim_i+!tide_spd_swim,!max_water_swim_i+!tide_spd_swim
		
org $00D5E7
    AutoTideSpds:   ; How fast Mario moves when not holding any buttons in a tide.
        dw !tide_auto_swim,!tide_auto_ground
		
		
		
		
