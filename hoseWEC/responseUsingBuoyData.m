% Load 1 week work of buoy data
load('mcrBuoyData.mat')

% Put simulated values into a grid
for i = 1:length(heightRange)
    power(:,i) = Pavg(1+length(periodRange)*(i-1):length(periodRange)+length(periodRange)*(i-1));
end
V = power';

% Make lookup surface of simulated values
[X,Y] = meshgrid(periodRange,heightRange);
figure; surf(X,Y,V); title('Original Sampling'); xlabel('Peak period (s)'); ylabel('Significant wave height (m)'); zlabel('Output power (W)')

% Make interpolated surface of values
[Xq,Yq] = meshgrid(min(period):0.01:max(period),min(Hs):0.01:max(Hs));
Xq = round(Xq,2);Yq = round(Yq,2);
Vq = interp2(X,Y,V,Xq,Yq,'linear',-20);
figure; surf(Xq,Yq,Vq); title('Linear Interpolation'); xlabel('Peak period (s)'); ylabel('Significant wave height (m)'); zlabel('Output power (W)')

% Run timeseries buoy data with lookup surface
for j = 1:length(period)
    if isempty(Vq(find(Xq==period(j) & Yq==Hs(j))))  
        powerOverTime(j) = -50;
    else
        powerOverTime(j) = Vq(find(Xq==period(j) & Yq==Hs(j)));
    end
end

time = linspace(0,7,length(powerOverTime));
figure;hold on;box on;plot(time,powerOverTime,'--.');xlabel('Time (days)'); ylabel('Average electrical power output (W)'); title('Predicted power output from buoy data')
% -20 means not within range of simulation
% -50 means interpolated point doesn't exist
