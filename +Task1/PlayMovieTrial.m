% function ER_movie = PlayMovieTrial( movie , current_ER , DataStruct  , DeadLine )
%
% % Pointer
% ER_movie = current_ER;
%
% % Start playback engine:
% Screen('PlayMovie', movie.Ptr , 1 );
%
% % Initilization
% timeindex = 0;
%
% % Playback loop: Runs until end of movie or keypress:
% while ~KbCheck && timeindex < DeadLine
%
%     % Wait for next movie frame, retrieve texture handle to it
%     [ texturePtr timeindex ] = Screen('GetMovieImage', DataStruct.PTB.Window, movie.Ptr);
%
%     % Valid texture returned? A negative value means end of movie reached:
%     if texturePtr<=0
%         % We're done, break out of loop:
%         break;
%     end
%
%     % Draw the new texture immediately to screen:
%     Screen('DrawTexture', DataStruct.PTB.Window, texturePtr);
%
%     % Update display
%     frame_onset = Screen('Flip', DataStruct.PTB.Window);
%
%     ER_movie.AddEvent( { 'Flip' frame_onset } );
%
%     % Release texture
%     Screen('Close', texturePtr);
%
% end
%
% % Stop playback:
% Screen('PlayMovie', movie.Ptr, 0);
%
% % Rewind movie
% Screen( 'SetMovieTimeIndex' , movie.Ptr, 0 );
%
% ER_movie.ClearEmptyEvents;
%
% end

function [ First_frame , Last_frame ] = PlayMovieTrial( movie , DataStruct  , DeadLine )

% Start playback engine:
Screen('PlayMovie', movie.Ptr , 1 );


%% Do ...

% Wait for next movie frame, retrieve texture handle to it
[ texturePtr timeindex ] = Screen('GetMovieImage', DataStruct.PTB.Window, movie.Ptr);

% Valid texture returned? A negative value means end of movie reached:
if texturePtr<=0
    % We're done, break out of loop:
    error('texturePtr<=0')
end

% Draw the new texture immediately to screen:
Screen('DrawTexture', DataStruct.PTB.Window, texturePtr);

% Update display
First_frame = Screen('Flip', DataStruct.PTB.Window);

% Release texture
Screen('Close', texturePtr);


%% ... While

% Playback loop: Runs until end of movie or keypress:
while ~KbCheck && timeindex < DeadLine
    
    % Wait for next movie frame, retrieve texture handle to it
    [ texturePtr timeindex ] = Screen('GetMovieImage', DataStruct.PTB.Window, movie.Ptr);
    
    % Valid texture returned? A negative value means end of movie reached:
    if texturePtr<=0
        % We're done, break out of loop:
        break;
    end
    
    % Draw the new texture immediately to screen:
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
