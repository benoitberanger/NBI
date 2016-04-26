function [ EP , Speed ] = Planning( DataStruct )
%% Pre-process the design

% Load design
load( [ pwd filesep '+Illusion' filesep 'NBI_optseq_sequences.mat' ] )

% Split each mini-bloc :

% Minibloc number ?
miniBloc_idx = cell2mat(optseqsequences(:,1)); %#ok<NODEF>
[miniBloc_id,~,idx2id] = unique_stable(miniBloc_idx);

% Prepare a cell containing all miniblocs
allBlocs = cell(length(miniBloc_id),1);
for b = 1 : length(miniBloc_id)
    allBlocs{b} = optseqsequences( miniBloc_id(b) == idx2id , : );
end

% Pair each block according to the compressFactor
compressFactor = 2;

runBlocs = cell(ceil(length(miniBloc_id)/compressFactor),1);
skip = 0;
count = 0;
for b = 1 : length(miniBloc_id)
    
    if skip > 0
        skip = skip - 1;
    else
        
        count = count + 1;
        
        for cf = 1 : compressFactor
            if b + cf - 1 <= size(allBlocs,1)
                runBlocs{count} = vertcat( runBlocs{count} , allBlocs{ b + cf - 1 } ); % Fusion
            else
                % Don't need a fusion : already the last one
            end            
        end
        
        skip = compressFactor - 1;
        
    end
    
end

% Adjust onset of the event after fusion of miniblocs

adjustedBlocs = runBlocs;

for mb = 1 : size(runBlocs,1)
    
    onsets = cell2mat(runBlocs{mb}(:,2));
    durations = cell2mat(runBlocs{mb}(:,4));
    
    Zero_idx = find( onsets == 0 );
    
    for z = 2 : length(Zero_idx)
        
        if z + 1 <= length(Zero_idx)
            onsets( Zero_idx(z) : Zero_idx(z+1)-1 ) = onsets( Zero_idx(z) : Zero_idx(z+1)-1 ) + onsets( Zero_idx(z) - 1 ) + durations( Zero_idx(z) ) ;
        else
            onsets( Zero_idx(z) : end ) = onsets( Zero_idx(z) : end ) + onsets( Zero_idx(z) - 1 ) + durations( Zero_idx(z) ) ;
        end
        
    end
    
    adjustedBlocs{mb}(:,2) = num2cell(onsets);
    
end


%% Tunning

if nargout > 0
    
    switch DataStruct.Environement
        
        case 'MRI'
            blocSelected = str2double( DataStruct.RunNumber );
            
        case 'Training'
            blocSelected = 1;
            adjustedBlocs = cell(1);
            NO = @(adjustedBlocs) adjustedBlocs{blocSelected}{end,2} + adjustedBlocs{blocSelected}{end,4};
            
            %             adjustedBlocs{blocSelected} = { 1 0 0 1.8 'Null' };
            %             for ii = 1:5
            %                 for i = 1:3
            %                     adjustedBlocs{blocSelected} = [adjustedBlocs{blocSelected} ; {1 NO(adjustedBlocs) 1 1.8 'Illusion_rotation'  } ];
            %                 end
            %                 for i = 1:3
            %                     adjustedBlocs{blocSelected} = [adjustedBlocs{blocSelected} ; {1 NO(adjustedBlocs) 3 1.8 'Control_rotation'   } ];
            %                 end
            %             end
            
            adjustedBlocs{blocSelected} = { 1 0 0 1.8 'Null' };
            adjustedBlocs{blocSelected} = [adjustedBlocs{blocSelected} ; {1 NO(adjustedBlocs) 1 1.8 'Illusion_rotation'  } ];
            adjustedBlocs{blocSelected} = [adjustedBlocs{blocSelected} ; {1 NO(adjustedBlocs) 2 1.8 'Illusion_InOut'     } ];
            adjustedBlocs{blocSelected} = [adjustedBlocs{blocSelected} ; {1 NO(adjustedBlocs) 3 1.8 'Control_rotation'   } ];
            adjustedBlocs{blocSelected} = [adjustedBlocs{blocSelected} ; {1 NO(adjustedBlocs) 4 1.8 'Control_inOut'      } ];
            adjustedBlocs{blocSelected} = [adjustedBlocs{blocSelected} ; {1 NO(adjustedBlocs) 5 1.8 'Control_global'     } ];
            adjustedBlocs{blocSelected} = [adjustedBlocs{blocSelected} ; {1 NO(adjustedBlocs) 6 1.8 'Control_local_rot'  } ];
            adjustedBlocs{blocSelected} = [adjustedBlocs{blocSelected} ; {1 NO(adjustedBlocs) 7 1.8 'Control_local_inOut'} ];
            
    end
    
else
    
    blocSelected = 1;
    
end

if nargout > 0
    
    switch DataStruct.OperationMode
        
        case 'Acquisition'
            
        case 'FastDebug'
            
        case 'RealisticDebug'
            
    end
    
end


%% Do

% Create and prepare
header = { 'event_name' , 'onset(s)' , 'duration(s)' };
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};

% --- Start ---------------------------------------------------------------

EP.AddPlanning({ 'StartTime' , 0 , 0 });

% --- Stim ----------------------------------------------------------------

displayBloc = adjustedBlocs{ blocSelected };

for trial = 1 : size( displayBloc , 1 )
    
    EP.AddPlanning({ displayBloc{trial,5} , displayBloc{trial,2} , displayBloc{trial,4} });
    
end

% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime' , NextOnset(EP) , 0 });


%% Acceleration

if nargout > 1
    
    switch DataStruct.OperationMode
        
        case 'Acquisition'
            
            Speed = 1; %#ok<*NASGU>
            
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

end
