function [ TaskData ] = Retinotopy( DataStruct )

try
    %%
    
    
    clc
    
    if exist('flicTexture','var')
        Screen('Close', flicTexture);
    end
    if exist('flacTexture','var')
        Screen('Close', flacTexture);
    end
    
    screenYpx = 768;
    
    segements = 24;
    alternance = 8;
    
    innerLimit = 50;
    
    a = linspace(0 , 360*( 1 - (1/segements)) , segements)';
    da = diff(a);
    
%     r = linspace(innerLimit , screenYpx , alternance+1)';
    r = logspace(log10(innerLimit), log10(screenYpx) , alternance+1)';
    
    dr = diff(r)/2;
    r(1) = [];
    
    %%
    innerCircle = NaN(length(r),4);
    for osef = 1:length(r)
        innerCircle(osef,:) = CenterRectOnPoint([0 0 r(osef) r(osef)],DataStruct.PTB.CenterH,DataStruct.PTB.CenterV);
    end
    
    
    bumper = 0;
    for angle = 1 : length(a)
        bumper = bumper + 1;
        for radius = 1 : length(r)
            bumper = bumper + 1;
            Screen('FrameArc',DataStruct.PTB.Window, 255*mod(bumper,2),innerCircle(radius,:),a(angle),da(1),dr(radius));
        end
    end
    
    Screen('DrawingFinished', DataStruct.PTB.Window);
    
    flicImage=Screen('GetImage', DataStruct.PTB.Window,[],'backBuffer');
    %     figure; image(flicImage)
    
    flicTexture=Screen('MakeTexture', DataStruct.PTB.Window, flicImage);
    flacTexture=Screen('MakeTexture', DataStruct.PTB.Window, 255 - flicImage);
    
    %     Screen('FillRect',DataStruct.PTB.Window, [255 255 255 128],CenterRectOnPoint([0 0 innerLimit innerLimit],DataStruct.PTB.CenterH,DataStruct.PTB.CenterV))
    
    %%
    
    % Start angle at which we would like our mask to begin (degrees)
    startAngle = 0;
    
    % Length of the arc (degrees)
    arcAngle = 270;
    
    
    % Rate at which our mask will rotate
    degPerSec = 20;
    degPerFrame = degPerSec * DataStruct.PTB.IFI;
    
    % The rect in which we will define our arc
    arcRect = CenterRectOnPoint([0 0 screenYpx*1.1 screenYpx*1.1],DataStruct.PTB.CenterH,DataStruct.PTB.CenterV);
    
    %% flic flac
    
    flicDuration = 1.000;
    flacDuration = 0.100;
    ifi = DataStruct.PTB.IFI;
    
    flicFrames = round(flicDuration/ifi);
    flacFrames = round(flacDuration/ifi);
    
    
    %%
    
    
    frame_counter = 0;
    
    %     Screen('DrawTexture', DataStruct.PTB.Window,flicTexture)
    
    while ~KbCheck
        
        frame_counter = frame_counter  + 1 ;
        
        
        if frame_counter > flicFrames
            
            if mod(frame_counter,flicFrames + flacFrames) < flacFrames
                Screen('DrawTexture', DataStruct.PTB.Window,flacTexture)
            else
                Screen('DrawTexture', DataStruct.PTB.Window,flicTexture)
            end
            
        else
            Screen('DrawTexture', DataStruct.PTB.Window,flicTexture)
        end
        
        % Draw our mask
        Screen('FillArc', DataStruct.PTB.Window, DataStruct.Parameters.Video.ScreenBackgroundColor, arcRect, startAngle, arcAngle)
        
        VBL = Screen('Flip',DataStruct.PTB.Window);
        
        
        % Increment the start angle of the mask
        startAngle = startAngle + degPerFrame;
        
        tic
        
    end
    
    disp
    
catch err %#ok<*NASGU>
    
    Common.Catch;
    
end

end
