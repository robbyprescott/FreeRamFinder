macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
init:
    REP #$20 
    LDA $7FC0FC ; The specified trigger here is Custom 00.
	            ; $7FC0F8 is one-shot
    AND #$FFFE  ; #$03 triggers 00 and 01. #$01 triggers just 00. 
                ; All following #%0000000 format, from right to left. 
                ; For example, 4 slots would be #%00001111, or #$0F. 
                ; #$1F for 5 slots, etc.
    STA $7FC0FC
    SEP #$20
	
    stz $22             ;\
    stz $23             ;| Reset layer 3 position.
    stz $24             ;|
    stz $25             ;/
	
stz $0D9F ; gradient
jsl retry_level_transition_init

STZ $0DE0 
STZ $0DE1
STZ $0DE2
STZ $0DE3
STZ $0DE4
STZ $0DE5
STZ $0DE6
STZ $0DE7
STZ $0DE8
STZ $0DE9
STZ $0DEA
STZ $0DEB
STZ $0DEC
STZ $0DED
STZ $0DEE
STZ $0DEF
STZ $0DF0
STZ $0DF1
STZ $0DF2
STZ $0DF3
STZ $0DF4
STZ $0DF5
STZ $0DF6
STZ $0DF7
STZ $0DF8
STZ $0DF9
STZ $0DFA 
STZ $0DFB ; p-switch music restore?
STZ $0DFC ; disable duck
STZ $0DFD ; up or down fireball
STZ $0DFE ; vine grow speed
STZ $0DFF ; fireball count increment

STZ $0E00 ; slanted pipe restore
STZ $0E01 ; magikoopa won't respawn after killed
STZ $0E02 ; HP system
STZ $0E03 ; decrement when hit
STZ $0E04
STZ $0E05
STZ $0E06 ; status bar condit
STZ $0E07
STZ $0E08 ; if enabled, vanilla float delay
STZ $0E09 ; normal vanilla freeze length when baby Yoshi grow big
STZ $0E0A ; sprite item box disable
STZ $0E0B ; goal walk death from muncher or sprite 
STZ $0E0C ; 1-up sound queue
STZ $0E0D ; speed oscillation
STZ $0E0E ; cape flight takeoff/p-speed jump
; Don't need to clear $0E0F-0E12, Interaction Line
STZ $0E13 ; Next four are Interaction Line
STZ $0E14
STZ $0E15
STZ $0E16

STZ $0E18 ; layer 2 manual scroll
STZ $0E19 ; layer 1 autoscroll
STZ $0E1A ; next two are alternate death sound
STZ $0E1B 
STZ $0E1C ; small fire Mario
STZ $0E1D ; switch palace switch
STZ $0E1E ; swallow sprite doesn't give coin
STZ $0E1F ; Disable NoMoreSpriteTileLimits
STZ $0E20 ; When active allow spin jump from noteblock
STZ $0E21 ; When active disables frame-perfect spin-jump from noteblock
STZ $0E22 ; for direction-controlled autowalker/runner
STZ $0E23 ; infinite throwblock no spawn
STZ $0E24 ; baby Yoshi double-eat reenable
STZ $0E25 ; reverse gravity placeholder
STZ $0E26 ; cape spin disable
STZ $0E27 ; Will kill you and reset when you don't get switch palace yump
STZ $0E28 ; Will do something else you get switch palace yump
STZ $0E29
STZ $0E2A
STZ $0E2B ; double jump
STZ $0E2C ; tempo
STZ $0E2D
STZ $0E2E
STZ $0E2F ; wall kick
STZ $0E30 ; p-swtch tck
STZ $0E31
STZ $0E32

STZ $15E8 ; palette at fade (to prevent carry over)

; end global

STZ $0E51 ; dolphin
STZ $0E52 ; mostly per-level
STZ $0E53 ; move layer 3 with L/R
STZ $0E55 
STZ $0E56
STZ $0E57
STZ $0E58
STZ $0E59
STZ $0E5A
STZ $0E5B
STZ $0E5C
STZ $0E5D
STZ $0E5E
STZ $0E5F
STZ $0E60
STZ $0E61
STZ $0E62
STZ $0E63
STZ $0E64
STZ $0E65
STZ $0E66
STZ $0E67
STZ $0E68
STZ $0E69
STZ $0E6A
STZ $0E6B
STZ $0E6C
STZ $0E6D
STZ $0E6E
STZ $0E6F
STZ $0E70
STZ $0E71
STZ $0E72
STZ $0E73
STZ $0E74
STZ $0E75
STZ $0E76
STZ $0E77
STZ $0E78
STZ $0E79
STZ $0E7A
STZ $0E7B
STZ $0E7C
STZ $0E7D
STZ $0E7E
STZ $0E7F
STZ $0E80
STZ $0E81
STZ $0E82
STZ $0E83
STZ $0E84
STZ $0E85
STZ $0E86
STZ $0E87
STZ $0E88
STZ $0E89
STZ $0E8A
STZ $0E8B
STZ $0E8C
STZ $0E8D
STZ $0E8E
STZ $0E8F
STZ $0E90
STZ $0E91
STZ $0E92
STZ $0E93
STZ $0E94
STZ $0E95
STZ $0E96
STZ $0E97
STZ $0E98
STZ $0E99
STZ $0E9A
STZ $0E9B
STZ $0E9C
STZ $0E9D
STZ $0E9E
STZ $0E9F
STZ $0EA0
STZ $0EA1
STZ $0EA2
STZ $0EA3
STZ $0EA4
STZ $0EA5
STZ $0EA6
STZ $0EA7
STZ $0EA8
STZ $0EA9
STZ $0EAA
STZ $0EAB
STZ $0EAC
STZ $0EAD
STZ $0EAE
STZ $0EAF
STZ $0EB0
STZ $0EB1
STZ $0EB2
STZ $0EB3
STZ $0EB4
STZ $0EB5
STZ $0EB6
STZ $0EB7
STZ $0EB8
STZ $0EB9
STZ $0EBA
STZ $0EBB
STZ $0EBC
STZ $0EBD
STZ $0EBE
STZ $0EBF
STZ $0EC0
STZ $0EC1
STZ $0EC2
STZ $0EC3
STZ $0EC4
STZ $0EC5
STZ $0EC6
STZ $0EC7
STZ $0EC8
STZ $0EC9
STZ $0ECA
STZ $0ECB
STZ $0ECC
STZ $0ECD
STZ $0ECE
STZ $0ECF
STZ $0ED0
STZ $0ED1
STZ $0ED2
STZ $0ED3
STZ $0ED4
STZ $0ED5
STZ $0ED6
STZ $0ED7
STZ $0ED8
STZ $0ED9
STZ $0EDA
STZ $0EDB
STZ $0EDC
STZ $0EDD
STZ $0EDE
STZ $0EDF
STZ $0EE0
STZ $0EE1
STZ $0EE2
STZ $0EE3
STZ $0EE4
STZ $0EE5
STZ $0EE6
STZ $0EE7
STZ $0EE8
STZ $0EE9
STZ $0EEA
STZ $0EEB
STZ $0EEC
STZ $0EED
STZ $0EEE
STZ $0EEF
STZ $0EF0
STZ $0EF1
STZ $0EF2
STZ $0EF3
STZ $0EF4
RTL