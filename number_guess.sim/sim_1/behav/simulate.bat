@echo off
set bin_path=C:\\modeltech_pe_10.4c\\win32pe
call %bin_path%/vsim   -do "do {seven_srg_mux_tb_simulate.do}" -l simulate.log
if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
exit 1
:SUCCESS
exit 0
