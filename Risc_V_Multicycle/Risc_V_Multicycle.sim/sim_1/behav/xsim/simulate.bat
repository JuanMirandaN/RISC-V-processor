@echo off
REM ****************************************************************************
REM Vivado (TM) v2022.2 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Mon Dec 23 10:05:29 -0300 2024
REM SW Build 3671981 on Fri Oct 14 05:00:03 MDT 2022
REM
REM IP Build 3669848 on Fri Oct 14 08:30:02 MDT 2022
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim LW_test_behav -key {Behavioral:sim_1:Functional:LW_test} -tclbatch LW_test.tcl -view C:/Users/Asus/Vivado_Projects/RISC-V-processor/Risc_V_Multicycle/LW_test_behav.wcfg -log simulate.log"
call xsim  LW_test_behav -key {Behavioral:sim_1:Functional:LW_test} -tclbatch LW_test.tcl -view C:/Users/Asus/Vivado_Projects/RISC-V-processor/Risc_V_Multicycle/LW_test_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
