function [ names , onsets , durations ] = SPMnod( DataStruct )
%SPMNOD Build 'names', 'onsets', 'durations' for SPM

try
    
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
    
    % Display 'durations' inside Display_cell for diagnostic
    for k = 2:size(EventData)
        EventData{k-1,3} = EventData{k,2} - sum(cell2mat(EventData(k-1,2)));
    end
    
    % Onsets building
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
            case 'leftOUT'
                onsets{1} = [onsets{1} ; EventData{event,2}];
            case 'leftIN'
                onsets{2} = [onsets{2} ; EventData{event,2}];
            case 'leftFIXATION'
                onsets{3} = [onsets{3} ; EventData{event,2}];
                
                % MTMST_Right
            case 'rightOUT'
                onsets{1} = [onsets{1} ; EventData{event,2}];
            case 'rightIN'
                onsets{2} = [onsets{2} ; EventData{event,2}];
            case 'rightFIXATION'
                onsets{3} = [onsets{3} ; EventData{event,2}];
                
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
    
    
    % Duratins building
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
            case 'leftOUT'
                durations{1} = [ durations{1} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'leftIN'
                durations{2} = [ durations{2} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'leftFIXATION'
                durations{3} = [ durations{3} ; EventData{event+1,2}-EventData{event,2}] ;
                
                % MTMST_Right
            case 'rightOUT'
                durations{1} = [ durations{1} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'rightIN'
                durations{2} = [ durations{2} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'rightFIXATION'
                durations{3} = [ durations{3} ; EventData{event+1,2}-EventData{event,2}] ;
                
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