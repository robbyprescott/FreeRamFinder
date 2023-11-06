;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; All-Inclusive Mario Physics Modifier Patch                                        ;;
;;  Coded by Kaizoman (Thomas).                                                      ;;
;;                                                                                   ;;
;; To use, edit the defines below.                                                   ;;
;; All the values are by default set as they are in SMW, so use them as a reference. ;;
;;                                                                                   ;;
;; NOTE: most values below are signed (i.e. positive/negative).                      ;;
;;  $00-$7F ($0000-$7FFF) is positive (right/down)                                   ;;
;;  $80-$FF ($8000-$FFFF) is negative (left/up)                                      ;;
;; There are NO checks put it to make sure everything checks out,                    ;;
;; so be careful with high speeds or it risks overflow.                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Special Hijacks
;;  These hijacks use freespace if enabled. Set to 1 to enable.
;;  NOTE: Once enabled, you shouldn't disable it without restoring your ROM to an old version.

!applyJumpFixes     =   0
!applyRunFixes      =   0
    ; These two will fix bugs from having too high an X speed (#$40+).
    ;  The first fixes Mario being unable to jump, and is recommended if you
    ;   increase any X speeds close to that limit.
    ;  The second fixes Mario's max speeds "looping" if you set them too high.
    ;   Recommended if you plan on setting his max speeds that high, obviously.

!moreSpeeds         =   0
    ; There's a couple of speed values that aren't normally editable
    ;  (specifically, falling acceleration in water
    ;   and vertical acceration in a Lakitu cloud/P-balloon).
    ;  Enable this hijack to allow editing that.

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Actual options below! ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Jumping

!base_jump_spd      =   $B0     ; Base normal jump speed.
!base_spin_spd      =   $B6     ; Base spin jump speed.

!jump_incr          =   $0280   ; How much of an impact Mario's X speed has on his jump height.
!spin_incr          =   $0250   ; How much of an impact Mario's X speed has on his spinjump height.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Falling

!max_fall           =   $40     ; Max fall speed.

!accel_fall_noAB    =   $06     ; Gravity without A/B held.
!accel_fall_AB      =   $03     ; Gravity with A/B held.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Running

!max_walk           =   $14     ; Max walk speed.   (no X/Y)
!max_run            =   $24     ; Max run speed.    (X/Y held)
!max_sprint         =   $30     ; Max sprint speed. (X/Y held, full P-speed)

!accel_walk         =   $0180   ; Acceleration when walking with >
!accel_run          =   $0180   ; Acceleration when running with > + X/Y
!accel_walk_s       =   $0080   ; Acceleration when walking in a slippery level with >
!accel_run_s        =   $0180   ; Acceleration when running in a slippery level with > + X/Y

!decel_still        =   $FF00   ; Deceleration on the ground with no directional input.
!decel_walk         =   $FD80   ; Deceleration when reversing direction with <
!decel_run          =   $FB00   ; Deceleration when reversing direction with < + X/Y
!decel_walk_s       =   $FFC0   ; Deceleration when reversing direction in a slippery level with <
!decel_run_s        =   $FD80   ; Deceleration when reversing direction in a slippery level with < + X/Y

!timer_sprint       =   $70     ; Time Mario has to be running on the ground in order to gain full P-speed.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Swimming

!max_water_walk     =   $08     ; Speed of Mario in water on the ground.
!max_water_swim     =   $10     ; Speed of Mario in water while swimming.
!max_water_walk_i   =   $10     ; Speed of Mario in water on the ground with an item.
!max_water_swim_i   =   $20     ; Speed of Mario in water while swimming with an item.

!tide_spd_walk      =   $FC     ; Speed that tides slow Mario by when walking.
!tide_spd_swim      =   $F8     ; Speed that tides slow Mario by when swimming.

!tide_auto_ground   =   $F800   ; Speed that tides autopush Mario with when on the ground.
!tide_auto_swim     =   $F000   ; Speed that tides autopush Mario with when off the ground.

!swim_init_boost    =   $D0     ; Initial Y speed to give when "boosting" off the ground in water.
!swim_boosts        =   $E0     ; Speed to add to Mario's Y speed each time A/B is pressed.

!max_water_rise_u   =   $D0     ; Maximum upwards speed in water when holding up.
!max_water_rise_n   =   $E8     ; Maximum upwards speed in water when not holding up/down.
!max_water_rise_d   =   $F8     ; Maximum upwards speed in water when holding down.
!max_water_sink     =   $40     ; Maximum downwards speed in water when not carrying an item.

!max_water_rise_i   =   $F0     ; Maximum upwards speed in water while carrying an item.
!max_water_sink_i   =   $10     ; Maximum downwards speed in water while carrying an item.

!water_jumpout      =   $AA     ; Y speed to give when jumping out of the surface of the water.

; Requires !moreSpeeds to be enabled:
!accel_sink         =   $02     ; Sinking acceleration speed in water (i.e. gravity in water).


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cape

!disable_takeoff    =   0       ; Set to 1 to disable takeoff.
!disable_flight     =   0       ; Set to 1 to disable flight.

!max_cape_hover     =   $10     ; Fall speed when hovering with A/B in midair.

!takeoff_boosts     =   $C8     ; Y speed to give during initial takeoff boosts.
!timer_takeoff      =   $50     ; How long Mario's takeoff jump can be. Smaller number = lower jump.

!accel_aircatch     =   $F4     ; Upwards acceleration during an air catch.
!max_flight_rise    =   $C8     ; Maximum possible upwards speed during flight. Bad idea to set lower than any of the below values.

!aircatch_max0      =   $00     ; Max speed during an aircatch, depending on the fastest downwards Y speed Mario has had since the last air catch.
!aircatch_max1      =   $00     ;  (max0 = speed of #$00-#$07, max1 = speed of #$08-#$0F, max2 = speed of #$10-17, etc.)
!aircatch_max2      =   $00     ; These values correspond to Mario's Y speed while catching the air,
!aircatch_max3      =   $F8     ;  and are the point at which Mario stops accerating upwards (i.e. the dive ends).
!aircatch_max4      =   $F8     ;  It can be thought of as the size of the aircatch.
!aircatch_max5      =   $F8     ; 
!aircatch_max6      =   $F4     ; Increasing the value (towards #$80) will create a larger aircatch.
!aircatch_max7      =   $F0     ;  Values lower than any previous value will be ignored (so max9/max10 use max8's value by default).
!aircatch_max8      =   $C8     ;  A value of #$00 indicates air can not be caught.
!aircatch_max9      =   $02     ;
!aircatch_max10     =   $01     ; (yes, this are a mess, I can't think of any other way of doing it)

!dive_fastdive      =   !aircatch_max8      ; This is the max speed (from above) at which Mario changes flight phase faster than normal (see below).

!dive_phase_slow    =   #$08    ; Rate at which Mario changes flight phases normally.
!dive_phase_fast    =   #$02    ; Rate at which Mario changes flight phases when he has the above specified max speed.

!max_dive0          =   $10     ; Max dive speeds at various flight phases.
!max_dive1          =   $30     ;  dive0 = pulling back, dive5 = full dive.
!max_dive2          =   $30     ; 
!max_dive3          =   $38     ; 
!max_dive4          =   $38     ; 
!max_dive5          =   $40     ; 

!accel_dive1        =   $01     ; Downwards accelerations at various flight phases.
!accel_dive2        =   $03     ;  dive1 = catching air/slight dive, dive5 = full dive.
!accel_dive3        =   $04     ;
!accel_dive4        =   $05     ;
!accel_dive5        =   $06     ;

!max_flight_spd     =   $30     ; Maximum horizontal flight X speed.
!max_frev_spd       =   $F8     ; Maximum flight X speed when reversing (with <+B).

!accel_flight       =   $0400   ; Forwards flight X speed acceleration.
!accel_frev         =   $0600   ; Reverse flight X speed acceleration.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Climbing

!disable_climbing   =   0       ; Set to 1 to disable climbing.

!climb_spd          =   $10     ; Climbing speed.
!climb_spd_w        =   $08     ; Climbing speed, when Mario is underwater.

!climbjump_spd      =   $B0     ; Y speed for jumping off a vine/net.
!climbjump_spd_w    =   $F0     ; Y speed for jumping off a vine/net, when Mario is underwater.

!ropejump_spd       =   $B0     ; Y speed for jumping off a line-guided rope mechanism.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sliding
;;  Sidenote: all "gradual" slope values also apply to the purple triangles used for wallrunning. For some reason.

!disable_sliding    =   0       ; Set to 1 to disable the ability to slide.

!max_gradu_slide    =   $28     ; Max X speed for sliding down a gradual slope,
!max_norml_slide    =   $2C     ; Max X speed for sliding down a normal slope,
!max_steep_slide    =   $30     ; Max X speed for sliding down a steep slope,
!max_spstp_slide    =   $20     ; Max X speed for sliding down a very steep slope,

!accel_gradu_slide      =   $0080   ; Acceleration when sliding on a gradual slope.
!accel_norml_slide      =   $0100   ; Acceleration when sliding on a normal slope.
!accel_steep_slide      =   $0180   ; Acceleration when sliding on a steep slope.
!accel_spstp_slide      =   $0280   ; Acceleration when sliding on a very steep slope.

!accel_gradu_slide_s    =   $0080   ; Acceleration when sliding on a gradual slope in a slippery level.
!accel_norml_slide_s    =   $0100   ; Acceleration when sliding on a normal slope in a slippery level.
!accel_steep_slide_s    =   $0180   ; Acceleration when sliding on a steep slope in a slippery level.
!accel_spstp_slide_s    =   $0280   ; Acceleration when sliding on a very steep slope in a slippery level.


!max_gradu_auto     =   $0000   ; Max autoslide speed when standing still on a gradual slope.
!max_norml_auto     =   $0000   ; Max autoslide speed when standing still on a normal slope.
!max_steep_auto     =   $1000   ; Max autoslide speed when standing still on a steep slope.
!max_spstp_auto     =   $2000   ; Max autoslide speed when standing still on a very steep slope.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enemy Interaction

!enemy_bounce_noAB      =   $D0     ; Y speed to give Mario when bouncing off an enemy without A/B held. 
!enemy_bounce_AB        =   $A8     ; Y speed to give Mario when bouncing off an enemy with A/B held.

!enemy_spin_stomp       =   $F8     ; Y speed to give Mario when crushing an enemy with a spinjump.

!disco_bounce           =   $E8     ; X speed to give Mario when bouncing off an active disco shell.

!chuck_bounce           =   $E0     ; X speed to give Mario when bouncing off of a Chargin' Chuck.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; P-Balloon / Lakitu Cloud

!max_cloud_y_u      =   $F3     ; Max Y speed for the Lakitu cloud with up held.
!max_cloud_y_n      =   $03     ; Base Y speed for the Lakitu cloud with no up/down input.
!max_cloud_y_d      =   $13     ; Max Y speed for the Lakitu cloud with down held.

!max_balloon_y_u    =   $F0     ; Max Y speed for the P-balloon with up held.
!max_balloon_y_n    =   $F8     ; Base Y speed for the P-balloon with no up/down input.
!max_balloon_y_d    =   $08     ; Max Y speed for the P-balloon with down held.

!max_cloud_x        =   $10     ; Maximum X speed for the balloon/cloud.
!accel_cloud_x      =   $01     ; Horizontal acceleration rate for the P-balloon/cloud.

!cloud_jumpout      =   $C0     ; Y speed to give when jumping out of a Lakitu cloud.

; Requires !moreSpeeds to be enabled:
!accel_cloud_y      =   $01     ; Vertical acceleration rate for the P-balloon/cloud.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Yoshi

!yoshi_airjump      =   $A0     ; Y speed to give when jumping off Yoshi in midair.

!yoshi_dismount_y   =   $C0     ; Y speed to give when dismounting Yoshi on the ground.
!yoshi_dismount_x   =   $F0     ; X speed to give when dismounting Yoshi on the ground.

!yoshi_knockedoff   =   $C0     ; Y speed to give when knocked off of Yoshi. 

!max_fall_wings     =   $20     ; Max fall speed when riding a winged Yoshi.
!accel_fall_wings   =   $04     ; Gravity when riding a winged Yoshi.

!ywings_boosts      =   $E0     ; Y speed to give when flapping on a winged Yoshi.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Springs

!spring_AB          =   $80     ; Y speed to give Mario when jumping off a springboard with A/B held.
!spring_noAB        =   $B0     ; Y speed to give Mario when jumping off a springboard without A/B held.

!wallspring_AB      =   $88     ; Max jump speed possible when jumping off a wall springboard (A/B held).
!wallspring_noAB    =   $B8     ; Max jump speed possible when bouncing on a wall springboard (no A/B held).



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Blocks

!noteblock_top      =   $A0     ; Y speed given when bouncing on top of a noteblock.
!noteblock_side     =   $20     ; X speed given when bouncing off the side of a noteblock.

!turnblock_break    =   $D0     ; Y speed given when breaking a turnblock by spinjumping on it.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Purple Triangles / Wall Running

!purple_triangle    =   $80     ; Y speed to give Mario when riding Yoshi and bouncing off of a purple triangle block.

!wallrun_jump_x     =   $E0     ; X speed to give Mario when jumping during a wallrun.
!wallrun_jump_y     =   $E0     ; Y speed to give Mario when jumping during a wallrun.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Conveyors

!conveyor_time      =   $03     ; Number of frames between "pushes" by the conveyor. Should be a power of 2; $00 means every frame.
!conveyor_time_spr  =   $03     ; Number of frames between "pushes" by the conveyor, for sprites. Same rules as above.

!conveyor_flat      =   $0001   ; Number of pixels that flat conveyors move Mario per "push".
!conveyor_slope     =   $0001   ; Number of pixels that slope conveyors move Mario per "push".
!conveyor_spr       =   $0001   ; Number of pixels that flat conveyors move other sprites per "push".
    ; (note: slope conveyors don't normally push sprites in SMW)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Diagonal Pipes

!diagonal_pipe_x    =   $40     ; X speed to give Mario when shot out of a diagonal pipe.
!diagonal_pipe_y    =   $C0     ; Y speed to give Mario when shot out of a diagonal pipe.





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Autocalculated Values
;;  You can change these if you want, but they're based on the above values anyway
;;  so it's not necessary to.

!p_speed_start      =   !max_run-1              ; X speed Mario has to have at minimum for the P-meter to start increasing.

!swim_init_boost2   =   !swim_init_boost-!swim_boosts   ; Recalculate this value, because the two values are actually stacked.

!wallspring_AB_1    =   !wallspring_AB+$08      ;; Additional wall springboard values, when jumping off with A/B.
!wallspring_AB_2    =   !wallspring_AB_1+$08    ; These define how Mario's distance from the base of the spring affects his jump speed.
!wallspring_AB_3    =   !wallspring_AB_2+$08    ; You can modify the "curve" of the values by editing the additions.
!wallspring_AB_4    =   !wallspring_AB_3+$08
!wallspring_AB_5    =   !wallspring_AB_4+$08
!wallspring_AB_6    =   !wallspring_AB_5+$04
!wallspring_AB_7    =   !wallspring_AB_6+$02

!wallspring_noAB_1  =   !wallspring_noAB+$08    ;; Additional wall springboard values, when bouncing off them without A/B held.
!wallspring_noAB_2  =   !wallspring_noAB_1+$08  ; These define how Mario's distance from the base of the spring affects his jump speed.
!wallspring_noAB_3  =   !wallspring_noAB_2+$08  ; You can modify the "curve" of the values by editing the additions.
!wallspring_noAB_4  =   !wallspring_noAB_3+$10
!wallspring_noAB_5  =   !wallspring_noAB_4+$08
!wallspring_noAB_6  =   $00
!wallspring_noAB_7  =   $00

!max_cloud_y_u_fix  =   !max_cloud_y_u-$03      ; Adjust the cloud's Y speed because Nintendo made this necessary for whatever reason.
!max_cloud_y_n_fix  =   !max_cloud_y_n-$03
!max_cloud_y_d_fix  =   !max_cloud_y_d-$03



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; End of stuff you'll probably have any interest in.                                       ;;
;;  There's some additional defines below, but they're a mess to work with and unnecessary. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Slope speed modifiers
;;  Adds on top of base speeds (pos = speed up, neg = slow down).
;; Since they're relative to the speeds you set above,
;;  you don't really need to mess with these, unless you
;;  want to make slopes seem "steeper".

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAX SPEEDS

!max_gradu_walk_u       =   $00     ; Gradual       Walking     Up
!max_norml_walk_u       =   $FE     ; Normal        Walking     Up
!max_steep_walk_u       =   $FC     ; Steep         Walking     Up
!max_spstp_walk_u       =   $DC     ; Very Steep    Walking     Up

!max_gradu_run_u        =   $00     ; Gradual       Running     Up
!max_norml_run_u        =   $FC     ; Normal        Running     Up
!max_steep_run_u        =   $F8     ; Steep         Running     Up
!max_spstp_run_u        =   $D4     ; Very Steep    Running     Up

!max_gradu_sprint_u     =   $00     ; Gradual       Sprinting   Up
!max_norml_sprint_u     =   $FC     ; Normal        Sprinting   Up
!max_steep_sprint_u     =   $F8     ; Steep         Sprinting   Up
!max_spstp_sprint_u     =   $CC     ; Very Steep    Sprinting   Up

!max_gradu_walk_d       =   $00     ; Gradual       Walking     Down
!max_norml_walk_d       =   $04     ; Normal        Walking     Down
!max_steep_walk_d       =   $10     ; Steep         Walking     Down
!max_spstp_walk_d       =   $10     ; Very Steep    Walking     Down

!max_gradu_run_d        =   $00     ; Gradual       Running     Down
!max_norml_run_d        =   $00     ; Normal        Running     Down
!max_steep_run_d        =   $00     ; Steep         Running     Down
!max_spstp_run_d        =   $00     ; Very Steep    Running     Down

!max_gradu_sprint_d     =   $00     ; Gradual       Sprinting   Down
!max_norml_sprint_d     =   $00     ; Normal        Sprinting   Down
!max_steep_sprint_d     =   $00     ; Steep         Sprinting   Down
!max_spstp_sprint_d     =   $00     ; Very Steep    Sprinting   Down


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ACCELERATIONS

!accel_gradu_walk_u     =   $0000   ; Gradual       >           Up
!accel_norml_walk_u     =   $FFC0   ; Normal        >           Up
!accel_steep_walk_u     =   $FF80   ; Steep         >           Up
!accel_spstp_walk_u     =   $FB80   ; Very Steep    >           Up

!accel_gradu_run_u      =   $0000   ; Gradual       > + X       Up
!accel_norml_run_u      =   $FFC0   ; Normal        > + X       Up
!accel_steep_run_u      =   $FF80   ; Steep         > + X       Up
!accel_spstp_run_u      =   $FB80   ; Very Steep    > + X       Up

!accel_gradu_walk_d     =   $0000   ; Gradual       >           Down
!accel_norml_walk_d     =   $0000   ; Normal        >           Down
!accel_steep_walk_d     =   $0000   ; Steep         >           Down
!accel_spstp_walk_d     =   $0280   ; Very Steep    >           Down

!accel_gradu_run_d      =   $0000   ; Gradual       > + X       Down
!accel_norml_run_d      =   $0000   ; Normal        > + X       Down
!accel_steep_run_d      =   $0000   ; Steep         > + X       Down
!accel_spstp_run_d      =   $0280   ; Very Steep    > + X       Down

!accel_gradu_walk_s_u   =   $0000   ; Gradual       >           Up      Slippery
!accel_norml_walk_s_u   =   $0000   ; Normal        >           Up      Slippery
!accel_steep_walk_s_u   =   $0000   ; Steep         >           Up      Slippery
!accel_spstp_walk_s_u   =   $FC80   ; Very Steep    >           Up      Slippery

!accel_gradu_run_s_u    =   $0000   ; Gradual       > + X       Up      Slippery
!accel_norml_run_s_u    =   $FFC0   ; Normal        > + X       Up      Slippery
!accel_steep_run_s_u    =   $FF80   ; Steep         > + X       Up      Slippery
!accel_spstp_run_s_u    =   $FB80   ; Very Steep    > + X       Up      Slippery

!accel_gradu_walk_s_d   =   $0000   ; Gradual       >           Down    Slippery
!accel_norml_walk_s_d   =   $0100   ; Normal        >           Down    Slippery
!accel_steep_walk_s_d   =   $0100   ; Steep         >           Down    Slippery
!accel_spstp_walk_s_d   =   $0380   ; Very Steep    >           Down    Slippery

!accel_gradu_run_s_d    =   $0000   ; Gradual       > + X       Down    Slippery
!accel_norml_run_s_d    =   $0000   ; Normal        > + X       Down    Slippery
!accel_steep_run_s_d    =   $0000   ; Steep         > + X       Down    Slippery
!accel_spstp_run_s_d    =   $0280   ; Very Steep    > + X       Down    Slippery


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DECELERATIONS
;;  notes: negative here = slower deceleration rate (Mario takes longer to turn)
;;   up/down refer to the direction Mario is **moving** in (not facing).

!decel_gradu_fast       =   $0000   ; Gradual       -----       Faster than autoslide
!decel_norml_fast       =   $FFC0   ; Gradual       -----       Faster than autoslide
!decel_steep_fast       =   $FF40   ; Gradual       -----       Faster than autoslide
!decel_spstp_fast       =   $FE00   ; Gradual       -----       Faster than autoslide

!decel_gradu_slow       =   $0000   ; Gradual       -----       Slower than autoslide
!decel_norml_slow       =   $0080   ; Gradual       -----       Slower than autoslide
!decel_steep_slow       =   $0100   ; Gradual       -----       Slower than autoslide
!decel_spstp_slow       =   $0300   ; Gradual       -----       Slower than autoslide


!decel_gradu_walk_u     =   $0000   ; Gradual       <           Up
!decel_norml_walk_u     =   $0040   ; Normal        <           Up
!decel_steep_walk_u     =   $0080   ; Steep         <           Up
!decel_spstp_walk_u     =   $0080   ; Very Steep    <           Up

!decel_gradu_run_u      =   $0000   ; Gradual       < + X       Up
!decel_norml_run_u      =   $0080   ; Normal        < + X       Up
!decel_steep_run_u      =   $0100   ; Steep         < + X       Up
!decel_spstp_run_u      =   $0100   ; Very Steep    < + X       Up

!decel_gradu_walk_d     =   $0000   ; Gradual       <           Down
!decel_norml_walk_d     =   $FFC0   ; Normal        <           Down
!decel_steep_walk_d     =   $FF80   ; Steep         <           Down
!decel_spstp_walk_d     =   $FA80   ; Very Steep    <           Down

!decel_gradu_run_d      =   $0000   ; Gradual       < + X       Down
!decel_norml_run_d      =   $FF80   ; Normal        < + X       Down
!decel_steep_run_d      =   $FF00   ; Steep         < + X       Down
!decel_spstp_run_d      =   $F500   ; Very Steep    < + X       Down

!decel_gradu_walk_s_u   =   $0000   ; Gradual       <           Up      Slippery
!decel_norml_walk_s_u   =   $0040   ; Normal        <           Up      Slippery
!decel_steep_walk_s_u   =   $02C0   ; Steep         <           Up      Slippery
!decel_spstp_walk_s_u   =   $02C0   ; Very Steep    <           Up      Slippery

!decel_gradu_run_s_u    =   $0000   ; Gradual       < + X       Up      Slippery
!decel_norml_run_s_u    =   $0040   ; Normal        < + X       Up      Slippery
!decel_steep_run_s_u    =   $0080   ; Steep         < + X       Up      Slippery
!decel_spstp_run_s_u    =   $0080   ; Very Steep    < + X       Up      Slippery

!decel_gradu_walk_s_d   =   $0000   ; Gradual       <           Down    Slippery
!decel_norml_walk_s_d   =   $0000   ; Normal        <           Down    Slippery
!decel_steep_walk_s_d   =   $0000   ; Steep         <           Down    Slippery
!decel_spstp_walk_s_d   =   $FCC0   ; Very Steep    <           Down    Slippery

!decel_gradu_run_s_d    =   $0000   ; Gradual       < + X       Down    Slippery
!decel_norml_run_s_d    =   $FFC0   ; Normal        < + X       Down    Slippery
!decel_steep_run_s_d    =   $FF80   ; Steep         < + X       Down    Slippery
!decel_spstp_run_s_d    =   $FA80   ; Very Steep    < + X       Down    Slippery



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Auto-calculated leftwards (inverted) values.
;;  If you want certain values to be assymetric for whatever reason, modify them here.
;;  Otherwise, don't touch.

!left_max_walk              =   $100-!max_walk
!left_max_run               =   $100-!max_run
!left_max_sprint            =   $100-!max_sprint

!left_accel_walk            =   $10000-!accel_walk
!left_accel_run             =   $10000-!accel_run
!left_accel_walk_s          =   $10000-!accel_walk_s
!left_accel_run_s           =   $10000-!accel_run_s

!left_decel_still           =   $10000-!decel_still
!left_decel_walk            =   $10000-!decel_walk
!left_decel_run             =   $10000-!decel_run
!left_decel_walk_s          =   $10000-!decel_walk_s
!left_decel_run_s           =   $10000-!decel_run_s

!left_climb_spd             =   $100-!climb_spd
!left_climb_spd_w           =   $100-!climb_spd_w

!left_max_gradu_slide       =   $100-!max_gradu_slide
!left_max_norml_slide       =   $100-!max_norml_slide
!left_max_steep_slide       =   $100-!max_steep_slide
!left_max_spstp_slide       =   $100-!max_spstp_slide

!left_accel_gradu_slide     =   $10000-!accel_gradu_slide
!left_accel_norml_slide     =   $10000-!accel_norml_slide
!left_accel_steep_slide     =   $10000-!accel_steep_slide
!left_accel_spstp_slide     =   $10000-!accel_spstp_slide

!left_accel_gradu_slide_s   =   $10000-!accel_gradu_slide_s
!left_accel_norml_slide_s   =   $10000-!accel_norml_slide_s
!left_accel_steep_slide_s   =   $10000-!accel_steep_slide_s
!left_accel_spstp_slide_s   =   $10000-!accel_spstp_slide_s

!left_max_gradu_auto        =   $10000-!max_gradu_auto
!left_max_norml_auto        =   $10000-!max_norml_auto
!left_max_steep_auto        =   $10000-!max_steep_auto
!left_max_spstp_auto        =   $10000-!max_spstp_auto

!left_max_flight_spd        =   $100-!max_flight_spd
!left_max_frev_spd          =   $100-!max_frev_spd

!left_accel_flight          =   $10000-!accel_flight
!left_accel_frev            =   $10000-!accel_frev

!left_max_water_walk        =   $100-!max_water_walk
!left_max_water_swim        =   $100-!max_water_swim
!left_max_water_walk_i      =   $100-!max_water_walk_i
!left_max_water_swim_i      =   $100-!max_water_swim_i

!left_tide_spd_walk         =   $100-!tide_spd_walk
!left_tide_spd_swim         =   $100-!tide_spd_swim

!left_max_cloud_x           =   $100-!max_cloud_x
!left_accel_cloud_x         =   $100-!accel_cloud_x

!left_yoshi_dismount_x      =   $100-!yoshi_dismount_x

!left_disco_bounce          =   $100-!disco_bounce
!left_chuck_bounce          =   $100-!chuck_bounce

!left_noteblock_side        =   $100-!noteblock_side

!left_conveyor_flat         =   $10000-!conveyor_flat
!left_conveyor_slope        =   $10000-!conveyor_slope
!left_conveyor_spr          =   $10000-!conveyor_spr

!left_wallrun_jump_x        =   $100-!wallrun_jump_x




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CODE/TABLES BEGIN; don't mess with these unless you know what you're doing.   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
    sa1rom
    !spriteYSpeed   =   $B3
else
    !spriteYSpeed   =   $AA
endif

if !applyJumpFixes
    freecode
    FixJumps:
        LDA.l JumpSpds,x
        STA $7D
        RTL
else
    org $00D2BD
endif

    JumpSpds:       ; Jump speeds, indexed by X speed. First byte is normal, second is spin.
        db !base_jump_spd,!base_spin_spd
        db !base_jump_spd-(!jump_incr/$100),!base_spin_spd-(!jump_incr/$100)
        db !base_jump_spd-(!jump_incr*2/$100),!base_spin_spd-(!spin_incr*2/$100)
        db !base_jump_spd-(!jump_incr*3/$100),!base_spin_spd-(!spin_incr*3/$100)
        db !base_jump_spd-(!jump_incr*4/$100),!base_spin_spd-(!spin_incr*4/$100)
        db !base_jump_spd-(!jump_incr*5/$100),!base_spin_spd-(!spin_incr*5/$100)
        db !base_jump_spd-(!jump_incr*6/$100),!base_spin_spd-(!spin_incr*6/$100)
        db !base_jump_spd-(!jump_incr*7/$100),!base_spin_spd-(!spin_incr*7/$100)
    if !applyJumpFixes
        db !base_jump_spd-(!jump_incr*8/$100),!base_spin_spd-(!spin_incr*8/$100)
        db !base_jump_spd-(!jump_incr*9/$100),!base_spin_spd-(!spin_incr*9/$100)
        db !base_jump_spd-(!jump_incr*10/$100),!base_spin_spd-(!spin_incr*10/$100)
        db !base_jump_spd-(!jump_incr*11/$100),!base_spin_spd-(!spin_incr*11/$100)
        db !base_jump_spd-(!jump_incr*12/$100),!base_spin_spd-(!spin_incr*12/$100)
        db !base_jump_spd-(!jump_incr*13/$100),!base_spin_spd-(!spin_incr*13/$100)
        db !base_jump_spd-(!jump_incr*14/$100),!base_spin_spd-(!spin_incr*14/$100)
        db !base_jump_spd-(!jump_incr*15/$100),!base_spin_spd-(!spin_incr*15/$100)
    endif

if !applyRunFixes
    freecode
    MaxSpeedFix:
        PHA
        EOR $D535,y
        BMI +
        PLA
        SEC
        SBC $D535,Y
        JML $00D748
      +
        PLA
        JML $00D74F
endif   
    
if !moreSpeeds
    freecode
    print pc
    WaterGravity:
        BNE +
        TYA
        CLC
        ADC #!accel_sink
        TAY
      +
        RTL
    
    CloudAccel:
        BPL +
        CLC
        ADC #!accel_cloud_y
        BRA ++
      +
        SEC
        SBC #!accel_cloud_y
      ++
        STA !spriteYSpeed,x
        RTL
endif
    
if !applyJumpFixes
    org $00D663         ; Hijack to fix jump speed table.
        autoclean JSL FixJumps
        NOP
endif
if !applyRunFixes
    org $00D744         ; Hijack to fix max speed limits.
        autoclean JML MaxSpeedFix
endif
if !moreSpeeds
    org $00DA0F         ; Hijack to add water acceleration control.
        autoclean JSL WaterGravity
    org $02D277         ; Hijack to add cloud acceleration control.
        JSL CloudAccel
        BRA $02
endif
        


;; End of freespace hijacks ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $00D2CD
    NoInputDecel:       ; Decelerations for Mario with no button pressed.
        dw !decel_still,!left_decel_still
        dw !decel_still-!decel_gradu_slow,!left_decel_still+!decel_gradu_fast
        dw !decel_still-!decel_gradu_fast,!left_decel_still+!decel_gradu_slow
        dw !decel_still-!decel_norml_slow,!left_decel_still+!decel_norml_fast
        dw !decel_still-!decel_norml_fast,!left_decel_still+!decel_norml_slow
        dw !decel_still-!decel_steep_slow,!left_decel_still+!decel_steep_fast
        dw !decel_still-!decel_steep_fast,!left_decel_still+!decel_steep_slow
        dw !decel_still-!decel_steep_slow,!left_decel_still+!decel_steep_fast
        dw !decel_still-!decel_steep_slow,!left_decel_still+!decel_steep_fast
        dw !decel_still-!decel_steep_fast,!left_decel_still+!decel_steep_slow
        dw !decel_still-!decel_steep_fast,!left_decel_still+!decel_steep_slow
        dw !decel_still-!decel_spstp_slow,!left_decel_still+!decel_spstp_fast
        dw !decel_still-!decel_spstp_fast,!left_decel_still+!decel_spstp_slow


org $00D345
    RunAccel:       ; Running accelerations. Four bytes per: walking + running, for left then right.
        dw !left_accel_walk,!left_accel_run,!accel_walk,!accel_run
        dw !left_accel_walk-!accel_gradu_walk_d,!left_accel_run-!accel_gradu_run_d,!accel_walk+!accel_gradu_walk_u,!accel_run+!accel_gradu_run_u
        dw !left_accel_walk-!accel_gradu_walk_u,!left_accel_run-!accel_gradu_run_u,!accel_walk+!accel_gradu_walk_d,!accel_run+!accel_gradu_run_d
        dw !left_accel_walk-!accel_norml_walk_d,!left_accel_run-!accel_norml_run_d,!accel_walk+!accel_norml_walk_u,!accel_run+!accel_norml_run_u
        dw !left_accel_walk-!accel_norml_walk_u,!left_accel_run-!accel_norml_run_u,!accel_walk+!accel_norml_walk_d,!accel_run+!accel_norml_run_d
        dw !left_accel_walk-!accel_steep_walk_d,!left_accel_run-!accel_steep_run_d,!accel_walk+!accel_steep_walk_u,!accel_run+!accel_steep_run_u
        dw !left_accel_walk-!accel_steep_walk_u,!left_accel_run-!accel_steep_run_u,!accel_walk+!accel_steep_walk_d,!accel_run+!accel_steep_run_d
        dw !left_accel_walk-!accel_steep_walk_d,!left_accel_run-!accel_steep_run_d,!accel_walk+!accel_steep_walk_u,!accel_run+!accel_steep_run_u
        dw !left_accel_walk-!accel_steep_walk_d,!left_accel_run-!accel_steep_run_d,!accel_walk+!accel_steep_walk_u,!accel_run+!accel_steep_run_u
        dw !left_accel_walk-!accel_steep_walk_u,!left_accel_run-!accel_steep_run_u,!accel_walk+!accel_steep_walk_d,!accel_run+!accel_steep_run_d
        dw !left_accel_walk-!accel_steep_walk_u,!left_accel_run-!accel_steep_run_u,!accel_walk+!accel_steep_walk_d,!accel_run+!accel_steep_run_d
        dw !left_accel_walk-!accel_spstp_walk_d,!left_accel_run-!accel_spstp_run_d,!accel_walk+!accel_spstp_walk_u,!accel_run+!accel_spstp_run_u
        dw !left_accel_walk-!accel_spstp_walk_u,!left_accel_run-!accel_spstp_run_u,!accel_walk+!accel_spstp_walk_d,!accel_run+!accel_spstp_run_d

org $00D3AD
    FlightAccel:    ; Flight accelerations.
        dw !left_accel_flight,!left_accel_flight,!accel_frev,!accel_frev
        dw !left_accel_frev,!left_accel_frev,!accel_flight,!accel_flight

org $00D3BD
    SlideAccel:     ; Sliding accelerations.
        dw !left_accel_gradu_slide,!accel_gradu_slide
        dw !left_accel_norml_slide,!accel_norml_slide
        dw !left_accel_steep_slide,!accel_steep_slide
        dw !left_accel_steep_slide,!left_accel_steep_slide
        dw !accel_steep_slide,!accel_steep_slide
        dw !left_accel_spstp_slide,!accel_spstp_slide

org $00D3D5
    RunDecel:       ; Running decelerations.
        dw !decel_walk,!decel_run,!left_decel_walk,!left_decel_run
        dw !decel_walk-!decel_gradu_walk_u,!decel_run-!decel_gradu_run_u,!left_decel_walk+!decel_gradu_walk_d,!left_decel_run+!decel_gradu_run_d
        dw !decel_walk-!decel_gradu_walk_d,!decel_run-!decel_gradu_run_d,!left_decel_walk+!decel_gradu_walk_u,!left_decel_run+!decel_gradu_run_u
        dw !decel_walk-!decel_norml_walk_u,!decel_run-!decel_norml_run_u,!left_decel_walk+!decel_norml_walk_d,!left_decel_run+!decel_norml_run_d
        dw !decel_walk-!decel_norml_walk_d,!decel_run-!decel_norml_run_d,!left_decel_walk+!decel_norml_walk_u,!left_decel_run+!decel_norml_run_u
        dw !decel_walk-!decel_steep_walk_u,!decel_run-!decel_steep_run_u,!left_decel_walk+!decel_steep_walk_d,!left_decel_run+!decel_steep_run_d
        dw !decel_walk-!decel_steep_walk_d,!decel_run-!decel_steep_run_d,!left_decel_walk+!decel_steep_walk_u,!left_decel_run+!decel_steep_run_u
        dw !decel_walk-!decel_steep_walk_u,!decel_run-!decel_steep_run_u,!left_decel_walk+!decel_steep_walk_d,!left_decel_run+!decel_steep_run_d
        dw !decel_walk-!decel_steep_walk_u,!decel_run-!decel_steep_run_u,!left_decel_walk+!decel_steep_walk_d,!left_decel_run+!decel_steep_run_d
        dw !decel_walk-!decel_steep_walk_d,!decel_run-!decel_steep_run_d,!left_decel_walk+!decel_steep_walk_u,!left_decel_run+!decel_steep_run_u
        dw !decel_walk-!decel_steep_walk_d,!decel_run-!decel_steep_run_d,!left_decel_walk+!decel_steep_walk_u,!left_decel_run+!decel_steep_run_u
        dw !decel_walk-!decel_spstp_walk_u,!decel_run-!decel_spstp_run_u,!left_decel_walk+!decel_spstp_walk_d,!left_decel_run+!decel_spstp_run_d
        dw !decel_walk-!decel_spstp_walk_d,!decel_run-!decel_spstp_run_d,!left_decel_walk+!decel_spstp_walk_u,!left_decel_run+!decel_spstp_run_u

org $00D43D
    SlipRunAccel:   ; Running accerations in slippery levels.
        dw !left_accel_walk_s,!left_accel_run_s,!accel_walk_s,!accel_run_s
        dw !left_accel_walk_s-!accel_gradu_walk_s_d,!left_accel_run_s-!accel_gradu_run_s_d,!accel_walk_s+!accel_gradu_walk_s_u,!accel_run_s+!accel_gradu_run_s_u
        dw !left_accel_walk_s-!accel_gradu_walk_s_u,!left_accel_run_s-!accel_gradu_run_s_u,!accel_walk_s+!accel_gradu_walk_s_d,!accel_run_s+!accel_gradu_run_s_d
        dw !left_accel_walk_s-!accel_norml_walk_s_d,!left_accel_run_s-!accel_norml_run_s_d,!accel_walk_s+!accel_norml_walk_s_u,!accel_run_s+!accel_norml_run_s_u
        dw !left_accel_walk_s-!accel_norml_walk_s_u,!left_accel_run_s-!accel_norml_run_s_u,!accel_walk_s+!accel_norml_walk_s_d,!accel_run_s+!accel_norml_run_s_d
        dw !left_accel_walk_s-!accel_steep_walk_s_d,!left_accel_run_s-!accel_steep_run_s_d,!accel_walk_s+!accel_steep_walk_s_u,!accel_run_s+!accel_steep_run_s_u
        dw !left_accel_walk_s-!accel_steep_walk_s_u,!left_accel_run_s-!accel_steep_run_s_u,!accel_walk_s+!accel_steep_walk_s_d,!accel_run_s+!accel_steep_run_s_d
        dw !left_accel_walk_s-!accel_steep_walk_s_d,!left_accel_run_s-!accel_steep_run_s_d,!accel_walk_s+!accel_steep_walk_s_u,!accel_run_s+!accel_steep_run_s_u
        dw !left_accel_walk_s-!accel_steep_walk_s_d,!left_accel_run_s-!accel_steep_run_s_d,!accel_walk_s+!accel_steep_walk_s_u,!accel_run_s+!accel_steep_run_s_u
        dw !left_accel_walk_s-!accel_steep_walk_s_u,!left_accel_run_s-!accel_steep_run_s_u,!accel_walk_s+!accel_steep_walk_s_d,!accel_run_s+!accel_steep_run_s_d
        dw !left_accel_walk_s-!accel_steep_walk_s_u,!left_accel_run_s-!accel_steep_run_s_u,!accel_walk_s+!accel_steep_walk_s_d,!accel_run_s+!accel_steep_run_s_d
        dw !left_accel_walk_s-!accel_spstp_walk_s_d,!left_accel_run_s-!accel_spstp_run_s_d,!accel_walk_s+!accel_spstp_walk_s_u,!accel_run_s+!accel_spstp_run_s_u
        dw !left_accel_walk_s-!accel_spstp_walk_s_u,!left_accel_run_s-!accel_spstp_run_s_u,!accel_walk_s+!accel_spstp_walk_s_d,!accel_run_s+!accel_spstp_run_s_d

org $00D4B5
    SlipSlideAccel: ; Sliding accelerations in slippery levels.
        dw !left_accel_gradu_slide_s,!accel_gradu_slide_s
        dw !left_accel_norml_slide_s,!accel_norml_slide_s
        dw !left_accel_steep_slide_s,!accel_steep_slide_s
        dw !left_accel_steep_slide_s,!left_accel_steep_slide_s
        dw !accel_steep_slide_s,!accel_steep_slide_s
        dw !left_accel_spstp_slide_s,!accel_spstp_slide_s

org $00D4CD
    SlipRunDecel:   ; Running decelerations in slippery levels.
        dw !decel_walk_s,!decel_run_s,!left_decel_walk_s,!left_decel_run_s
        dw !decel_walk_s-!decel_gradu_walk_s_u,!decel_run_s-!decel_gradu_run_s_u,!left_decel_walk_s+!decel_gradu_walk_s_d,!left_decel_run_s+!decel_gradu_run_s_d
        dw !decel_walk_s-!decel_gradu_walk_s_d,!decel_run_s-!decel_gradu_run_s_d,!left_decel_walk_s+!decel_gradu_walk_s_u,!left_decel_run_s+!decel_gradu_run_s_u
        dw !decel_walk_s-!decel_norml_walk_s_u,!decel_run_s-!decel_norml_run_s_u,!left_decel_walk_s+!decel_norml_walk_s_d,!left_decel_run_s+!decel_norml_run_s_d
        dw !decel_walk_s-!decel_norml_walk_s_d,!decel_run_s-!decel_norml_run_s_d,!left_decel_walk_s+!decel_norml_walk_s_u,!left_decel_run_s+!decel_norml_run_s_u
        dw !decel_walk_s-!decel_steep_walk_s_u,!decel_run_s-!decel_steep_run_s_u,!left_decel_walk_s+!decel_steep_walk_s_d,!left_decel_run_s+!decel_steep_run_s_d
        dw !decel_walk_s-!decel_steep_walk_s_d,!decel_run_s-!decel_steep_run_s_d,!left_decel_walk_s+!decel_steep_walk_s_u,!left_decel_run_s+!decel_steep_run_s_u
        dw !decel_walk_s-!decel_steep_walk_s_u,!decel_run_s-!decel_steep_run_s_u,!left_decel_walk_s+!decel_steep_walk_s_d,!left_decel_run_s+!decel_steep_run_s_d
        dw !decel_walk_s-!decel_steep_walk_s_u,!decel_run_s-!decel_steep_run_s_u,!left_decel_walk_s+!decel_steep_walk_s_d,!left_decel_run_s+!decel_steep_run_s_d
        dw !decel_walk_s-!decel_steep_walk_s_d,!decel_run_s-!decel_steep_run_s_d,!left_decel_walk_s+!decel_steep_walk_s_u,!left_decel_run_s+!decel_steep_run_s_u
        dw !decel_walk_s-!decel_steep_walk_s_d,!decel_run_s-!decel_steep_run_s_d,!left_decel_walk_s+!decel_steep_walk_s_u,!left_decel_run_s+!decel_steep_run_s_u
        dw !decel_walk_s-!decel_spstp_walk_s_u,!decel_run_s-!decel_spstp_run_s_u,!left_decel_walk_s+!decel_spstp_walk_s_d,!left_decel_run_s+!decel_spstp_run_s_d
        dw !decel_walk_s-!decel_spstp_walk_s_d,!decel_run_s-!decel_spstp_run_s_d,!left_decel_walk_s+!decel_spstp_walk_s_u,!left_decel_run_s+!decel_spstp_run_s_u

org $00D535
    RunMax:         ; Max X speeds. Each set is left/right in the order walk, run, run fast, sprint.
        db !left_max_walk,!max_walk,!left_max_run,!max_run,!left_max_run,!max_run,!left_max_sprint,!max_sprint
        db !left_max_walk-!max_gradu_walk_d,!max_walk+!max_gradu_walk_u,!left_max_run-!max_gradu_run_d,!max_run+!max_gradu_run_u,!left_max_run-!max_gradu_run_d,!max_run+!max_gradu_run_u,!left_max_sprint-!max_gradu_sprint_d,!max_sprint+!max_gradu_sprint_u
        db !left_max_walk-!max_gradu_walk_u,!max_walk+!max_gradu_walk_d,!left_max_run-!max_gradu_run_u,!max_run+!max_gradu_run_d,!left_max_run-!max_gradu_run_u,!max_run+!max_gradu_run_d,!left_max_sprint-!max_gradu_sprint_u,!max_sprint+!max_gradu_sprint_d
        db !left_max_walk-!max_norml_walk_d,!max_walk+!max_norml_walk_u,!left_max_run-!max_norml_run_d,!max_run+!max_norml_run_u,!left_max_run-!max_norml_run_d,!max_run+!max_norml_run_u,!left_max_sprint-!max_norml_sprint_d,!max_sprint+!max_norml_sprint_u
        db !left_max_walk-!max_norml_walk_u,!max_walk+!max_norml_walk_d,!left_max_run-!max_norml_run_u,!max_run+!max_norml_run_d,!left_max_run-!max_norml_run_u,!max_run+!max_norml_run_d,!left_max_sprint-!max_norml_sprint_u,!max_sprint+!max_norml_sprint_d
        db !left_max_walk-!max_steep_walk_d,!max_walk+!max_steep_walk_u,!left_max_run-!max_steep_run_d,!max_run+!max_steep_run_u,!left_max_run-!max_steep_run_d,!max_run+!max_steep_run_u,!left_max_sprint-!max_steep_sprint_d,!max_sprint+!max_steep_sprint_u
        db !left_max_walk-!max_steep_walk_u,!max_walk+!max_steep_walk_d,!left_max_run-!max_steep_run_u,!max_run+!max_steep_run_d,!left_max_run-!max_steep_run_u,!max_run+!max_steep_run_d,!left_max_sprint-!max_steep_sprint_u,!max_sprint+!max_steep_sprint_d
        db !left_max_walk-!max_steep_walk_d,!max_walk+!max_steep_walk_u,!left_max_run-!max_steep_run_d,!max_run+!max_steep_run_u,!left_max_run-!max_steep_run_d,!max_run+!max_steep_run_u,!left_max_sprint-!max_steep_sprint_d,!max_sprint+!max_steep_sprint_u
        db !left_max_walk-!max_steep_walk_d,!max_walk+!max_steep_walk_u,!left_max_run-!max_steep_run_d,!max_run+!max_steep_run_u,!left_max_run-!max_steep_run_d,!max_run+!max_steep_run_u,!left_max_sprint-!max_steep_sprint_d,!max_sprint+!max_steep_sprint_u
        db !left_max_walk-!max_steep_walk_u,!max_walk+!max_steep_walk_d,!left_max_run-!max_steep_run_u,!max_run+!max_steep_run_d,!left_max_run-!max_steep_run_u,!max_run+!max_steep_run_d,!left_max_sprint-!max_steep_sprint_u,!max_sprint+!max_steep_sprint_d
        db !left_max_walk-!max_steep_walk_u,!max_walk+!max_steep_walk_d,!left_max_run-!max_steep_run_u,!max_run+!max_steep_run_d,!left_max_run-!max_steep_run_u,!max_run+!max_steep_run_d,!left_max_sprint-!max_steep_sprint_u,!max_sprint+!max_steep_sprint_d
        db !left_max_walk-!max_spstp_walk_d,!max_walk+!max_spstp_walk_u,!left_max_run-!max_spstp_run_d,!max_run+!max_spstp_run_u,!left_max_run-!max_spstp_run_d,!max_run+!max_spstp_run_u,!left_max_sprint-!max_spstp_sprint_d,!max_sprint+!max_spstp_sprint_u
        db !left_max_walk-!max_spstp_walk_u,!max_walk+!max_spstp_walk_d,!left_max_run-!max_spstp_run_u,!max_run+!max_spstp_run_d,!left_max_run-!max_spstp_run_u,!max_run+!max_spstp_run_d,!left_max_sprint-!max_spstp_sprint_u,!max_sprint+!max_spstp_sprint_d

org $00D59D
    FlightMax:      ; Max flight speeds.
        db !left_max_flight_spd,!left_max_frev_spd,!left_max_flight_spd,!left_max_frev_spd,$00,$00,$00,$00
        db !max_frev_spd,!max_flight_spd,!max_frev_spd,!max_flight_spd,$00,$00,$00,$00

org $00D5AD
    WaterMax:       ; Max swim speeds, in the order: on ground, swimming, tide ground, tide swimming. Left then right.
        db !left_max_water_walk,!max_water_walk,!left_max_water_swim,!max_water_swim
        db !left_max_water_walk+!tide_spd_walk,!max_water_walk+!tide_spd_walk,!left_max_water_swim+!tide_spd_swim,!max_water_swim+!tide_spd_swim
    
    WaterItemMax:   ; Max swim speeds with an item, same order as above.
        db !left_max_water_walk_i,!max_water_walk_i,!left_max_water_swim_i,!max_water_swim_i
        db !left_max_water_walk_i+!tide_spd_walk,!max_water_walk_i+!tide_spd_walk,!left_max_water_swim_i+!tide_spd_swim,!max_water_swim_i+!tide_spd_swim

org $00D5BD
    SlideSpds:      ; Max sliding speeds on slopes.
        db !left_max_gradu_slide,!max_gradu_slide
        db !left_max_norml_slide,!max_norml_slide
        db !left_max_steep_slide,!max_steep_slide
        db !left_max_steep_slide,!left_max_steep_slide
        db !max_steep_slide,!max_steep_slide
        db !left_max_spstp_slide,!max_spstp_slide

    AutoSlideSpds:  ; How fast Mario slides on various slope tiles, when not holding any buttons.
        dw $0000
        dw !left_max_gradu_auto,!max_gradu_auto
        dw !left_max_norml_auto,!max_norml_auto
        dw !left_max_steep_auto,!max_steep_auto
        dw $0000,$0000
        dw $0000,$0000
        dw !left_max_spstp_auto,!max_spstp_auto
        dw $0000,$0000

org $00D5E7
    AutoTideSpds:   ; How fast Mario moves when not holding any buttons in a tide.
        dw !tide_auto_swim,!tide_auto_ground


org $00D7A5
    Gravity:        ; Falling accelerations.
        db !accel_fall_noAB,!accel_fall_AB
        db !accel_fall_wings
        db $10
        db !accel_aircatch
        db !accel_dive1,!accel_dive2,!accel_dive3,!accel_dive4,!accel_dive5

org $00D7AF
    FallMax:        ; Max falling speeds. Note: the actual max is this + gravity.
        db !max_fall,!max_fall,!max_fall_wings
        db $40,$40,$40,$40,$40,$40,$40  ; These all are unused.
    
org $00D7B9
    BoostSpeeds:    ; Special cape and wings speeds.
        db !max_cape_hover
        db !takeoff_boosts
        db !ywings_boosts

org $00D7C9
    CapeDiveSpd:    ; Max cape diving speeds.
        db !max_dive0,!max_dive1,!max_dive2,!max_dive3,!max_dive4,!max_dive5

org $00D7D9
    CapeRiseSpd:    ; Max cape rise speeds (individual)
        db !aircatch_max0,!aircatch_max1,!aircatch_max2,!aircatch_max3,!aircatch_max4,!aircatch_max5
        db !aircatch_max6,!aircatch_max7,!aircatch_max8,!aircatch_max9,!aircatch_max10

org $00D876
    db !dive_fastdive
org $00D871
    db !dive_phase_slow
org $00D87A
    db !dive_phase_fast
        
org $00D88B         ; Max cape rise speeds (global)
    db !max_flight_rise
org $00D88F
    db !max_flight_rise


org $00DAB7
    ClimbSpds:      ; Climbing X/Y speeds. Odd bytes are, oddly, used when climbing in water.
        db !climb_spd,!climb_spd_w,!left_climb_spd,!left_climb_spd_w
    
    ClimbJumpSpds:  ; Jumps speeds given when jumping off a net/vine.
        db !climbjump_spd,!climbjump_spd_w

org $00CD54
    if !disable_climbing
        db $80
    else
        db $D0
    endif

org $01DA34         ; Jumps speed given when jumping off a rope mechanism.
    db !ropejump_spd



org $00D9D0         ; Water speeds are kinda scattered around.
    db !max_water_sink_i
org $00D9D4
    db !max_water_sink_i
org $00D9D8
    db !max_water_rise_i
org $00D9DC
    db !max_water_rise_i
org $00D984
    db !max_water_rise_n,!max_water_rise_d,!max_water_rise_u,!max_water_rise_u
org $00DA1E
    db !max_water_sink
org $00DA22
    db !max_water_sink
org $00DA05
    db !swim_init_boost2
org $00DA09
    db $100-!swim_boosts
org $00EAA0
    db !water_jumpout
    

org $00D66E         ; P-speed values are scattered too.
    db !timer_sprint
org $00D976
    db !timer_sprint
org $00D97B
    db !timer_sprint
org $00CCB4
    db !timer_sprint
org $00D677
    if !disable_takeoff
        db $02
    else
        db !timer_takeoff
    endif
org $00D806
    if !disable_flight
        db $80
    else
        db $D0
    endif
org $00D724
    db !p_speed_start


org $02D210         ; Lakitu Cloud / P-balloon speed values.
    db !accel_cloud_x,!left_accel_cloud_x
org $02D212
    db !max_cloud_x,!left_max_cloud_x
org $02D248
    db !max_cloud_y_n_fix
org $02D256
    db !max_cloud_y_d_fix
org $02D25C
    db !max_cloud_y_u_fix
org $02D260
    db !max_balloon_y_n
org $02D268
    db !max_balloon_y_u
org $02D26E
    db !max_balloon_y_d
org $01E88D
    db !cloud_jumpout

    
org $01EBC0         ; Yoshi dismount values.
    db !left_yoshi_dismount_x,!yoshi_dismount_x
org $01EDB2
    db !yoshi_airjump   
org $01EDC0
    db !yoshi_dismount_y
org $01F72A
    db !yoshi_knockedoff
org $02A491
    db !yoshi_knockedoff


org $01AA38         ; Enemy bounce speeds.
    db !enemy_bounce_noAB
org $01AA3E
    db !enemy_bounce_AB
org $01A929
    db !enemy_spin_stomp
org $01A953
    db !left_disco_bounce
org $01A959
    db !disco_bounce
org $02C79B
    db !left_chuck_bounce,!chuck_bounce



org $0290DB         ; Noteblock bounce speeds.
    db !left_noteblock_side,!noteblock_side
org $02916D
    db !noteblock_top


org $028774         ; Turnblock bounce speed.
    db !turnblock_break


org $00EFD0         ; Conveyor timers.
    db !conveyor_time
org $0193DC
    db !conveyor_time_spr
    
org $00E913
    ConveyorX:      ; Conveyor X speeds.
        dw !conveyor_flat,!left_conveyor_flat
        dw !conveyor_slope,!conveyor_slope
        dw !left_conveyor_slope,!left_conveyor_slope
        
org $00E923
    ConveyorY:      ; Conveyor Y speeds.
        dw !left_conveyor_slope,!conveyor_slope
        dw !left_conveyor_slope,!conveyor_slope

org $0192C5
    ConveyorSpr:    ; Conveyor sprite X speeds.
        db !conveyor_spr&$FF,!left_conveyor_spr&$FF
        db !conveyor_spr>>8,!left_conveyor_spr>>8


org $01E68E         ; Portable springboard speeds.
    db !spring_noAB
org $01E6A3
    db !spring_AB
    
org $02CDFF         ; Wall springboard speeds.
    db !wallspring_AB_7,!wallspring_AB_6,!wallspring_AB_5,!wallspring_AB_4,!wallspring_AB_3,!wallspring_AB_2,!wallspring_AB_1,!wallspring_AB
org $02CE07
    db !wallspring_noAB_7,!wallspring_noAB_6,!wallspring_noAB_5,!wallspring_noAB_4,!wallspring_noAB_3,!wallspring_noAB_2,!wallspring_noAB_1,!wallspring_noAB


org $00F02A         ; Purple triangle bounce speed.
    db !purple_triangle
    
org $00EABB         ; Wallrun jump speeds.
    db !left_wallrun_jump_x,!wallrun_jump_x
org $00EB70
    db !wallrun_jump_y


org $00D2B7			; Diagonal pipe speeds.
    db !diagonal_pipe_y
if read1($00D2B2) == $22
	org read3($00D2B3)+1
		db !diagonal_pipe_x
	org read3($00D2B3)+7
		db $100-!diagonal_pipe_x
else
	org $00D2B3         
		db !diagonal_pipe_x
endif

org $00EEF6
    if !disable_sliding
        db $80
    else
        db $F0
    endif

