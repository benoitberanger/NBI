for m = 1 : length(movie)
    
    % [ moviePtr [duration] [fps] [width] [height] [count] [aspectRatio]]=Screen('OpenMovie', windowPtr, moviefile [, async=0] [, preloadSecs=1] [, specialFlags1=0][, pixelFormat=4][, maxNumberThreads=-1][, movieOptions]);
    [ movie(m).Ptr movie(m).duration movie(m).fps movie(m).width movie(m).height movie(m).count movie(m).aspectRatio ] = Screen( 'OpenMovie' , DataStruct.PTB.Window , movie(m).file );
    
    disp( movie(m) )
    disp(' ')
    
end

TaskData.movie = movie;
