function ER_movie = PlayMovieTrial( moviePtr , Speed , DataStruct , count )

ER_movie = EventRecorder( { 'event_name' , 'onset(s)'} , count );

frame_counter = 0;

% Start playback engine:
Screen('PlayMovie', moviePtr , 1 );

% Playback loop: Runs until end of movie or keypress:
while ~KbCheck
    
    frame_counter = frame_counter + 1;
    
    % Wait for next movie frame, retrieve texture handle to it
    [ texturePtr timeindex ] = Screen('GetMovieImage', DataStruct.PTB.Window, moviePtr);
    
    % Valid texture returned? A negative value means end of movie reached:
    if texturePtr<=0
        % We're done, break out of loop:
        break;
    end
    
    % Draw the new texture immediately to screen:
    Screen('DrawTexture', DataStruct.PTB.Window, texturePtr);
    
    if mod(frame_counter,Speed) == 0
    
        % Update display
        frame_onset = Screen('Flip', DataStruct.PTB.Window);
        
        ER_movie.AddEvent( { 'frame' frame_onset } );
        
    end
    
    % Release texture
    Screen('Close', texturePtr);
    
end

% Stop playback:
Screen('PlayMovie', moviePtr, 0);

% Close movie:
Screen('CloseMovie', moviePtr);

ER_movie.ClearEmptyEvents;

end
