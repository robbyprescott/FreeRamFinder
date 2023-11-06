main:
	LDA $71		;\
	CMP #$01	;|don't run if mario is frozen in a pipe or cutscene. 
	BCS .return	;/

	LDA $1493|!addr ;\
	BNE .return	;/don't run when level has been beaten. maybe remove this for kaizo.
		
	
	STZ $1401|!addr ;disable screen scroll

	LDA $17 	;load controller flag
	AND #%00100000 	;check if l button is pressed, use #%00010000 for R
	BNE .stopMario	
	RTL

.stopMario:
	LDA $D2 ;screen this frame
	STA $95	;set screen to this frame
	LDA $D4 ;screen y this frame
	STA $97	;set y screen to this frame

	LDA $D1 ;position this frame
	STA $94	;set next frame to this frame
	LDA $D3 ;y position this frame
	STA $96	;set y next frame to this frame

.return
RTL