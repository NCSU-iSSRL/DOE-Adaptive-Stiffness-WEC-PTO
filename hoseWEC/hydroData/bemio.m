% clc; clear all; close all;

%% hydro data
hydro = struct();
hydro = readAQWA(hydro, 'hoseWEC.AH1', 'hoseWEC.LIS');
hydro = radiationIRF(hydro,[],[],[],[],[]);
hydro = radiationIRFSS(hydro,[],[]);
hydro = excitationIRF(hydro,[],[],[],[],[]);
writeBEMIOH5(hydro)

%% Plot hydro data
% plotBEMIO(hydro)
