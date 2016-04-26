function[m] = framesIllusion(stim, visual, noiseimg, fd)

% here we prepare one set texture with drifting internal motion (2D noise)
% (only one of the 16!)

if mod(stim.textureSize_px,2) == 0
    stim.textureSize_px = stim.textureSize_px+1;
end

stepf = round(visual.ppd*(stim.internalSpeed*fd));
nFrames = round(stim.period/fd);
reversal = nFrames/2;

% gaussian envelope
imWidth = floor(stim.textureSize_px/2);
[gx,gy]=meshgrid(-imWidth:imWidth, -imWidth:imWidth);
env = exp( -((gx.^2)+(gy.^2)) /(2*(stim.sigma_px)^2));

segBeg = 1;
segEnd = stim.textureSize_px;
segBeg2 = 1 + stepf*reversal;
segEnd2 = stim.textureSize_px + stepf*reversal;

% compute textures for individual frames
m = zeros(stim.textureSize_px, stim.textureSize_px, nFrames);
cf = 0; cb = 0; fi = 0;
for i=1:nFrames
    if i<=reversal
        aBeg = segBeg + (cf*stepf);
        aEnd = segEnd + (cf*stepf);
        cf = cf+1;
    else
        aBeg = segBeg2 - (cb*stepf);
        aEnd = segEnd2 - (cb*stepf);
        cb = cb+1;
    end
    fi = fi + 1;
    noisePatt = noiseimg(aBeg:aEnd,:);
    m(:,:,fi) = uint8(visual.bgColor + noisePatt.*env);
end
