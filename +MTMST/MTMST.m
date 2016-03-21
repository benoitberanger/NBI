function [ TaskData ] = MTMST( DataStruct )

try
    %% Parallel port
    
    Common.PrepareParPort;
    
    
    %% Tunning of the task
    
    switch DataStruct.Task
        case 'MTMST_Left'
            MTMST.PlanningLeft;
        case 'MTMST_Right'
            MTMST.PlanningRight;
        otherwise
            error( 'task error : %s' , DataStruct.Task )
    end
    
    
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
    DotColor = DataStruct.PTB.White;
    
    diameter = round( PixelPerDegree * DotVisualAngle );
    rectOval = [ 0 0 diameter diameter ];
    
    FixationDotCenter.Px = DotFieldCenter.Px*2 + FieldBorderToDot.Px;
    FixH = FixationDotCenter.Px;
    
    % -------------------------
    % Set dot field parameters
    % -------------------------
    
    DotSpeed.Deg        = 3;    % dot speed (deg/sec)
    DotFractionKill = 0.005; % fraction of dots to kill each frame (limited lifetime)
    
    NumberOfDots     = 200; % number of dots
    MaxiumRadius.Deg  = 7*sqrt(2);   % maximum radius of  annulus (degrees)
    MinimumRadius.Deg = 0.2;    % minumum
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
    
    
    %% Start recording eye motions
    
    Eyelink.StartRecording( DataStruct );
    
    
    %% Go
    
    flip_onset = 0;
    Exit_flag = 0;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        switch EP.Data{evt,1}
            
            case 'StartTime'
                
                % Draw fixation point
                MTMST.DrawFixation;
                
                Common.StartTimeEvent;
                
            case 'StopTime'
                
                Common.StopTimeEvent;
                
                
            otherwise
                
                frame = 0;
                
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
                    otherwise
                        mdir = mdirIN; % during Fixation, it will randomize the dot position
                end
                
                dr = PixelFrameSpeed * mdir;                % change in radius per frame (pixels)
                dxdy = [dr dr] .* cs;                       % change in x and y per frame (pixels)
                
                while flip_onset < StartTime + EP.Data{evt+1,2} - DataStruct.PTB.slack * 1
                    
                    % ESCAPE key pressed ?
                    Common.Interrupt;
                    
                    frame = frame + 1 ;
                    
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
                    
                    % Fixation dot                    
                    MTMST.DrawFixation;
                    
                    Screen('DrawingFinished', DataStruct.PTB.Window); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    
                    
                    xy = xy + dxdy;						% move dots
                    r = r + dr;							% update polar coordinates too
                    
                    % check to see which dots have gone beyond the borders of the annuli
                    
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
                    
                    
%                     % Parallel port message
%                     if strcmp( DataStruct.ParPort , 'On' )
%                         WriteParPort( current_message );
%                         WaitSecs( msg.duration );
%                         WriteParPort( 0 );
%                     end
                    
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