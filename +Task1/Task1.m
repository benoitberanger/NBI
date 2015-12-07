function [ TaskData ] = Task1( DataStruct )

try
    %% Preparation

    clc
    
    % Load movie
    moviefile1 = [pwd filesep 'videos' filesep 'pathS_InOut.mov'];
    moviefile2 = [pwd filesep 'videos' filesep 'pathS_Rot.mov'];
    
    % [ moviePtr [duration] [fps] [width] [height] [count] [aspectRatio]]=Screen('OpenMovie', windowPtr, moviefile [, async=0] [, preloadSecs=1] [, specialFlags1=0][, pixelFormat=4][, maxNumberThreads=-1][, movieOptions]);
    [ moviePtr1 duration fps width height count aspectRatio]=Screen('OpenMovie', DataStruct.PTB.Window, moviefile1);
    [ moviePtr2 duration fps width height count aspectRatio]=Screen('OpenMovie', DataStruct.PTB.Window, moviefile2);

    speed = 10;
    
    %% Go 1
    
    % Start playback engine:
    Screen('PlayMovie', moviePtr1, speed);
    
    % Playback loop: Runs until end of movie or keypress:
    while ~KbCheck
        % Wait for next movie frame, retrieve texture handle to it
        [ texturePtr timeindex ] = Screen('GetMovieImage', DataStruct.PTB.Window, moviePtr1)
        
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
    Screen('PlayMovie', moviePtr1, 0);
    
    % Close movie:
    Screen('CloseMovie', moviePtr1);
    
    %% Go 1
    
    % Start playback engine:
    Screen('PlayMovie', moviePtr2, speed);
    
    % Playback loop: Runs until end of movie or keypress:
    while ~KbCheck
        % Wait for next movie frame, retrieve texture handle to it
        [ texturePtr2 timeindex ] = Screen('GetMovieImage', DataStruct.PTB.Window, moviePtr2)
        
        % Valid texture returned? A negative value means end of movie reached:
        if texturePtr2<=0
            % We're done, break out of loop:
            break;
        end
        
        % Draw the new texture immediately to screen:
        Screen('DrawTexture', DataStruct.PTB.Window, texturePtr2);
        
        % Update display:
        Screen('Flip', DataStruct.PTB.Window);
        
        % Release texture:
        Screen('Close', texturePtr2);
        
    end
    
    % Stop playback:
    Screen('PlayMovie', moviePtr2, 0);
    
    % Close movie:
    Screen('CloseMovie', moviePtr2);
    
    %% End
    
    TaskData = DataStruct;
    
catch err
    
    sca
    rethrow(err)
    
end

