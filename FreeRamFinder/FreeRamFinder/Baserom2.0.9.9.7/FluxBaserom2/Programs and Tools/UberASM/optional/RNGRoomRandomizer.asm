; Randomized NG rooms: beat a series of randomized rooms without dying, to spawn in the ending room.
; Created by Aerithos.
; Be sure to read and set all the options.

; This is the intro room that leads to the randomized rooms.
; You'll want to enter this directly from the OW, not as a sublevel of anything
!starting_room = $0138

; Set this to match the x-coordinate where the door is in the intro/starting room.
; (Allows time for the RNG state to advance and have some randomness mixed in.)
!door_position_in_intro_room = $00D0

; The number of randomized rooms to beat.
!number_of_rooms = 4 
!make_sure_this_matches_the_above_number = 4

; These are the LM level numbers of the rooms/levels to be randomized. 
; Make sure the number of entries matches the number of rooms defined above. (Do not include start or end room.)
LevelList:
    dw $0051,$0052,$0053,$0054 ; Modify these as needed
.End:
    dw !ending_room ; Do not modify this

; This is the goal room, where you'll be warped after you've beaten the other rooms
!ending_room = $0105

; Set to 0 to disable for testing purposes
!active = 1

; Freeram Configuration
!current_level_index = $7FA200
!rng_state = $7FA201 ; 4 bytes
!selected_levels = $7FA300 ; Table containing which levels were selected, needs to be at least as many bytes as entrys in the level list + 1
!assigned_levels_generated_weights = $7FA400 ; Table containing the random weights assigned for picking levels, needs to be at least twice as many bytes as entrys in the level list

; Address locations for RNG routine
!RandomResult = $148D|!addr
!RandomState = $148B|!addr

init:
    if !active == 0
        RTL
    endif

    STZ $4201
    LDA #$80 : STA $4201

    REP #$20
        ; XORshift requires a non-zero starting seed
        ; Mix H and V count into a constant for low word of state
        ; and store constant to high word
        LDA !RandomState
        ORA !RandomResult
        BNE +
            LDA #$137C
            ORA $213C
            STA !RandomState
            LDA #$51E3
            STA !RandomResult
        +
        LDA $010B|!addr
        CMP #!starting_room
    SEP #$20

    BNE .SetLevelExit
        LDA #$80
        STA !current_level_index
        ; Restore the RNG state to avoid retry reset issues that might occur
        REP #$20
            LDA !rng_state
            STA !RandomState
            LDA !rng_state+2
            STA !RandomResult
        SEP #$20
        RTL

    .SetLevelExit:
        LDA !current_level_index
        TAX
        INC A
        STA !current_level_index
        LDA !selected_levels,X
        ASL
        TAX
        LDA LevelList,X
        STA $19B8|!addr
        LDA LevelList+1,X
        ORA #$04
        STA $19D8|!addr
        RTL

main:
    if !active == 0
        RTL
    endif

    REP #$20
        LDA $010B|!addr
        CMP #!starting_room
    SEP #$20

    BEQ .CheckForRNGTrigger
        ; Advance RNG state every 64 frames in the random levels to avoid having the same selection of levels
        LDA $14
        AND #%00111111
        CMP #%00111111
        BNE +
            JSR xorShift
            REP #$20
                LDA !RandomState
                STA !rng_state
                LDA !RandomResult
                STA !rng_state+2
            SEP #$20
        +
        RTL

    .CheckForRNGTrigger:
        ; Help seed RNG by waiting until mario has reached a specific X coordinate
        ; and advancing the RNG with some sources mixed in before then.
        REP #$20
            LDA $94
            CMP #!door_position_in_intro_room
        SEP #$20
        BCS .InitAndSelectRandomLevel

        ; Help improve RNG by advancing the state every 8 frames
        LDA $14
        AND #%00000111
        CMP #%00000111
        BNE +
            JSR xorShift
        +

        ..Return:
            RTL

    .InitAndSelectRandomLevel:
        ; Check if we've already selected the levels
        LDA !current_level_index
        BMI +
            RTL
        +

        ; Backup the RNG state to restore later
        REP #$20
            LDA !RandomState
            STA !rng_state
            LDA !RandomResult
            STA !rng_state+2
        SEP #$20

        ; Init the level selection to the first level
        LDA.b #$00
        STA !current_level_index

        if (!make_sure_this_matches_the_above_number+1-!number_of_rooms) > 0
            ; Get the random number of levels to select
            JSR xorShift
            REP #$20
                ; Start divide operation while we zero out the selection list.
                LDA !RandomResult
                STA $4204
                LDY.b #(!make_sure_this_matches_the_above_number+1-!number_of_rooms)
                STY $4206
            SEP #$20
        endif
        
        ; While we wait for the division result,
        ; assign random weight values to all levels
        LDX.b #(LevelList_End-LevelList-2)
        ..AssignWeightsLoop:
            JSR xorShift
            REP #$20
                LDA !RandomResult
                BNE +
                    LDA.w #$0001
                +
                STA !assigned_levels_generated_weights,x
            SEP #$20
            DEX
            DEX
        BPL ..AssignWeightsLoop

        if (!make_sure_this_matches_the_above_number+1-!number_of_rooms) > 0
            LDA $4216
            CLC : ADC.b #!number_of_rooms
            DEC A
        else
            JSR xorShift
            LDA.b #!number_of_rooms-1
        endif
        STA $00
        STA $03

        ; Set the ending level as the last level
        TAX
        LDA.b #((LevelList_End-LevelList)/2)
        STA !selected_levels+1,x

        ..SelectLevelsLoop:
            LDX.b #(LevelList_End-LevelList-2)
            REP #$20
                STZ $01
                ...FindMaxWeightLoop:
                    LDA !assigned_levels_generated_weights,X
                    CMP $01
                    BCC +
                        STA $01
                        TXY
                    +
                    DEX
                    DEX
                BPL ...FindMaxWeightLoop
                ; Zero the weight value for our selected level
                TYX
                LDA #$0000
                STA !assigned_levels_generated_weights,X
            SEP #$20

            TYA
            LSR A
            LDX $00
            STA !selected_levels,x
            DEC $00
        BPL ..SelectLevelsLoop

        BRL init_SetLevelExit
    RTL

; Implementation of XORShift with a 32bit state
; Use the high word for optimal entropy
; Requires the seed to be non-zero
; Has a period of 2^32 - 1
xorShift:
    REP #$30
        ; Round 1
        ; x = x ^ (x << 13)
        LDA !RandomState
        STA $0A
        LDA !RandomResult
        TAY
        LSR
        ROR $0A
        ROR
        ROR $0A
        ROR
        ROR $0A
        ROR
        AND #$E000
        EOR !RandomState
        STA $0C
        TYA
        EOR $0A
        TAY
        STA $0E

        ; Round 2
        ; x = x ^ (x >> 17)
        LSR
        EOR $0C
        STA $0C

        ; Round 3
        ; x = x ^ (x << 5)
        ASL
        ROL $0E
        ASL
        ROL $0E
        ASL
        ROL $0E
        ASL
        ROL $0E
        ASL
        ROL $0E
        EOR $0C
        STA !RandomState
        TYA
        EOR $0E
        STA !RandomResult
    SEP #$30
    RTS