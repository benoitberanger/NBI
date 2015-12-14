function [ TaskData ] = Task1( DataStruct )

try
    %% Preparation of movies
    
    % Load location
    TaskData.moviefile1 = [pwd filesep 'videos' filesep 'pathS_InOut.mov'];
    TaskData.moviefile2 = [pwd filesep 'videos' filesep 'pathS_Rot.mov'];
    
    % [ moviePtr [duration] [fps] [width] [height] [count] [aspectRatio]]=Screen('OpenMovie', windowPtr, moviefile [, async=0] [, preloadSecs=1] [, specialFlags1=0][, pixelFormat=4][, maxNumberThreads=-1][, movieOptions]);
    [ moviePtr1 duration1 fps1 width1 height1 count1 aspectRatio1]=Screen('OpenMovie', DataStruct.PTB.Window, TaskData.moviefile1)
    [ moviePtr2 duration2 fps2 width2 height2 count2 aspectRatio2]=Screen('OpenMovie', DataStruct.PTB.Window, TaskData.moviefile2)
    
    speed = 1;
    
    %% Tunning of the task
    
    % Create the planning object
    header = { 'event_name' , 'onset(s)'         , 'duration(s)' , 'movie_Prt' , 'movie_file'};
    EP     = EventPlanning(header);
    
    % Define a planing
    EP.AddPlanning({
        'StartTime'           0                    0               []            []
        'InOut'               0                    duration1       moviePtr1     TaskData.moviefile1
        'Rotation'            duration1            duration2       moviePtr2     TaskData.moviefile2
        'StopTime'            duration1+duration2  0               []            []
        });
    
    EP.BuildGraph;
    TaskData.EP = EP;
    
    % Prepare event record
    ER = EventRecorder(header(1:2),10);
    ER.AddStartTime('StartTime',0);
    
    
    %% Generate MRI triggers
    
    KbName('UnifyKeyNames');
    
    keys = {'space' '5%' 'escape'};
    
    KL = KbLogger(KbName(keys) , keys);
    
    KL.GenerateMRITrigger(0.950, ceil( EP.Data{end,2} ) );
    
    KL.ScaleTime;
    KL.ComputeDurations;
    
    KL.BuildGraph;
    
    
    %% Go
    
    StartTime = GetSecs;
    
    ER_movie1 = PlayMovieTrial( moviePtr1 , speed , DataStruct , count1 );

    ER_movie1.ClearEmptyEvents;
    ER.AddEvent({ 'InOut' ER_movie1.Data{1,2}-StartTime })
    %     ER.AddEvent({'movie1_end' ER_movie1.Data{end,2}});
    
    ER_movie2 = PlayMovieTrial( moviePtr2 , speed , DataStruct , count2 );
    
    ER_movie2.ClearEmptyEvents;
    ER.AddEvent({ 'Rotation' ER_movie2.Data{1,2}-StartTime })
    %     ER.AddEvent({'movie2_end' ER_movie2.Data{end,2}});


    %% End
    
    ER.AddStopTime( 'StopTime' , GetSecs - StartTime );
    ER.ClearEmptyEvents;
    
    ER.BuildGraph;
    TaskData.ER = ER;
    
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