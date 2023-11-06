@includefrom castle_cutscene_palettes.asm

; Here you can set the palette for each cutscene.
; First, you need to have the palette ready in Lunar Magic.
; Then export it from the Palette Editor, but not in .pal format: in the
; file type dropdown menu, choose "Mario World Custom Palette Files (*.mw3)".
; To be sure you chose the correct format, check the file size: it should be 514 bytes.
; Then, put the .mw3 file in the same folder as this file and insert a new entry here below.
; The format is simple: on a new line, put %set_palette(X,name)
; where X is the cutscene number (the same as Lunar Magic's Change Boss Sequence Levels dialog)
; and name is the name of the palette file extracted from Lunar Magic (including the extension).
; There's an example (that you can freely remove), which would set palette1.mw3 in cutscene 2 (Morton).
; After setting the entries, patch the "castle_cutscene_palettes.asm" file (not this file!).

%set_palette(2,palette1.mw3)
