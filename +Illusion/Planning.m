function [ EP , Speed ] = Planning( DataStruct )
% Pre-process the design

%% Load design
load( [ pwd filesep '+Illusion' filesep 'NBI_optseq_sequences.mat' ] )


%% Split each mini-block :

% Miniblock number ?
miniBlock_idx = cell2mat(optseqsequences(:,1)); %#ok<NODEF>
% [miniBlock_id,~,idx2id] = unique(miniBlock_idx,'stable');
[miniBlock_id,~,idx2id] = unique(miniBlock_idx);

% Prepare a cell containing all miniblocks
allBlocks = cell(length(miniBlock_id),1);
for b = 1 : length(miniBlock_id)
    allBlocks{b} = optseqsequences( miniBlock_id(b) == idx2id , : );
end


%% Catch trials

for b = 1 : length(miniBlock_id)
    %% Add the catch trials
    
    % Select the block
    currentBlock = allBlocks{b};
    
    nConditions = 7;
    rep = 10;
    
    condList = {...
        'Illusion_InOut'      ; ...
        'Illusion_rotation'   ; ...
        'Control_inOut'       ; ...
        'Control_rotation'    ; ...
        'Control_global'      ; ...
        'Control_local_inOut' ; ...
        'Control_local_rot'   ; ...
        };
    
    % Shuffle the catch conditions order for each block
    shuffledConditions = Shuffle(1:nConditions);
    
    % Space between each catch trials must be roughtly constant
    unprojected_onset = linspace( 1 , currentBlock{end,2} , nConditions + 1 ) + 10;
    unprojected_onset(end) = [];
    
    allOnsets = nan(rep,nConditions);
    
    % Fetch all onsets for each contions
    for c = 1 : nConditions
        allOnsets(:, shuffledConditions(c) ) = cell2mat( currentBlock( strcmp(currentBlock(:,5),condList{c}) , 2 ) );
        %     allOnsets(:, c ) = cell2mat( currentBlock( strcmp(currentBlock(:,5),condList{c}) , 2 ) );
    end
    
    listOnsets = cell2mat( currentBlock(:,2) ); % List of all onsets
    
    allOnsets_idx = allOnsets * nan;
    
    %  Link each onset with the event index : line number in the sequence
    for i = 1:rep
        for j = 1:nConditions
            allOnsets_idx(i,j) = find( allOnsets(i,j) == listOnsets );
        end
    end
    
    % Project the roughly spaced onset onto the real onset
    projected_onset = allOnsets*nan;
    for c = 1 : nConditions
        projected_onset(:,c) = abs(allOnsets(:,c) - unprojected_onset(c));
    end
    [~,projOnset_idx] = min(projected_onset,[],1); % Catch trial index for each shuffled condition
    
    currentBlock(:,6) = num2cell(zeros(size(currentBlock,1),1)); % Prepare a row for the catch trials
    
    % Add the catch trial index in the current block
    for ct = 1 : nConditions
        currentBlock{ allOnsets_idx(projOnset_idx(ct),ct) , 6 } = 1;
    end
    
    % Add 9 TR=900ms at the end end of each uncombined mini-block
    switch currentBlock{end,5}
        case 'Null'
            currentBlock{end,4} = currentBlock{end,4} + 9*0.900;
        otherwise
            currentBlock(end+1,:) = {currentBlock{end,1} currentBlock{end,2}+currentBlock{end,4} 0 9*0.900 'Null' 0 }; %#ok<*AGROW>
    end

    % Save the catch trials
    allBlocks{b} = currentBlock;
    
    
    %% Check : uncomment below
    
    %     fprintf('\n --- block = %d --- \n',b)
    %
    %     catch_idx = find( cell2mat( currentBlock(:,6) ) );
    %     catchOnset = cell2mat( currentBlock( catch_idx , 2 ) ) %#ok<FNDSB>
    %
    %     d = diff(catchOnset)
    %
    %     mean_d = mean(d)
    %
    %     shuffledConditions
    
    
end


%% Pair each block according to the compressFactor

compressFactor = 2;

runBlocks = cell(ceil(length(miniBlock_id)/compressFactor),1);
skip = 0;
count = 0;
for b = 1 : length(miniBlock_id)
    
    if skip > 0
        skip = skip - 1;
    else
        
        count = count + 1;
        
        for cf = 1 : compressFactor
            if b + cf - 1 <= size(allBlocks,1)
                runBlocks{count} = vertcat( runBlocks{count} , allBlocks{ b + cf - 1 } ); % Fusion
            else
                % Don't need a fusion : already the last one
            end
        end
        
        skip = compressFactor - 1;
        
    end
    
end

%% Adjust onset of the event after fusion of miniblocks

adjustedBlocks = runBlocks;

for mb = 1 : size(runBlocks,1)
    
    onsets = cell2mat(runBlocks{mb}(:,2));
    durations = cell2mat(runBlocks{mb}(:,4));
    
    Zero_idx = find( onsets == 0 );
    
    for z = 2 : length(Zero_idx)
        
        if z + 1 <= length(Zero_idx)
            onsets( Zero_idx(z) : Zero_idx(z+1)-1 ) = onsets( Zero_idx(z) : Zero_idx(z+1)-1 ) + onsets( Zero_idx(z) - 1 ) + durations( Zero_idx(z) - 1 ) ;
        else
            onsets( Zero_idx(z) : end ) = onsets( Zero_idx(z) : end ) + onsets( Zero_idx(z) - 1 ) + durations( Zero_idx(z) - 1 ) ;
        end
        
    end
    
    adjustedBlocks{mb}(:,2) = num2cell(onsets);
    
end


%% Select adjusted block (optseq), or generate it (generation)

if nargout > 0
    
    switch DataStruct.Environement
        
        case 'MRI'
            blockSelected = DataStruct.BlockNumber ;
            
        case 'Training'
            blockSelected = 1;
            adjustedBlocks = cell(1);
            NO = @(adjustedBlocks) adjustedBlocks{blockSelected}{end,2} + adjustedBlocks{blockSelected}{end,4};
            
            switch DataStruct.BlockNumber
                
                case 1
                    adjustedBlocks{blockSelected} = {1 0 0 1.8 'Null' 0 };
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 1 1.8 'Illusion_rotation'   0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 2 1.8 'Illusion_InOut'      1 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 0 0.9 'Null'                0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 3 1.8 'Control_rotation'    0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 4 1.8 'Control_inOut'       0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 5 1.8 'Control_global'      1 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 0 2.7 'Null'                0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 6 1.8 'Control_local_rot'   1 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 7 1.8 'Control_local_inOut' 0 } ];
                    
                    
                case 2
                    adjustedBlocks{blockSelected} = { 1 0 0 1.8 'Null' 0 };
                    for ii = 1:5
                        for i = 1:3
                            adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 1 1.8 'Illusion_rotation' 0 } ];
                        end
                        adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 1 1.8 'Illusion_rotation' 1 } ];
                        for i = 1:3
                            adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 3 1.8 'Control_rotation'  0 } ];
                        end
                        adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 3 1.8 'Control_rotation'  1 } ];
                    end
                    
                case 3
                    rep = 3;
                    
                    adjustedBlocks{blockSelected} = {1 0 0 1.8 'Null' 0 };
                    for i = 1:rep-1
                        adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 1 1.8 'Illusion_rotation'   0 } ];
                    end
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 1 1.8 'Illusion_rotation'   1 } ];
                    
                    for i = 1:rep
                        adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 2 1.8 'Illusion_InOut'      0 } ];
                    end
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 2 1.8 'Illusion_InOut'      1 } ];
                    
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 0 0.9 'Null'                0 } ];
                    
                    for i = 1:rep
                        adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 3 1.8 'Control_rotation'    0 } ];
                    end
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 3 1.8 'Control_rotation'    1 } ];
                    
                    for i = 1:rep
                        adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 4 1.8 'Control_inOut'       0 } ];
                    end
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 4 1.8 'Control_inOut'       1 } ];
                    
                    for i = 1:rep
                        adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 5 1.8 'Control_global'      0 } ];
                    end
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 5 1.8 'Control_global'      1 } ];
                    
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 0 2.7 'Null'                0 } ];
                    
                    for i = 1:rep
                        adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 6 1.8 'Control_local_rot'   0 } ];
                    end
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 6 1.8 'Control_local_rot'   1 } ];
                    
                    for i = 1:rep
                        adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 7 1.8 'Control_local_inOut' 0 } ];
                    end
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 7 1.8 'Control_local_inOut' 1 } ];
                    
                case 4
                    adjustedBlocks{blockSelected} = { 1 0 0 1.8 'Null' 0 };
                    for ii = 1:10
                        adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 1 1.8 'Illusion_InOut' 0 } ];
                        adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 1 1.8 'Illusion_rotation' 0 } ];
                    end
                    
                case 5
                    adjustedBlocks{blockSelected} = { 1 0 0 1.8 'Null' 0 };
                    for ii = 1:10
                        adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 1 1.8 'Control_inOut' 0 } ];
                        adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 1 1.8 'Control_rotation' 0 } ];
                    end
                    
                case 6
                    adjustedBlocks{blockSelected} = {1 0 6 1.8 'Control_local_rot'   0 };
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 6 1.8 'Control_local_rot'   0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 6 1.8 'Control_local_rot'   0 } ];
                case 7
                    adjustedBlocks{blockSelected} = {1 0 7 1.8 'Control_local_inOut' 0 } ;
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 7 1.8 'Control_local_inOut' 0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 7 1.8 'Control_local_inOut' 0 } ];
                    
                otherwise
                    adjustedBlocks{blockSelected} = {1 0 0 1.8 'Null' 0 };
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 1 1.8 'Illusion_rotation'   0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 2 1.8 'Illusion_InOut'      0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 0 0.9 'Null'                0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 3 1.8 'Control_rotation'    0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 4 1.8 'Control_inOut'       0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 5 1.8 'Control_global'      0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 0 2.7 'Null'                0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 6 1.8 'Control_local_rot'   0 } ];
                    adjustedBlocks{blockSelected} = [adjustedBlocks{blockSelected} ; {1 NO(adjustedBlocks) 7 1.8 'Control_local_inOut' 0 } ];
                    
            end % switch Run
            
    end % switch Env
    
else
    
    blockSelected = 1;
    
end


%% Add the adjustedBlocks into the Planning object

% Create and prepare
header = { 'event_name' , 'onset(s)' , 'duration(s)' 'condition_ID' 'catch_trial'};
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};

% --- Start ---------------------------------------------------------------

EP.AddPlanning({ 'StartTime' , 0 , 0 , -1 , 0 });

% --- Stim ----------------------------------------------------------------

displayBlock = adjustedBlocks{ blockSelected };

for trial = 1 : size( displayBlock , 1 )
    
    EP.AddPlanning({ displayBlock{trial,5} displayBlock{trial,2} displayBlock{trial,4} displayBlock{trial,3}  displayBlock{trial,6} });
    
end

% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime' , NextOnset(EP) , 0 , -2 , 0 });


%% Acceleration

if nargout > 0
    
    switch DataStruct.OperationMode
        
        case 'Acquisition'
            
            Speed = 1; %#ok<*NASGU>
            
        case 'FastDebug'
            
            Speed = 5;
            
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
