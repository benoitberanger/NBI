% Adjust the order of the sequence by selecting a different starting point
% so that each noise patches initially appear at the middle point of its
% trajectory
seq = 1:nFrames;
sqShift = round(nFrames/4);
seq = circshift(seq, [0, -sqShift]);

% Here, if required, the path shortening is added (if tarPos != 0 and
% tarPos<nCycles) the cycle in which it will appear is given by tarPos
% (should be 1) if tarPos is set to 0 the normal stimulus is presented
% (whole trajectory)
nFrameSkip = round(tarShort * (nFrames/2));
seq_tar = [seq(1:(sqShift-ceil(nFrameSkip/2))), seq((sqShift+floor(nFrameSkip/2)+1):end)];
