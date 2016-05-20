function [ TaskData ] = Retinotopy( DataStruct )

try
    %% Parallel port
    
    Common.PrepareParPort;
    
    
    
    %% Tunning of the task
    
    Retinotopy.Planning;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    Common.PrepareRecorders;
    
    
    %% Prepare dots/checkerboard
    
    % Dot
    PixelPerDegree = va2pix( 1 , DataStruct.Parameters.Video.SubjectDistance , DataStruct.Parameters.Video.ScreenWidthM , DataStruct.Parameters.Video.ScreenWidthPx );
    DotVisualAngle = 0.30;
    DotColor = [255 0 0];
    
    diameter = round( PixelPerDegree * DotVisualAngle );
    rectOval = [ 0 0 diameter diameter ];
    
    FixH = DataStruct.PTB.CenterH;
    FixV = DataStruct.PTB.CenterV;
    
    % Checkerboard
    Checkerboard.segements = 40; % angles
    Checkerboard.alternance = 24; % radius
    Checkerboard.innerLimit = PixelPerDegree*DotVisualAngle*1; % Pixel
    
    % Wedge
    Wedge.startAngle = 45; % Start angle at which we would like our mask to begin (degrees)
    Wedge.arcAngle = 315; % Length of the arc (degrees)
    
    Wedge.arcRect = CenterRectOnPoint([0 0 DataStruct.PTB.WindowRect(4)*1.1 DataStruct.PTB.WindowRect(4)*1.1],DataStruct.PTB.CenterH,DataStruct.PTB.CenterV); % The rect in which we will define our arc
    
    % flic flac
    Flic.Duration = DataStruct.PTB.IFI * 12;
    Flac.Duration = DataStruct.PTB.IFI * 3;
    
    Flic.flotFrames = Flic.Duration/DataStruct.PTB.IFI;
    Flac.flotFrames = Flac.Duration/DataStruct.PTB.IFI;
    Flic.Frames = round(Flic.flotFrames);
    Flac.Frames = round(Flac.flotFrames);
    
    fprintf('\n')
    fprintf('Flic.flotFrames = %g -> %d \n',Flic.flotFrames,Flic.Frames)
    fprintf('Flac.flotFrames = %g -> %d \n',Flac.flotFrames,Flac.Frames)
    
    
    %% Prepare coordinates
    
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
    Flic.Image(Flic.Image == 127) = 128;
    Flac.Image = 255 - Flic.Image;
    Flac.Image(Flac.Image == 127) = 128;
    
    %     figure; image(Flic.Image)
    
    Flic.Texture=Screen('MakeTexture', DataStruct.PTB.Window, Flic.Image);
    Flac.Texture=Screen('MakeTexture', DataStruct.PTB.Window, Flac.Image);
    
    
    %% Catch the point
    
    Catch.N            = 20; % how many catch trials ?
    Catch.nCatchFrame  = round( 0.100 / DataStruct.PTB.IFI ); % secondes / ifi = frames
    Catch.stimDuration = EP.Data{end,2}; % secondes
    % Catch trials onsets are lineary spaced over timen + a random value
    % defined in the interval [ min , max ]
    Catch.minrand      = 5;  % min value (secondes) for randomization of the onset
    Catch.maxrand      = 15; % max value (secondes) for randomization of the onset
    
    Common.GenerateCatchFrameNumber
    
    
    %% Start recording eye motions
    
    Eyelink.StartRecording( DataStruct );
    
    
    %% Go
    
    flip_onset = 0;
    Exit_flag = 0;
    total_frame = 0;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay;
        
        switch EP.Data{evt,1}
            
            case 'StartTime'
                
                Screen('FillRect',DataStruct.PTB.Window,DataStruct.Parameters.Video.ScreenBackgroundColor);
                
                % Draw fixation point
                MTMST.DrawFixation;
                
                Common.StartTimeEvent;
                
            case 'StopTime'
                
                Common.StopTimeEvent;
                
                
            otherwise
                
                frame = 0;
                fix_counter = 0;
                
                while flip_onset < StartTime + EP.Data{evt+1,2} - DataStruct.PTB.slack * 1
                    
                    % ESCAPE key pressed ?
                    Common.Interrupt;
                    
                    total_frame = total_frame + 1;
                    frame = frame  + 1 ;
                    pp = 0;
                    
                    if frame > Flic.Frames
                        
                        if mod(frame,Flic.Frames + Flac.Frames) < Flac.Frames
                            Screen('DrawTexture', DataStruct.PTB.Window,Flac.Texture)
                            pp = pp + msg.flac;
                        else
                            Screen('DrawTexture', DataStruct.PTB.Window,Flic.Texture)
                            pp = pp + msg.flic;
                        end
                        
                    else
                        Screen('DrawTexture', DataStruct.PTB.Window,Flic.Texture)
                        pp = pp + msg.flic;
                    end
                    
                    % Draw our mask
                    Screen('FillArc', DataStruct.PTB.Window, DataStruct.Parameters.Video.ScreenBackgroundColor, Wedge.arcRect, Wedge.startAngle, Wedge.arcAngle)
                    
                    % Draw fixation point
                    if fix_counter == 0
                        if any( total_frame == Catch.frame )
                            fix_counter = Catch.nCatchFrame;
                            Common.CATCHecho;
                        else
                            MTMST.DrawFixation;
                        end
                    end
                    
                    % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    Screen('DrawingFinished', DataStruct.PTB.Window);
                    
                    % Flip
                    flip_onset = Screen('Flip',DataStruct.PTB.Window);
                    
                    % Flash
                    if fix_counter > 0
                        if fix_counter == Catch.nCatchFrame
                            RR.AddEvent( { 'Catch' flip_onset-StartTime DataStruct.PTB.IFI*Catch.nCatchFrame } );
                        end
                        pp = pp + msg.flash;
                        fix_counter = fix_counter - 1;
                    end
                    
                    % Clic
                    if keyCode(DataStruct.Parameters.Keybinds.Right_Blue_1_ASCII)
                        RR.AddEvent( { 'Click' flip_onset-StartTime DataStruct.PTB.IFI } );
                        pp = pp + msg.clic;
                        Common.CLICKecho;
                    end
                    
                    if frame == 1
                        
                        % Save onset
                        ER.AddEvent({ EP.Data{evt,1} flip_onset-StartTime })
                        
                    end
                    
                    % Increment the start angle of the mask
                    switch EP.Data{evt,4}
                        case 'cw'
                            Wedge.startAngle = Wedge.startAngle + EP.Data{evt,5}* DataStruct.PTB.IFI * Speed;
                            pp = pp + msg.cw;
                        case 'ccw'
                            Wedge.startAngle = Wedge.startAngle - EP.Data{evt,5}* DataStruct.PTB.IFI * Speed;
                            pp = pp + msg.ccw;
                    end
                    
                    Common.SendParPortMessage
                    
                end % while
                
                
        end % switch
        
        if Exit_flag
            break %#ok<*UNRCH>
        end
        
        
    end % for
    
    %% End of stimulation
    
    Common.EndOfStimulationScript;
    
    
catch err %#ok<*NASGU>
    
    Common.Catch;
    
end

end
