@echo off 
cd /d "%~dp0"

start /b /wait /d "Programs and Tools\UberASM" UberASMTool.exe "list.txt"
@pause