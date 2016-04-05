%% Tuning

FixationDuration = 1; % seconds
INOUTDuration = 1; % seconds

%% Prepare event

% Create and prepare
header = { 'event_name' , 'onset(s)' , 'duration(s)' , 'rotation', 'deg/sec' };
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


%% Define a planning <--- paradigme

% --- Start ---------------------------------------------------------------

EP.AddPlanning({ 'StartTime' 0  0 [] [] });

% --- Stim ----------------------------------------------------------------

EP.AddPlanning({ 'cw' NextOnset(EP) 18 'cw' 20 });
EP.AddPlanning({ 'cw' NextOnset(EP) 18 'cw' 20 });
EP.AddPlanning({ 'ccw' NextOnset(EP) 18 'ccw' 20 });
EP.AddPlanning({ 'ccw' NextOnset(EP) 18 'ccw' 20 });
EP.AddPlanning({ 'cw' NextOnset(EP) 18 'cw' 20 });
EP.AddPlanning({ 'ccw' NextOnset(EP) 18 'ccw' 20 });

% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime' NextOnset(EP) 0 [] [] });


%% Acceleration

switch DataStruct.OperationMode
    
    case 'Acquisition'
        
        Speed = 1;
        
    case 'FastDebug'
        
        Speed = 10;
        
        new_onsets = cellfun( @(x) {x/Speed} , EP.Data(:,2) );
        EP.Data(:,2) = new_onsets;
        
        new_durations = cellfun( @(x) {x/Speed} , EP.Data(:,3) );
        EP.Data(:,3) = new_durations;
        
    case 'RealisticDebug'
        
        Speed = 1;
        
    otherwise
        error( 'DataStruct.OperationMode = %s' , DataStruct.OperationMode )
        
end
