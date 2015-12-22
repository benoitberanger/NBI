function [] = makeVideo_control_pathS(filename)
%
% Make video, double-drift condition
%

%% various
saveMovie = 0;    % logical (set to 1 if you want to save a movie)
squaredMovie = 0; % if movie is required this will make it in a "squared frame" (looks nicer for demo and presentations)

%% stimulus parameters

% all values here are in degree of visual angle, and will be transformed 
% in pixel based on monitor settings below (display settings)

stim.sigma = 0.35;      % sigma of gaussian envelope in dva
stim.nOctaves = 3;      % number of noisy functions added to make the noise
stim.gridSize = 0.25;   % this set the spatial frequency of the noise functions with lowest spatial frequency
stim.textureSize = 1.9; % increase this if the gaussian envelope appear clipped

% spatial & motion parameters
stim.internalSpeed = 2/2; % degree (visual angle)/ sec
stim.ecc = 6;               % eccentricity of each set of noise patches at the center of its path
stim.pathLength = 2.5;      % physical length of motion path of each noise patch
stim.sep = 3.5;             % distance between noise patches
stim.period = 2.5;          % sec, duration of one motion cycle (determine speed)

stim.externalSpeed = stim.pathLength/stim.period; % degree (visual angle)/ sec

%% display settings

% these are used to compute values in degree of visual angle
% adjust them to match your monitor
scr.subDist = 80;    % subject distance (cm)
scr.width   = 435;   % monitor width (mm)

%% other settings
nCycles = 6; % number of motion cycles for the video
ScreenRes = [1024, 768];


%% target
tarPos = 3;     % motion cycle at which the target is presented
                % set it to 0 to have the normal stimulus with no path shortening
                
tarShort = 0.8; % proportion of path skipped
                % (when = 1, skip half of the whole path).

                
%%-----------------------------------------------------------------------%%
%
% from this point on you shouln't need to change anything
%
%%-----------------------------------------------------------------------%%

if nargin<1
    filename = 'test';
end

%% set display
scr.colDept = 32; % color depth
scr.allScreens = Screen('Screens');         % If there are multiple displays guess that one without the menu bar is the
% scr.expScreen  = max(scr.allScreens);       % best choice.  Dislay 0 has the menu bar
scr.expScreen  = 1;       % best choice.  Dislay 0 has the menu bar
Screen('Resolution', scr.expScreen, ScreenRes(1), ScreenRes(2)); % set resolution
[scr.main,scr.rect] = Screen('OpenWindow',scr.expScreen, [0.5 0.5 0.5],[],scr.colDept,2,0,4); % open a window

% get information about  screen
[scr.xres, scr.yres]    = Screen('WindowSize', scr.main); % heigth and width of screen [pix]
[scr.centerX, scr.centerY] = WindowCenter(scr.main);      % determine th main window's center
scr.fd = Screen('GetFlipInterval',scr.main);    % frame duration [s]

WaitSecs(2); % make sure the monitor has time to resync after change in display mode
HideCursor;

% visual settings
visual.ppd = va2pix(1,scr);   % pixel per degree
visual.black = BlackIndex(scr.main);
visual.white = WhiteIndex(scr.main);
visual.bgColor = round((visual.black + visual.white) / 2);     % background color
visual.fgColor = visual.black;

priorityLevel=MaxPriority(scr.main); % set priority of window activities to maximum
Priority(priorityLevel);


%% prepare noise textures

Screen('FillRect', scr.main, visual.bgColor);
DrawFormattedText(scr.main, 'Preparing visual stimuli.\nPlease wait...', 'center', 'center', visual.fgColor,70);
Screen('Flip', scr.main);

% here we prepare one set of 16 textures with drifting internal motion
% and 16 with no internal motion (dinamic noise)

% convert everything in pixels
stim.sigma_px = round(visual.ppd * stim.sigma);
stim.gridSize_px = round(visual.ppd * stim.gridSize);
stim.textureSize_px = round(visual.ppd * stim.textureSize);
stim.internalSpeed_px = round(visual.ppd * stim.internalSpeed);
stim.externalSpeed_px = round(visual.ppd * stim.externalSpeed);

if mod(stim.textureSize_px,2) == 0
    stim.textureSize_px = stim.textureSize_px+1;
end

step = round(visual.ppd*(stim.internalSpeed*scr.fd));
nFrames = round(stim.period/scr.fd);
reversal = nFrames/2;

% gaussian envelope
imWidth = floor(stim.textureSize_px/2);
[gx,gy]=meshgrid(-imWidth:imWidth, -imWidth:imWidth);
env = exp( -((gx.^2)+(gy.^2)) /(2*(stim.sigma_px)^2));

motionTex = zeros(16, nFrames);
for ti = 1:16
    noiseimg = 255 * fractionalNoise3(zeros(stim.textureSize_px, stim.textureSize_px, nFrames+2), stim.gridSize_px, stim.nOctaves, step) - visual.bgColor;
    
    % c = step+1;
    c = 2;
    for fi=1:nFrames
        if fi>1
            if fi<=reversal
                c = c+1; %step;
            else
                c = c-1; %step;
            end
        end
        noisePatt = noiseimg(:,:,c);
        m = uint8(visual.bgColor + noisePatt.*env);
        motionTex(ti,fi)=Screen('MakeTexture', scr.main, m);
    end
end
%toc

Screen('FillRect', scr.main, visual.bgColor);
Screen('Flip', scr.main);
WaitSecs(0.5);


%% compute path coordinates 

stim.ecc_px = (visual.ppd *stim.ecc);
stim.pathLength_px = (visual.ppd *stim.pathLength);
stim.sep_px = (visual.ppd*stim.sep);

% position along path (starting at the midpoint)
timeIndex = linspace(0, 1, nFrames);
pathPos = round(((stim.pathLength_px/2) * sawtooth(2*pi*timeIndex, 0.5)));

% compute first set of positions (defined respect to screen center)
c1_x = round((stim.ecc*visual.ppd)/sqrt(2)); % center of motion path
c1_y = -round((stim.ecc*visual.ppd)/sqrt(2));
pg1_x = c1_x+pathPos; % position of center of gabor array
pg1_y = repmat(c1_y,1, length(pathPos));

% rotate the forst set of positions so that is aligned radially from fixation
rotMat_ctrEx = [cosd(45), -sind(45); sind(45), cosd(45)];
rotPg1 = rotMat_ctrEx * [(pg1_x-c1_x) ; (c1_y-pg1_y)];
pg1_x = rotPg1(1,:)+c1_x;
pg1_y = c1_y-rotPg1(2,:);

sep = round(stim.sep_px/2);
ps_1 = zeros(2,4,nFrames);
ps_1(1,1,:) = pg1_x;
ps_1(2,1,:) = pg1_y + sep;
ps_1(1,2,:) = pg1_x + sep;
ps_1(2,2,:) = pg1_y;
ps_1(1,3,:) = pg1_x;
ps_1(2,3,:) = pg1_y - sep;
ps_1(1,4,:) = pg1_x - sep;
ps_1(2,4,:) = pg1_y;

% compute array of rect limits for 1st set of stimuli
rect_1 = cat(1,ps_1,ps_1) + repmat([-imWidth; - imWidth; imWidth; imWidth],[1,4,nFrames]);

% this matrix do a 2D rotation of 90 deg. counter-clockwise in screen coordinates
% (that is a rotation of -90 deg. in standard cartesian coordinates)
rotMat = [0, 1; -1, 0];

% rotate the initial array to get position of the other 3 sets
rect_2 = zeros(4,4,nFrames);
rect_3 = rect_2;
rect_4 = rect_2;

for d = 1:4
    rect_2(1:2,d,:) = rotMat*squeeze(rect_1(1:2,d,:));
    rect_2(3:4,d,:) = rotMat*squeeze(rect_1(3:4,d,:));
    rect_3(1:2,d,:) = rotMat*squeeze(rect_2(1:2,d,:));
    rect_3(3:4,d,:) = rotMat*squeeze(rect_2(3:4,d,:));
    rect_4(1:2,d,:) = rotMat*squeeze(rect_3(1:2,d,:));
    rect_4(3:4,d,:) = rotMat*squeeze(rect_3(3:4,d,:));
end

% merge arrays
rectAll = cat(2, rect_1, rect_2, rect_3, rect_4) + repmat([scr.centerX; scr.centerY],[2,16,nFrames]);


%% set sequence index
% sequence index index (motion start at trajectory midpoint)
seq = 1:nFrames;
sqShift = round(nFrames/4);
seq = circshift(seq, [0, -sqShift]);

nFrameSkip = round(tarShort * (nFrames/2));
seq_tar = [seq(1:(sqShift-ceil(nFrameSkip/2))), seq((sqShift+floor(nFrameSkip/2)):end)]; 


%% Expanding contractin

% prepare movie 1
if saveMovie
    movieName = sprintf('%s_InOut.mov',filename);
    if squaredMovie
        movieHalfWidth = scr.yres/2 - 5;
        imageRect = [(scr.centerX-movieHalfWidth) (scr.centerY-movieHalfWidth) (scr.centerX+movieHalfWidth) (scr.centerY+movieHalfWidth)];
    else
        imageRect = [0 0 scr.xres scr.yres];
    end
    movieX = imageRect(3)-imageRect(1);     movieY = imageRect(4)-imageRect(2);
    moviePtr = Screen('CreateMovie', scr.main, movieName, movieX, movieY, 60, 'CodecSettings= Videoquality=1 EncodingQuality=1');
    %moviePtr = Screen('CreateMovie', scr.main, movieName, movieX, movieY, 60, 'CodecType=x264enc Videoquality=1 EncodingQuality=1');
    %moviePtr = Screen('CreateMovie', scr.main, movieName, movieX, movieY, 60);
end


% This should be the best blend function for drawing the noise patches
Screen('BlendFunction', scr.main, GL_ONE, GL_ZERO);

% initial angles values
angles = [0, 0, 0, 0, 90, 90, 90, 90, 0, 0, 0, 0, 90, 90, 90, 90];
for cycle = 1:nCycles
    if cycle == tarPos
        for i = seq_tar
            Screen('DrawTextures', scr.main, motionTex(:,i), [], squeeze(rectAll(:,:,i)), angles);
            drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual)
            Screen('Flip', scr.main);
            if saveMovie; Screen('AddFrameToMovie', scr.main, imageRect, 'frontBuffer', moviePtr, 1); end
        end
    else
        for i = seq
            Screen('DrawTextures', scr.main, motionTex(:,i), [], squeeze(rectAll(:,:,i)), angles);
            drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual)
            Screen('Flip', scr.main);
            if saveMovie; Screen('AddFrameToMovie', scr.main, imageRect, 'frontBuffer', moviePtr, 1); end
        end
    end
end

% finalize movie
if saveMovie
    Screen('FinalizeMovie', moviePtr);
end

%% Rotation

% new physical path

stim.ecc_px = (visual.ppd *stim.ecc);
stim.pathLength_px = (visual.ppd *stim.pathLength);
stim.sep_px = (visual.ppd*stim.sep);

% position along path (starting at the midpoint)
timeIndex = linspace(0, 1, nFrames);
pathPos = round(((stim.pathLength_px/2) * sawtooth(2*pi*timeIndex, 0.5)));

% compute first set of positions (defined respect to screen center)
c1_x = round((stim.ecc*visual.ppd)/sqrt(2)); % center of motion path
c1_y = -round((stim.ecc*visual.ppd)/sqrt(2));
pg1_x = c1_x+pathPos; % position of center of gabor array
pg1_y = repmat(c1_y,1, length(pathPos));

% rotate the forst set of positions so that is tangential with respect to fixation
rotMat_ctrEx = [cosd(-45), -sind(-45); sind(-45), cosd(-45)];
rotPg1 = rotMat_ctrEx * [(pg1_x-c1_x) ; (c1_y-pg1_y)];
pg1_x = rotPg1(1,:)+c1_x;
pg1_y = c1_y-rotPg1(2,:);

sep = round(stim.sep_px/2);
ps_1 = zeros(2,4,nFrames);
ps_1(1,1,:) = pg1_x;
ps_1(2,1,:) = pg1_y + sep;
ps_1(1,2,:) = pg1_x + sep;
ps_1(2,2,:) = pg1_y;
ps_1(1,3,:) = pg1_x;
ps_1(2,3,:) = pg1_y - sep;
ps_1(1,4,:) = pg1_x - sep;
ps_1(2,4,:) = pg1_y;

% compute array of rect limits for 1st set of stimuli
rect_1 = cat(1,ps_1,ps_1) + repmat([-imWidth; - imWidth; imWidth; imWidth],[1,4,nFrames]);

% this matrix do a 2D rotation of 90 deg. counter-clockwise in screen coordinates
% (that is a rotation of -90 deg. in standard cartesian coordinates)
rotMat = [0, 1; -1, 0];

% rotate the initial array to get position of the other 3 sets
rect_2 = zeros(4,4,nFrames);
rect_3 = rect_2;
rect_4 = rect_2;

for d = 1:4
    rect_2(1:2,d,:) = rotMat*squeeze(rect_1(1:2,d,:));
    rect_2(3:4,d,:) = rotMat*squeeze(rect_1(3:4,d,:));
    rect_3(1:2,d,:) = rotMat*squeeze(rect_2(1:2,d,:));
    rect_3(3:4,d,:) = rotMat*squeeze(rect_2(3:4,d,:));
    rect_4(1:2,d,:) = rotMat*squeeze(rect_3(1:2,d,:));
    rect_4(3:4,d,:) = rotMat*squeeze(rect_3(3:4,d,:));
end

% merge arrays
rectAll = cat(2, rect_1, rect_2, rect_3, rect_4) + repmat([scr.centerX; scr.centerY],[2,16,nFrames]);


%%

Screen('FillRect', scr.main, visual.bgColor);
Screen('Flip', scr.main);
WaitSecs(0.5);

% prepare movie 2
if saveMovie
    movieName = sprintf('%s_Rot.mov',filename);
    if squaredMovie
        movieHalfWidth = scr.yres/2 - 5;
        imageRect = [(scr.centerX-movieHalfWidth) (scr.centerY-movieHalfWidth) (scr.centerX+movieHalfWidth) (scr.centerY+movieHalfWidth)];
    else
        imageRect = [0 0 scr.xres scr.yres];
    end
    movieX = imageRect(3)-imageRect(1);     movieY = imageRect(4)-imageRect(2);
    moviePtr2 = Screen('CreateMovie', scr.main, movieName, movieX, movieY, 60, 'CodecSettings= Videoquality=1 EncodingQuality=1');
    %moviePtr2 = Screen('CreateMovie', scr.main, movieName, movieX, movieY, 60);
    %moviePtr2 = Screen('CreateMovie', scr.main, movieName, movieX, movieY, 60, 'CodecType=x264enc Videoquality=1 EncodingQuality=1');
end


% This should be the best blend function for drawing the noise patches
Screen('BlendFunction', scr.main, GL_ONE, GL_ZERO);

% initial angles values
angles = 180+[0, 0, 0, 0, 90, 90, 90, 90, 0, 0, 0, 0, 90, 90, 90, 90];
for cycle = 1:nCycles
    if cycle == tarPos
        for i = seq_tar
            Screen('DrawTextures', scr.main, motionTex(:,i), [], squeeze(rectAll(:,:,i)), angles);
            drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual)
            Screen('Flip', scr.main);
            if saveMovie; Screen('AddFrameToMovie', scr.main, imageRect, 'frontBuffer', moviePtr, 1); end
        end
    else
        for i = seq
            Screen('DrawTextures', scr.main, motionTex(:,i), [], squeeze(rectAll(:,:,i)), angles);
            drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual)
            Screen('Flip', scr.main);
            if saveMovie; Screen('AddFrameToMovie', scr.main, imageRect, 'frontBuffer', moviePtr, 1); end
        end
    end
end

% finalize movie
if saveMovie
    Screen('FinalizeMovie', moviePtr2);
end

Priority(0);
ShowCursor;

% Close all textures. Not strictly needed but avoid warnings
Screen('Close');

% Close window:
Screen('CloseAll');

end % end of main function (multiSquare)

%%-----------------------------------------------------------------------%%
%% LOCAL FUNCTIONS

function pix=va2pix(va, scr)
pix = scr.subDist*tan(va*pi/180)/(scr.width/(10*scr.xres));
end

function drawFixation(col,loc,scr,visual)
if length(loc)==2
    loc=[loc loc];
end
pu = round(visual.ppd*0.1);
Screen(scr.main,'FillOval',col,loc+[-pu -pu pu pu]);
end


function im = fractionalNoise3(im, w, octaves, step, persistence, lacunarity)
if nargin == 4
    lacunarity = 2;
    persistence = 0.5;
end
[n, m, v] = size(im); a = 1;
for oct = 1:octaves
    rndim = -1 +2*rand(ceil(n/w),ceil(m/w),ceil(v/w));   % uniform 
    [Xq,Yq,Zq] = ndgrid(linspace(1,size(rndim,2),m),linspace(1,size(rndim,1),n),linspace(1,step*size(rndim,3),v));
    d = interp3(rndim,Xq,Yq,Zq, 'cubic');
    im = im + a*d(1:n, 1:m, 1:v);
    a = a*persistence;
    w = w/lacunarity;
end
im = (im - min(min(min(im(:,:,:))))) ./ (max(max(max(im(:,:,:)))) - min(min(min(im(:,:,:)))));
end