;$0297B3 	1 byte 	Sprite Misc. 	[$F0] OAM index (in $0200) used by the sprite contact graphics (when not in Reznor/Morton/Roy's room). Since this sprite draws 4 tiles, it overlaps with Mario's fireballs (which use slots $F8 and $FC), causing it to be partially cutoff whenever there's some fireballs (it's easy to see if you spinjump on a spiky enemy while being fireflower Mario). To fix it, change this to $E8.


org $0297B3 
db $E8 ; vanilla F0