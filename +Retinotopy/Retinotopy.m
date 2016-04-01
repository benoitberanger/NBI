function [ TaskData ] = Retinotopy( DataStruct )

try
    %%
    
    
    clc
    
%     Screen('FillRect',DataStruct.PTB.Window, DataStruct.Parameters.Video.ScreenBackgroundColor);
%     vbl = Screen('Flip',DataStruct.PTB.Window);
    
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
    %     da = da(1)
    
    r = linspace(innerLimit , screenYpx , alternance+1)';
    r(1) = [];
    dr = diff(r)/2;
    %     dr = dr(1)
    
    %     innerCircle = CenterRectOnPoint([0 0 innerLimit+dr innerLimit+dr],DataStruct.PTB.CenterH,DataStruct.PTB.CenterV);
    %     for osef = 2:length(r)
    %         innerCircle = vertcat( innerCircle , InsetRect(innerCircle(end,:),dr,dr) );
    %     end
    
    innerCircle = NaN(length(r),4);
    for osef = 1:length(r)
        innerCircle(osef,:) = CenterRectOnPoint([0 0 r(osef) r(osef)],DataStruct.PTB.CenterH,DataStruct.PTB.CenterV);
    end
    
    %     %     positionOfMainCircle = [0 0 100 100];
    %         positionOfMainCircle = CenterRectOnPoint([0 0 100 100],DataStruct.PTB.CenterH-100,DataStruct.PTB.CenterV-100);
    %
    %         Screen('FillRect',DataStruct.PTB.Window, [255 255 0 50],positionOfMainCircle)
    %
    %         for angle = 1 : length(r)
    %         Screen('FrameArc',DataStruct.PTB.Window, 255*rand(1,3),positionOfMainCircle + angle * 50,a(angle),r(angle),10);
    %         end
    %         Screen('DrawArc',DataStruct.PTB.Window, [255 0 0],positionOfMainCircle-10,45,-90 );
    
%     Screen('FillRect',DataStruct.PTB.Window, 255/2)
    
    bumper = 0;
    for angle = 1 : length(a)
        bumper = bumper + 1;
        for radius = 1 : length(r)
            bumper = bumper + 1;
            Screen('FrameArc',DataStruct.PTB.Window, 255*mod(bumper,2),innerCircle(radius,:),a(angle),da(1),dr(1));
        end
    end
    
%     WaitSecs(0.200);
    
    Screen('DrawingFinished', DataStruct.PTB.Window);
    
%     vbl = Screen('Flip',DataStruct.PTB.Window,[],1);
    flicImage=Screen('GetImage', DataStruct.PTB.Window,[],'backBuffer');
    
%     WaitSecs(0.200);
    
    figure; image(flicImage)
    
%     vbl = Screen('Flip',DataStruct.PTB.Window,[],1);
    
    flicTexture=Screen('MakeTexture', DataStruct.PTB.Window, flicImage);
    flacTexture=Screen('MakeTexture', DataStruct.PTB.Window, 255 - flicImage);
    
%     Screen('FillRect',DataStruct.PTB.Window, [255 255 255 128],CenterRectOnPoint([0 0 innerLimit innerLimit],DataStruct.PTB.CenterH,DataStruct.PTB.CenterV))
    
    %%
    
    flicflac = 0;
    
%     WaitSecs(0.4)
    
    vbl = Screen('Flip',DataStruct.PTB.Window);
    
    while ~KbCheck
        
        flicflac = flicflac + 1;
        
        switch mod(flicflac,2)
            case 0
                Screen('DrawTexture', DataStruct.PTB.Window,flicTexture)
            case 1
                Screen('DrawTexture', DataStruct.PTB.Window,flacTexture)
        end

        
        vbl = Screen('Flip',DataStruct.PTB.Window,vbl + 0.250 - DataStruct.PTB.slack);
        
        tic
        
    end
    
    disp
    
catch err %#ok<*NASGU>
    
    Common.Catch;
    
end

end
