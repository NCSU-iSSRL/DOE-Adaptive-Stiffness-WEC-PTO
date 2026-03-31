% quick script for adding WEC-Sim and custom source files to path

% recommended to add a copy of WEC-Sim to your Users folder and update this
%   script to point to it for your computer (same for a copy of the GitHub repo)

addSource = 1;
switch getenv('COMPUTERNAME')
    case {"MAE-DT-001"}
        wecSimFolder = 'S:\Users\cmmcguir\WEC-Sim-6.1.2';
        noodle_PTO_folder = "S:\Users\cmmcguir\DOE-Adaptive-Stiffness-WEC-PTO\Source";
    otherwise
        % add other computers here
        disp('!!! No WEC-Sim repo folder specified !!!')
        addSource = 0;
end

returnDir = pwd;
cd(wecSimFolder);
addWecSimSource;
cd(returnDir);
addpath(genpath(noodle_PTO_folder))