function calc = CalculateBeamTime(varargin)

% Define scalar factors
calc.sad = 105; % cm
calc.scd = 100 + 5; % cm
calc.k = 1.85; % Gy/min
calc.cf = 1/1.21;

% Load tabulated factors
calc.tpr_data = csvread('./calcdata/ViewRay_TPR.csv');
calc.scp_data = csvread('./calcdata/ViewRay_Scp.csv');

% Initialize provided factors
calc.mode = 'Planned';
calc.dose = 0;
calc.r = 0;
calc.depth = 0;

% Load data structure from varargin
for i = 1:2:nargin
    
    if strcmp(varargin{i}, 'dose')
        calc.dose = varargin{i+1};  
        
    elseif strcmp(varargin{i}, 'depth')
        calc.depth = varargin{i+1};  
   
    elseif strcmp(varargin{i}, 'r')
        if length(varargin{i+1}) == 1   
            calc.r = varargin{i+1};
        else
            calc.r = 2 * varargin{i+1}(1) * varargin{i+1}(2) / ...
                (varargin{i+1}(1) + varargin{i+1}(2));
        end
    
    elseif strcmp(varargin{i}, 'oad')
        calc.oad = varargin{i+1}; 
    
    elseif strcmp(varargin{i}, 'angle')
        calc.angle = varargin{i+1}; 
    
    elseif strcmp(varargin{i}, 'k')
        calc.k = varargin{i+1}; 
    end
end

% Calculate couch factor
if calc.angle > 240 || calc.angle < 130
    calc.cf = 1;
end

% Compute beam time
[x, y] = meshgrid(calc.tpr_data(2:end,1), calc.tpr_data(1,2:end));
calc.tpr = interp2(x, y, calc.tpr_data(2:end, 2:end)', calc.depth, ...
    calc.r, 'linear', 0);
calc.scp = interp1(calc.scp_data(1,:), calc.scp_data(2,:), calc.r, ...
    'linear', 0);
calc.oar = 1;
calc.time = calc.dose/(calc.k*calc.tpr*calc.scp*calc.oar*calc.cf*...
    (calc.scd/calc.sad)^2)*60;

% Log result
if exist('Event', 'file') == 2
    Event(sprintf(['Beam on time calculation:\nEnergy = Co-60\nK = %g ', ...
        'Gy/sec\nSCD = %g cm\nSAD = %g cm\nDose = %g cGy\nDepth = %g cm\n', ...
        'Field Size (r) = %g cm x %g cm (equiv)\nOAD = %g cm\nTPR = %g\n', ...
        'Scp = %g\nOAR = %g\nCF = %g\nTime = %0.3f sec\n'], calc.k, ...
        calc.scd, calc.sad, calc.dose, calc.depth, calc.r, ...
        calc.r, calc.oad, calc.tpr, calc.scp, calc.oar, calc.cf, ...
        calc.time));
end

