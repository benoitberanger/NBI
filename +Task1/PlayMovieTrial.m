function [ First_frame , Last_frame , Exit_flag ] = PlayMovieTrial( movie , DataStruct  , DeadLine )

Last_frame = NaN; % Just to avoid some bugs

% Flag
Exit_flag = 0;

% Start playback engine
Screen('PlayMovie', movie.Ptr , 1 );


%% Do ...

% Wait for next movie frame, retrieve texture handle to it
[ texturePtr timeindex ] = Screen('GetMovieImage', DataStruct.PTB.Window, movie.Ptr);

% Valid texture returned? A negative value means end of movie reached:
if texturePtr<=0
    % We're done, break out of loop
    error('texturePtr<=0')
end

% Draw the new texture immediately to screen
Screen('DrawTexture', DataStruct.PTB.Window, texturePtr);

% Update display
First_frame = Screen('Flip', DataStruct.PTB.Window);

% Release texture
Screen('Close', texturePtr);


%% ... While

% Playback loop
while timeindex < DeadLine
    
    % Escape ?
    [ keyIsDown, ~ , keyCode ] = KbCheck;
    if keyIsDown
        if keyCode(DataStruct.Parameters.Keybinds.Stop_Escape_ASCII)
            Exit_flag = 1;
            break
        end
    end
    
    % Wait for next movie frame, retrieve texture handle to it
    [ texturePtr timeindex ] = Screen('GetMovieImage', DataStruct.PTB.Window, movie.Ptr);
    
    % Valid texture returned? A negative value means end of movie reached
    if texturePtr<=0
        % We're done, break out of loop
        break
    end
    
    % Draw the new texture immediately to screen
    Screen('DrawTexture', DataStruct.PTB.Window, texturePtr);
    
    % Update display
    Last_frame = Screen('Flip', DataStruct.PTB.Window);

    % Release texture
    Screen('Close', texturePtr);
    
end


%% Rewind

% Stop playback
Screen('PlayMovie', movie.Ptr, 0);

% Rewind movie
Screen( 'SetMovieTimeIndex' , movie.Ptr, 0 );

end
