function im = fractionalNoise(im, w, octaves, persistence, lacunarity)
% creates and sum successive noise functions, each with higher
% frequency and lower amplitude. nomalize output within [0 1]
%
% input:
% - im: initial matrix
% - wl: grid size in pixels of the first noise octave (lowest spatial frequency)
% - octaves: number of noisy octaves with increasing spatial frequency to
%            be added
%
% optional:
% - lacunarity: frequency multiplier for each octave (usually set to 2 so 
%               spatial frequency doubles each octave)
% - persistence: amplitude gain (usually set to 1/lacunarity)
%
% When lacunarity=2 and persistence=0.5 you get ~ 1/f noise
%
if nargin == 3
    lacunarity = 2;
    persistence = 0.5;
end
[n, m] = size(im); a = 1;
for oct = 1:octaves
    rndim = -1 + 2*rand(ceil(n/w),ceil(m/w)); % uniform
    [Xq,Yq] = meshgrid(linspace(1,size(rndim,2),m),linspace(1,size(rndim,1),n));
    d = interp2(rndim,Xq,Yq, 'cubic');
    im = im + a*d(1:n, 1:m);
    a = a*persistence;
    w = w/lacunarity;
end
im = (im - min(min(im(:,:)))) ./ (max(max(im(:,:))) - min(min(im(:,:))));
end