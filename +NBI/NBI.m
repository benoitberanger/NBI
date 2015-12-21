function [ TaskData ] = NBI( DataStruct )

try
    %% Preparation of movies
    
    % Preallocation ?
    movie = struct;
    
    % Load location
    movie(1).file = [ pwd filesep 'videos' filesep 'pathS_InOut.mov'          ];
    movie(2).file = [ pwd filesep 'videos' filesep 'pathS_Rot.mov'            ];
    movie(3).file = [ pwd filesep 'videos' filesep 'control2_pathS_InOut.mov' ];
    movie(4).file = [ pwd filesep 'videos' filesep 'control2_pathS_Rot.mov'   ];
    
    for m = 1 : length(movie)
        
        % [ moviePtr [duration] [fps] [width] [height] [count] [aspectRatio]]=Screen('OpenMovie', windowPtr, moviefile [, async=0] [, preloadSecs=1] [, specialFlags1=0][, pixelFormat=4][, maxNumberThreads=-1][, movieOptions]);
        [ movie(m).Ptr movie(m).duration movie(m).fps movie(m).width movie(m).height movie(m).count movie(m).aspectRatio ] = Screen( 'OpenMovie' , DataStruct.PTB.Window , movie(m).file );
        
        disp( movie(m) )
        disp(' ')
        
    end
    
    TaskData.movie = movie;
    
    
    %% Tunning of the task
    
    % Create and prepare
    header = {       'event_name' ,          'onset(s)' ,   'duration(s)' ,    'movie_Prt' , 'movie_file'};
    EP     = EventPlanning(header);
    
    % NextOnset = PreviousOnset + PreviousDuration
    NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};
    
    % Define a planning <--- paradigme
    
    EP.AddPlanning({ 'StartTime'             0              0                  []            []            });
    
    EP.AddPlanning({ 'Fixation'              NextOnset(EP)  5                  []            []            });
    
    % --- Bloc ------------------------------------------------------------
    
    % Condition 1 + Fixation
    EP.AddPlanning({ 'pathS_InOut'           NextOnset(EP)  movie(1).duration  movie(1).Ptr  movie(1).file });
    EP.AddPlanning({ 'Fixation'              NextOnset(EP)  5                  []            []            });
    
    % Condition 2 + Fixation
    EP.AddPlanning({ 'pathS_Rot'             NextOnset(EP)  movie(2).duration  movie(2).Ptr  movie(2).file });
    EP.AddPlanning({ 'Fixation'              NextOnset(EP)  5                  []            []            });
    
    % Condition 3 + Fixation
    EP.AddPlanning({ 'control2_pathS_InOut'  NextOnset(EP)  movie(3).duration  movie(3).Ptr  movie(3).file });
    EP.AddPlanning({ 'Fixation'              NextOnset(EP)  5                  []            []            });
    
    % Condition 4 + Fixation
    EP.AddPlanning({ 'control2_pathS_Rot'    NextOnset(EP)  movie(4).duration  movie(4).Ptr  movie(4).file });
    EP.AddPlanning({ 'Fixation'              NextOnset(EP)  5                  []            []            });
    
    % ---------------------------------------------------------------------
    
    EP.AddPlanning({ 'StopTime'              NextOnset(EP)  0                  []            []            });
    
    switch DataStruct.OperationMode
        case 'Acquisition'
            
            Speed = 1;
            
        case 'FastDebug'
            
            Speed = 10;
            
            new_onsets = cellfun( @(x) {x/Speed} , EP.Data(:,2) );
            EP.Data(:,2) = new_onsets;
            
            new_durations = cellfun( @(x) {x/Speed} , EP.Data(:,3) );
            EP.Data(:,3) = new_durations;
            
        case 'RealisticDebug'
            
            Speed = 1;
            
        otherwise
            error( 'DataStruct.OperationMode = %s' , DataStruct.OperationMode )
    end
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record
    
    % Create
    ER = EventRecorder( header(1:2) , size(EP.Data,1) );
    
    % Prepare
    ER.AddStartTime( 'StartTime' , 0 );
    
    
    %% Prepare fixation dot
    
    PixelPerDegree = NBI.va2pix( 1 , DataStruct.Parameters.Video.SubjectDistance , DataStruct.Parameters.Video.ScreenWidthM , DataStruct.Parameters.Video.ScreenWidthPx );
    
    DotVisualAngle = 0.1;
    
    
    %% Prepare the logger of MRI triggers
    
    KbName('UnifyKeyNames');
    keys = {'5%'}; % fORP in USB : MRI trigger are converted into keyboard input
    KL = KbLogger(KbName(keys) , keys);
    
    switch DataStruct.OperationMode
        
        case 'Acquisition'
            
            % Start recording events
            KL.Start;
            
        case 'FastDebug'
            
            TR = 0.950; % seconds
            nbVolumes = ceil( EP.Data{end,2} / TR ) + 2 ; % nb of volumes for the estimated time of stimulation + 2 to be safe
            KL.GenerateMRITrigger( TR , nbVolumes );
            
        case 'RealisticDebug'
            
            TR = 0.950; % seconds
            nbVolumes = ceil( EP.Data{end,2} / TR ) + 2 ; % nb of volumes for the estimated time of stimulation + 2 to be safe
            KL.GenerateMRITrigger( TR , nbVolumes );
            
    end
    
    %% Start recording eye motions
    
    TaskData.EyelinkFile = Eyelink.StartRecording( DataStruct );
    
    
    %% Go
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        switch EP.Data{evt,1}
            
            case 'StartTime'
                
                % Draw fixation point
                NBI.DrawFixation( DataStruct.PTB.Window , DataStruct.PTB.Black , DataStruct.PTB.CenterH , DataStruct.PTB.CenterV , DotVisualAngle , PixelPerDegree )
                
                % Flip video
                Screen( 'Flip' , DataStruct.PTB.Window );
                
                % Synchronization
                StartTime = WaitForTTL( DataStruct );
                
                
            case 'Fixation'
                
                % Draw fixation point
                NBI.DrawFixation( DataStruct.PTB.Window , DataStruct.PTB.Black , DataStruct.PTB.CenterH , DataStruct.PTB.CenterV , DotVisualAngle , PixelPerDegree )
                
                % Flip video
                fixation_onset = Screen( 'Flip' , DataStruct.PTB.Window , StartTime + EP.Data{evt,2} - DataStruct.PTB.slack );
                
                % Save onset
                ER.AddEvent({ 'Fixation' fixation_onset-StartTime })
                
                % Fixation duration handeling
                WaitSecs('UntilTime', StartTime + EP.Data{evt+1,2} - DataStruct.PTB.slack*0 );
                
                
            case 'StopTime'
                
                % Stop time
                StopTime = GetSecs;
                
                % Record StopTime
                ER.AddStopTime( 'StopTime' , StopTime - StartTime );
                
                
            otherwise % == movie
                
                % Which condition ?
                switch EP.Data{evt,1}
                    
                    case 'pathS_InOut'
                        movie_ref = 1;
                        
                    case 'pathS_Rot'
                        movie_ref = 2;
                        
                    case 'control2_pathS_InOut'
                        movie_ref = 3;
                        
                    case 'control2_pathS_Rot'
                        movie_ref = 4;
                        
                end
                
                if Speed ~= 1
                    DeadLine = EP.Data{evt,3};
                else
                    DeadLine = Inf;
                end
                
                % Play movie
                [ First_frame , Last_frame , Subject_inputtime , Exit_flag ] = NBI.PlayMovieTrial( movie(movie_ref) , DataStruct , DeadLine ); %#ok<ASGLU>
                
                % Save onset
                ER.AddEvent({ EP.Data{evt,1} First_frame-StartTime })
                
                if Exit_flag
                    
                    % Stop time
                    StopTime = GetSecs;
                    
                    % Record StopTime
                    ER.AddStopTime( 'StopTime' , StopTime - StartTime );
                    
                    break
                    
                end
                
        end
        
        
    end
    
    
    %% End of stimulation
    
    % EventRecorder
    ER.ClearEmptyEvents;
    ER.BuildGraph;
    TaskData.ER = ER;
    
    % KbLogger
    switch DataStruct.OperationMode
        
        case 'Acquisition'
            
            % Stop recording events
            KL.Stop;
            
        case 'FastDebug'
            
        case 'RealisticDebug'
            
        otherwise
            
    end
    KL.ScaleTime;
    KL.ComputeDurations;
    KL.BuildGraph;
    TaskData.KL = KL;
    
    % Save some values
    TaskData.Speed          = Speed;
    TaskData.PixelPerDegree = PixelPerDegree;
    TaskData.DotVisualAngle = DotVisualAngle;
    TaskData.StartTime      = StartTime;
    TaskData.StopTime       = StopTime;
    
    
    %% Send infos to base workspace
    
    assignin('base','EP',EP)
    assignin('base','ER',ER)
    assignin('base','KL',KL)
    
    assignin('base','TaskData',TaskData)
    
    
    %% Close all movies
    
    for m = 1 : length(movie)
        Screen('CloseMovie', movie(m).Ptr );
    end
    
    
catch err
    
    sca
    rethrow(err)
    
end

end
