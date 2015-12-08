function [ TaskData ] = Task1( DataStruct )

try
    %% Preparation of movies
    
    % Load location
    TaskData.moviefile1 = [pwd filesep 'videos' filesep 'pathS_InOut.mov'];
    TaskData.moviefile2 = [pwd filesep 'videos' filesep 'pathS_Rot.mov'];
    
    % [ moviePtr [duration] [fps] [width] [height] [count] [aspectRatio]]=Screen('OpenMovie', windowPtr, moviefile [, async=0] [, preloadSecs=1] [, specialFlags1=0][, pixelFormat=4][, maxNumberThreads=-1][, movieOptions]);
    [ moviePtr1 duration1 fps1 width1 height1 count1 aspectRatio1]=Screen('OpenMovie', DataStruct.PTB.Window, TaskData.moviefile1);
    [ moviePtr2 duration2 fps2 width2 height2 count2 aspectRatio2]=Screen('OpenMovie', DataStruct.PTB.Window, TaskData.moviefile2);
    
    speed = 10;
    
    %% Tunning of the task
    
    % Create the planning object
    header = { 'event_name' , 'onset(s)'         , 'duration(s)' , 'movie_ref' , 'movie_file'};
    EP     = EventPlanning(header);
    
    % Define a planing
    EP.AddPlanning({
               'StartTime'    0                    0               []            []
               'InOut'        0                    duration1       moviePtr1     TaskData.moviefile1
               'Rotation'     duration1            duration2       moviePtr2     TaskData.moviefile2
               'StopTime'     duration1+duration2  0               []            []
        });

    TaskData.EP = EP;
    
    % Prepare event record
    ER = EventRecorder(header,10);
    ER.AddStartTime('StartTime',0);

    

    
    
    %% Go
    
    PlayMovieTrial( moviePtr1 , speed , DataStruct )
    PlayMovieTrial( moviePtr2 , speed , DataStruct )
    

    %% End
    
    ER.AddStopTime('StopTime',GetSecs-ER.Data{1,2});
    ER.ClearEmptyEvents;
    
catch err
    
    sca
    rethrow(err)
    
end

end

%% Local functions

%--------------------------------------------------------------------------
%                             PlayMovieTrial
%--------------------------------------------------------------------------
function PlayMovieTrial( moviePtr , speed , DataStruct )

% Start playback engine:
Screen('PlayMovie', moviePtr, speed);

% Playback loop: Runs until end of movie or keypress:
while ~KbCheckk
    
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
    Screen('Flip', DataStruct.PTB.Window);
    
    % Release texture:
    Screen('Close', texturePtr);
    
end

% Stop playback:
Screen('PlayMovie', moviePtr, 0);

% Close movie:
Screen('CloseMovie', moviePtr);

end