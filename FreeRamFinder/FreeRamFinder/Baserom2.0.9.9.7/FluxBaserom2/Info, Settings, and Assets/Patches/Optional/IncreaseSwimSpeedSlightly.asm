; You can use Uber version instead

org $00D5AF
db $xx,$xx ; Left then right. (Vanilla $F0,$10)


;org $00D5AD
    ;WaterMax:       ; Max swim speeds, in the order: on ground, swimming, tide ground, tide swimming. Left then right.
        ;db !left_max_water_walk,!max_water_walk,!left_max_water_swim,!max_water_swim
        ;db !left_max_water_walk+!tide_spd_walk,!max_water_walk+!tide_spd_walk,!left_max_water_swim+!tide_spd_swim,!max_water_swim+!tide_spd_swim
    
    ;WaterItemMax:   ; Max swim speeds with an item, same order as above.
        ;db !left_max_water_walk_i,!max_water_walk_i,!left_max_water_swim_i,!max_water_swim_i
        ;db !left_max_water_walk_i+!tide_spd_walk,!max_water_walk_i+!tide_spd_walk,!left_max_water_swim_i+!tide_spd_swim,!max_water_swim_i+!tide_spd_swim
		
		
		                          ;db $F8,$08,$F0,$10,$F4,$04,$E8,$08
                                  ;db $F0,$10,$E0,$20,$EC,$0C,$D8,$18
                                  ;db $D8,$28,$D4,$2C,$D0,$30,$D0,$D0
                                  ;db $30,$30,$E0,$20