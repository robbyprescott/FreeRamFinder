; Insert in gamemode C

; 277 (0x115) bytes of freeram (same as other file)
; Make sure this isn't used by something else in levels
!freeram = $7F9600

init:
    %move_block(!freeram,$000DE0|!bank|!addr,277)
    rtl
