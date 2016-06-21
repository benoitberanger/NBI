%% Tuning


INOUTDuration    = 1;  % seconds
FixationDuration = 10; % seconds


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

if nargout < 1
    DataStruct.Task = 'MTMST_Left';
end

switch DataStruct.Task
    
    case 'MTMST_Left'
        
        for cycle = 1 : 17
            for rep = 1 : 5
                EP.AddPlanning({ 'leftOUT'      NextOnset(EP) INOUTDuration    1 0 0 'out'      });
                EP.AddPlanning({ 'leftIN'       NextOnset(EP) INOUTDuration    1 0 0 'in'       });
            end
            EP.AddPlanning({     'leftFIXATION' NextOnset(EP) FixationDuration 1 0 0 'fixation' });
        end
        EP.AddPlanning({         'leftREST'     NextOnset(EP) FixationDuration 0 0 0 ''         });
        
    case 'MTMST_Right'
        
        for cycle = 1 : 17
            for rep = 1 : 5
                EP.AddPlanning({ 'rightOUT'      NextOnset(EP) INOUTDuration    0 0 1 'out'      });
                EP.AddPlanning({ 'rightIN'       NextOnset(EP) INOUTDuration    0 0 1 'in'       });
            end
            EP.AddPlanning({     'rightFIXATION' NextOnset(EP) FixationDuration 0 0 1 'fixation' });
        end
        EP.AddPlanning({         'rightREST'     NextOnset(EP) FixationDuration 0 0 0 ''         });
        
end


%     EP.AddPlanning({ 'centerIN'   NextOnset(EP) INOUTDuration 0 1 0 'in' });
%     for rep = 1 : 4
%         EP.AddPlanning({ 'centerOUT'  NextOnset(EP) INOUTDuration 0 1 0 'out' });
%         EP.AddPlanning({ 'centerIN'   NextOnset(EP) INOUTDuration 0 1 0 'in' });
%     end



% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime' NextOnset(EP) 0 [] [] [] [] });


%% Acceleration

if nargout > 0
    
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
    
end


%% Display

% To prepare the planning and visualize it, we can execute the function
% without output argument

if nargout < 1
    
    fprintf( '\n' )
    fprintf(' \n Total stim duration : %g seconds \n' , NextOnset(EP) )
    fprintf( '\n' )
    
    EP.Plot
    
end
