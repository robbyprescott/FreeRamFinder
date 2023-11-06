Interactable Yoshi fireball with blocks v1.2
By LX5

This patch gives to Yoshi's fireballs the ability to interact with Layer 1 blocks.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Note that giving anything layer 1 interaction is a bit slow, I made this patch to just
use one interaction point (in the center) on the sprite, so when the center of the fire
hits with a layer 1 block it will run the code. It won't check the whole sprite image.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

1) How to add more interactable blocks:

Open yoshi_effects.asm and search this part:

interact_table:
	dw $0165 : db $00
	dw $011E : db $03
.end	

That's what you want to edit... but, how do you edit them?

Well, the table works like this:

	dw <Acts Like number> : db <Code index>

This table entry uses Acts Like number to detect blocks instead of Map16 number.
However, if you want, you can use the actual Map16 number instead
by changing this define (it can be found at the top of yoshi_fire.asm):

	!use_map16_only		= 0

Change it to 1 and it will only check Map16 numbers.
You can't use Acts Like and Map16 numbers at the same time on a ROM.

Let's move to Code index, what is it?

I found more easy to include an index in the block table to get the routine
that the block will run when the projectile touches it.
I've included a few codes that should cover up most possible interactions
as well some useful macros that might help you.

Included codes (with their code index):
00 	Puff of smoke on block's position
01	Break block on touch like a turn block (brown pieces).
02	Break block on touch like a throw block (rainbow pieces).
03	Kills Yoshi's fire on touch (vanishes with a puff of smoke).

So, if you want the cement block (block number $0130) to kill the fire,
your entry in the table would be this:

	dw $0130 : db $03

... but that will affect every block that acts like $0130!, how to work around this:

a) Change !use_map16_only to 1

b) Put a block that acts like 0130 in the expanded Map16 area (like 0200)
and then put another block that acts like 0200.

Your entry will look like this:

	dw $0200 : db $03

And every block that acts like 0200 will stun the projectile.
The second solution is a bit silly, but it works.

2) Making your own interaction codes.

First of all, you need to expand the table at the top of yoshi_effects.asm like this:

	dw	Smoke			;00
	dw	BreakNormal		;01
	dw	BreakRainbow		;02
	dw	KillFire		;03

;here goes your new pointers

	dw	YourNewEffect		;04

YourNewEffect is obviously a placeholder name, change it to whatever you want.
Then place YourNewEffect somewhere in the file and start coding your interaction.

You can use raw code in your interaction, but you can also use some macros that I included.

Included macros:
%return(): Ends interaction code.
%give_coins(<num>): Gives player an specified amount of coins. <num> represents how many coins it will give.
%generate_smw_tile(<value>): Generates a tile, <value> corresponds to the posible $9C values.
%generate_smoke(): Creates a puff of smoke on block's position.
%shatter_block(<type>): Creates broken pieces. <type> represents which type of broken pieces it will spawn.
			$00 for brown pieces, anything else for rainbow pieces.
%generate_sound(<sfx>,<port>): Generates sound, <sfx> is the SFX number on a certain <port>.
			       <port> can ONLY be $1DF9, $1DFA, $1DFB or $1DFC.

When coding your own interaction codes they need to end in RTS, also A/X/Y are 8-bit.
And $98-$9B contains the rounded up coordinates of the current block.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Found bugs?
PM me: http://www.smwcentral.net/?p=pm&do=compose&user=12344

Have fun!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Changelog:

v1.0 (04/Jan/16)
- Initial release

v1.1
- Changed GetMap16 routine to be the same one used in pixi. Supports LM3 exlevels now.

v1.2
- Fixed a bug in the exlevel flag detection that would detect versions prior LM2 greater than 53 as being having exlevel enabled. Like anyone would run into this lul.