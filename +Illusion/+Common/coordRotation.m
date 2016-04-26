function[rectAll] = coordRotation(stim, visual, scr)
% scr.fd = duration of monitor refresh

stim.textureSize_px = round(visual.ppd * stim.textureSize);
imWidth = floor(stim.textureSize_px/2);
stim.ecc_px = (visual.ppd *stim.ecc);
stim.pathLength_px = (visual.ppd *stim.pathLength);
stim.sep_px = (visual.ppd*stim.sep);

nFrames = round(stim.period/scr.fd);

% position along path (starting at the midpoint)
timeIndex = linspace(0, 1, nFrames);
pathPos = round(((stim.pathLength_px/2) * sawtooth(2*pi*timeIndex, 0.5)));

% compute first set of positions (defined respect to screen center)
c1_x = round((stim.ecc*visual.ppd)/sqrt(2)); % center of motion path
c1_y = -round((stim.ecc*visual.ppd)/sqrt(2));
pg1_x = c1_x+pathPos; % position of center of gabor array
pg1_y = repmat(c1_y,1, length(pathPos));

% ROTATION 
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

