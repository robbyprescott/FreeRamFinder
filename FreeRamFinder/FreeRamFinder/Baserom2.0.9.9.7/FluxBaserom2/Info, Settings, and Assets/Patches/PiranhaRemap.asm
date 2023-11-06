; https://bin.smwcentral.net/u/25222/spriteremap.asm


;;; Growing vine
org $01C19E : db $AE : org $07F477 : db $3A                                       ; Frame 1
org $01C1A2 : db $AE : org $07F477 : db $3A                                       ; Frame 2

;;; Jumpin' piranha plant
org $019BBD : db $AE : org $07F44D : db $08                                       ; Head 1
org $019BBF : db $AE : org $07F44D : db $08                                       ; Head 2

;;; Jumpin' fire-spitting piranha plant
org $019BBD : db $AE : org $07F44E : db $08                                       ; Head 1
org $019BBF : db $AE : org $07F44E : db $08                                       ; Head 2

;;; Upside-down piranha plant
org $019BBD : db $AE : org $07F428 : db $08                                       ; Head 1
org $019BBE : db $CE : org $018E93 : db $EA                                       ; Stem 1
org $019BBF : db $AE : org $07F428 : db $08                                       ; Head 2
org $019BC0 : db $CE : org $018E93 : db $EA                                       ; Stem 2

;;; Piranha plant
org $019BBD : db $AE : org $07F418 : db $08                                       ; Head 1
org $019BBE : db $CE : org $018E92 : db $EA                                       ; Stem 1
org $019BBF : db $AE : org $07F418 : db $08                                       ; Head 2
org $019BC0 : db $CE : org $018E92 : db $EA                                       ; Stem 2