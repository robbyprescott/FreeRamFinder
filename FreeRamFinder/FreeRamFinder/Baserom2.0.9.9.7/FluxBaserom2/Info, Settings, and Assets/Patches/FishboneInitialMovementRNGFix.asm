; Makes initial movement consistently 15 frames

macro Tweak_57_RemoveFishboneSpawnRandomness(delay)
    ; delay is the number of frames fishbone spends in its initial acceleration phase before beginning to decelerate
    ; SMW normally uses a random value from 0 to 31
    ; subsequent phases are 48

    org $01858E
      LDA.b #<delay>
      BRA $02

    ; original bytes: $22,$F9,$AC,$01  (JSL $01ACF9)


endmacro

; Remove Fishbone Spawn Randomness
%Tweak_57_RemoveFishboneSpawnRandomness(15)