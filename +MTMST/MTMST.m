function [ TaskData ] = MTMST( DataStruct )

try
    %% Parallel port
    
    Common.PrepareParPort;
    
    
    %% Tunning of the task
    
    MTMST.Planning;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    Common.PrepareRecorders;
    
    
    %% Prepare dots
    
    FixV = DataStruct.PTB.CenterV;
    PixelPerDegree = va2pix( 1 , DataStruct.Parameters.Video.SubjectDistance , DataStruct.Parameters.Video.ScreenWidthM , DataStruct.Parameters.Video.ScreenWidthPx );
    
    FieldBorderToDot.Deg = 10;
    FieldBorderToDot.Px = FieldBorderToDot.Deg * PixelPerDegree;
    
    FixationDotOffcet.Deg = 1;
    FixationDotOffcet.Px = FixationDotOffcet.Deg * PixelPerDegree;
    
    DotFieldCenter.Px = (DataStruct.Parameters.Video.ScreenWidthPx -FixationDotOffcet.Px - FieldBorderToDot.Px)/2;
    
    MaskRect = [ DotFieldCenter.Px*2 DataStruct.PTB.WindowRect(2) DataStruct.PTB.WindowRect(3) DataStruct.PTB.WindowRect(4) ];
    
    % -----------------
    % Set fixation dot
    % -----------------
    
    DotVisualAngle = 0.15;
    DotColor = [255 0 0];
    
    diameter = round( PixelPerDegree * DotVisualAngle );
    rectOval = [ 0 0 diameter diameter ];
    
    FixationDotCenter.Px = DotFieldCenter.Px*2 + FieldBorderToDot.Px;
    
    % Initialize fixation point position
    switch DataStruct.Task
        case 'MTMST_Right'
            FixH = DataStruct.Parameters.Video.ScreenWidthPx - FixationDotCenter.Px;
        case 'MTMST_Left'
            FixH = FixationDotCenter.Px;
    end
    
    % -------------------------
    % Set dot field parameters
    % -------------------------
    
    DotSpeed.Deg          = 3;    % dot speed (deg/sec)
    DotFractionKill_InOut = 0.005; % fraction of dots to kill each frame (limited lifetime)
    DotFractionKill_Fix   = 0; % fraction of dots to kill each frame (limited lifetime)
    
    NumberOfDots      = 500; % number of dots
    MaxiumRadius.Deg  = 7*sqrt(2);   % maximum radius of  annulus (degrees)
    MinimumRadius.Deg = 0.1;    % minumum
    DotSize.Deg       = 0.1;  % width of dot (deg)
    
    
    % -----------------------------------------
    % Transform each visual angles into pixels
    % -----------------------------------------
    
    
    PixelFrameSpeed = DotSpeed.Deg * PixelPerDegree / DataStruct.PTB.FPS;                            % dot speed (pixels/frame)
    DotSize.Px = DotSize.Deg * PixelPerDegree;                                        % dot size (pixels)
    
    MaxiumRadius.Px  = MaxiumRadius.Deg  * PixelPerDegree; % maximum radius of annulus (pixels from center)
    MinimumRadius.Px = MinimumRadius.Deg * PixelPerDegree; % minimum
    
    % Positive or negative speed ?
    mdirIN  = -ones(NumberOfDots,1);
    mdirOUT = -mdirIN;
    mdirFIXATAION = zeros(NumberOfDots,1);
    
    
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
                
                % Draw fixation point
                MTMST.DrawFixation;
                
                Common.StartTimeEvent;
                
            case 'StopTime'
                
                Common.StopTimeEvent;
                
            otherwise
                
                frame = 0;
                fix_counter = 0;
                
                % New set of points at each IN/OUT trial
                r = MaxiumRadius.Px * sqrt(rand(NumberOfDots,1));	% r
                r(r<MinimumRadius.Px) = MinimumRadius.Px;
                t = 2*pi*rand(NumberOfDots,1);                     % theta polar coordinate
                cs = [cos(t), sin(t)];
                xy = [r r] .* cs;   % dot positions in Cartesian coordinates (pixels from center)
                xymatrix = transpose(xy);
                
                switch EP.Data{evt,7}
                    case 'in'
                        mdir = mdirIN;
                    case 'out'
                        mdir = mdirOUT;
                    case 'fixation'
                        mdir = mdirFIXATAION;
                end
                
                dr = PixelFrameSpeed * mdir;                % change in radius per frame (pixels)
                dxdy = [dr dr] .* cs;                       % change in x and y per frame (pixels)
                
                while flip_onset < StartTime + EP.Data{evt+1,2} - DataStruct.PTB.slack * 1
                    
                    % ESCAPE key pressed ?
                    Common.Interrupt;
                    
                    total_frame = total_frame + 1;
                    frame = frame + 1 ;
                    pp = 0;
                    
                    % Left ?
                    if EP.Data{evt,4}
                        Screen('DrawDots', DataStruct.PTB.Window, xymatrix, DotSize.Px, DataStruct.PTB.White , [DotFieldCenter.Px DataStruct.PTB.CenterV],1);  % change 1 to 0 to draw square dots
                        Screen('FillRect', DataStruct.PTB.Window , DataStruct.PTB.Black , MaskRect )
                        FixH = FixationDotCenter.Px;
                    end
                    % Center ?
                    if EP.Data{evt,5}
                        Screen('DrawDots', DataStruct.PTB.Window, xymatrix, DotSize.Px, DataStruct.PTB.White , [DataStruct.PTB.CenterH DataStruct.PTB.CenterV],1);  % change 1 to 0 to draw square dots
                        FixH = DataStruct.PTB.CenterH;
                    end
                    % Right ?
                    if EP.Data{evt,6}
                        Screen('DrawDots', DataStruct.PTB.Window, xymatrix, DotSize.Px, DataStruct.PTB.White , [DataStruct.Parameters.Video.ScreenWidthPx-DotFieldCenter.Px DataStruct.PTB.CenterV],1);  % change 1 to 0 to draw square dots
                        Screen('FillRect', DataStruct.PTB.Window , DataStruct.PTB.Black , MaskRect - [ DotFieldCenter.Px*2 0 DotFieldCenter.Px*2 0 ] )
                        FixH = DataStruct.Parameters.Video.ScreenWidthPx - FixationDotCenter.Px;
                    end
                    
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
                    
                    
                    xy = xy + dxdy;						% move dots
                    r = r + dr;							% update polar coordinates too
                    
                    % check to see which dots have gone beyond the borders of the annuli
                    
                    % DotFractionKill depends on the condition
                    switch EP.Data{evt,7}
                        case 'in'
                            DotFractionKill = DotFractionKill_InOut;
                            pp = pp + msg.in;
                        case 'out'
                            DotFractionKill = DotFractionKill_InOut;
                            pp = pp + msg.out;
                        case 'fixation'
                            DotFractionKill = DotFractionKill_Fix;
                            pp = pp + msg.fixation;
                    end
                    
                    r_out = find(r > MaxiumRadius.Px | r < MinimumRadius.Px | rand(NumberOfDots,1) < DotFractionKill);	% dots to reposition
                    nout = length(r_out);
                    
                    if nout
                        
                        % choose new coordinates
                        
                        r(r_out) = MaxiumRadius.Px * sqrt(rand(nout,1));
                        r(r<MinimumRadius.Px) = MinimumRadius.Px;
                        t(r_out) = 2*pi*(rand(nout,1));
                        
                        % now convert the polar coordinates to Cartesian
                        
                        cs(r_out,:) = [cos(t(r_out)), sin(t(r_out))];
                        xy(r_out,:) = [r(r_out) r(r_out)] .* cs(r_out,:);
                        
                        % compute the new cartesian velocities
                        
                        dxdy(r_out,:) = [dr(r_out) dr(r_out)] .* cs(r_out,:);
                    end;
                    xymatrix = transpose(xy);
                    
                    flip_onset = Screen('Flip', DataStruct.PTB.Window);
                    
                    % Flash
                    if fix_counter > 0
                        RR.AddEvent( { 'Flash' flip_onset-StartTime } );
                        pp = pp + msg.flash;
                        fix_counter = fix_counter - 1;
                    end
                    
                    % Clic
                    if keyCode(DataStruct.Parameters.Keybinds.Right_Blue_1_ASCII)
                        RR.AddEvent( { 'Clic' flip_onset-StartTime } );
                        pp = pp + msg.clic;
                        Common.CLICKecho;
                    end
                    
                    Common.SendParPortMessage
                    
                    if frame == 1
                        
                        % Save onset
                        ER.AddEvent({ EP.Data{evt,1} flip_onset-StartTime })
                        
                    end
                    
                end
                
                
                
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
