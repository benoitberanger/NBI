% StopTime = WaitSecs('UntilTime', StartTime + EP.Data{evt,2} ); % This stops the stimulation at the planned StopTime onset, wich is not the machine's reality
StopTime = WaitSecs('UntilTime', StartTime + ER.Data{ER.EventCount,2} + EP.Data{evt-1,3} ); % Wait for the last event to have it's real duration, even if it's real onset is delayed.
% Usually, the difference is 1 or 2 frames : it's the natural delay due to
% the execution of the machine.

% Record StopTime
ER.AddStopTime( 'StopTime' , StopTime - StartTime );
RR.AddEvent( { 'StopTime' , StopTime - StartTime , 0 } );

ShowCursor;
Priority( DataStruct.PTB.oldLevel );
