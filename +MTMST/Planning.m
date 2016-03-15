%% Tuning

% Create and prepare
header = {       'event_name' , 'onset(s)' , 'duration(s)' , 'left' , 'center' , 'right' ,'ParPort_message'};
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


%% Define a planning <--- paradigme

% --- Start ---------------------------------------------------------------

EP.AddPlanning({ 'StartTime' 0  0 [] [] [] [] });

% --- Stim ----------------------------------------------------------------

EP.AddPlanning({ 'Fixation' NextOnset(EP) 3 0 0 0 2 });
EP.AddPlanning({ 'Left'     NextOnset(EP) 3 1 0 0 4 });
EP.AddPlanning({ 'Fixation' NextOnset(EP) 3 0 1 0 2 });
EP.AddPlanning({ 'Right'    NextOnset(EP) 3 0 0 1 1 });
EP.AddPlanning({ 'LR'       NextOnset(EP) 3 1 0 1 1 });

% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime' NextOnset(EP) 0 [] [] [] [] });


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
