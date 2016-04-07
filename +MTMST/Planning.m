%% Tuning

FixationDuration = 1; % seconds
INOUTDuration = 1; % seconds

%% Prepare event

% Create and prepare
header = { 'event_name' , 'onset(s)' , 'duration(s)' , 'left' , 'center' , 'right' , 'mouvement_dir'};
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


%% Define a planning <--- paradigme

% --- Start ---------------------------------------------------------------

EP.AddPlanning({ 'StartTime' 0  0 [] [] [] [] });

% ---Stim ----------------------------------------------------------------


EP.AddPlanning({ 'Fixation' NextOnset(EP) FixationDuration 0 0 0 '' });

switch DataStruct.Task
    
    case 'MTMST_Left'
        
        for cycle = 1 : 2
            
            EP.AddPlanning({ 'leftIN'   NextOnset(EP) INOUTDuration 1 0 0 'in' });
            for rep = 1 : 4
                EP.AddPlanning({ 'leftOUT'  NextOnset(EP) INOUTDuration 1 0 0 'out' });
                EP.AddPlanning({ 'leftIN'   NextOnset(EP) INOUTDuration 1 0 0 'in' });
            end
            
%             EP.AddPlanning({ 'rightFIXATION'   NextOnset(EP) INOUTDuration 0 0 -1 'fixation' });
            
        end
        
        
    case 'MTMST_Right'
        
        
        for cycle = 1 : 2
            
            EP.AddPlanning({ 'rightIN'   NextOnset(EP) INOUTDuration 0 0 1 'in' });
            for rep = 1 : 4
                EP.AddPlanning({ 'rightOUT'  NextOnset(EP) INOUTDuration 0 0 1 'out' });
                EP.AddPlanning({ 'rightIN'   NextOnset(EP) INOUTDuration 0 0 1 'in' });
            end
            
        end
        
        
end


%     EP.AddPlanning({ 'centerIN'   NextOnset(EP) INOUTDuration 0 1 0 'in' });
%     for rep = 1 : 4
%         EP.AddPlanning({ 'centerOUT'  NextOnset(EP) INOUTDuration 0 1 0 'out' });
%         EP.AddPlanning({ 'centerIN'   NextOnset(EP) INOUTDuration 0 1 0 'in' });
%     end



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
