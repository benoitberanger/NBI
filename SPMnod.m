function [ names , onsets , durations ] = SPMnod( DataStruct )
%NAMESONSETSDURATIONSDPM Build 'names', 'onsets', 'durations' for SPM

try
    
    % 'names' for SPM
    switch DataStruct.Task
        
        case 'Localizer'
            names = {
                'rest'          ;
                'sentence'      ;
                'psedo_sentence'
                };
            
        case 'MSIT'
            names = {
                'rest'    ;
                'C0'      ;
                'C1'      ;
                'response'
                };
            
        case 'Morphology_nonce'
            names = {
                'condition_0_cross'     ; 'condition_0_playback'    ; 'condition_0_record'    ;
                'condition_1_cross'     ; 'condition_1_playback'    ; 'condition_1_record'    ;
                'condition_NULL_cross'  ; 'condition_NULL_playback' ; 'condition_NULL_record' ;
                'good_response_playback';
                };
            
        case 'Morphology_words'
            names = {
                'condition_0_cross'     ; 'condition_0_playback'    ; 'condition_0_record'    ;
                'condition_1_cross'     ; 'condition_1_playback'    ; 'condition_1_record'    ;
                'condition_NULL_cross'  ; 'condition_NULL_playback' ; 'condition_NULL_record' ;
                'good_response_playback';
                };
            
        case 'LexicalCategorization'
            names = {
                'condition_LE_pics'   ; 'condition_LE_record'   ;
                'condition_HE_pics'   ; 'condition_HE_record'   ;
                'condition_NULL_pics' ; 'condition_NULL_record' ;
                };
            
        case 'STROOP'
            names = {
                'cross'    ;
                'condition';
                'mini_rest';
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
            
            case 'cross'
                onsets{1} = [onsets{1} ; Display_cell{event,2}];
            case 'rest'
                onsets{1} = [onsets{1} ; Display_cell{event,2}];
                
            case 'sentence'
                onsets{2} = [onsets{2} ; Display_cell{event,2}];
            case 'psedo_sentence'
                onsets{3} = [onsets{3} ; Display_cell{event,2}];
                
            case 'condition_0'
                onsets{1} = [onsets{1} ; Display_cell{event,2}];
            case 'condition_1'
                onsets{2} = [onsets{2} ; Display_cell{event,2}];
                
            case 'condition'
                onsets{2} = [onsets{2} ; Display_cell{event,2}];
            case 'mini_rest'
                onsets{3} = [onsets{3} ; Display_cell{event,2}];
                
            case 'C0'
                onsets{2} = [onsets{2} ; Display_cell{event,2}];
            case 'C1'
                onsets{3} = [onsets{3} ; Display_cell{event,2}];
            case 'micro_rest'
                onsets{4} = [onsets{4} ; Display_cell{event,2}];
                
            case 'condition_0_cross'
                onsets{1} = [onsets{1} ; Display_cell{event,2}];                      % condition_0_cross
                onsets{2} = [onsets{2} ; DataStruct.TaskData.Playback_cell{event,2}]; % condition_0_playback
                onsets{3} = [onsets{3} ; DataStruct.TaskData.Record_cell{event,2}];   % condition_0_record
                
            case 'condition_1_cross'
                onsets{4} = [onsets{4} ; Display_cell{event,2}];                      % condition_1_cross
                onsets{5} = [onsets{5} ; DataStruct.TaskData.Playback_cell{event,2}]; % condition_1_playback
                onsets{6} = [onsets{6} ; DataStruct.TaskData.Record_cell{event,2}];   % condition_1_record
                
            case 'condition_NULL_cross'
                onsets{7} = [onsets{7} ; Display_cell{event,2}];                      % condition_1_cross
                onsets{8} = [onsets{8} ; DataStruct.TaskData.Playback_cell{event,2}]; % condition_1_playback
                onsets{9} = [onsets{9} ; DataStruct.TaskData.Record_cell{event,2}];   % condition_1_record
                
            case 'condition_LE_pictures'
                onsets{1} = [onsets{1} ; Display_cell{event,2}];                    % condition_LE_pic
                onsets{2} = [onsets{2} ; DataStruct.TaskData.Record_cell{event,2}]; % condition_LE_record
                
            case 'condition_HE_pictures'
                onsets{3} = [onsets{3} ; Display_cell{event,2}];                    % condition_HE_pic
                onsets{4} = [onsets{4} ; DataStruct.TaskData.Record_cell{event,2}]; % condition_HE_record
                
            case 'condition_NULL_pictures'
                onsets{5} = [onsets{5} ; Display_cell{event,2}];                    % condition_HE_pic
                onsets{6} = [onsets{6} ; DataStruct.TaskData.Record_cell{event,2}]; % condition_HE_record
        end
        
    end
    
    
    % Duratins building
    for event = 1:size(Display_cell,1)
        
        switch Display_cell{event,1}
            
            case 'cross'
                durations{1} = [ durations{1} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
            case 'rest'
                durations{1} = [ durations{1} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
                
            case 'sentence'
                durations{2} = [ durations{2} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
            case 'psedo_sentence'
                durations{3} = [ durations{3} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
                
            case 'condition_0'
                durations{1} = [ durations{1} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
            case 'condition_1'
                durations{2} = [ durations{2} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
                
            case 'condition'
                durations{2} = [ durations{2} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
            case 'mini_rest'
                durations{3} = [ durations{3} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
                
            case 'C0'
                durations{2} = [ durations{2} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
            case 'C1'
                durations{3} = [ durations{3} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
            case 'micro_rest'
                durations{4} = [ durations{4} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
                
            case 'condition_0_cross'
                durations{1} = [ durations{1} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
                durations{2} = [ durations{2} ; DataStruct.TaskData.Playback_cell{event+1,2}-DataStruct.TaskData.Playback_cell{event,2}] ;
                durations{3} = [ durations{3} ; DataStruct.TaskData.Record_cell{event+1,2}-DataStruct.TaskData.Record_cell{event,2}] ;
            case 'condition_1_cross'
                durations{4} = [ durations{4} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
                durations{5} = [ durations{5} ; DataStruct.TaskData.Playback_cell{event+1,2}-DataStruct.TaskData.Playback_cell{event,2}] ;
                durations{6} = [ durations{6} ; DataStruct.TaskData.Record_cell{event+1,2}-DataStruct.TaskData.Record_cell{event,2}] ;
            case 'condition_NULL_cross'
                durations{7} = [ durations{7} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
                durations{8} = [ durations{8} ; DataStruct.TaskData.Playback_cell{event+1,2}-DataStruct.TaskData.Playback_cell{event,2}] ;
                durations{9} = [ durations{9} ; DataStruct.TaskData.Record_cell{event+1,2}-DataStruct.TaskData.Record_cell{event,2}] ;
                
            case 'condition_LE_pictures'
                durations{1} = [ durations{1} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
                durations{2} = [ durations{2} ; DataStruct.TaskData.Record_cell{event+1,2}-DataStruct.TaskData.Record_cell{event,2}] ;
            case 'condition_HE_pictures'
                durations{3} = [ durations{3} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
                durations{4} = [ durations{4} ; DataStruct.TaskData.Record_cell{event+1,2}-DataStruct.TaskData.Record_cell{event,2}] ;
            case 'condition_NULL_pictures'
                durations{5} = [ durations{5} ; Display_cell{event+1,2}-Display_cell{event,2}] ;
                durations{6} = [ durations{6} ; DataStruct.TaskData.Record_cell{event+1,2}-DataStruct.TaskData.Record_cell{event,2}] ;
                
        end
        
    end
    
    
catch err
    
    sca
    rethrow(err)
    
end

end