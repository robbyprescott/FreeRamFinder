; Insert in gamemode 5 and F

; 277 (0x115) bytes of freeram (same as other file)
; Make sure this isn't used by something else in levels
!freeram = $7F9600

init:
    %move_block($000DE0|!bank|!addr,!freeram,277)
    rtl
