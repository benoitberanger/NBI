function [ names , onsets , durations ] = SPMnod( DataStruct )
%SPMNOD Build 'names', 'onsets', 'durations' for SPM

try
    %% Preparation
    
    % 'names' for SPM
    switch DataStruct.Task
        
        case 'NBI'
            names = {
                'Fixation'             ;
                'pathS_InOut'          ;
                'pathS_Rot'            ;
                'control2_pathS_InOut' ;
                'control2_pathS_Rot'   ;
                'Response'             ;
                };
            
        case 'EyelinkCalibration'
            names = {'EyeLinkCalibration'};
            
        case 'MTMST_Left'
            names = {
                'leftOUT'      ;
                'leftIN'       ;
                'leftFIXATION' ;
                };
            
        case 'MTMST_Right'
            names = {
                'rightOUT'      ;
                'rightIN'       ;
                'rightFIXATION' ;
                };
            
        case 'Retinotopy'
            names = {
                'cw'  ;
                'ccw' ;
                };
            
        case 'Illusion'
            names = {
                'Illusion_InOut'      ;
                'Illusion_rotation'   ;
                'Control_inOut'       ;
                'Control_rotation'    ;
                'Control_global'      ;
                'Control_local_inOut' ;
                'Control_local_rot'   ;
                'Null'                ;
                };
            
    end
    
    % 'onsets' & 'durations' for SPM
    onsets    = cell(size(names));
    durations = cell(size(names));
    
    % Shortcut
    EventData = DataStruct.TaskData.ER.Data;
    
    
    %% MTMST special : transform into bloc
    
    if regexp(DataStruct.Task,'MTMST') % 'MTMST' task ?
        
        % Fetch tag 'left' / 'right'
        LR = lower(DataStruct.Task(7:end));
        
        % Where is  In or OUT event ?
        inout_idx1 = regexp(EventData(:,1),'IN|OUT');
        inout_idx2 = ~cellfun(@isempty,inout_idx1);
        %         inout_idx3 = find(inout_idx2);
        
        % Prepare a cell that will receive the blocs
        EventData_compressed = cell(size(EventData));
        EventData_compressed(1,:) = EventData(1,:);
        
        blocDuration = 0;
        blocStartTime = 0;
        evt_count = 1;
        for evt = 2 : size(EventData,1)
            
            if inout_idx2(evt) % if 'IN' or 'OUT'
                
                if blocDuration == 0 % new bloc
                    blocStartTime = EventData{evt,2}; % store start time
                    blocDuration = blocDuration + EventData{evt,3}; % add duration
                else
                    blocDuration = blocDuration + EventData{evt,3}; % add duration
                end
                
            else % 'FIXATION' or 'StopTime'
                
                % Store bloc
                evt_count = evt_count + 1;
                EventData_compressed{evt_count,1} = [LR 'INOUT'];
                EventData_compressed{evt_count,2} = blocStartTime;
                EventData_compressed{evt_count,3} = blocDuration;
                blocDuration = 0;
                
                % Store FIXATION
                evt_count = evt_count + 1;
                EventData_compressed(evt_count,:) = EventData(evt,:);
                
            end
            
        end
        
        % Clean empty lines
        empty_idx = cellfun( @isempty , EventData_compressed(:,1) );
        EventData_compressed( empty_idx , : ) = [];
        
        % Upper loop add an incorrect bloc for the last event
        EventData_compressed(end-1,:) = [];
        
        % Store the new cell
        EventData = EventData_compressed;
        
    end
    
    
    %% Onsets building
    
    for event = 1:size(EventData,1)
        
        switch EventData{event,1}
            
            % NBI
            case 'Fixation'
                onsets{1} = [onsets{1} ; EventData{event,2}];
            case 'pathS_InOut'
                onsets{2} = [onsets{2} ; EventData{event,2}];
            case 'pathS_Rot'
                onsets{3} = [onsets{3} ; EventData{event,2}];
            case 'control2_pathS_InOut'
                onsets{4} = [onsets{4} ; EventData{event,2}];
            case 'control2_pathS_Rot'
                onsets{5} = [onsets{5} ; EventData{event,2}];
            case 'Response'
                onsets{6} = [onsets{6} ; EventData{event,2}];
                
                % MTMST_Left
            case 'leftINOUT'
                onsets{1} = [onsets{1} ; EventData{event,2}];
            case 'leftFIXATION'
                onsets{2} = [onsets{2} ; EventData{event,2}];
                
                % MTMST_Right
            case 'rightINOUT'
                onsets{1} = [onsets{1} ; EventData{event,2}];
            case 'rightFIXATION'
                onsets{2} = [onsets{2} ; EventData{event,2}];
                
                % Retinotopy
            case 'cw'
                onsets{1} = [onsets{1} ; EventData{event,2}];
            case 'ccw'
                onsets{2} = [onsets{2} ; EventData{event,2}];
                
                % Illusion
            case 'Illusion_InOut'
                onsets{1} = [onsets{1} ; EventData{event,2}];
            case 'Illusion_rotation'
                onsets{2} = [onsets{2} ; EventData{event,2}];
            case 'Control_inOut'
                onsets{3} = [onsets{3} ; EventData{event,2}];
            case 'Control_rotation'
                onsets{4} = [onsets{4} ; EventData{event,2}];
            case 'Control_global'
                onsets{5} = [onsets{5} ; EventData{event,2}];
            case 'Control_local_inOut'
                onsets{6} = [onsets{6} ; EventData{event,2}];
            case 'Control_local_rot'
                onsets{7} = [onsets{7} ; EventData{event,2}];
            case 'Null'
                onsets{8} = [onsets{8} ; EventData{event,2}];
                
        end
        
    end
    
    
    %% Duratins building
    
    for event = 1:size(EventData,1)
        
        switch EventData{event,1}
            
            % NBI
            case 'Fixation'
                durations{1} = [ durations{1} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'pathS_InOut'
                durations{2} = [ durations{2} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'pathS_Rot'
                durations{3} = [ durations{3} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'control2_pathS_InOut'
                durations{4} = [ durations{4} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'control2_pathS_Rot'
                durations{5} = [ durations{5} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'Response'
                durations{6} = [ durations{6} ; EventData{event+1,2}-EventData{event,2}] ;
                
                % MTMST_Left
            case 'leftINOUT'
                durations{1} = [ durations{1} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'leftFIXATION'
                durations{2} = [ durations{2} ; EventData{event+1,2}-EventData{event,2}] ;
                
                % MTMST_Right
            case 'rightINOUT'
                durations{1} = [ durations{1} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'rightFIXATION'
                durations{2} = [ durations{2} ; EventData{event+1,2}-EventData{event,2}] ;
                
                % Retinotopy
            case 'cw'
                durations{1} = [ durations{1} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'ccw'
                durations{2} = [ durations{2} ; EventData{event+1,2}-EventData{event,2}] ;
                
                % Illusion
            case 'Illusion_InOut'
                durations{1} = [ durations{1} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'Illusion_rotation'
                durations{2} = [ durations{2} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'Control_inOut'
                durations{3} = [ durations{3} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'Control_rotation'
                durations{4} = [ durations{4} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'Control_global'
                durations{5} = [ durations{5} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'Control_local_inOut'
                durations{6} = [ durations{6} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'Control_local_rot'
                durations{7} = [ durations{7} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'Null'
                durations{8} = [ durations{8} ; EventData{event+1,2}-EventData{event,2}] ;
                
        end
        
    end
    
    
catch err
    
    sca
    rethrow(err)
    
end

end