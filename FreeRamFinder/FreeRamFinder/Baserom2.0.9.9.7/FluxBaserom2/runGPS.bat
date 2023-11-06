@echo off

set ROMFILE="..\FluxBase2.smc"

cd .\Programs and Tools\
.\gps.exe -l "gps_list.txt" -s "GPSroutines/" %ROMFILE%

@pause