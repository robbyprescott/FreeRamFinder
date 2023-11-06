; Note that this contains an incsrc, "SSPDefines.asm"

; Make sure that you apply the wall-clip/note-block fix patch BEFORE you apply this. 
; If you need to apply the wall-clip patch AFTER this one, find the instructions pertaining to this.

;This patch fixes:

;-Since $72 is bad to use in interactive layer 2 levels (it assumes mario is falling
; during a block routine EVEN if you are on ground), so the only way for horizontal pipes
; to detect if mario is on the ground is to use $77 (the blocked status). Too bad $00EAA9
; (this clears out blocked and slope status as well as decompressed graphics flag) runs before
; the custom blocks routine, causing blocks to always assume $77 is #$00. So I had to hijack
; it and save it to a freeram and let it clear $77 right after (so that it clears when mario
; is touching nothing). Do note that the backup version is a frame late.

;
;To tell if the player is in the pipe, use this code:
;	LDA !Freeram_SSP_PipeDir
;	AND.b #%00001111
;	;^After the above, A will be nonzero should the player be inside the pipe. Use BEQ/BNE
;	; after this.
;To make the sprites invisible when carried into the pipe:
;	1) Make sure you have the defines folder (containing the defines file) located in the same
;	   directory as sprite inserter tool (pixi.exe).
;	2) Copy and paste all files inside the [Pixi_Routines] folder into Pixi's routines folder.
;	3) Edit the sprites that can be carried by the player to skip the graphics code. See readme.
;
;NOTE: This will apply to ALL levels since the patch modifies code used in all levels. Therefore
;even if you don't have SSPs in any level and not have them run on uberasm tool on those levels,
;the freeram are still used. So avoid recycling RAM address during levels used by the SSPs.
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SA1 detector:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	!dp = $0000
	!addr = $0000
	!sa1 = 0
	!gsu = 0

if read1($00FFD6) == $15
	sfxrom
	!dp = $6000
	!addr = !dp
	!gsu = 1
elseif read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!sa1 = 1
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check for other hijacks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Walljump/Note Block Glitch Fix
	!WalljumpNoteBlockFixPatch = 0
	if read1($00EA16) != $C2		;>Originally [REP #$20] [C2 20]
		!WalljumpNoteBlockFixPatch = 1
	endif

incsrc "SSPDefines.asm"
	
	org $00EAA9				;\This is why blocks always assume $77, $13E1 and $13EE
		autoclean JSL BlockedFix	;/are stored as zero (this runs every frame).
		nop #1
	if !WalljumpNoteBlockFixPatch == 0
		;Assuming there only exist SMW's code or my patch code, but not the WJNB fix patch.
			if !Setting_SSP_Hijack_00EA18 == 0
				;Remove the SSP's Fixes.asm patch hijack at $00EA18
					if read1($00EA18) == $5C
						autoclean read3($00EA18+1)
					endif
					org $00EA18
						LDA $94
						CLC
						ADC.w $00E90D,y
					print "This patch no longer fixes the possible 1-pixel off issue with downwards-facing small pipe cap unless you set Setting_SSP_Hijack_00EA18 to 1 or (don't choose both) install the WJNB fix patch, and then repatch this."
			else
				;Hijack at $00EA18
					org $00EA18
						autoclean JML DisablePushingPlayer
							;^This prevents a strange oddity that if you are small mario, and enter the downwards facing small pipe cap from the
							; very bottom corners, can push the player 1 pixel to the left. Note that this is fixed automatically if you've patched
							; the “Walljump/Note Block Glitch Fix”.
					print "$00EA18 hijack applied. This fixes a possible 1-pixel off issue with downwards-facing small pipe cap. Not compatible with the WJNB fix patch though unless you set Setting_SSP_Hijack_00EA18, repatch this, then install WJNB fix patch."
			endif
	else
		print "WJNB patch detected, so $00EA18 is not modified by this patch. You're good to go."
	endif


freecode

;---------------------------------------------------------------------------------
BlockedFix: ;>JSL from $00EAA9
;	LDA $13E1|!addr		;\In case you also wanted blocks to detect slope, remove
;	STA $xxxxxx		;/the semicolons (";") before it and add a freeram in place of xxxxxx
	STZ $13E1|!addr		;>Restore code (clears slope type)

	LDA $77				;\backup/save block status for use for blocks...
	STA !Freeram_BlockedStatBkp	;/
	STZ $77				;>...before its cleared.

	;^This (or both) freeram will get cleared when $77 and/or $13E1
	; gets cleared on the next frame due to a whole big loop SMW runs.
	; when mario isn't touching a solid object.

	;So after executing $00EAA9, you should use the freeram that has
	;the blocked and/or slope status saved in them. If before $00EAA9,
	;then use the original ($77 and/or $13E1). Do not write a value on
	;this freeram, it will do nothing, write on those default ram address.
	RTL
;---------------------------------------------------------------------------------
if and(equal(!WalljumpNoteBlockFixPatch, 0), notequal(!Setting_SSP_Hijack_00EA18, 0))
	DisablePushingPlayer:	;>JML from $00EA18
		;A: 16-bit
		LDA !Freeram_SSP_PipeDir
		AND.w #%0000000000001111
		BNE .InPipe
		
		.OutOfPipe
			LDA $94
			CLC
			ADC.w $00E90D,Y
			STA $94
		.InPipe
			JML $00EA20
endif