function [ TaskData ] = Task1( DataStruct )

try
    %% Preparation of movies
    
    % Load location
    movie(1).file = [ pwd filesep 'videos' filesep 'pathS_InOut.mov' ];
    movie(2).file = [ pwd filesep 'videos' filesep 'pathS_Rot.mov' ];
    
    % [ moviePtr [duration] [fps] [width] [height] [count] [aspectRatio]]=Screen('OpenMovie', windowPtr, moviefile [, async=0] [, preloadSecs=1] [, specialFlags1=0][, pixelFormat=4][, maxNumberThreads=-1][, movieOptions]);
    [ movie(1).Ptr movie(1).duration movie(1).fps movie(1).width movie(1).height movie(1).count movie(1).aspectRatio] = Screen( 'OpenMovie' , DataStruct.PTB.Window , movie(1).file );
    [ movie(2).Ptr movie(2).duration movie(2).fps movie(2).width movie(2).height movie(2).count movie(2).aspectRatio] = Screen( 'OpenMovie' , DataStruct.PTB.Window , movie(2).file );
    
    disp(movie(1))
    disp(' ')
    disp(movie(2))

    TaskData.movie = movie;
    
    %% Tunning of the task
    
    % Create and prepare
    header = {       'event_name' , 'onset(s)'    , 'duration(s)' ,    'movie_Prt' , 'movie_file'};
    EP     = EventPlanning(header);
    
    NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};
    
    % Define a planning <--- paradigme
    
    EP.AddPlanning({ 'StartTime'    0               0                  []            []            });
    
    EP.AddPlanning({ 'Fixation'     NextOnset(EP)   5                  []            []            });
    EP.AddPlanning({ 'InOut'        NextOnset(EP)   movie(1).duration  movie(1).Ptr  movie(1).file });
    EP.AddPlanning({ 'Fixation'     NextOnset(EP)   5                  []            []            });
    EP.AddPlanning({ 'Rotation'     NextOnset(EP)   movie(2).duration  movie(2).Ptr  movie(2).file });
    EP.AddPlanning({ 'Fixation'     NextOnset(EP)   5                  []            []            });
    
    EP.AddPlanning({ 'StopTime'     NextOnset(EP)   0                  []            []            });
    
    switch DataStruct.OperationMode
        case 'Acquisition'
            
            Speed = 1;
            
        case 'FastDebug'
            
            Speed = 5;
            
            new_onsets = cellfun( @(x) {x/Speed} , EP.Data(:,2) , 'UniformOutput' , true );
            EP.Data(:,2) = new_onsets;
            
            new_durations = cellfun( @(x) {x/Speed} , EP.Data(:,3) , 'UniformOutput' , true );
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
    
    PixelPerDegree = Task1.va2pix( 1 , DataStruct.Parameters.Video.SubjectDistance , DataStruct.Parameters.Video.ScreenWidthM , DataStruct.Parameters.Video.ScreenWidthPx );
    
    DotVisualAngle = 0.1;
    
    
    %% Prepare the logger of MRI triggers
    
    KbName('UnifyKeyNames');
    keys = {'5%'};
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
            
        otherwise
            
    end
    
    
    %% Synchronization
    
    StartTime = WaitForTTL( DataStruct );
    
    
    %% Go
    
    
    for evt = 1 : size( EP.Data , 1 )
        
        switch EP.Data{evt,1}
            
            case 'Fixation'
                
                Task1.DrawFixation( DataStruct.PTB.Window , DataStruct.PTB.Black , DataStruct.PTB.CenterH , DataStruct.PTB.CenterV , DotVisualAngle , PixelPerDegree )

                fixation_onset = Screen( 'Flip' , DataStruct.PTB.Window , StartTime + EP.Data{evt,2} - DataStruct.PTB.slack );
                
                ER.AddEvent({ 'Fixation' fixation_onset-StartTime })
                
                if evt < size( EP.Data , 1 )
                    WaitSecs('UntilTime', fixation_onset + EP.Data{evt,3} - DataStruct.PTB.slack );
                end
                
            case 'InOut'
                
                %                 WaitSecs('UntilTime', StartTime + EP.Data{evt,2} - DataStruct.PTB.slack );
                
                ER_movie1 = Task1.PlayMovieTrial( movie(1).Ptr , Speed , DataStruct , movie(1).count );
                
                ER.AddEvent({ 'InOut' ER_movie1.Data{1,2}-StartTime })
                
                ER_movie1.ScaleTime;
                
                ER_movie1.Data

                
            case 'Rotation'
                
                %                 WaitSecs('UntilTime', StartTime + EP.Data{evt,2} - DataStruct.PTB.slack );
                
                ER_movie2 = Task1.PlayMovieTrial( movie(2).Ptr , Speed , DataStruct , movie(2).count );
                
                ER.AddEvent({ 'Rotation' ER_movie2.Data{1,2}-StartTime })
                
                ER_movie1.ScaleTime;
                
                ER_movie1.Data

                
        end
        
    end
    
    % Stop time
    StopTime = GetSecs;
    
    % Record StopTime
    ER.AddStopTime( 'StopTime' , StopTime - StartTime );
    
    
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
    
    
catch err
    
    sca
    rethrow(err)
    
end

end
