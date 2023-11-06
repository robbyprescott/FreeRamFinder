                        Interaction Line
                        by MarioFanGamer
                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

What do this patch do?
----------------------------------------------------------
This patch adds an interaction line. That means, it adds
another layer of interactions in addition to the blocks in
the level.
Unlike blocks, the interaction is much more simple which
means you can't do many complex set ups but it is more
lightweight than layer 2 interaction (which includes
tides) which results in a larger level (since the
playfield is cut in half with two foregrounds) as well as
causing fewer slowdowns due to lightweight code (layer 2
interaction means handling Mario's interaction twice, for
example).

What are the default interactions?
----------------------------------------------------------
Water, lava, solid blocks and magma.
These are the type of interactions which are recreated as
closely as you can without making the code too
complicated (for example, none of the codes handle side
interaction for obvious reasons which affects magma the
most).

It should be noted that the interactions are treated like
they are on layer 2 i.e. Mario falls at a higher speed
than normal and carryable sprites don't bounce of the
ground. These all are necessary because the line can be
freely moved.

How do I activate these interactions?
----------------------------------------------------------
The most important point is that you include the defines
from InteractionLineDef.asm in UberASM's macro library
(either by incsrc or manually copying).

You then use a level code which stores the interaction
type to !InteractionType. It must be a multiple of two.
It also means you can have only 127 unique interactions.
That should be enough for most hacks, though, and you can
easily control the existing ones them however you want
(e.g. switch between solid ice and liquid water per On/Off
switch).
If you do run out of space, just use a second byte of
freeRAM.

In addition, I also include various applications of the
interaction line.

Can I add in custom interaction?
----------------------------------------------------------
Of course you can. The codes are all handled in the file
InteractionLineCodes.asm.

In general, the interaction is best handled by comparing
the height of the interaction point with it and check
whether the value is positive or negative.

To handle Mario's interaction, a pointer to the
interaction point offsets is stored to $00. You just need
to add in an in Y which can take the following values:
Y = 0: MarioBody
Y = 2: MarioSide
Y = 4: MarioHead
Y = 6: MarioBelow
Y = 8: MarioAbove
Y = A: MarioTopCorner
For example, to load MarioBelow:
LDY #$06
LDA ($00),y
In addition, the routine always ends with an RTS.

To handle sprites, I provided two routines instead:
GetSpriteV and GetSpriteW. The former is the routine
which gets the interaction point for vertical interaction
and the latter for water interaction. Their values are
returned as a 16-bit value in A (though A is still in
8-bit mode).
In contrast to Mario's code, these interactions end with
an RTL.

For fireballs, their interaction point is calculated
beforehand (which means at the very bottom of the
fireball). The value is stored to $00. You then can use
it to call CmpLine.
Much like with sprite codes, they use RTL to end their
code.

y no pure uberasm?
----------------------------------------------------------
Because that is IMO the best option. It's good to have
them integrated with the rest of the interaction, not to
mention that water interactions of Mario and sprites is
handled by the same code.

Furthermore, I can't avoid air bubbles from not working
without a patch anyway (they disappear in the air).

What happens if the interaction line is above the screen?
----------------------------------------------------------
To keep it short: Avoid it. The interaction line can only
handle positive values very well while negative values
would make it too complicated. Chances are, you'd use
other methods to handle them anyway.

Which graphics work for e.g. water?
----------------------------------------------------------
You can use SMW's tide but Super Metroid's layer 3 water
also work. In general, as long as the graphics to be
interacted is around the bottom half of the tilemap (which
includes the aforementioned graphics) is fine. Anything
else requires.
Furthermore, you need graphics

Do I must give you credits?
----------------------------------------------------------
I'll say yes. This is a somewhat complex patch but also
the graphics code for the water is.

Why did you make this patch?
----------------------------------------------------------
The origin had been somewhat lost in time but I do know
that I had two reasons for motivation: Ragey, Yoshi's
Island and Super Metroid.
Let's start with the former: Ragey is a user who likes to
rework SMW while also keeping it as compatible with Lunar
Magic as much as possible. In one example, it's about
handling the water graphics (SMB3's in this case) with
HDMA since below the surface, the water uses a solid
colour.
Since using the vanilla tide interaction is somewhat
complicated and also limiting (see above), I handled the
interaction in a similar way like Yoshi's Island: With an
interaction line!

Where does Super Metroid come in play? With the graphics,
of course!
It still is possible to use a layer 3 image but it only
works if the level has got a height of 32 blocks. That is,
until you use HDMA.
The way how Super Metroid handles layer 3 is different
from SMW in the sense that it uses a separate tilemap for
the status bar and for the layer 3 image. But only for
fullscreen images such as mist and petals.
For liquids, though, it uses one 32x64 layer 3 image but
it and the status bar's positions are kept in place with
HDMA.


I've got a question!
----------------------------------------------------------
Post it to the forums. In the worst case, you can PM me.

Is that really all?
----------------------------------------------------------
Just... make sure you HAVE read the readme, okay?

Changelog
----------------------------------------------------------
1.0:
 - Initial release