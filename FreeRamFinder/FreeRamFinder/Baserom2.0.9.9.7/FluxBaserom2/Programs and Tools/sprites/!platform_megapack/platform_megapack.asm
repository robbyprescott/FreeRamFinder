; SJC, minor fix to CFG file only

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Platform Megapack by Mandew
; Expanded by dtothefourth
;
; Uses one extra byte to determine the platform type
; Fill in under extension in LM as follows:
;
;	0 -- Brown Boost Platform
;	1 -- Gold Boost Platform, can jump infinitely.
;	
;	2 -- Grey Falling Platform, 2 tiles wide.
;	3 -- Grey Falling Platform, 4 tiles wide.
;	4 -- Grey, upwards Falling Platform, 2 tiles wide.
;	5 -- Grey, upwards Falling Platform, 4 tiles wide.
;	6 -- Grey, rightwards Falling Platform, 2 tiles wide.
;	7 -- Grey, rightwards Falling Platform, 4 tiles wide.
;	8 -- Grey, leftwards Falling Platform, 2 tiles wide.
;	9 -- Grey, leftwards Falling Platform, 4 tiles wide.
;	
;	A -- Grey Falling Platform, drifts to the left. 3 tiles wide.
;	B -- Grey Falling Platform, drifts to the right. 3 tiles wide.
;	
;	C -- Vertically-wrapping Brown platform, going down. 2 tiles wide.
;	D -- Vertically-wrapping Brown platform, going down. 4 tiles wide.
;	E -- Vertically-wrapping Brown platform, going up. 2 tiles wide.
;	F -- Vertically-wrapping Brown platform, going up. 4 tiles wide.
;
;	10 -- Grey falling platform, 1-tile big, falling down
;	11 -- Grey falling platform, 1-tile big, falling up
;	12 -- Grey falling platform, 1-tile big, falling right
;	13 -- Grey falling platform, 1-tile big, falling left
;
;	14 -- Vertical Wrapping Platform, 1-tile big, going down
;	15 -- Vertical Wrapping Platform, 1-tile big, going up
;
;	To make the platform solid from below, add 80
;	To make the platform solid+sticky from below, add C0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; 	Choose which sub-sprites are inserted.
;		0 = do not insert
;		1 = do insert
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!ss0_boost_platform_insert = 1
!ss1_falling_platform_insert = 1
!ss2_drifting_platform_insert = 1
!ss3_vwrap_platform_insert = 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; 	Labels for each subsprite
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

macro define_label(label, condition)
	if !<condition> == 1
		!<label> = <label>
	else
		!<label> = ss_invalid
	endif
endmacro
	
macro include_if(file, condition)
	if !<condition> = 1
		incsrc <file>
	endif
endmacro
	
%define_label(ss0_init, ss0_boost_platform_insert)
%define_label(ss0_main, ss0_boost_platform_insert)
%define_label(ss0_mainA, ss0_boost_platform_insert)

%define_label(ss1_init, ss1_falling_platform_insert)
%define_label(ss1_initA, ss1_falling_platform_insert)
%define_label(ss1_main, ss1_falling_platform_insert)

%define_label(ss2_init, ss2_drifting_platform_insert)
%define_label(ss2_main, ss2_drifting_platform_insert)

%define_label(ss3_init, ss3_vwrap_platform_insert)
%define_label(ss3_main, ss3_vwrap_platform_insert)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	includes
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc "mpm_start.asm"
incsrc "mpm_sharedgfx.asm"
incsrc "mpm_falldown.asm"
incsrc "mpm_fallingplatform.asm"
incsrc "mpm_wrapping.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; 	subspr includes
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include_if("boost_platform.asm", ss0_boost_platform_insert)
%include_if("falling_platform.asm", ss1_falling_platform_insert)
%include_if("drifting_platform.asm",ss2_drifting_platform_insert)
%include_if("vwrap_platform.asm",ss3_vwrap_platform_insert)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	misc table defines
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!falldown_timer = !1540
!platform_prop = !1594
!behavior = !C2
