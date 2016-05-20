%% Tuning

CompleteTurnDuration = 48;

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

for i = 1 : 4
    EP.AddPlanning({ 'cw'  NextOnset(EP) CompleteTurnDuration 'cw'  360/CompleteTurnDuration });
end
for i = 1 : 4
    EP.AddPlanning({ 'ccw' NextOnset(EP) CompleteTurnDuration 'ccw' 360/CompleteTurnDuration });
end

% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime' NextOnset(EP) 0 [] [] });


%% Acceleration

switch DataStruct.OperationMode
    
    case 'Acquisition'
        
        Speed = 1;
        
    case 'FastDebug'
        
        Speed = 20;
        
        new_onsets = cellfun( @(x) {x/Speed} , EP.Data(:,2) );
        EP.Data(:,2) = new_onsets;
        
        new_durations = cellfun( @(x) {x/Speed} , EP.Data(:,3) );
        EP.Data(:,3) = new_durations;
        
    case 'RealisticDebug'
        
        Speed = 1;
        
    otherwise
        error( 'DataStruct.OperationMode = %s' , DataStruct.OperationMode )
        
end
