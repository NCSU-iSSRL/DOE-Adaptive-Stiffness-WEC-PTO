%% Simulation Data
simu = simulationClass();                       % Initialize simulationClass
simu.simMechanicsFile = 'hoseWEC_main1.slx';              % Simulink Model File
simu.mode = 'normal';                   % Specify Simulation Mode ('normal','accelerator','rapid-accelerator')

simu.explorer = 'off';                   % Turn SimMechanics Explorer (on/off)
simu.endTime = 1800;      %1800       100                  % Simulation End Time [s]

simu.startTime = 0;                             % Simulation Start Time [s]
simu.rampTime = 15;                         	% Wave Ramp Time [s]
power_avg_start_time = 120; % time to start measuring average power (start after wave ramp-up)
simu.dt = 0.01;                                  % Simulation time-step [s]
simu.domainSize = 2;
simu.solver = 'ode1be'; % ode1be hose-pump flowrate values match closest to experiment (ode4 also matches with very small simu.dt), integrator errors with obe1be
%simu.solver = 'ode4'; % noisy signal in ACV with ode4 

simu.saveWorkspace = 1;
simu.cicEndTime = 4;

%% Wave Information  
% Regular Waves 
wave_type = "irregular";            %regularCIC  irregular
waves = waveClass(wave_type);           

heightRange = [1 2]; %0.5:0.25:3.5;
periodRange = [4 8]; %4:1:13;
waves.height = heightRange;                     % Wave Height [m]
waves.period = periodRange;                     % Wave Period [s]
waves.spectrumType = 'JS';

%% Body Data
% Float
% Note: Body origin is at CG location set in AQWA
body(1) = bodyClass('hydroData/ANALYSIS.h5');        % Initialize bodyClass for Float, -190mm most closely matches actual buoy
body(1).geometryFile = 'geometry/allison.stl';    % Geometry File
body(1).mass = 399.459752; %kg
body(1).inertia = [5.937, 5.937, 7.846];  % Moment of Inertia [kg*m^2]   
%body(1).initial.displacement = [0 0 0.67];
%body(1).nonlinearHydro = 2;

body.quadDrag.area = [0.4428 0.4428 1.6742 0 0 0];
body.quadDrag.cd   = [1     1     1     0 0 0];

%% Hose pump parameters
%HP_max_stretch = 3.8583/100;
HP_unstretched_length = 13.411; % m
HP_unstretched_radius = 8.29/3/100;
HP_unstretched_fiber_angle = 50*pi/180; % rad
R_inlet = 0.02; % m, inlet tube radius
mu = 0.001; %Pa*s
L_inlet = 0.1; %m, inlet tube length
HP_bladder_elastic_modulus = 2e6; 
HP_unstretched_wall_thickness = 0.006; % m
HP_flowrate_damping_coefficient = 0; % N/(m3/s)

% NeuMotors 3805/18/522
kV = 522; % RPM/V
kT = 0.0183; % Nm/A
Rm = 0.261; % Ohm

% NeuMotors 2515 I/3.25D/339
% kV = 339; % RPM/V
% kT = 0.028225; % Nm/A
% Rm = 0.013; % Ohm

R_load = 2; % 0.8375; % Ohm
gen_eta = 1; % generator efficiency, <=1
turbine_D = 1 / (5 * 1000); % 1 / (rev/L * L/m3) --> m3/rev

PTO_capacity_W = 2000;


%% PTO and Constraint Parameters
% rotational joint at reaction plate
constraint(1) = constraintClass('Constraint1'); % Initialize constraintClass for Constraint1
%constraint(3) = constraintClass('Constraint3'); % Initialize constraintClass for Constraint1
%constraint(1).location = [0 0 -1];

% bridle at bottom of buoy
constraint(2) = constraintClass('Constraint2'); % Initialize constraintClass for Constraint1
bodyCG = h5read('hydroData/ANALYSIS.h5', '/body1/properties/cg');
%bodyCG =  [-.73 0 0];
%constraint(2).location = [.73 0 -0.4015] + bodyCG;
constraint(2).location = [0 0 -.410];

%constraint(2).location = [.6 0 -0.4015] + body.initial.displacement;  % Constraint Location [m]

constraint(1).location = constraint(2).location + [0 0 -1*HP_unstretched_length] + [0 0 -2];
%constraint(1).location = [0 0 -0.4015] + body.initial.displacement + [0 0 -1*HP_unstretched_length];


%constraint(3) = constraintClass('Constraint3'); % Initialize constraintClass for Constraint1
%constraint(3).location = constraint(2).location + [0 0 .4015];   

% Translational PTO
pto(1) = ptoClass('PTO1');                      % Initialize ptoClass for PTO1
pto(1).stiffness = 0;%534;                                   % PTO Stiffness [N/m]
pto(1).damping = 30;                             % PTO Damping [N/(m/s)]
%pto(1).location = [0 0 -0.1341-0.1] + body.initial.displacement;       % PTO Location [m]
%pto(1).location = [0 0 .067];
pto(1).location = constraint(2).location;
%pto(1).location = [0 0 -0.4015] + body.initial.displacement + [0 0 -1*HP_unstretched_length];
%pto(1).hardStops.upperLimitSpecify = 'on';
%pto(1).hardStops.upperLimitBound = 0.05;
%pto(1).initial.displacement = [0 0 HP_unstretched_length];
%pto(1).hardStops.upperLimitBound = 0.1;%0.95*(HP_max_stretch);

cable(1) = cableClass('Cable1', 'constraint(1)',  'pto(1)');
cable(1).stiffness = 0; %100;
cable(1).damping = 0;
cable(1).cableLength = norm(constraint(2).location - constraint(1).location) + 2; 