incsrc "asm/work/library.asm"
incsrc "../../other/macro_library.asm"
!level_nmi	= 0
!overworld_nmi	= 0
!gamemode_nmi	= 1
!global_nmi	= 0

!sprite_RAM	= $7FAC80

autoclean $A3A052
autoclean $A8BDC8
autoclean $A3C651
autoclean $9CF780
autoclean $9AFFF3
autoclean $A48037
autoclean $94B068
autoclean $95F7E2
autoclean $9CF697
autoclean $95F847
autoclean $A3C63C
autoclean $9CF772
autoclean $A6880A
autoclean $9DA955
autoclean $95F88E
autoclean $9AFFEE
autoclean $A48006
autoclean $97E227
autoclean $9DB3C5
autoclean $9CFE95
autoclean $A480CD
autoclean $9DBA91
autoclean $A4AB37
autoclean $9DBD54
autoclean $9DE101
autoclean $9EFFD3
autoclean $A4BB60
autoclean $9DBA90
autoclean $A4AB33
autoclean $9DFFD1
autoclean $A4B97B
autoclean $9DBD4E
autoclean $9DB369
autoclean $A4AEEC
autoclean $A3DC49
autoclean $A3C414
autoclean $A3C30C
autoclean $A3C211
autoclean $A3A38D
autoclean $A2CE33
autoclean $A2E66A
autoclean $A2CE22
autoclean $9EFF27
autoclean $A3BE38
autoclean $ADD5DD
autoclean $9BFFE1
autoclean $9DB5C2
autoclean $9FFF5E
autoclean $A2E568
autoclean $A3A1F7
autoclean $9DFFC7
autoclean $A1FF8D
autoclean $9AFFE2
autoclean $97FFE8
autoclean $97FFA1
autoclean $A2E4A5
autoclean $A2E441
autoclean $90F5DC
autoclean $A2CD9B
autoclean $97E21C
autoclean $95F592
autoclean $9DB874
autoclean $A1FEC7
autoclean $97E14A
autoclean $9CFFC4

!previous_mode = !sprite_RAM+(!sprite_slots*3)

incsrc level.asm
incsrc overworld.asm
incsrc gamemode.asm
incsrc global.asm
incsrc sprites.asm
incsrc statusbar.asm


print freespaceuse
