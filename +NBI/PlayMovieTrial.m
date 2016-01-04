function [ First_frame , Last_frame , Subject_inputtime , Exit_flag ] = PlayMovieTrial( when , movie , DataStruct , DeadLine , adr , msg , dur )

% Just to avoid some bugs
First_frame = NaN;
Last_frame  = NaN;

Subject_inputtime = zeros( movie.count , 2 );

% Flag
Exit_flag = 0;

% Frame counter
frame = 0;

timeindex = 0;

% Sync with movie is special
WaitSecs('UntilTime', when );

% Start playback engine
Screen('PlayMovie', movie.Ptr , 1 );


%% Playback

% Playback loop
while timeindex < DeadLine
    
    frame = frame + 1;
    
    % Escape ?
    [ ~ , secs , keyCode ] = KbCheck;
    
    Subject_inputtime(frame,:) = [ secs keyCode(DataStruct.Parameters.Keybinds.Right_Blue_1_ASCII) ];
    
    if keyCode(DataStruct.Parameters.Keybinds.Stop_Escape_ASCII)
        Exit_flag = 1;
        break
    end
    
    
    % Wait for next movie frame, retrieve texture handle to it
    [ texturePtr timeindex ] = Screen('GetMovieImage', DataStruct.PTB.Window, movie.Ptr);
    
    % Valid texture returned? A negative value means end of movie reached
    if texturePtr<=0
        % We're done, break out of loop)
        break
    end
    
    Screen( 'FillRect' , DataStruct.PTB.Window , [0 0 0] );
    
    % Draw the new texture immediately to screen
    % Screen('DrawTexture', DataStruct.PTB.Window, texturePtr , [] , CenterRectOnPoint(ScaleRect([0 0 1039 1039],0.5,0.5),DataStruct.PTB.CenterH,DataStruct.PTB.CenterV) );
    Screen('DrawTexture', DataStruct.PTB.Window, texturePtr );
    
    Last_frame = Screen('Flip', DataStruct.PTB.Window );
    
    if frame == 1
        First_frame = Last_frame;
    end
    
    if strcmp( DataStruct.ParPort , 'On' )
        
        % Send Trigger
        outp( adr , msg );
        WaitSecs( dur );
        outp( adr , 0 );
        
    end
    
    % Release texture
    Screen('Close', texturePtr);
    
end


%% Rewind

% Stop playback
Screen('PlayMovie', movie.Ptr, 0);

% Rewind movie
Screen( 'SetMovieTimeIndex' , movie.Ptr, 0 );


end
