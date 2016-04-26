function[noiseimg] = generateNoiseImage(stim,visual,fd)
%
% fd = vertical refresh duration in seconds
%
nFrames = round(stim.period/fd);
stepf = round(visual.ppd*(stim.internalSpeed*fd));
noiseimg = (255 * Illusion.Common.fractionalNoise(zeros(stim.textureSize_px*2+stepf*nFrames, stim.textureSize_px), stim.gridSize_px, stim.nOctaves))  - visual.bgColor;
