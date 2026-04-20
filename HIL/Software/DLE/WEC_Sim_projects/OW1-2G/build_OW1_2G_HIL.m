clear all; clc;

% Before running, WEC-Sim environment needs to be initialized.
% This only needs to happen once per session, so it's left to the user to do manually.
% Run: S:\Users\cmmcguir\DOE-Adaptive-Stiffness-WEC-PTO\HIL\Software\DLE\WEC_Sim_projects\addWecSimSource_ext.m

% initialize WEC Sim model
cd 'S:\Users\cmmcguir\DOE-Adaptive-Stiffness-WEC-PTO\HIL\Software\DLE\WEC_Sim_projects\OW1-2G'
open_system("OW1_2G_HIL.slx")
open_system(bdroot) % need to be at top level for initializeWecSim script to work properly
initializeWecSim

% move to build folder (local drive) for faster builds
% this drive is also excluded from Windows Defender real-time scanning
%   (since it was set up as a dev drive)
cd F:\SG_builds
model_name = 'OW1_2G_HIL';
slbuild(model_name)

% deploy and load model on Speedgoat
tg = slrealtime;
load(tg, model_name);
disp('Model deployed to Speedgoat and loaded')

% Now, move to Simulink window and connect model to run in external mode.
% Or, start model from SLRT explorer (useful if external mode is being finicky). 