; This UberASM needs 3 bytes of FreeRAM
; Set these to 3 FreeRAM bytes in the range $0000-$1FFF:
!last_x = $13F4
!clip_timer = $13F5
!jump_buffer = $13F6			; (This goes unused when !pre_leniency is 0)

; Number of frames you can press A/B BEFORE getting the clip and still jump
; Acceptable values: 0-4. Default: 1
!pre_leniency = 1

; Number of frames you can press A/B AFTER getting the clip and still jump
; Acceptable values: 0-254. Default: 3
!post_leniency = 3

; If you don't use AddmusicK, change this to 0:
!addmusick = 1


; Purpose of FreeRAM:
; !last_x holds the x-speed Mario had on the previous frame
; !clip_timer holds the counter for how long a wall clip should last
; !jump_buffer preserves A/B inputs from previous frames for leniency

; ---------------------------------------------------------------------
; Code begins here: Initialize FreeRAM addresses
; ---------------------------------------------------------------------
init:
STZ !last_x
STZ !clip_timer
RTL					



; ---------------------------------------------------------------------
; Main routine. Checks for collision and other general stuff.
; ---------------------------------------------------------------------
main:
LDA $9D					; \
BNE +					; | Do nothing when the game is paused
LDA $13D4				; |
BEQ ++					; /
+							
JMP Pause

++
LDA $77					; \
AND #$04				; |
BEQ NoGround			; | Branch if player touches the ground
JSR Ground				; |
BRA SimulateClip		; /

NoGround:				
LDA $77					; \
AND #$03				; | Does the player touch a wall?
BEQ SimulateClip		; | If yes, check if a wall clip should happen.
JSR WallClipCheck		; /



; ---------------------------------------------------------------------
; This part simulates walljumps (but only after a wallclip was triggered)
; ---------------------------------------------------------------------
SimulateClip:
LDA !clip_timer			; \ If the wallclip timer is not set, do nothing
BEQ Return				; / 
DEC !clip_timer			; > Decrease the wallclip timer

; The jump routine (mostly abridged vanilla code)
STZ $73					; \
LDA $15					; |
AND #$04				; | Allow the player to duck
BEQ +					; |
STA $73					; |
STZ $13E8				; /

+
LDA $16					; \
ORA $18					; | Not pressing A/B? No jump.
BPL Return				; /
LDA $18					; \
BPL NormalJump			; | When pressing B or if holding an item:
LDA $148F				; | Normal jump. Otherwise spinjump
BNE NormalJump			; / 

SpinJump:
INC						; \ Set spinjump flag
STA $140D				; /
LDA #$04				; \ Sound for the spinjump
STA $1DFC				; /
LDA $187A				; \ Branch if sitting on yoshi (dismount)
BNE NoMeter				; / 
LDA #$B6				; \ Set spinjump height
BRA Jump				; /	

NormalJump:
if !addmusick			; \
LDA #$2B				; | 
STA $1DF9				; | Sound for the normal jump
else					; | (differs depending on AMK being installed)
LDA #$01				; |
STA $1DFA				; |
endif					; /
LDA #$B0				; > Normal jump height

Jump:
STA $7D 				; > Store y-speed (the actual jump!)
LDA #$0B				; > "Not sprinting" status
LDY $13E4				; \ Check for p-meter:
CPY #$6C				; | If it's high enough, the player
BCC NoMeter				; / should do a sprint jump
LDA $149F				; \ Check for takeoff meter
BNE PreNoMeter			; / 
LDA #$50				; \ Give takeoff meter
STA $149F				; / 

PreNoMeter:
LDA #$0C				; > "Sprinting jump" status
NoMeter:
STA $72					; > Update "Player in air" flag
STZ !clip_timer			; > End the pseudo-wall clip



; ---------------------------------------------------------------------
; This part updates all relevant RAM addresses for the frame before RTL'ing
; ---------------------------------------------------------------------
Return:
LDA $7B					; \ Update last x-speed
STA !last_x				; /

; If required, update the jump input buffers now

if !pre_leniency == 1
STZ !jump_buffer		; > Clear the buffer
LDA $16					; \
ORA $18					; | Check if any jump button was pressed 
BPL Pause				; / 
INC !jump_buffer		; > If so, log a jump		
LDA $18					; \
BPL Pause				; | If it was a spinjump, log that instead
INC !jump_buffer		; /
endif

if !pre_leniency > 1
LDA !jump_buffer		; \
LSR						; | Clear the oldest entries in the buffer
LSR 					; |
STA !jump_buffer		; /
LDA $18					; \
BPL +					; | If A was just pressed, log a spinjump
LDA #(2*(4**(!pre_leniency-1)))
BRA ++					; /
+						; \
LDA $16					; | If B was just pressed, log a normal jump
BPL Pause				; | 
LDA #(4**(!pre_leniency-1))
++						; \ Actually update the buffer
TSB !jump_buffer		; /
endif

Pause:					; > Game is paused? Buffers don't get updated
RTL



; ---------------------------------------------------------------------
; Subroutine that ends the clip when Mario is touching the ground
; ---------------------------------------------------------------------
Ground:
STZ !clip_timer
RTS



; ---------------------------------------------------------------------
; Subroutine for when Mario touches a wall. This part does the wallclips
; ---------------------------------------------------------------------
WallClipCheck:
; Step 1: Set up the X register with the correct interaction point
PHB						; > Stack magic for later
AND #$02				; \ Left wall or right wall?
BEQ LeftWall			; / 
LDX #$0E				; > Set up correct interaction point for right wall
LDA $187A				; \
BEQ +					; | Adjust interaction point when on yoshi
LDX #$3E				; / 
+
LDA !last_x				; \
EOR #$FF				; | It's a right wall: Flip x-speed
INC						; / 
BRA GenericChecks

LeftWall:
LDX #$02				; > Interaction point for left wall
LDA $187A				; \
BEQ +					; | Adjust interaction point when on yoshi
LDX #$32				; /
+
LDA !last_x				; > If it's a left wall: Don't flip speeds


; Step 2: Make some basic wallclip sanity checks
GenericChecks:						
CMP #$1D				; \ Need at least 29 (=0x1D) x-speed for a wallclip
BCC EndWallClipCheck	; / 
LDA $7D					; \ Moving upwards? No clip.
BMI EndWallClipCheck	; /


; Step 3: Check for layer 1 interaction
LDA $5B					; \
AND #$41				; | Check if the relevant interaction point
STA $8E					; | touches a solid tile on layer 1
JSR CheckForSolidTile	; / <- You'll find this routine below.
BEQ TriggerWallClip		; > Found a solid tile! Initiate wallclip.


; Step 4: Didn't find a solid tile on layer 1? Try layer 2!
LDA $5B					; \ Check if layer 2 interaction is enabled
BPL EndWallClipCheck	; / If not, no solid tile was found.
AND #$82				; \ Same as step 3 but for layer 2
STA $8E					; / 
REP #$20				; \ 
LDA $94					; | 
CLC						; | 
ADC $26					; | Unfortunately, layer 2 is inherently more
STA $94					; | complicated than layer 1 because you have to
LDA $96					; | offset Mario's position manually.
CLC						; |	(This is how the vanilla game does it as well)
ADC $28					; | Source: $00E951
STA $96					; |
SEP #$20				; /
JSR CheckForSolidTile	; <- This is the actual collision check!
PHA						; \ Preserve the result of the collision check
REP #$20				; |
LDA $94					; |
SEC						; |
SBC $26					; | Undo Mario's position offset
STA $94					; | (Layer 2 is a mess)
LDA $96					; |
SEC						; |	
SBC $28					; |
STA $96					; |
SEP #$20				; |
PLA						; / Get the collision check result back
BNE EndWallClipCheck	; > Now actually use the result!


; Step 5: All checks done! Initiate the wallclip.
TriggerWallClip:
LDA #(!post_leniency+1)	; \ Set the wallclip timer
STA !clip_timer			; / 
STZ $7D					; > Reset y-speed
STZ $140D				; > Reset spinjump status
REP #$20				; \
LDA $96					; |
SEC						; | Move Mario 4 pixels upwards
SBC #$0004				; |
STA $96					; |
SEP #$20				; /
STZ $72					; > Pretend that the player touches the ground

; Step 6: If a jump was logged in the jump buffer, make it happen
if !pre_leniency
LDA !jump_buffer		; \ Check if any jump was buffered
BEQ EndWallClipCheck	; / 
AND #$AA				; \ If a jump was buffered, was it a spinjump?
BEQ +					; /
LDA #$80				; \
TSB $18					; | If yes, pretend A was pressed and return
BRA EndWallClipCheck	; /
+						; \
LDA #$80				; | If no, pretend B was pressed
TSB $16					; /
endif

EndWallClipCheck:
PLB						; > End the stack magic
RTS



; ---------------------------------------------------------------------
; This part checks if Marios bottom side interaction point touches a solid tile
; Setup: Depending on $8E it checks layer 1 or 2 (handled mostly by $00F44D)
; You also have to setup the X register with the correct interaction point.
; BEQ after this routine is done to check the result.
; ---------------------------------------------------------------------

CheckForSolidTile:
LDA #$00				; \
PHA						; |
PLB						; | Stack magic to prepare for a JML into an RTS
PHK						; |
PEA.w .jmlrts-1			; | 
PEA.w $0084CF-1			; / <- There's an RTL at this address
JML $00F44D				; > Find out which tile the interaction point touches

.jmlrts
BEQ NotSolid			; > This branches iff the resulting tile is on page 0
CPY #$6E				; \ Blocks outside of 100-16D have no ground collision
BCS NotSolid			; /
LDA $1931				; \
CMP #$03				; |
BEQ CaveTileset			; | Special casing for the Cave Tileset
CMP #$0E				; |
BNE Solid				; /

CaveTileset:
CPY #$59				; \
BCC Solid				; | In the Cave Tileset, tiles 159-15B aren't solid
CPY #$5C				; | (Because they are lava)
BCC NotSolid			; /

Solid:
LDA #$00				; \
RTS						; |
NotSolid:				; | The next BEQ will branch iff the block was solid
LDA #$01				; |
RTS						; /