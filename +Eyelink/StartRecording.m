function [ EyelinkFile ] = StartRecording( DataStruct )
%STARTRECORDINGEYELINK Check if Eyelink is available, then start recording.

try
    
    % Default value
    EyelinkFile = 'EyelinkNotAvailable';
    
    % Eyelink mode 'On' ?
    switch DataStruct.EyelinkMode
        
        case 'On'
            
            % Eyelink toolbox avalable ?
            if DataStruct.EyelinkToolboxAvailable
                
                % Acquisition ?
                switch DataStruct.OperationMode
                    
                    case 'Acquisition'
                        
                        % Check if connected (assume the Eyelink is calibrated)
                        status = Eyelink('IsConnected');
                        switch status
                            case 1
                                disp('Eyelink connected')
                            case -1
                                disp('Eyelink dummy-connected')
                            case 2
                                disp('Eyelink broadcast-connected')
                            case 0
                                error('Eyelink is not connected')
                        end
                        
                        
                        % Code for Task
                        switch DataStruct.Task
                            case 'NBI'
                                aliasTask = 'A';
                        end
                        
                        % Code for Environement
                        switch DataStruct.Environement
                            case 'MRI'
                                aliasEnvironement = 'X';
                            case 'Training'
                                aliasEnvironement = 'Y';
                        end
                        
                        % Name of Eyelinik file
                        EyelinkFile = sprintf('%s_%s%s%s', DataStruct.SubjectID, aliasTask, aliasEnvironement, DataStruct.RunNumber);
                        
                        % Open file
                        status = Eyelink('OpenFile',EyelinkFile);
                        if status ~= 0
                            error('OpenFile error, status : %d ',status)
                        end
                        
                        % Start recording
                        startrecording_error = Eyelink('StartRecording');
                        if startrecording_error ~= 0
                            error('StartRecording error, startrecording_error : %d ',startrecording_error)
                        end
                        
                    otherwise
                        
                        error('StartRecordingEyelink:EyelinkModeOnWithoutAcquisition','\n Eyelink mode should be ''Off'' if not in Acquisition mode \n')
                        
                end
                
            end
            
        case 'Off'
            
    end
    
    
catch err
    
    sca
    rethrow(err)
    
    
end

end