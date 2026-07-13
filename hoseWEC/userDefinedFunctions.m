% %Example of user input MATLAB file for post processing
% 
% %Plot waves
%         waves.plotElevation(simu.rampTime);
%         try 
%             waves.plotSpectrum();
%         catch
%         end
% 
%        %% Body 1 and Body 2: Heave, Pitch, and Roll Responses
% 
% for iBody = 1:1
% 
%     t = output.bodies(iBody).time;
% 
%     % Heave = DOF 3
%     heave_pos = output.bodies(iBody).position(:,3);
%     heave_vel = output.bodies(iBody).velocity(:,3);
%     heave_acc = output.bodies(iBody).acceleration(:,3);
% 
%     % Roll = DOF 4, Pitch = DOF 5
%     roll_pos = output.bodies(iBody).position(:,4)*180/pi;
%     roll_vel = output.bodies(iBody).velocity(:,4)*180/pi;
%     roll_acc = output.bodies(iBody).acceleration(:,4)*180/pi;
% 
%     pitch_pos = output.bodies(iBody).position(:,5)*180/pi;
%     pitch_vel = output.bodies(iBody).velocity(:,5)*180/pi;
%     pitch_acc = output.bodies(iBody).acceleration(:,5)*180/pi;
% 
% 
%     figure
% 
%     subplot(3,3,1)
%     plot(t, heave_pos)
%     grid on
%     ylabel('Position (m)')
%     title(['Body ', num2str(iBody), ' Heave'])
% 
%     subplot(3,3,4)
%     plot(t, heave_vel)
%     grid on
%     ylabel('Velocity (m/s)')
% 
%     subplot(3,3,7)
%     plot(t, heave_acc)
%     grid on
%     xlabel('Time (s)')
%     ylabel('Acceleration (m/s^2)')
% 
%     subplot(3,3,2)
%     plot(t, roll_pos)
%     grid on
%     ylabel('Position (deg)')
%     title(['Body ', num2str(iBody), ' Roll'])
% 
%     subplot(3,3,5)
%     plot(t, roll_vel)
%     grid on
%     ylabel('Velocity (deg/s)')
% 
%     subplot(3,3,8)
%     plot(t, roll_acc)
%     grid on
%     xlabel('Time (s)')
%     ylabel('Acceleration (deg/s^2)')
% 
%     subplot(3,3,3)
%     plot(t, pitch_pos)
%     grid on
%     ylabel('Position (deg)')
%     title(['Body ', num2str(iBody), ' Pitch'])
% 
%     subplot(3,3,6)
%     plot(t, pitch_vel)
%     grid on
%     ylabel('Velocity (deg/s)')
% 
%     subplot(3,3,9)
%     plot(t, pitch_acc)
%     grid on
%     xlabel('Time (s)')
%     ylabel('Acceleration (deg/s^2)')
% 
%     sgtitle(['Body ', num2str(iBody), ' Motion Response'])
% 
% end
% 
% %Save waves and response as video
% %output.saveViz(simu,body,waves,...
% %'timesPerFrame',5,'axisLimits',[-150 150 -150 150 -50 20],...
% %'startEndTime',[100 125]);
% 
% 
% figure
% subplot(4,1,1); hold on; box on; plot(x.time,x.data); xlabel('Time (s)'); ylabel('Hose-pump stretch (m)')
% subplot(4,1,4); hold on; box on; plot(Ff2mc.time,Ff2mc.data); xlabel('Time (s)'); ylabel('Hose-pump force (N)');ylim([0 10000])
% subplot(4,1,2); hold on; box on; plot(P.time,P.data/1000/6.89475729); xlabel('Time (s)'); ylabel('Hose-pump pressure (psi)');ylim([0 200])
% subplot(4,1,3); hold on; box on; plot(Vtd.time,Vtd.data*1000); xlabel('Time (s)'); ylabel('Turbine flow rate (L/s)');ylim([0 20])
% 
% figure
% subplot(4,1,1); hold on; box on; plot(x.time,x.data); xlabel('Time (s)'); ylabel('Hose-pump stretch (m)')
% subplot(4,1,2); hold on; box on; plot(P.time,P.data.*Vtd.data); xlabel('Time (s)'); ylabel('Hydraulic turbine power (W)');%ylim([0 200])
% subplot(4,1,3); hold on; box on; plot(Tl.time,Tl.data.*theta2d.data); xlabel('Time (s)'); ylabel('Mechanical generator power (W)');%ylim([0 10000])
% subplot(4,1,4); hold on; box on; plot(electricalPowerOut.time,electricalPowerOut.data); xlabel('Time (s)'); ylabel('Electrical power out (W)');%ylim([0 20])





if wave_type=='regularCIC'
    i1 = 0;
    startOfACycle = [];
    for z=2:length(electricalPowerOut.data)
        if electricalPowerOut.data(z)>0.1 && electricalPowerOut.data(z-1)<0.1 %Cycle starts (stretch)
            i1 = i1+1;
            startOfACycle(i1) = z;
        end
    end
    avgElectrical = mean(electricalPowerOut.data(startOfACycle(end-3):startOfACycle(end))); %last 3 full cycles (so not final peak, final full on+off)
    peakElectrical = max(electricalPowerOut.data(startOfACycle(end-3):startOfACycle(end))); 
    maxPress = max(P.data(startOfACycle(end-3):startOfACycle(end)));
    maxF = max(Ff2mc.data(startOfACycle(end-3):startOfACycle(end)));
    avgVtd = mean(Vtd.data(startOfACycle(end-3):startOfACycle(end)));
elseif wave_type=='irregular'
    avgElectrical = mean(electricalPowerOut.data);
    peakElectrical = max(electricalPowerOut.data);
    maxPress = max(P.data);
    maxF = max(Ff2mc.data);
    avgVtd = mean(Vtd.data);
else
    avgElectrical = mean(electricalPowerOut.data);
    peakElectrical = max(electricalPowerOut.data);
    maxPress = max(P.data);
    maxF = max(Ff2mc.data);
    avgVtd = mean(Vtd.data);
end

mcr.Avgpower(imcr) = avgElectrical;
mcr.peakpower(imcr) = peakElectrical;
mcr.maxPressure(imcr) = maxPress;
mcr.maxForce(imcr) = maxF;
mcr.AvgVtd(imcr) = avgVtd;

if imcr == length(mcr.cases)
    H = mcr.cases(:,1);
    T = mcr.cases(:,2);
    Pavg = mcr.Avgpower;
    Ppeak = mcr.peakpower;
    PressureMax = mcr.maxPressure;
    ForceMax = mcr.maxForce;
    Vtdavg = mcr.AvgVtd;
end

% heightMatrix(imcr) = waves.height;
% periodMatrix(imcr) = waves.period;
% strokeMatrix(imcr) = max(x.data)-min(x.data);
% maxPressureMatrix(imcr) = max(P.data);
% maxForceMatrix(imcr) = max(Ff2mc.data);
% maxFlowrateMatrix(imcr) = max(Vtd.data);
% powerMatrix(imcr) = mean(electricalPowerOut.data);
