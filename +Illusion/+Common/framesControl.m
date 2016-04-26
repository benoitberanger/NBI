function[m] = framesControl(stim, visual, noiseimg, fd)

% here we prepare one set texture with control dynamic noise (3D noise)
% (only one of the 16!)

if mod(stim.textureSize_px,2) == 0
    stim.textureSize_px = stim.textureSize_px+1;
end

nFrames = round(stim.period/fd);
reversal = nFrames/2;

% gaussian envelope
imWidth = floor(stim.textureSize_px/2);
[gx,gy]=meshgrid(-imWidth:imWidth, -imWidth:imWidth);
env = exp( -((gx.^2)+(gy.^2)) /(2*(stim.sigma_px)^2));

m = zeros(stim.textureSize_px, stim.textureSize_px, nFrames);
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
    m(:,:,fi) = uint8(visual.bgColor + noisePatt.*env);
end
