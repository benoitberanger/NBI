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
    
    PixelPerDegree = va2pix( 1 , DataStruct.Parameters.Video.SubjectDistance , DataStruct.Parameters.Video.ScreenWidthM , DataStruct.Parameters.Video.ScreenWidthPx );
    
    % -----------------
    % Set fixation dot
    % -----------------
    
    DotVisualAngle = 0.15;
    DotColor = DataStruct.PTB.White;
    
    diameter = round( PixelPerDegree * DotVisualAngle );
    rectOval = [ 0 0 diameter diameter ];
    
    
    % -------------------------
    % Set dot field parameters
    % -------------------------
    
    DotSpeed        = 3;    % dot speed (deg/sec)
    DotFractionKill = 0.001; % fraction of dots to kill each frame (limited lifetime)
    
    NumberOfDots     = 50; % number of dots
    MaxiumRadiusDeg  = 3;   % maximum radius of  annulus (degrees)
    MinimumRadiusDeg = 0.2;    % minumum
    DotSizeDeg       = 0.1;  % width of dot (deg)
    
    LRoffcetDeg = 5;
    
    % -----------------------------------------
    % Transform each visual angles into pixels
    % -----------------------------------------
    
    LRoffcetPx = LRoffcetDeg*PixelPerDegree;
    
    PixelFrameSpeed = DotSpeed * PixelPerDegree / DataStruct.PTB.FPS;                            % dot speed (pixels/frame)
    DotSizePx = DotSizeDeg * PixelPerDegree;                                        % dot size (pixels)
    
    MaxiumRadiusPx  = MaxiumRadiusDeg  * PixelPerDegree; % maximum radius of annulus (pixels from center)
    MinimumRadiusPx = MinimumRadiusDeg * PixelPerDegree; % minimum
    
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
                Common.DrawFixation;
                
                Common.StartTimeEvent;
                
            case 'StopTime'
                
                Common.StopTimeEvent;
                
                
            otherwise
                
                frame = 0;
                
                % New set of points at each IN/OUT trial
                r = MaxiumRadiusPx * sqrt(rand(NumberOfDots,1));	% r
                r(r<MinimumRadiusPx) = MinimumRadiusPx;
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
                    
                    % Fixation dot                    
                    Common.DrawFixation;
                    
                    % Left ?
                    if EP.Data{evt,4}
                        Screen('DrawDots', DataStruct.PTB.Window, xymatrix, DotSizePx, DataStruct.PTB.White , [DataStruct.PTB.CenterH-LRoffcetPx DataStruct.PTB.CenterV],1);  % change 1 to 0 to draw square dots
                    end
                    % Center ?
                    if EP.Data{evt,5}
                        Screen('DrawDots', DataStruct.PTB.Window, xymatrix, DotSizePx, DataStruct.PTB.White , [DataStruct.PTB.CenterH DataStruct.PTB.CenterV],1);  % change 1 to 0 to draw square dots
                    end
                    % Right ?
                    if EP.Data{evt,6}
                        Screen('DrawDots', DataStruct.PTB.Window, xymatrix, DotSizePx, DataStruct.PTB.White , [DataStruct.PTB.CenterH+LRoffcetPx DataStruct.PTB.CenterV],1);  % change 1 to 0 to draw square dots
                    end
                    
                    Screen('DrawingFinished', DataStruct.PTB.Window); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    
                    
                    xy = xy + dxdy;						% move dots
                    r = r + dr;							% update polar coordinates too
                    
                    % check to see which dots have gone beyond the borders of the annuli
                    
                    r_out = find(r > MaxiumRadiusPx | r < MinimumRadiusPx | rand(NumberOfDots,1) < DotFractionKill);	% dots to reposition
                    nout = length(r_out);
                    
                    if nout
                        
                        % choose new coordinates
                        
                        r(r_out) = MaxiumRadiusPx * sqrt(rand(nout,1));
                        r(r<MinimumRadiusPx) = MinimumRadiusPx;
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
