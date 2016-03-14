%% Tuning

FixationDuration = 2; % secondes

movieDurationOffcet = 0.050; % secondes

% Create and prepare
header = {       'event_name' ,          'onset(s)' ,   'duration(s)' ,                       'movie_Prt' , 'movie_file' , 'ParPort_message'};
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


%% Define a planning <--- paradigme

% --- Start ---------------------------------------------------------------

EP.AddPlanning({ 'StartTime'             0              0                                      []            []             []                       });

% --- Stim ----------------------------------------------------------------

EP.AddPlanning({ 'Fixation'              NextOnset(EP)  FixationDuration                       []            []             msg.Fixation             });

% Condition 1 + Fixation
EP.AddPlanning({ 'pathS_InOut'           NextOnset(EP)  movie(1).duration+movieDurationOffcet  movie(1).Ptr  movie(1).file  msg.pathS_InOut          });
EP.AddPlanning({ 'Fixation'              NextOnset(EP)  FixationDuration                       []            []             msg.Fixation             });

% Condition 2 + Fixation
EP.AddPlanning({ 'pathS_Rot'             NextOnset(EP)  movie(2).duration+movieDurationOffcet  movie(2).Ptr  movie(2).file  msg.pathS_Rot            });
EP.AddPlanning({ 'Fixation'              NextOnset(EP)  FixationDuration                       []            []             msg.Fixation             });

% Condition 3 + Fixation
EP.AddPlanning({ 'control2_pathS_InOut'  NextOnset(EP)  movie(3).duration+movieDurationOffcet  movie(3).Ptr  movie(3).file  msg.control2_pathS_InOut });
EP.AddPlanning({ 'Fixation'              NextOnset(EP)  FixationDuration                       []            []             msg.Fixation             });

% Condition 4 + Fixation
EP.AddPlanning({ 'control2_pathS_Rot'    NextOnset(EP)  movie(4).duration+movieDurationOffcet  movie(4).Ptr  movie(4).file  msg.control2_pathS_Rot   });
EP.AddPlanning({ 'Fixation'              NextOnset(EP)  FixationDuration                       []            []             msg.Fixation             });

% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime'              NextOnset(EP)  0                                      []            []             []                       });


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
