@echo off
REM ****************************************************************************
REM Vivado (TM) v2020.1 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Fri Oct 02 17:11:07 +0200 2020
REM SW Build 2902540 on Wed May 27 19:54:49 MDT 2020
REM
REM Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
echo "xelab -wto 05a4345b51ce46728985b3b0dfd04bbe --incr --debug typical --relax --mt 2 -L fifo_generator_v13_2_5 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot RS232top_TB_behav xil_defaultlib.RS232top_TB xil_defaultlib.glbl -log elaborate.log"
call xelab  -wto 05a4345b51ce46728985b3b0dfd04bbe --incr --debug typical --relax --mt 2 -L fifo_generator_v13_2_5 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot RS232top_TB_behav xil_defaultlib.RS232top_TB xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
