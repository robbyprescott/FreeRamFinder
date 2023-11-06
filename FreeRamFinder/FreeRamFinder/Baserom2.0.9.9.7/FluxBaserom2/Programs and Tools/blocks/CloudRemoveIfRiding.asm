;This block removes lakitu cloud if player's riding one.
;Do note that it only removes cloud if mario's touching it and is in the cloud.
;It does not remove the cloud itself upon contact (i don't think it can trigger interaction anyway), so be aware of potential abuse.
;By RussianMan, requrested by FailSandwich.

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : BRA HeadInside	;saves one byte. it's silly, i know

MarioBelow:
MarioAbove:
MarioSide:

TopCorner:
BodyInside:
HeadInside:

LDA $18C2|!addr			;check if in the cloud
BEQ SpriteV			;return if not
STA $18E0|!addr			;should store $01 ($18C2 = $01 - is in cloud. 00 doesn't work cuz indefinite time)

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
RTL

Print "This sprite-killing block only removes the (Lakitu) cloud if the player touches it while riding it."