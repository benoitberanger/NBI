function[noiseimg] = generateNoiseVolume(stim,visual, fd)

nFrames = round(stim.period/fd);
stepf = round(visual.ppd*(stim.internalSpeedControl*fd));
noiseimg = 255 * Illusion.Common.fractionalNoise3(zeros(stim.textureSize_px, stim.textureSize_px, nFrames+2), stim.gridSize_px, stim.nOctaves, stepf) - visual.bgColor;