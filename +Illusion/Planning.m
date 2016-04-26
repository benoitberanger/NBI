function [ EP ] = Planning( DataStruct )
%% Pre-process the design

% Load design
load( [ pwd filesep '+Illusion' filesep 'NBI_optseq_sequences.mat' ] )

% Split each mini-bloc : 

% Minibloc number ?
miniBloc_idx = cell2mat(optseqsequences(:,1)); %#ok<NODEF>
[miniBloc_id,~,idx2id] = unique(miniBloc_idx,'stable');

% Prepare a cell containing all miniblocs
allBlocs = cell(length(miniBloc_id),1);
for b = 1 : length(miniBloc_id)
    allBlocs{b} = optseqsequences( miniBloc_id(b) == idx2id , : );
end

% Pair each block accordinf to the compressFactor
compressFactor = 2;

runBlocs = cell(ceil(length(miniBloc_id)/compressFactor),1);
skip = 0;
count = 0;
for b = 1 : length(miniBloc_id)

    if skip > 0
    
        skip = skip - 1;
        
    else
        
        count = count + 1;
        
        for c = 1 : compressFactor
            
            if b + c - 1 <= size(allBlocs,1)
                runBlocs{count} = vertcat( runBlocs{count} , allBlocs{ b + c - 1 } ); % Fusion
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
    blocSelected = 1; % temporary
    switch DataStruct.Environement
        
        case 'MRI'
            
        case 'Training'
            
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
