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
    
    speed = 1;
    
    TaskData.movie = movie;
    
    %% Tunning of the task
    
    % Create the planning object
    header = {       'event_name' , 'onset(s)'         ,  'duration(s)' ,    'movie_Prt' , 'movie_file'};
    EP     = EventPlanning(header);
    
    % Define a planing
    
    EP.AddPlanning({ 'StartTime'    0                     0                  []            []            });
    EP.AddPlanning({ 'InOut'        OnsetCalculator(EP)   movie(1).duration  movie(1).Ptr  movie(1).file });
    EP.AddPlanning({ 'Fixation'     OnsetCalculator(EP)   5                  []            []            });
    EP.AddPlanning({ 'Rotation'     OnsetCalculator(EP)   movie(2).duration  movie(2).Ptr  movie(2).file });
    EP.AddPlanning({ 'Fixation'     OnsetCalculator(EP)   5                  []            []            });
    EP.AddPlanning({ 'StopTime'     OnsetCalculator(EP)   0                  []            []            });
    
    EP.BuildGraph;
    TaskData.EP = EP;
    
    % Prepare event record
    ER = EventRecorder( header(1:2) , size(EP.Data,1) );
    ER.AddStartTime( 'StartTime' , 0 );
    
    %% Prepare fixation dot
    
    PixelPerDegree = va2pix( 1 , DataStruct.Parameters.Video.SubjectDistance , DataStruct.Parameters.Video.ScreenWidthM , DataStruct.Parameters.Video.ScreenWidthPx );
    DotVisualAngle = 0.1; 

    
    %% Generate MRI triggers
    
    KbName('UnifyKeyNames');
    
    keys = {'space' '5%' 'escape'};
    
    KL = KbLogger(KbName(keys) , keys);
    
    KL.GenerateMRITrigger( 0.950 , ceil( EP.Data{end,2} ) );
    
    KL.ScaleTime;
    KL.ComputeDurations;
    
    KL.BuildGraph;
    
    
    %% Go
    
    StartTime = GetSecs;
    
    for evt = 1 : size( EP.Data , 1 )
        
        switch EP.Data{evt,1}
            
            case 'Fixation'
                
                DrawFixation( DataStruct.PTB.Window , DataStruct.PTB.Black , DataStruct.PTB.CenterH , DataStruct.PTB.CenterV , DotVisualAngle , PixelPerDegree )
                fixation_onset = Screen( 'Flip' , DataStruct.PTB.Window , StartTime + EP.Data{evt,2} - DataStruct.PTB.slack );
                
                ER.AddEvent({ 'Fixation' fixation_onset-StartTime })
                
                if evt < size( EP.Data , 1 )
                    WaitSecs('UntilTime', fixation_onset + EP.Data{evt,3} - DataStruct.PTB.slack );
                end
                
            case 'InOut'
                
                WaitSecs('UntilTime', StartTime + EP.Data{evt,2} - DataStruct.PTB.slack );
                
                ER_movie1 = PlayMovieTrial( movie(1).Ptr , speed , DataStruct , movie(1).count );
                ER_movie1.ClearEmptyEvents;
                ER.AddEvent({ 'InOut' ER_movie1.Data{1,2}-StartTime })
    
            case 'Rotation'
            
                WaitSecs('UntilTime', StartTime + EP.Data{evt,2} - DataStruct.PTB.slack );
                
                ER_movie2 = PlayMovieTrial( movie(2).Ptr , speed , DataStruct , movie(2).count );
                
                ER_movie2.ClearEmptyEvents;
                ER.AddEvent({ 'Rotation' ER_movie2.Data{1,2}-StartTime })
                
        end
            
    end


    %% End
    
    ER.AddStopTime( 'StopTime' , GetSecs - StartTime );
    ER.ClearEmptyEvents;
    
    ER.BuildGraph;
    TaskData.ER = ER;
    
    TaskData.KL = KL;
    
    plotStim(EP,ER,KL)
    
    
    %% Send infos to base workspace
    
    assignin('base','EP',EP)
    assignin('base','ER',ER)
    assignin('base','KL',KL)
    
    %     assignin('base','ER_movie1',ER_movie1)
    %     assignin('base','ER_movie2',ER_movie2)
    
    assignin('base','TaskData',TaskData)
    
    
catch err
    
    sca
    rethrow(err)
    
end

end

%% Local functions

%--------------------------------------------------------------------------
%                                 va2pix
%--------------------------------------------------------------------------
function PixelPerDegree = va2pix( VisualAngle , SubjectDistance , ScreenWidthM , ScreenWidthPx )
PixelPerDegree = SubjectDistance * tan(VisualAngle*pi/180) / (ScreenWidthM/ScreenWidthPx);
end

%--------------------------------------------------------------------------
%                              DrawFixation
%--------------------------------------------------------------------------
function DrawFixation( winPtr , Color , PositionH , PositionV , VisualAngle , PixelPerDegree )
pu = round( PixelPerDegree * VisualAngle );
rect = [ 0 0 pu pu ];
Screen( winPtr , 'FillOval' , Color , CenterRectOnPoint(rect,PositionH,PositionV) );
end

%--------------------------------------------------------------------------
%                             PlayMovieTrial
%--------------------------------------------------------------------------
function ER_movie = PlayMovieTrial( moviePtr , speed , DataStruct , count )

ER_movie = EventRecorder( { 'event_name' , 'onset(s)'} , count );

% Start playback engine:
Screen('PlayMovie', moviePtr, speed);

% Playback loop: Runs until end of movie or keypress:
while ~KbCheck
    
    % Wait for next movie frame, retrieve texture handle to it
    [ texturePtr timeindex ] = Screen('GetMovieImage', DataStruct.PTB.Window, moviePtr);
    
    % Valid texture returned? A negative value means end of movie reached:
    if texturePtr<=0
        % We're done, break out of loop:
        break;
    end
    
    % Draw the new texture immediately to screen:
    Screen('DrawTexture', DataStruct.PTB.Window, texturePtr);
    
    % Update display:
    frame_onset = Screen('Flip', DataStruct.PTB.Window);

    % Release texture:
    Screen('Close', texturePtr);
    
    ER_movie.AddEvent( { 'frame' frame_onset } );
    
end

% Stop playback:
Screen('PlayMovie', moviePtr, 0);

% Close movie:
Screen('CloseMovie', moviePtr);

end

%--------------------------------------------------------------------------
%                            OnsetCalculator
%--------------------------------------------------------------------------
function Onset = OnsetCalculator(EP)
Onset = EP.Data{end,2} + EP.Data{end,3};
end