stim.sigma_px = round(visual.ppd * stim.sigma);
stim.gridSize_px = round(visual.ppd * stim.gridSize);
stim.textureSize_px = round(visual.ppd * stim.textureSize);
stim.internalSpeed_px = round(visual.ppd * stim.internalSpeed);
stim.externalSpeed_px = round(visual.ppd * stim.externalSpeed);
if mod(stim.textureSize_px,2) == 0
    stim.textureSize_px = stim.textureSize_px+1;
end
