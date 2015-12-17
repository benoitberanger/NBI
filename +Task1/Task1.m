function [ TaskData ] = Task1( DataStruct )

try
    %% Preparation of movies
    
    % Preallocation ?
    movie = struct;
    
    % Load location
    movie(1).file = [ pwd filesep 'videos' filesep 'pathS_InOut.mov' ];
    movie(2).file = [ pwd filesep 'videos' filesep 'pathS_Rot.mov' ];
    
    for m = 1 : length(movie)
        
        % [ moviePtr [duration] [fps] [width] [height] [count] [aspectRatio]]=Screen('OpenMovie', windowPtr, moviefile [, async=0] [, preloadSecs=1] [, specialFlags1=0][, pixelFormat=4][, maxNumberThreads=-1][, movieOptions]);
        [ movie(m).Ptr movie(m).duration movie(m).fps movie(m).width movie(m).height movie(m).count movie(m).aspectRatio ] = Screen( 'OpenMovie' , DataStruct.PTB.Window , movie(m).file );
        
        disp( movie(m) )
        disp(' ')
        
    end
    
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
    EP.AddPlanning({ 'InOut'        NextOnset(EP)   movie(1).duration  movie(1).Ptr  movie(1).file });
    EP.AddPlanning({ 'Fixation'     NextOnset(EP)   5                  []            []            });
    EP.AddPlanning({ 'Rotation'     NextOnset(EP)   movie(2).duration  movie(2).Ptr  movie(2).file });
    EP.AddPlanning({ 'Fixation'     NextOnset(EP)   5                  []            []            });
    
    EP.AddPlanning({ 'InOut'        NextOnset(EP)   movie(1).duration  movie(1).Ptr  movie(1).file });
    EP.AddPlanning({ 'Fixation'     NextOnset(EP)   5                  []            []            });
    EP.AddPlanning({ 'Rotation'     NextOnset(EP)   movie(2).duration  movie(2).Ptr  movie(2).file });
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
    
    %% Prepare a structure to handle each movie event recorder
    
    % Preallocation of each ER is necessary to avoid pointers to refer on
    % a single object.
    
%     ER_movieStruct = struct;
%     
%     for ev = 1 : size( EP.Data , 1 )
%         
%         ER_movieStruct(ev).ER = EventRecorder( header(1:2) , max([movie.count]) );
%         
%     end
    
            
    %% Synchronization
    
    StartTime = WaitForTTL( DataStruct );
    
    
    %% Go

    delay = nan( 1 , size( EP.Data , 1 ) );
    
    for evt = 1 : size( EP.Data , 1 )
        
        delay(evt) = (GetSecs - EP.Data{evt,2} - StartTime) * 1000
        
        switch EP.Data{evt,1}
            
            case 'Fixation'
                
                Task1.DrawFixation( DataStruct.PTB.Window , DataStruct.PTB.Black , DataStruct.PTB.CenterH , DataStruct.PTB.CenterV , DotVisualAngle , PixelPerDegree )

                fixation_onset = Screen( 'Flip' , DataStruct.PTB.Window , StartTime + EP.Data{evt,2} - DataStruct.PTB.slack );
                
                ER.AddEvent({ 'Fixation' fixation_onset-StartTime })
                
                if evt < size( EP.Data , 1 )
                    WaitSecs('UntilTime', StartTime + EP.Data{evt+1,2} - DataStruct.PTB.slack*2 );
                else
                    WaitSecs('UntilTime', fixation_onset + EP.Data{evt,3} );
                end
                
            case 'InOut'
                
                if Speed ~= 1
                    DeadLine = EP.Data{evt,3};
                else
                    DeadLine = Inf;
                end
                
%                 ER_movieStruct(evt).EP_header = EP.Header;
%                 ER_movieStruct(evt).EP_line   = EP.Data(evt,:);
                
%                 ER_movieStruct(evt).ER        = Task1.PlayMovieTrial( movie(1) , ER_movieStruct(evt).ER , DataStruct , DeadLine );
                [ First_frame , ~ ]        = Task1.PlayMovieTrial( movie(1) , DataStruct , DeadLine );
                
                ER.AddEvent({ 'InOut' First_frame-StartTime })
                
%                 ER_movieStruct(evt).ER.ScaleTime;
                

                
            case 'Rotation'

                if Speed ~= 1
                    DeadLine = EP.Data{evt,3};
                else
                    DeadLine = Inf;
                end
                
%                 ER_movieStruct(evt).EP_header = EP.Header;
%                 ER_movieStruct(evt).EP_line   = EP.Data(evt,:);
                
%                 ER_movieStruct(evt).ER        = Task1.PlayMovieTrial( movie(2) , ER_movieStruct(evt).ER , DataStruct , DeadLine );
                [ First_frame , ~ ]        = Task1.PlayMovieTrial( movie(2) , DataStruct , DeadLine );
                
                ER.AddEvent({ 'Rotation' First_frame-StartTime })
                
%                 ER_movieStruct(evt).ER.ScaleTime;

        end
        
    end
    
    % Stop time
    StopTime = GetSecs;
    
    % Record StopTime
    ER.AddStopTime( 'StopTime' , StopTime - StartTime );
    
    
    [ ER.Data(:,1) cellfun( @(b,a) { (b-a)*1000 } , ER.Data(:,2) , EP.Data(:,2) ) ]
    
    figure
    plot( cellfun( @(b,a) (b-a)*1000 , ER.Data(:,2) , EP.Data(:,2) ) )
    
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
    
%     assignin('base','ER_movieStruct',ER_movieStruct)
    
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
