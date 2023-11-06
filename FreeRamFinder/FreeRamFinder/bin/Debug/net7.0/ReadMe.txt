This is a program that finds all the free ram usages and potential conflicts in a smw project

How to run:
* you might need to download .NET 7? idk I haven't tested it.

1) Double click the FreeRamFinder executable in this directory.

2) It will open up a console where you are to drag in the root directory of your smw project, do this.

3) After dragging in the directory you will see it populated the path, hit enter until you see output in the console.

4) check the __output__ folder located in this directory for the results :)


Some helpful info:

AllSmwFreeRamAddresses is a file compiled from the list given on smw central:
https://www.smwcentral.net/?p=memorymap&game=smw&region[]=ram&type=Empty

The descriptions for some of the addresses will say if that particular address is cleared on level-load.
So basically for these, just because there are conflicts it might not actually cause problems in your rom. 
Just make sure the ASM files containing the outputted "conflicts" are not used in the same level.
But keep in mind the addresses that are not cleared on level load will actually cause problems if used in other levels.