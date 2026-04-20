%% Simulation Data
simu = simulationClass();                       % Initialize simulationClass
simu.simMechanicsFile = 'OW1_2G_HIL.slx';              % Simulink Model File
simu.mode = 'normal';                   % Specify Simulation Mode ('normal','accelerator','rapid-accelerator')

simu.explorer = 'off';                   % Turn SimMechanics Explorer (on/off)
simu.endTime = 240;                               % Simulation End Time [s]

simu.startTime = 0;                             % Simulation Start Time [s]
simu.rampTime = 15;                         	% Wave Ramp Time [s]
power_avg_start_time = 30; % time to start measuring average power (start after wave ramp-up)

simu.dt = 0.0001; % IMPORTANT - This is the overall model timestep, i.e., the 
%   fastest rate that the Speedgoat will run at. Set the timestep for the
%   WEC-Sim model in its "Global Reference Frame - Custom" block.                                 % Simulation time-step [s]
wecSimModelRate = 0.002;
simu.dtOut = wecSimModelRate; % set this to the WEC-Sim data rate
simu.morisonDt = wecSimModelRate;
simu.nonlinearDt = wecSimModelRate;

simu.domainSize = 2;
%simu.solver = 'ode1be'; % ode1be hose-pump flowrate values match closest to experiment (ode4 also matches with very small simu.dt), integrator errors with obe1be
%simu.solver = 'ode15s';
%simu.solver = 'ode23t';
%simu.solver = 'ode45';
%simu.solver = 'ode14x';
simu.solver = 'ode4';
simu.saveWorkspace = 0;

simu.cicEndTime = 4;
simu.cicDt = wecSimModelRate;

%% Wave Information  
% Regular Waves 
%waves = waveClass("regularCIC");                   % Initialize waveClass
waves = waveClass("noWaveCIC");

waves.height = 0.3;                                  % Wave Height [m]
waves.period = 4;                                    % Wave Period [s]
%charLength = 0.305; % characteristic length for wave pow eqn, lower cylinder diameter
%wavePower = 1000*9.81^2/64/pi * waves.height^2 * waves.period * charLength;

%% Body Data
% Float
% Note: Body origin is at CG location set in AQWA
body(1) = bodyClass('hydroData/OW1_hydro.h5');        % Initialize bodyClass for Float, -190mm most closely matches actual buoy
body(1).geometryFile = 'geometry/OW1-rev1_AQWA_model.stl';    % Geometry File
%body(1).mass = 11.2 - 2.3;                   % Mass [kg]
body(1).mass = 13.26;% + 2.3;% kg
%body(1).inertia = [0.122 0.122 0.0819];  % Moment of Inertia [kg*m^2]   
body(1).inertia = [0.197 0.197 0.260];
body(1).initial.displacement = [0 0 -0.1];
% body.initial.angle = 10*pi/180;
%body(1).nonlinearHydro = 2;

% body.morisonElement.option = 1;
%body.morisonElement.cd = [0.2 0.2 1];
%body.morisonElement.area = [0.041 0.041 0.0730];
%body.morisonElement.area = [0.0771 0.0771 pi/4*(0.305^2 - 0.127^2)]; 
% body.morisonElement.VME = 0.04; % approx volume of OW1-2G hull
% body.morisonElement.ca = [5e-3 5e-3 0.014]; % approx. from normalized added mass plots from BEM data
% body.morisonElement.z = [0 0 1];

body.quadDrag.area = [0.0771 0.0771 pi*0.225^2 0 0.041 0]; % [linear x, y, z, rotational x, y, z]
body.quadDrag.cd = [0.2 0.2 2 0 0.1 0];
body.linearDamping = 10 * eye(6);

%% PTO and Constraint Parameters
% rotational joint
constraint(1) = constraintClass('Constraint1'); % Initialize constraintClass for Constraint1
%constraint(1).location = [0 0 -1];
constraint(2) = constraintClass('Constraint2'); % Initialize constraintClass for Constraint1
constraint(2).location = [0 0 -0.1143] + body.initial.displacement;  % Constraint Location [m]

constraint(1).location = constraint(2).location + [0 0 -3];

% Translational PTO
pto(1) = ptoClass('PTO1');                      % Initialize ptoClass for PTO1
pto(1).stiffness = 0;%534;                                   % PTO Stiffness [N/m]
pto(1).damping = 0*30;                             % PTO Damping [N/(m/s)]
%pto(1).location = [0 0 -0.1341-0.1] + body.initial.displacement;       % PTO Location [m]
pto(1).location = constraint(1).location;
%pto(1).hardStops.upperLimitSpecify = 'on';
%pto(1).hardStops.upperLimitBound = 0.05;

cable(1) = cableClass('Cable1', 'pto(1)',  'constraint(2)');
cable(1).stiffness = 10000;
cable(1).damping = 500;
cable(1).cableLength = norm(constraint(2).location - constraint(1).location);
% 
% cable(2) = cableClass('Cable2', 'constraint(1)', 'pto(1)');
% cable(2).stiffness = 1e5/2;
% cable(2).damping = 500;

predictor_dT = 0.04; % forward-looking time delta for position and velocity prediction