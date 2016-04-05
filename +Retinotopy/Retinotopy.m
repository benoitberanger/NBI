function [ TaskData ] = Retinotopy( DataStruct )

try
    %% Parallel port
    
    Common.PrepareParPort;
    
    
    
    %% Tunning of the task
    
%     Retinotopy.Planning;
%     
%     % End of preparations
%     EP.BuildGraph;
%     TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
%     Common.PrepareRecorders;

    
    %% Prepare dots/checkerboard
    
    % Dot
    PixelPerDegree = va2pix( 1 , DataStruct.Parameters.Video.SubjectDistance , DataStruct.Parameters.Video.ScreenWidthM , DataStruct.Parameters.Video.ScreenWidthPx );
    
    % Checkerboard
    Checkerboard.segements = 24;
    Checkerboard.alternance = 8;
    Checkerboard.innerLimit = 50; % Pixel
    
    % Wedge
    Wedge.startAngle = 90; % Start angle at which we would like our mask to begin (degrees)
    Wedge.arcAngle = 270; % Length of the arc (degrees)
    Wedge.degPerSec = 20; % Rate at which our mask will rotate
    
    Wedge.degPerFrame = Wedge.degPerSec * DataStruct.PTB.IFI;
    Wedge.arcRect = CenterRectOnPoint([0 0 DataStruct.PTB.WindowRect(4)*1.1 DataStruct.PTB.WindowRect(4)*1.1],DataStruct.PTB.CenterH,DataStruct.PTB.CenterV); % The rect in which we will define our arc
    
    
    %% flic flac
    
    Flic.Duration = 0.750;
    Flac.Duration = 0.150;
    
    Flic.Frames = round(Flic.Duration/DataStruct.PTB.IFI);
    Flac.Frames = round(Flac.Duration/DataStruct.PTB.IFI);
    
    
    %%
    
    if exist('flic.Texture','var')
        Screen('Close', Flic.Texture);
    end
    if exist('flac.Texture','var')
        Screen('Close', Flac.Texture);
    end
    
    a = linspace(0 , 360*( 1 - (1/Checkerboard.segements)) , Checkerboard.segements)';
    da = diff(a);
    
    %     r = linspace(Checkerboard.innerLimit , DataStruct.PTB.WindowRect(4) , Checkerboard.alternance+1)';
    r = logspace(log10(Checkerboard.innerLimit), log10(DataStruct.PTB.WindowRect(4)) , Checkerboard.alternance+1)';
    
    dr = diff(r)/2;
    r(1) = [];
    
    
    %% Create the checkerboard
    
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
    
    Flic.Image=Screen('GetImage', DataStruct.PTB.Window,[],'backBuffer');
    %     figure; image(Flic.Image)
    
    Flic.Texture=Screen('MakeTexture', DataStruct.PTB.Window, Flic.Image);
    Flac.Texture=Screen('MakeTexture', DataStruct.PTB.Window, 255 - Flic.Image);
    
    
    
    %% Start recording eye motions
    
    Eyelink.StartRecording( DataStruct );
    
    
    %% Go
    
%     % Loop over the EventPlanning
%     for evt = 1 : size( EP.Data , 1 )
%         
%         switch EP.Data{evt,1}
%             
%             case 'StartTime'
%                 
%                 % Draw fixation point
%                 MTMST.DrawFixation;
%                 
%                 Common.StartTimeEvent;
%                 
%             case 'StopTime'
%                 
%                 Common.StopTimeEvent;
%                 
%                 
%             otherwise
                
                frame_counter = 0;
                
                while ~KbCheck
                    
                    frame_counter = frame_counter  + 1 ;
                    
                    
                    if frame_counter > Flic.Frames
                        
                        if mod(frame_counter,Flic.Frames + Flac.Frames) < Flac.Frames
                            Screen('DrawTexture', DataStruct.PTB.Window,Flac.Texture)
                        else
                            Screen('DrawTexture', DataStruct.PTB.Window,Flic.Texture)
                        end
                        
                    else
                        Screen('DrawTexture', DataStruct.PTB.Window,Flic.Texture)
                    end
                    
                    % Draw our mask
                    Screen('FillArc', DataStruct.PTB.Window, DataStruct.Parameters.Video.ScreenBackgroundColor, Wedge.arcRect, Wedge.startAngle, Wedge.arcAngle)
                    
                    VBL = Screen('Flip',DataStruct.PTB.Window);
                    
                    
                    % Increment the start angle of the mask
                    Wedge.startAngle = Wedge.startAngle + Wedge.degPerFrame;
                    
                    
                end % while
                
                
%         end % switch
%         
%         %         if Exit_flag
%         %             break %#ok<*UNRCH>
%         %         end
%         
%         
%     end % for
    
    %% End of stimulation
    
%     Common.EndOfStimulationScript;
    

catch err %#ok<*NASGU>
    
    Common.Catch;
    
end

end
