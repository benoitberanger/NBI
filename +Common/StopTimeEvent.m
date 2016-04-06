% Fixation duration handeling
StopTime = WaitSecs('UntilTime', StartTime + EP.Data{evt,2} );

% Record StopTime
ER.AddStopTime( 'StopTime' , StopTime - StartTime );
RR.AddStopTime( 'StopTime' , StopTime - StartTime );

ShowCursor;
Priority( DataStruct.PTB.oldLevel );
