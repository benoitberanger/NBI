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

        case 'EyelinkCalibrationNPI'
            names = {'EyeLinkCalibration'};
            
        case 'MTMST'
            names = {
                '1' ;
                '2' ;
                '3' ;
                '4' ;
                '5' ;
                '6' ;
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
                
        end
        
    end
    
    
    % Duratins building
    for event = 1:size(EventData,1)
        
        switch EventData{event,1}
            
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

                
        end
        
    end
    
    
catch err
    
    sca
    rethrow(err)
    
end

end