function [ names , onsets , durations ] = SPMnod( DataStruct )
%SPMNOD Build 'names', 'onsets', 'durations' for SPM

try
    
    % 'names' for SPM
    switch DataStruct.Task
        
        case 'Task1'
            names = {
                'Cross'    ;
                'InOut'      ;
                'Rotation'      ;
                'Response'
                };

        case 'EyelinkCalibrationNPI'
            names = {'EyeLinkCalibration'};
            
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
            
            case 'Point'
                onsets{1} = [onsets{1} ; EventData{event,2}];
            case 'InOut'
                onsets{2} = [onsets{2} ; EventData{event,2}];
            case 'Rotation'
                onsets{3} = [onsets{3} ; EventData{event,2}];
            case 'Response'
                onsets{4} = [onsets{4} ; EventData{event,2}];
                
        end
        
    end
    
    
    % Duratins building
    for event = 1:size(EventData,1)
        
        switch EventData{event,1}
            
            case 'Point'
                durations{1} = [ durations{1} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'InOut'
                durations{2} = [ durations{2} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'Rotation'
                durations{3} = [ durations{3} ; EventData{event+1,2}-EventData{event,2}] ;
            case 'Response'
                durations{4} = [ durations{4} ; EventData{event+1,2}-EventData{event,2}] ;

                
        end
        
    end
    
    
catch err
    
    sca
    rethrow(err)
    
end

end