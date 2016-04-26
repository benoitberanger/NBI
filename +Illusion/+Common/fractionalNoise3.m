function im = fractionalNoise3(im, w, octaves, step, persistence, lacunarity)

% fractionalNoise3(zeros(stim.textureSize_px, stim.textureSize_px, nFrames+2), stim.gridSize_px, stim.nOctaves, step)

if nargin == 4
    lacunarity = 2;
    persistence = 0.5;
end

% debug
% im = zeros(stim.textureSize_px, stim.textureSize_px, nFrames+2);
% w = stim.gridSize_px;
% octaves = 2;
% step= 4;

[n, m, v] = size(im); a = 1;

for oct = 1:octaves
    rndim = -1 +2*rand(ceil(n/w),ceil(m/w),step*ceil(v/w));   % uniform 
    [Xq,Yq,Zq] = ndgrid(linspace(1,size(rndim,2),m),linspace(1,size(rndim,1),n),linspace(1,size(rndim,3),v));
    d = interp3(rndim,Xq,Yq,Zq, 'cubic');
    im = im + a*d(1:n, 1:m, 1:v);
    a = a*persistence;
    w = w/lacunarity;
end

% debug
% for i = 1:size(d,3)
%     surf(im(:,:,i));
%     axis([0 100 0 100 -2 2]);
%     drawnow;
%     WaitSecs(0.05);
% end

im = (im - min(min(min(im(:,:,:))))) ./ (max(max(max(im(:,:,:)))) - min(min(min(im(:,:,:)))));