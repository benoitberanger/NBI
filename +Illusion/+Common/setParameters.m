%
% here you can set the parameters for all conditions
%

%% stimulus parameters

% all values here are in degree of visual angle, and will be transformed 
% in pixel based on monitor settings below (display settings)

% noise pattern
stim.sigma = 0.3;       % sigma of gaussian envelope in dva
stim.nOctaves = 3;      % number of noisy functions added to make the noise
stim.gridSize = 0.2;    % this set the spatial frequency of the noise functions with lowest spatial frequency
stim.textureSize = 1.5; % increase this if the gaussian envelope appear clipped

% spatial & motion parameters
stim.internalSpeed = 4;     % degree (visual angle)/ sec
stim.internalSpeedControl = 2;   % this set the speed of flickering for the control stimulus 
stim.ecc = 5.5;             % eccentricity of each set of noise patches at the center of its path
stim.pathLength = 2.6;      % physical length of motion path of each noise patch
stim.sep = 2.5;             % distance between noise patches
stim.period = 1.8;          % sec, duration of one motion cycle (determine speed)

stim.externalSpeed = stim.pathLength/stim.period; % external speed (degree/sec) currently set as a function of period

%% display settings

% % these are used to compute values in degree of visual angle
% % adjust them to match your monitor
% scr.subDist = 120;   % subject distance (cm)
% scr.width   = 400;   % monitor width (mm)

%% other settings

% nCycles = 5; % number of motion cycles
% ScreenRes = [1024, 768];

%% target
tarPos = 0;     % motion cycle at which the target is presented
                % set it to 0 to have the normal stimulus with no path shortening
                
tarShort = 1; % proportion of path skipped
                % (when = 1, skip half of the whole path).

