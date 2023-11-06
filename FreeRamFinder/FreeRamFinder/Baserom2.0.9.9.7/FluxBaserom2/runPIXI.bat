@echo off

set ROMFILE="..\FluxBase2.smc"
set LISTFILE="Programs and Tools\pixi_list.txt"

cd .\Programs and Tools\
.\pixi.exe -sp sprites/ -g sprites(extended,etc)/generators/ -a sprites_pixi_basecode/ -c sprites(extended,etc)/cluster/ -e sprites(extended,etc)/extended/ -sh sprites(extended,etc)/shooters/ -r PIXIroutines/ -l %LISTFILE% %ROMFILE% 

@pause