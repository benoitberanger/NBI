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
    try
        Display_cell = DataStruct.TaskData.Display_cell.Data;
    catch
        Display_cell = DataStruct.TaskData.Display_cell;
    end
    
    % Display 'durations' inside Display_cell for diagnostic
    for k = 2:size(Display_cell)
        Display_cell{k-1,3} = Display_cell{k,2} - sum(cell2mat(Display_cell(k-1,2)));
    end
    
    % Onsets building
    for event = 1:size(Display_cell,1)
        
        switch Display_cell{event,1}
            
            case 'Cross'
                onsets{1} = [onsets{1} ; Display_cell{event,2}];
            case 'InOut'
                onsets{1} = [onsets{1} ; Display_cell{event,2}];
            case 'Rotation'
                onsets{1} = [onsets{1} ; Display_cell{event,2}];
            case 'Response'
                onsets{1} = [onsets{1} ; Display_cell{event,2}];
                
        end
        
    end
    
    
    % Duratins building
    for event = 1:size(Display_cell,1)
        
        switch Display_cell{event,1}
            
            case 'Cross'
                durations{1} = [ durations{1} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
            case 'InOut'
                durations{1} = [ durations{1} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
            case 'Rotation'
                durations{1} = [ durations{1} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
            case 'Response'
                durations{1} = [ durations{1} ; Display_cell{event+1,2}-Display_cell{event,2}] ;

                
        end
        
    end
    
    
catch err
    
    sca
    rethrow(err)
    
end

end